const {
  authenticateFib,
  createMockPaymentSession,
  getFibConfig,
  normalizePaymentSession,
  setCors,
} = require("./_fib");

module.exports = async function handler(req, res) {
  setCors(res, "POST, OPTIONS");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Method not allowed" });
  }

  try {
    const config = getFibConfig(req);
    const {
      amount,
      description,
      redirectUri,
      expiresIn,
      refundableFor,
    } = req.body || {};

    const normalizedAmount = Number.parseFloat(`${amount ?? ""}`);
    if (!Number.isFinite(normalizedAmount) || normalizedAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: "A valid payment amount is required",
      });
    }

    if (config.mockMode) {
      return res.status(200).json({
        success: true,
        payment: createMockPaymentSession({
          amount: normalizedAmount.toFixed(2),
          description: description || "DipStore Checkout",
          config,
        }),
      });
    }

    const token = await authenticateFib(config);

    const paymentResponse = await fetch(
      `https://fib-${config.environment}.fib.iq/protected/v1/payments`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          monetaryValue: {
            amount: normalizedAmount.toFixed(2),
            currency: config.currency,
          },
          statusCallbackUrl: config.statusCallbackUrl,
          description: description || "DipStore Checkout",
          redirectUri: redirectUri || config.redirectUri || "",
          expiresIn: expiresIn || "PT8H6M12.345S",
          refundableFor: refundableFor || "PT48H",
        }),
      },
    );

    const paymentData = await paymentResponse.json().catch(() => ({}));

    if (!paymentResponse.ok) {
      const message =
        paymentData?.message ||
        paymentData?.error ||
        "Failed to create FIB payment";
      return res.status(paymentResponse.status).json({
        success: false,
        message,
        details: paymentData,
      });
    }

    return res.status(200).json({
      success: true,
      payment: normalizePaymentSession(paymentData),
    });
  } catch (error) {
    console.error("FIB create payment error:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to create FIB payment",
    });
  }
};