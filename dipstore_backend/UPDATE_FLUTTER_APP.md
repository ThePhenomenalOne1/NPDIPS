# Update Flutter App for Backend OTP

After deploying your Vercel backend, update the Flutter app to call it.

## Step 1: Update auth_service.dart

Replace the OTP methods to call your backend API:

```dart
// Replace the sendOtp and verifyOtp methods with this:

Future<void> sendOtp(
  String phoneNumber, {
  required Function(String) onCodeSent,
  required Function(String) onError,
}) async {
  try {
    // Call your backend API
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_URL/api/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        _currentPhoneNumber = phoneNumber;
        // For development, backend returns the OTP
        if (data['otp'] != null) {
          _currentOtpCode = data['otp'];
        }
        debugPrint("✅ OTP sent to $phoneNumber");
        onCodeSent(data['otp'] ?? phoneNumber);
        return;
      }
    }
    onError("Failed to send OTP");
  } catch (e) {
    debugPrint("Send OTP Error: $e");
    onError(e.toString());
  }
}

Future<bool> verifyOtp(String otp) async {
  try {
    if (_currentPhoneNumber == null) {
      return false;
    }

    // Call your backend API
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_URL/api/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': _currentPhoneNumber,
        'otp': otp.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        _isAuthenticated = true;
        notifyListeners();
        debugPrint("✅ OTP verified successfully");
        return true;
      }
    }
    return false;
  } catch (e) {
    debugPrint("Verify OTP Error: $e");
    return false;
  }
}
```

## Step 2: Add http package to pubspec.yaml

```yaml
dependencies:
  http: ^1.1.0
```

Then run:
```bash
flutter pub get
```

## Step 3: Replace YOUR_BACKEND_URL

Use your Vercel URL from deployment:
```
https://your-project-name.vercel.app
```

Example:
```dart
Uri.parse('https://dipstore-otp.vercel.app/api/send-otp')
```

## Step 4: Add import to auth_service.dart

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
```

## Testing

1. Sign up with a phone number
2. OTP will be sent via Twilio to that number OR shown in development
3. Enter the OTP to verify
4. Account created! ✅

## Troubleshooting

**"Connection refused"**
- Make sure your Vercel URL is correct
- Check if backend is deployed at vercel.com

**"CORS error"**
- Backend has CORS enabled, should work with any origin
- Check browser console for actual error

**"Invalid OTP"**
- Make sure you're entering the exact code
- OTP expires in 10 minutes

**"OTP not received"**
- Check Twilio credentials in Vercel environment variables
- Check phone number format: must start with +

## Production Notes

For production use:
1. Use a real database instead of in-memory OTP storage
2. Add rate limiting per IP
3. Add phone number validation
4. Use Firebase Auth with custom tokens
5. Implement refresh tokens
