/**
 * deduplicate_firestore.js
 * ─────────────────────────────────────────────────────────────
 * Scans the Firestore database for duplicate documents and
 * removes them, keeping the OLDEST record (by createdAt).
 *
 * HOW TO RUN
 * ──────────
 * 1. Download a Service Account key from Firebase Console:
 *    Firebase Console → Project Settings → Service Accounts
 *    → Generate new private key  → save as serviceAccount.json
 *    (place the file next to this script, or set SERVICE_ACCOUNT_PATH)
 *
 * 2. Install dependencies (from this folder):
 *       npm install firebase-admin
 *
 * 3. Run:
 *       node deduplicate_firestore.js
 *    Or dry-run (no deletions, just reports):
 *       node deduplicate_firestore.js --dry-run
 *
 * WHAT IT CHECKS
 * ──────────────
 *   users             → duplicate email addresses
 *   stores  (pass 1) → duplicate (name + ownerId) combinations
 *   stores  (pass 2) → duplicate store names, any owner (case-insensitive)
 *                       e.g. "Urban Sole" and "urban sole" → keep oldest
 *   shops   (pass 1) → duplicate (name + ownerId) in legacy collection
 *   shops   (pass 2) → duplicate store names, any owner (case-insensitive)
 *   products          → duplicate (name + storeId) combinations
 *   reviews           → duplicate (userId + targetId) combinations
 * ─────────────────────────────────────────────────────────────
 */

"use strict";

const admin = require("firebase-admin");
const path  = require("path");
const fs    = require("fs");

// ── Configuration ─────────────────────────────────────────────
const DRY_RUN = process.argv.includes("--dry-run");
const SERVICE_ACCOUNT_PATH =
  process.env.SERVICE_ACCOUNT_PATH ||
  path.join(__dirname, "serviceAccount.json");
// ──────────────────────────────────────────────────────────────

// ── Initialise Firebase Admin ──────────────────────────────────
if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error(
    `\n❌  Service account key not found at: ${SERVICE_ACCOUNT_PATH}\n` +
    `   Download it from Firebase Console → Project Settings → Service Accounts\n` +
    `   and save it as "serviceAccount.json" next to this script.\n`
  );
  process.exit(1);
}

const serviceAccount = JSON.parse(fs.readFileSync(SERVICE_ACCOUNT_PATH, "utf8"));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── Helpers ────────────────────────────────────────────────────

/**
 * Returns a stable string key from a Firestore document's data.
 * @param {admin.firestore.DocumentData} data
 * @param {string[]} fields
 * @returns {string}
 */
function compositeKey(data, fields) {
  return fields
    .map((f) => String(data[f] ?? "").trim().toLowerCase())
    .join("::");
}

/**
 * Compares two Firestore documents by createdAt, returning the older one first.
 * Documents without createdAt sort to the end (treated as newest).
 */
function compareByCreatedAt(a, b) {
  const ta = a.data().createdAt?.toMillis?.() ?? Number.MAX_SAFE_INTEGER;
  const tb = b.data().createdAt?.toMillis?.() ?? Number.MAX_SAFE_INTEGER;
  return ta - tb; // ascending — oldest first
}

/**
 * Fetches all documents from a collection and deduplicates them.
 *
 * @param {string}   collectionName   Firestore collection path
 * @param {string[]} keyFields        Fields that together form the unique key
 * @param {string}   label            Human-readable name for log output
 */
async function deduplicateCollection(collectionName, keyFields, label) {
  console.log(`\n── ${label} (${collectionName}) ──────────────────────────`);

  const snapshot = await db.collection(collectionName).get();
  if (snapshot.empty) {
    console.log("  Collection is empty — nothing to check.");
    return;
  }

  // Group documents by composite key
  /** @type {Map<string, admin.firestore.QueryDocumentSnapshot[]>} */
  const groups = new Map();

  for (const doc of snapshot.docs) {
    const key = compositeKey(doc.data(), keyFields);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(doc);
  }

  let totalDupes = 0;
  const batch = db.batch();
  let batchCount = 0;

  for (const [key, docs] of groups.entries()) {
    if (docs.length === 1) continue; // no duplicate

    // Sort so index 0 is the one to KEEP (oldest)
    docs.sort(compareByCreatedAt);

    const keeper   = docs[0];
    const dupeList = docs.slice(1);
    totalDupes += dupeList.length;

    console.log(
      `  🔑  Key "${key}" — ${docs.length} copies found.\n` +
      `       Keeping  : ${keeper.id} (createdAt: ${keeper.data().createdAt?.toDate?.() ?? "unknown"})\n` +
      `       Removing : ${dupeList.map((d) => d.id).join(", ")}`
    );

    for (const dupe of dupeList) {
      batch.delete(dupe.ref);
      batchCount++;

      // Firestore batch limit is 500 operations — flush as needed
      if (batchCount === 490) {
        if (!DRY_RUN) await batch.commit();
        batchCount = 0;
      }
    }
  }

  if (totalDupes === 0) {
    console.log("  ✅  No duplicates found.");
    return;
  }

  console.log(
    `\n  Summary: ${totalDupes} duplicate document(s) scheduled for deletion.`
  );

  if (DRY_RUN) {
    console.log("  ⚠️   DRY RUN — no documents were deleted.");
  } else {
    if (batchCount > 0) await batch.commit();
    console.log(`  🗑   ${totalDupes} duplicate(s) deleted.`);
  }
}

// ── Main ───────────────────────────────────────────────────────

async function main() {
  const mode = DRY_RUN ? "DRY RUN (read-only)" : "LIVE (will delete)";
  console.log(
    `\n╔══════════════════════════════════════════════════════════╗`
  );
  console.log(
    `║  DipStore Firestore Deduplication Tool                  ║`
  );
  console.log(
    `║  Project : little-wing-v2                               ║`
  );
  console.log(
    `║  Mode    : ${mode.padEnd(46)}║`
  );
  console.log(
    `╚══════════════════════════════════════════════════════════╝`
  );

  try {
    // users — unique by email
    await deduplicateCollection(
      "users",
      ["email"],
      "Users (dedup by email)"
    );

    // stores — pass 1: same name AND same owner
    await deduplicateCollection(
      "stores",
      ["name", "ownerId"],
      "Stores pass 1 (dedup by name + ownerId)"
    );

    // stores — pass 2: same name across ANY owner (e.g. duplicate "Urban Sole")
    await deduplicateCollection(
      "stores",
      ["name"],
      "Stores pass 2 (dedup by name only, case-insensitive)"
    );

    // shops — legacy collection; pass 1: same name + same owner
    await deduplicateCollection(
      "shops",
      ["name", "ownerId"],
      "Shops [legacy] pass 1 (dedup by name + ownerId)"
    );

    // shops — legacy collection; pass 2: same name across any owner
    await deduplicateCollection(
      "shops",
      ["name"],
      "Shops [legacy] pass 2 (dedup by name only, case-insensitive)"
    );

    // products — unique by name + storeId
    await deduplicateCollection(
      "products",
      ["name", "storeId"],
      "Products (dedup by name + storeId)"
    );

    // reviews — one review per user per target
    await deduplicateCollection(
      "reviews",
      ["userId", "targetId"],
      "Reviews (dedup by userId + targetId)"
    );

    console.log("\n✅  Deduplication complete.\n");
  } catch (err) {
    console.error("\n❌  Error during deduplication:", err.message || err);
    process.exit(1);
  }
}

main();
