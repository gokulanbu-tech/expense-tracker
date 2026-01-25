import 'dart:io' show Platform;
import 'package:telephony/telephony.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for background handling (Android only)
backgoundMessageHandler(SmsMessage message) async {
  if (!Platform.isAndroid) return;
  final apiService = ApiService();
  final prefs = await SharedPreferences.getInstance();
  final senderNumber = prefs.getString('user_mobile');

  if (senderNumber != null && message.address != null) {
      final smsData = {
        "messageId": message.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        "content": message.body ?? "",
        "senderNumber": senderNumber,
        "recipientNumber": message.address ?? "",
        "timestamp": DateTime.now().toIso8601String(),
        "encryptionStatus": "NONE"
      };

      try {
        await apiService.sendSmsToBackend(smsData);
      } catch (e) {
        print("Error sending background SMS: $e");
      }
  }
}

class SmsService {
  final _apiService = ApiService();

  Future<void> initialize() async {
    // SMS Reading is only supported on Android
    if (!Platform.isAndroid) {
      print("SMS Sync is not supported on this platform (iOS). Manual entry required.");
      return;
    }

    final Telephony telephony = Telephony.instance;
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted != null && permissionsGranted) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          print("New SMS received: ${message.body}");
          await _processSms(message);
        },
        onBackgroundMessage: backgoundMessageHandler,
      );
    }
  }

  Future<void> _processSms(SmsMessage message) async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    final userMobile = prefs.getString('user_mobile');

    if (userMobile == null || message.address == null) return;

    final smsData = {
      "messageId": message.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "content": message.body ?? "",
      "senderNumber": userMobile,
      "recipientNumber": message.address ?? "",
      "timestamp": DateTime.now().toIso8601String(),
      "encryptionStatus": "NONE"
    };

    try {
      await _apiService.sendSmsToBackend(smsData);
    } catch (e) {
      print("Error sending SMS to backend: $e");
    }
  }
}
