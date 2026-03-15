const functions = require("firebase-functions");
const twilio = require("twilio");
const admin = require("firebase-admin");

admin.initializeApp();

// Twilio credentials (use Firebase Secrets in production)
const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID || "ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN || "your_twilio_auth_token";
const TWILIO_PHONE_NUMBER = process.env.TWILIO_PHONE_NUMBER || "+10000000000";

const client = twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);

/**
 * Send OTP via Twilio SMS
 * Called from Flutter app with: phoneNumber
 * Returns: { success, otpCode, expiresAt }
 */
exports.sendOtp = functions.https.onCall(async (data, context) => {
  try {
    // Verify user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated"
      );
    }

    const phoneNumber = data.phoneNumber;
    if (!phoneNumber) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Phone number is required"
      );
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes

    // Send SMS via Twilio
    const message = await client.messages.create({
      body: `Your DipStore verification code is: ${otp}. Do not share this code.`,
      from: TWILIO_PHONE_NUMBER,
      to: phoneNumber,
    });

    console.log(`OTP sent to ${phoneNumber}: ${message.sid}`);

    // Store OTP in Firestore for verification
    await admin
      .firestore()
      .collection("otp_sessions")
      .doc(context.auth.uid)
      .set(
        {
          phoneNumber: phoneNumber,
          otpCode: otp,
          expiresAt: expiresAt,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          verified: false,
        },
        { merge: true }
      );

    return {
      success: true,
      expiresAt: expiresAt,
      message: `OTP sent to ${phoneNumber}`,
    };
  } catch (error) {
    console.error("Send OTP error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Verify OTP code
 * Called from Flutter app with: otpCode
 * Returns: { success, message }
 */
exports.verifyOtp = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated"
      );
    }

    const otpCode = data.otpCode;
    if (!otpCode) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "OTP code is required"
      );
    }

    // Get OTP session
    const session = await admin
      .firestore()
      .collection("otp_sessions")
      .doc(context.auth.uid)
      .get();

    if (!session.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "OTP session not found"
      );
    }

    const sessionData = session.data();

    // Check if expired
    if (Date.now() > sessionData.expiresAt) {
      throw new functions.https.HttpsError("failed-precondition", "OTP expired");
    }

    // Verify code
    if (sessionData.otpCode !== otpCode) {
      throw new functions.https.HttpsError("invalid-argument", "Invalid OTP code");
    }

    // Mark as verified
    await admin
      .firestore()
      .collection("otp_sessions")
      .doc(context.auth.uid)
      .update({
        verified: true,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    // Update user document with verified phone
    await admin
      .firestore()
      .collection("users")
      .doc(context.auth.uid)
      .update({
        phoneNumber: sessionData.phoneNumber,
        phoneVerified: true,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return {
      success: true,
      message: "Phone verified successfully",
    };
  } catch (error) {
    console.error("Verify OTP error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
