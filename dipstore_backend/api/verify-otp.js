const twilio = require("twilio");

function setCors(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.setHeader("Access-Control-Max-Age", "86400");
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

    const { phoneNumber, otp } = req.body || {};
    const cleanPhone = (phoneNumber || "").replace(/\s/g, "");
    const code = (otp || "").trim();

    if (!cleanPhone || !code) {
      return res.status(400).json({
        success: false,
        message: "Phone number and OTP are required",
      });
    }

    const client = twilio(accountSid, authToken);

    const check = await client.verify.v2
      .services(verifyServiceSid)
      .verificationChecks.create({ to: cleanPhone, code });

    if (check.status === "approved") {
      return res.status(200).json({ success: true, message: "Phone verified successfully" });
    }

    return res.status(400).json({ success: false, message: "Invalid or expired OTP" });
  } catch (error) {
    const twilioCode = error?.code;
    const msg = error?.message || "Failed to verify OTP";
    console.error("Verify OTP error:", twilioCode, msg);
    return res.status(500).json({ success: false, message: msg, code: twilioCode });
  }
};
