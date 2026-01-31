import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GmailService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [GmailApi.gmailReadonlyScope],
  );

  final ApiService _apiService = ApiService();

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> syncExpenses(String userId) async {
    final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    if (account == null) return;

    final authHeaders = await account.authHeaders;
    final authenticateClient = auth.authenticatedClient(
      http.Client(),
      auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          authHeaders['Authorization']!.replaceAll('Bearer ', ''),
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        ),
        null,
        [GmailApi.gmailReadonlyScope],
      ),
    );

    final gmailApi = GmailApi(authenticateClient);
    
    // Calculate timestamp for 24 hours ago (in seconds)
    final int oneDayAgo = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (24 * 60 * 60);

    // Updated query: Filter by subject keywords only, strictly after 24 hours ago
    final results = await gmailApi.users.messages.list(
      'me',
      q: 'subject:(debited OR credited OR spent) after:$oneDayAgo',
    );

    if (results.messages == null || results.messages!.isEmpty) return;

    for (var messageSummary in results.messages!) {
      final message = await gmailApi.users.messages.get('me', messageSummary.id!, format: 'full');
      await _processMessage(message, userId);
    }
  }

  Future<void> _processMessage(Message message, String userId) async {
    String? body;
    String subject = "";
    String sender = "";
    
    // Extract headers
    message.payload?.headers?.forEach((header) {
      if (header.name == 'Subject') subject = header.value ?? "";
      if (header.name == 'From') sender = header.value ?? "";
    });

    // Extract body
    // Extract body using recursive helper
    body = _extractBody(message.payload);
    
    // Fallback to snippet if body is empty
    if (body == null || body.isEmpty) {
      print("Body missing for ${message.id}, using snippet.");
      body = message.snippet;
    }

    // Combine subject and body to check for patterns
    final combinedText = "$subject $body";
    
    // Strict Regex to match your specific examples:
    // 1. INR 100.00 was debited...
    // 2. INR 100.00 was credited...
    // 3. INR 101722.5 spent on...
    final strictFilter = RegExp(
      r"(?:[A-Z]{3}|Rs\.?|₹)\s*[\d,.]+\s+(?:was\s+(?:debited|credited)|spent\s+on)", 
      caseSensitive: false
    );

    if (!strictFilter.hasMatch(combinedText)) {
      print("Skipping email (Pattern mismatch): $subject");
      return;
    }

    final emailData = {
      "user": {"id": userId},
      "messageId": message.id,
      "subject": subject,
      "body": body ?? "",
      "sender": sender,
      "receivedAt": DateTime.fromMillisecondsSinceEpoch(
        int.parse(message.internalDate ?? DateTime.now().millisecondsSinceEpoch.toString())
      ).toIso8601String()
    };
      
    try {
      await _apiService.saveEmailLog(emailData);
      print("Successfully synced email: $subject");
    } catch (e) {
      print("Error syncing email log: $e");
    }
  }

  String? _extractBody(MessagePart? part) {
    if (part == null) return null;

    if (part.body?.data != null) {
      if (part.mimeType == 'text/plain' || part.mimeType == 'text/html') {
        return utf8.decode(base64Url.decode(part.body!.data!));
      }
    }

    if (part.parts != null) {
      for (final subPart in part.parts!) {
        final body = _extractBody(subPart);
        if (body != null) return body;
      }
    }
    
    return null;
  }
}
