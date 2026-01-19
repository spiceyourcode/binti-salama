import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class AfricasTalkingService {
  static const String _sandboxUrl = 'https://api.sandbox.africastalking.com/version1/messaging';
  static const String _prodUrl = 'https://api.africastalking.com/version1/messaging';

  final bool isSandbox;
  final String username;
  final String apiKey;

  AfricasTalkingService._({
    required this.username,
    required this.apiKey,
    required this.isSandbox,
  });

  /// Factory constructor to initialize from environment variables
  factory AfricasTalkingService.fromEnv() {
    final rawUsername = dotenv.env['AT_USERNAME']?.trim() ?? '';
    final apiKey = dotenv.env['AT_API_KEY']?.trim() ?? '';
    final env = dotenv.env['AT_ENV']?.trim() ?? 'sandbox';
    final bool isSandboxMode = env.toLowerCase() == 'sandbox';

    // In sandbox mode, the username MUST be 'sandbox'
    final username = isSandboxMode ? 'sandbox' : rawUsername;

    if (username.isEmpty || apiKey.isEmpty) {
      AppLogger.warning('Africa\'s Talking credentials missing in .env');
    }

    if (isSandboxMode && rawUsername.isNotEmpty && rawUsername.toLowerCase() != 'sandbox') {
      AppLogger.warning('Africa\'s Talking: AT_ENV is sandbox, but AT_USERNAME is "$rawUsername". Using "sandbox" instead.');
    }

    return AfricasTalkingService._(
      username: username,
      apiKey: apiKey,
      isSandbox: isSandboxMode,
    );
  }

  /// Send SMS using the Standard Africa's Talking API
  /// (Form-encoded is more compatible with Sandbox)
  Future<bool> sendSMS({
    required List<String> recipients,
    required String message,
  }) async {
    if (username.isEmpty || apiKey.isEmpty) {
      AppLogger.error('Cannot send SMS: Missing Africa\'s Talking credentials (username: "$username", hasApiKey: ${apiKey.isNotEmpty})');
      return false;
    }

    if (recipients.isEmpty) {
      AppLogger.warning('Cannot send SMS: No recipients provided');
      return false;
    }

    // Ensure all recipients have the '+' prefix for international format
    final formattedRecipients = recipients.map((r) {
      final trimmed = r.trim();
      return trimmed.startsWith('+') ? trimmed : '+$trimmed';
    }).toList();

    final url = Uri.parse(isSandbox ? _sandboxUrl : _prodUrl);
    
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'apiKey': apiKey,
    };

    // Standard API uses comma-separated 'to' and form-encoded body
    final body = {
      'username': username,
      'to': formattedRecipients.join(','),
      'message': message,
    };

    try {
      AppLogger.info('Sending SMS via Africa\'s Talking (Standard API)...');
      AppLogger.info('Mode: ${isSandbox ? "SANDBOX" : "PRODUCTION"}');
      AppLogger.info('Username: $username');
      AppLogger.info('Recipients: ${formattedRecipients.length} (${formattedRecipients.join(", ")})');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      AppLogger.info('Africa\'s Talking Response State: ${response.statusCode}');
      AppLogger.info('Africa\'s Talking Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final smsMessageData = data['SMSMessageData'];
        
        if (smsMessageData != null) {
          final recipientsList = smsMessageData['Recipients'] as List?;
          final summary = smsMessageData['Message'] ?? 'No summary';
          
          AppLogger.info('Africa\'s Talking Summary: $summary');
          
          if (recipientsList != null && recipientsList.isNotEmpty) {
            bool atLeastOneSent = false;
            for (var recipient in recipientsList) {
              final number = recipient['number'];
              final status = recipient['status']; // e.g., "Success", "InsufficientBalance", "InvalidPhoneNumber"
              final cost = recipient['cost'];
              
              if (status == 'Success' || status == 'Sent') {
                atLeastOneSent = true;
                AppLogger.info('✅ SMS Sent to $number (Cost: $cost)');
              } else {
                AppLogger.error('❌ SMS Failed for $number: $status - Body: ${recipient.toString()}');
              }
            }
            return atLeastOneSent;
          }
          
          if (summary.contains('Sent to 0/')) {
            AppLogger.error('Africa\'s Talking reported 0 messages sent. Check balance or Sender ID.');
            return false;
          }
          return true; 
        }
        return true; 
      } else {
        AppLogger.error(
          'Africa\'s Talking Error: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Africa\'s Talking Exception', error: e);
      return false;
    }
  }
}
