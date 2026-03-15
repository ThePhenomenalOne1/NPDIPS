# Twilio OTP Setup Guide

## Current Status

The app is currently using **mock OTP** for testing purposes. Real SMS will be sent through Twilio once deployed to production with Firebase Blaze plan enabled.

## Development Testing

### How to Test OTP Flow

1. **Navigate to Phone Auth Screen** → Click "Sign Up with Phone"
2. **Enter any valid phone number** (e.g., +964 750 123 4567)
3. **Check the debug console** → Look for the message:
   ```
   📱 OTP for testing: XXXXXX
   ⏰ OTP expires in 10 minutes
   💡 In production, SMS will be sent to +964 750 123 4567
   ```
4. **Use the OTP code** from the debug console to verify

### What's Stored

- OTP codes are stored in Firestore collection: `otp_sessions`
- Format: `temp_<phone_number_digits_only>`
- Fields: `phoneNumber`, `otpCode`, `expiresAt`, `verified`, `createdAt`

## Production Deployment

### Prerequisites

1. **Firebase Blaze Plan** (required for Cloud Functions)
   - Upgrade your Firebase project: https://console.firebase.google.com/billing
   - Enable Cloud Functions API

2. **Twilio Account**
  - Account SID: `ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
  - Auth Token: `your_twilio_auth_token`
  - Phone Number: `+10000000000`

### Step 1: Enable Secret Manager

Store Twilio credentials securely in Firebase Secrets:

```bash
firebase functions:secrets:set TWILIO_ACCOUNT_SID --project little-wing-v2
firebase functions:secrets:set TWILIO_AUTH_TOKEN --project little-wing-v2
firebase functions:secrets:set TWILIO_PHONE_NUMBER --project little-wing-v2
```

When prompted, enter the respective values.

### Step 2: Update Cloud Function

Update `functions/otp.js` to use secrets:

```javascript
const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const TWILIO_PHONE_NUMBER = process.env.TWILIO_PHONE_NUMBER;
```

### Step 3: Deploy Cloud Functions

```bash
cd dipstore_ui
firebase deploy --project little-wing-v2 --only functions
```

### Step 4: Update Auth Service

Replace the mock implementation in `lib/core/services/auth_service.dart`:

```dart
Future<void> sendOtp(String phoneNumber, {
  required Function(String) onCodeSent,
  required Function(String) onError,
}) async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('sendOtp');
    final result = await callable.call({'phoneNumber': phoneNumber});
    
    if (result.data['success']) {
      onCodeSent(phoneNumber);
    } else {
      onError(result.data['error'] ?? 'Failed to send OTP');
    }
  } catch (e) {
    onError(e.toString());
  }
}
```

### Step 5: Deploy Flutter App

```bash
flutter build web --release
firebase deploy --project little-wing-v2 --only hosting
```

## Files Reference

- **Cloud Function**: `functions/otp.js`
- **Cloud Function Config**: `functions/package.json`
- **Auth Service**: `lib/core/services/auth_service.dart`
- **Phone Auth Screen**: `lib/features/auth/phone_auth_screen.dart`
- **OTP Verification Screen**: `lib/features/auth/otp_verification_screen.dart`
- **Firestore Collection**: `otp_sessions`

## Troubleshooting

### OTP Not Sending

1. Check Firebase Console → Cloud Functions logs
2. Verify Twilio credentials are correct
3. Ensure phone number format is valid (e.g., +1234567890)

### OTP Always Expires

- Default expiry: 10 minutes
- Edit in `functions/otp.js` or `auth_service.dart`

### Build/Deploy Errors

- Ensure Node.js 18+ is installed: `node --version`
- Clear build cache: `flutter clean`
- Reinstall dependencies: `flutter pub get`

## Security Notes

⚠️ **Never commit credentials** to source code!
- Use Firebase Secrets Manager
- Never hardcode API keys
- Store tokens server-side only

✅ **Best Practices**
- Tokens expire after 10 minutes
- One-time use verification
- Rate limiting recommended (implement in Cloud Function)
- Monitor Twilio billing to prevent abuse

## Testing Real SMS (Optional)

To test Twilio integration without Firebase deployment:

1. Create a simple Node.js server with Twilio SDK
2. Call from Flutter app via HTTP
3. Or use Twilio Console to send test SMS directly

## Support

For Twilio issues: https://www.twilio.com/docs
For Firebase issues: https://firebase.google.com/docs
