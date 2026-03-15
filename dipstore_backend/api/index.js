const twilio = require("twilio");

// In-memory OTP store (simple, for testing - use database in production)
const otpStore = new Map();

// Initialize Twilio client
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

const client = accountSid && authToken ? twilio(accountSid, authToken) : null;

// Helper to generate 6-digit OTP
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Helper to validate phone number
function isValidPhoneNumber(phone) {
  return /^\+\d{10,15}$/.test(phone.replace(/\s/g, ""));
}

/**
 * POST /api/send-otp
 * Request body: { phoneNumber: string }
 * Response: { success: boolean, otp?: string, message: string }
 */
async function sendOtp(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Method not allowed" });
  }

  try {
    const { phoneNumber } = req.body;

    // Validate input
    if (!phoneNumber) {
      return res.status(400).json({ success: false, message: "Phone number is required" });
    }

    // Validate phone format
    const cleanPhone = phoneNumber.replace(/\s/g, "");
    if (!isValidPhoneNumber(cleanPhone)) {
      return res.status(400).json({ success: false, message: "Invalid phone number format" });
    }

    // Generate OTP
    const otp = generateOtp();
    const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes

    // Store OTP
    otpStore.set(cleanPhone, { otp, expiresAt, attempts: 0 });

    // Send SMS via Twilio
    if (client && twilioPhoneNumber) {
      try {
        await client.messages.create({
          body: `Your DipStore verification code is: ${otp}. Do not share this code. Valid for 10 minutes.`,
          from: twilioPhoneNumber,
          to: cleanPhone,
        });
        console.log(`✅ SMS sent to ${cleanPhone}`);
      } catch (twilioError) {
        console.error("❌ Twilio error:", twilioError.message);
        // If Twilio fails but OTP is stored, return success for testing
        return res.status(200).json({
          success: true,
          otp: otp, // Return OTP for development/testing
          message: `OTP generated (SMS failed - use code for testing): ${otp}`,
        });
      }
    } else {
      console.log(`⚠️ Twilio not configured, returning OTP for testing: ${otp}`);
      return res.status(200).json({
        success: true,
        otp: otp,
        message: `OTP for testing (Twilio not configured): ${otp}`,
      });
    }

    return res.status(200).json({
      success: true,
      message: `OTP sent to ${cleanPhone}`,
    });
  } catch (error) {
    console.error("Send OTP error:", error);
    return res.status(500).json({
      success: false,
      message: `Error: ${error.message}`,
    });
  }
}

/**
 * POST /api/verify-otp
 * Request body: { phoneNumber: string, otp: string }
 * Response: { success: boolean, message: string }
 */
async function verifyOtp(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Method not allowed" });
  }

  try {
    const { phoneNumber, otp } = req.body;

    // Validate input
    if (!phoneNumber || !otp) {
      return res.status(400).json({
        success: false,
        message: "Phone number and OTP are required",
      });
    }

    const cleanPhone = phoneNumber.replace(/\s/g, "");

    // Check if OTP exists
    const stored = otpStore.get(cleanPhone);
    if (!stored) {
      return res.status(400).json({
        success: false,
        message: "No OTP found for this phone number",
      });
    }

    // Check if expired
    if (Date.now() > stored.expiresAt) {
      otpStore.delete(cleanPhone);
      return res.status(400).json({
        success: false,
        message: "OTP expired. Please request a new one.",
      });
    }

    // Check attempts
    if (stored.attempts >= 5) {
      otpStore.delete(cleanPhone);
      return res.status(400).json({
        success: false,
        message: "Too many failed attempts. Please request a new OTP.",
      });
    }

    // Verify OTP
    if (otp.trim() !== stored.otp) {
      stored.attempts++;
      return res.status(400).json({
        success: false,
        message: `Invalid OTP. ${5 - stored.attempts} attempts remaining.`,
      });
    }

    // Success - delete OTP
    otpStore.delete(cleanPhone);

    return res.status(200).json({
      success: true,
      message: "Phone verified successfully",
    });
  } catch (error) {
    console.error("Verify OTP error:", error);
    return res.status(500).json({
      success: false,
      message: `Error: ${error.message}`,
    });
  }
}

/**
 * Combined handler for all routes
 */
export default async function handler(req, res) {
  // Set CORS headers for all requests
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.setHeader("Access-Control-Max-Age", "86400");

  // Handle preflight OPTIONS request
  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  const { pathname } = new URL(req.url, `http://${req.headers.host}`);

  if (pathname === "/api/send-otp" || pathname === "/send-otp") {
    return sendOtp(req, res);
  } else if (pathname === "/api/verify-otp" || pathname === "/verify-otp") {
    return verifyOtp(req, res);
  } else {
    return res.status(200).json({
      success: true,
      message: "DipStore OTP API",
      endpoints: ["/api/send-otp", "/api/verify-otp"],
    });
  }
}
