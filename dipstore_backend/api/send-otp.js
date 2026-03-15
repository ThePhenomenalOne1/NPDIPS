const twilio = require("twilio");

function setCors(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.setHeader("Access-Control-Max-Age", "86400");
}

function isValidPhoneNumber(phone) {
  return /^\+\d{10,15}$/.test((phone || "").replace(/\s/g, ""));
}

module.exports = async function handler(req, res) {
  setCors(res);

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Method not allowed" });
  }

  try {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const verifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

    if (!accountSid || !authToken || !verifyServiceSid) {
      return res.status(500).json({
        success: false,
        message:
          "Missing Twilio env vars. Required: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_VERIFY_SERVICE_SID",
      });
    }

    const { phoneNumber } = req.body || {};
    const cleanPhone = (phoneNumber || "").replace(/\s/g, "");

    if (!cleanPhone || !isValidPhoneNumber(cleanPhone)) {
      return res.status(400).json({ success: false, message: "Invalid phone number" });
    }

    const client = twilio(accountSid, authToken);

    await client.verify.v2
      .services(verifyServiceSid)
      .verifications.create({ to: cleanPhone, channel: "sms" });

    return res.status(200).json({
      success: true,
      message: `OTP sent to ${cleanPhone}`,
    });
  } catch (error) {
    const code = error?.code;
    const msg = error?.message || "Failed to send OTP";
    console.error("Send OTP error:", code, msg);
    return res.status(500).json({ success: false, message: msg, code });
  }
};
