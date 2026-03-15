function setCors(res, methods = "GET, POST, OPTIONS") {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", methods);
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.setHeader("Access-Control-Max-Age", "86400");
}

function getPublicBaseUrl(req) {
  const protocol = req.headers["x-forwarded-proto"] || "https";
  const host = req.headers["x-forwarded-host"] || req.headers.host;
  return `${protocol}://${host}`;
}

function getFibConfig(req) {
  const clientId = process.env.FIB_CLIENT_ID;
  const clientSecret = process.env.FIB_CLIENT_SECRET;
  const environment = process.env.FIB_ENVIRONMENT || "dev";
  const publicBaseUrl = getPublicBaseUrl(req);
  const mockMode =
    process.env.FIB_MOCK_MODE === "true" ||
    process.env.FIB_MOCK_MODE === "1" ||
    !clientId ||
    !clientSecret;

  if (!mockMode && (!clientId || !clientSecret)) {
    throw new Error(
      "Missing FIB env vars. Required: FIB_CLIENT_ID, FIB_CLIENT_SECRET",
    );
  }

  return {
    clientId,
    clientSecret,
    environment,
    mockMode,
    publicBaseUrl,
    currency: process.env.FIB_CURRENCY || "IQD",
    statusCallbackUrl:
      process.env.FIB_STATUS_CALLBACK_URL ||
      `${publicBaseUrl}/api/fib/payment-callback`,
    redirectUri: process.env.FIB_REDIRECT_URI || null,
  };
}

async function authenticateFib(config) {
  const tokenResponse = await fetch(
    `https://fib-${config.environment}.fib.iq/auth/realms/fib-online-shop/protocol/openid-connect/token`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        client_id: config.clientId,
        client_secret: config.clientSecret,
      }),
    },
  );

  const tokenData = await tokenResponse.json().catch(() => ({}));

  if (!tokenResponse.ok || !tokenData.access_token) {
    const message =
      tokenData.error_description ||
      tokenData.error ||
      "Failed to authenticate with FIB";
    throw new Error(message);
  }

  return tokenData.access_token;
}

function normalizePaymentSession(response) {
  return {
    paymentId: response.paymentId,
    qrCode: response.qrCode || "",
    readableCode: response.readableCode || "",
    validUntil: response.validUntil || "",
    mockMode: response.mockMode === true,
    mockMessage: response.mockMessage || "",
    personalAppLink: response.personalAppLink || "",
    businessAppLink: response.businessAppLink || "",
    corporateAppLink: response.corporateAppLink || "",
  };
}

function createMockPaymentSession({ amount, description, config }) {
  const timestamp = Date.now();
  const paymentId = `MOCK-FIB-${timestamp}`;
  const encodedPaymentId = encodeURIComponent(paymentId);
  const readableCode = `${timestamp}`.substring(5, 13);
  const mockLink = `${config.publicBaseUrl}/api/fib/payment-status?paymentId=${encodedPaymentId}`;

  return normalizePaymentSession({
    paymentId,
    qrCode: "mock-qr-code",
    readableCode,
    validUntil: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
    mockMode: true,
    mockMessage:
      "Mock FIB mode is enabled. Use Verify Payment to simulate a completed payment.",
    personalAppLink: mockLink,
    businessAppLink: mockLink,
    corporateAppLink: mockLink,
    description,
    amount,
  });
}

function getMockPaymentStatus(paymentId) {
  const normalizedId = `${paymentId || ""}`.toUpperCase();
  if (normalizedId.startsWith("MOCK-FIB-")) {
    return {
      paymentId,
      status: "PAID",
      mockMode: true,
    };
  }

  return null;
}

module.exports = {
  createMockPaymentSession,
  authenticateFib,
  getFibConfig,
  getMockPaymentStatus,
  normalizePaymentSession,
  setCors,
};