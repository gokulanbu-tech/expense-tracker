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
    
    // Expanded search query to look in content, not just subject
    final results = await gmailApi.users.messages.list(
      'me',
      q: '(transaction OR debit OR spent OR "alert for" OR "vpa debited") after:1d',
    );

    if (results.messages == null || results.messages!.isEmpty) return;

    for (var messageSummary in results.messages!) {
      final message = await gmailApi.users.messages.get('me', messageSummary.id!);
      await _processMessage(message, userId);
    }
  }

  Future<void> _processMessage(Message message, String userId) async {
    String? body;
    String subject = "";
    
    // Extract Subject
    message.payload?.headers?.forEach((header) {
      if (header.name == 'Subject') subject = header.value ?? "";
    });

    // Attempt to extract body
    if (message.payload?.parts != null) {
      for (var part in message.payload!.parts!) {
        if ((part.mimeType == 'text/plain' || part.mimeType == 'text/html') && part.body?.data != null) {
          body = utf8.decode(base64Url.decode(part.body!.data!));
          break;
        }
      }
    } else if (message.payload?.body?.data != null) {
      body = utf8.decode(base64Url.decode(message.payload!.body!.data!));
    }

    final combinedText = "$subject ${body ?? ""}";

    final expense = _parseEmail(combinedText);
    if (expense != null) {
      expense['user'] = {'id': userId};
      expense['source'] = 'Mail';
      expense['date'] = DateTime.fromMillisecondsSinceEpoch(
        int.parse(message.internalDate ?? DateTime.now().millisecondsSinceEpoch.toString())
      ).toIso8601String();
      
      try {
        await _apiService.createExpense(expense);
        print("Successfully synced expense: ${expense['merchant']} - ${expense['amount']}");
      } catch (e) {
        print("Sync error or duplicate: $e");
      }
    } else {
      print("Could not parse transaction from email. Subject: $subject");
    }
  }

  Map<String, dynamic>? _parseEmail(String text) {
    // Normalize: replace newlines with spaces and condense whitespace
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ');

    // Pattern 1: Amount ... at/to/at ... Merchant
    final reg1 = RegExp(r"(?:Debited|Spent|Paid|Alert|vpa debited).*?(?:₹|INR|Rs\.?)\s*([\d,.]+).*?(?:at|to|info:)\s*(.*?)(?:\s+on|\s+using|\s+at|\.|$)", caseSensitive: false);
    
    // Pattern 2: Account debited for Amount ... Merchant
    final reg2 = RegExp(r"debited.*?Rs\.?\s*([\d,.]+).*?info[:\s]+(.*?)(?:\s+on|\s+at|$)", caseSensitive: false);

    // Pattern 3: Transaction of Amount at Merchant
    final reg3 = RegExp(r"transaction.*?(?:₹|INR|Rs\.?)\s*([\d,.]+).*?at\s+(.*?)(?:\s+on|$)", caseSensitive: false);

    // Pattern 4: [Amount] was debited ... towards [Merchant] (Your specific case)
    final reg4 = RegExp(r"(?:₹|INR|Rs\.?)\s*([\d,.]+)\s+(?:was\s+)?debited.*?(?:towards|to|at)\s*(.*?)(?:\s+from|\s+on|\s+at|\.|$)", caseSensitive: false);

    final match = reg1.firstMatch(normalized) ?? 
                  reg2.firstMatch(normalized) ?? 
                  reg3.firstMatch(normalized) ?? 
                  reg4.firstMatch(normalized);
    
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '') ?? '0';
      final merchantRaw = match.group(2)?.trim() ?? 'Unknown';
      
      // Cleanup merchant (remove "your A/c", dates, etc)
      String merchant = merchantRaw.split(RegExp(r"your A/c|from account", caseSensitive: false))[0].trim();
      merchant = merchant.replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');

      return {
        "amount": double.tryParse(amountStr) ?? 0.0,
        "currency": "INR",
        "merchant": merchant.isEmpty ? "Bank Transaction" : merchant,
        "category": _categorize(merchant),
        "type": "Purchase",
        "notes": "Auto-synced from Email"
      };
    }
    return null;
  }

  String _categorize(String merchant) {
    final m = merchant.toLowerCase();
    if (m.contains('swiggy') || m.contains('zomato') || m.contains('food') || m.contains('restaurant') || m.contains('starbucks')) return 'Food';
    if (m.contains('uber') || m.contains('ola') || m.contains('petrol') || m.contains('fuel') || m.contains('transport')) return 'Transport';
    if (m.contains('amazon') || m.contains('flipkart') || m.contains('myntra') || m.contains('shopping')) return 'Shopping';
    if (m.contains('netflix') || m.contains('spotify') || m.contains('theatre') || m.contains('hotstar')) return 'Entertainment';
    if (m.contains('bill') || m.contains('recharge') || m.contains('airtel') || m.contains('jio') || m.contains('utility')) return 'Utilities';
    if (m.contains('hospital') || m.contains('pharmacy') || m.contains('medical')) return 'Health';
    return 'Travel';
  }
}
