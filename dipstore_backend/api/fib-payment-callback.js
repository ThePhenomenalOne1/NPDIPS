const { setCors } = require("./_fib");

module.exports = async function handler(req, res) {
  setCors(res, "POST, OPTIONS");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Method not allowed" });
  }

  console.log("FIB payment callback received:", req.body || {});

  return res.status(200).json({ success: true });
};