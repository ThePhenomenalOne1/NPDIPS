const { authenticateFib, getFibConfig, setCors } = require("./_fib");

module.exports = async function handler(req, res) {
  setCors(res, "GET, OPTIONS");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "GET") {
    return res.status(405).json({ success: false, message: "Method not allowed" });
  }

  try {
    const paymentId = `${req.query?.paymentId || ""}`.trim();
    if (!paymentId) {
      return res.status(400).json({
        success: false,
        message: "paymentId is required",
      });
    }

    const config = getFibConfig(req);
    const token = await authenticateFib(config);

    const statusResponse = await fetch(
      `https://fib-${config.environment}.fib.iq/protected/v1/payments/${encodeURIComponent(paymentId)}/status`,
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      },
    );

    const statusData = await statusResponse.json().catch(() => ({}));

    if (!statusResponse.ok) {
      const message =
        statusData?.message ||
        statusData?.error ||
        "Failed to fetch payment status";
      return res.status(statusResponse.status).json({
        success: false,
        message,
        details: statusData,
      });
    }

    return res.status(200).json({
      success: true,
      paymentId: statusData.paymentId || paymentId,
      status: statusData.status || "UNKNOWN",
    });
  } catch (error) {
    console.error("FIB payment status error:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch payment status",
    });
  }
};