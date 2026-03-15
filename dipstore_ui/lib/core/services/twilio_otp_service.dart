/// DEPRECATED — OTP sending is handled server-side via the Vercel backend.
/// This file is kept as a reference only. Credentials have been removed.
/// Do NOT add real credentials here; use environment variables on the server.
library;

import 'dart:convert';

class TwilioOtpService {
  // Credentials intentionally empty — configure on the Vercel backend via
  // environment variables (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER)
  static const String twilioAccountSid = '';
  static const String twilioAuthToken = '';
  static const String twilioPhoneNumber = '';

  static String generateOtp() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }

  static Map<String, String> buildSmsPayload(String toPhoneNumber, String otpCode) {
    return {
      'From': twilioPhoneNumber,
      'To': toPhoneNumber,
      'Body': 'Your DipStore verification code is: $otpCode. Do not share this code.',
    };
  }

  static String buildAuthHeader() {
    final credentials = '$twilioAccountSid:$twilioAuthToken';
    final bytes = utf8.encode(credentials);
    final base64 = base64Encode(bytes);
    return 'Basic $base64';
  }
}

  /// Generate a 6-digit OTP code
  static String generateOtp() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }

  /// Build Twilio API request body
  static Map<String, String> buildSmsPayload(String toPhoneNumber, String otpCode) {
    return {
      'From': twilioPhoneNumber,
      'To': toPhoneNumber,
      'Body': 'Your DipStore verification code is: $otpCode. Do not share this code.',
    };
  }

  /// Build Twilio API auth header (Basic Auth)
  static String buildAuthHeader() {
    final credentials = '$twilioAccountSid:$twilioAuthToken';
    final bytes = utf8.encode(credentials);
    final base64 = base64Encode(bytes);
    return 'Basic $base64';
  }
}
