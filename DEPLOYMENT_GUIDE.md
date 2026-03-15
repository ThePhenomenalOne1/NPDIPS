# DipStore Complete Setup Guide

## Summary of Changes

✅ Created free backend for Twilio OTP SMS  
✅ Updated Flutter app to use backend API  
✅ OTP will be sent via SMS to real phone numbers  

## Deployment Steps

### Step 1: Deploy Backend to Vercel (5 minutes)

1. Go to https://vercel.com and sign up (free)
2. Click "Add New Project"
3. Select "Other" → "CLI"
4. In terminal, run:
   ```bash
   cd dipstore_backend
   npm install -g vercel
   vercel
   ```
5. Follow prompts to link your project
6. **Copy your Vercel URL** (e.g., `https://dipstore-otp.vercel.app`)

### Step 2: Add Environment Variables to Vercel

In Vercel dashboard:
1. Go to Project Settings → Environment Variables
2. Add these 3 variables:

```
TWILIO_ACCOUNT_SID = ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN = your_twilio_auth_token
TWILIO_PHONE_NUMBER = +10000000000
```

3. Click "Save"

### Step 3: Update Flutter App

In `lib/core/services/auth_service.dart`, replace:

```dart
const String OTP_BACKEND_URL = 'https://dipstore-otp.vercel.app';
```

With your actual Vercel URL.

### Step 4: Get Dependencies

```bash
cd dipstore_ui
flutter pub get
```

### Step 5: Restart Flutter App

```bash
flutter run -d chrome
```

## Testing

1. **Sign up** with a new phone number (must start with +)
2. **OTP Dialog appears** showing the code
3. **SMS is sent** to that phone number (via Twilio)
4. **Enter the code** you received by SMS
5. **Account created!** ✅

## What Your Teacher Will See

When your teacher tests on their phone:

1. They enter their phone number: `+1234567890`
2. They receive an SMS:
   ```
   Your DipStore verification code is: 861100. 
   Do not share this code. Valid for 10 minutes.
   ```
3. They enter the code and account is verified ✅

## Backend Files

```
dipstore_backend/
├── api/
│   └── index.js          # Main OTP API handler
├── package.json          # Node dependencies
├── vercel.json          # Vercel configuration
├── .env.example         # Environment variables template
├── README.md            # Backend documentation
└── UPDATE_FLUTTER_APP.md # Flutter integration guide
```

## Flutter Files Updated

```
dipstore_ui/
├── pubspec.yaml         # Added http dependency
└── lib/core/services/
    └── auth_service.dart # Updated to use backend API
```

## Key Features

✅ Real SMS delivery via Twilio  
✅ Free hosting on Vercel  
✅ OTP expires in 10 minutes  
✅ 5 verification attempts allowed  
✅ CORS enabled for Flutter web  
✅ Development fallback mode  

## Troubleshooting

**"Connection refused"**
- Check if Vercel backend is deployed
- Verify OTP_BACKEND_URL is correct

**"OTP not received"**
- Check if Twilio credentials are correct in Vercel
- Verify phone number format (must start with +)
- Check Twilio SMS limit (free trial has limits)

**"OTP Invalid"**
- Make sure you enter exact code
- Code expires after 10 minutes
- Max 5 attempts per phone number

## Free Tier Limits

- **Vercel**: Unlimited deployments, 100GB bandwidth/month
- **Twilio**: Free trial with $15 credit (~150 SMS messages)

## Next Steps After Testing

1. Set up production database for OTP storage
2. Implement user authentication tokens
3. Add payment processing
4. Deploy Flutter web app to production

## Support

See these files for more help:
- `dipstore_backend/README.md` - Backend setup
- `dipstore_backend/UPDATE_FLUTTER_APP.md` - Flutter integration
