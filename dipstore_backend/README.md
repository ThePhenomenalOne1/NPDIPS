# DipStore OTP Backend

Free backend service for sending OTP via Twilio SMS using Vercel.

## Quick Setup (5 minutes)

### 1. Deploy to Vercel (Free)

Click the button below or follow manual steps:

```bash
# Manual deployment:
1. Create account at https://vercel.com (free)
2. Connect your GitHub account
3. Import this repository
4. Add environment variables (see below)
5. Deploy
```

### 2. Set Environment Variables

In your Vercel project settings, add:

```
TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+10000000000
FIB_CLIENT_ID=your-fib-client-id
FIB_CLIENT_SECRET=your-fib-client-secret
FIB_ENVIRONMENT=dev
FIB_CURRENCY=IQD
# Optional overrides:
# FIB_STATUS_CALLBACK_URL=https://your-project.vercel.app/api/fib/payment-callback
# FIB_REDIRECT_URI=clientapp://your.url.example.co/responsePayment
```

### 3. Get Your Backend URL

After deployment, Vercel gives you a URL like:
```
https://your-project.vercel.app
```

Your API endpoints will be:
- Send OTP: `https://your-project.vercel.app/api/send-otp`
- Verify OTP: `https://your-project.vercel.app/api/verify-otp`
- FIB Create Payment: `https://your-project.vercel.app/api/fib/create-payment`
- FIB Payment Status: `https://your-project.vercel.app/api/fib/payment-status?paymentId=PAY-123`

## API Endpoints

### Send OTP

**POST** `/api/send-otp`

Request:
```json
{
  "phoneNumber": "+9647511019862"
}
```

Response (Success):
```json
{
  "success": true,
  "message": "OTP sent to +9647511019862"
}
```

Response (Dev Mode - if Twilio fails):
```json
{
  "success": true,
  "otp": "861100",
  "message": "OTP for testing (Twilio not configured): 861100"
}
```

### Verify OTP

**POST** `/api/verify-otp`

Request:
```json
{
  "phoneNumber": "+9647511019862",
  "otp": "861100"
}
```

Response (Success):
```json
{
  "success": true,
  "message": "Phone verified successfully"
}
```

### Create FIB Payment

**POST** `/api/fib/create-payment`

Request:
```json
{
  "amount": 15000,
  "description": "DipStore Checkout"
}
```

Response (Success):
```json
{
  "success": true,
  "payment": {
    "paymentId": "PAY-123",
    "qrCode": "...",
    "readableCode": "1234-5678",
    "validUntil": "2026-03-15T10:00:00.000Z",
    "personalAppLink": "https://personal...",
    "businessAppLink": "https://business...",
    "corporateAppLink": "https://corporate..."
  }
}
```

### Check FIB Payment Status

**GET** `/api/fib/payment-status?paymentId=PAY-123`

Response (Success):
```json
{
  "success": true,
  "paymentId": "PAY-123",
  "status": "PAID"
}
```

Note: FIB's official API is typically configured for IQD amounts. If your storefront still displays USD values, align the app currency before using real payments in production.

## Local Testing

```bash
# Install dependencies
npm install

# Set up .env file
cp .env.example .env

# Run locally
npm run dev

# Your local backend will be at http://localhost:3000
```

## Features

✅ Generate 6-digit OTP  
✅ Send SMS via Twilio  
✅ Verify OTP with expiration (10 min)  
✅ Rate limiting (5 attempts max)  
✅ CORS enabled for Flutter web  
✅ Free Vercel hosting  
✅ Development fallback (shows OTP if Twilio fails)  
✅ FIB payment session creation and status checks  

## Files

- `api/index.js` - Main OTP API handler
- `api/fib-create-payment.js` - Creates official FIB payment sessions
- `api/fib-payment-status.js` - Checks FIB payment status
- `api/fib-payment-callback.js` - Receives optional FIB callbacks
- `vercel.json` - Vercel configuration
- `package.json` - Node dependencies
- `.env.example` - Environment variables template

## Next Steps

1. Deploy to Vercel ✅
2. Update Flutter app to call your backend API
3. Test OTP flow

See `UPDATE_FLUTTER_APP.md` for Flutter integration.
