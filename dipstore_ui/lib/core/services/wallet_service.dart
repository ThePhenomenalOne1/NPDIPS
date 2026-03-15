import 'package:cloud_firestore/cloud_firestore.dart';

/// A simple helper that keeps track of user "wallet" balances and performs
/// transfers between accounts. All writes are done inside a transaction to
/// prevent races and to ensure consistency.
class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ensures a wallet document exists for the given user. This is a no-op if
  /// the document is already present. Useful to call after registering/login.
  Future<void> ensureWallet(String uid, {double initialBalance = 0.0}) async {
    final ref = _firestore.collection('wallets').doc(uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({'balance': initialBalance});
    }
  }

  /// Reads the current balance for [uid]. Returns 0.0 if there is no doc.
  Future<double> getBalance(String uid) async {
    final snapshot = await _firestore.collection('wallets').doc(uid).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['balance'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Stream version that emits updates whenever the wallet document changes.
  Stream<double> balanceStream(String uid) {
    return _firestore.collection('wallets').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return 0.0;
      final data = snap.data()!;
      return (data['balance'] as num?)?.toDouble() ?? 0.0;
    });
  }

  /// Transfers [amount] from [fromUid] to [toUid]. Throws if the sender has
  /// insufficient funds. Both wallets will be created automatically if missing.
  Future<void> transfer({
    required String fromUid,
    required String toUid,
    required double amount,
  }) async {
    if (amount <= 0) return;

    final fromRef = _firestore.collection('wallets').doc(fromUid);
    final toRef = _firestore.collection('wallets').doc(toUid);

    await _firestore.runTransaction((tx) async {
      final fromSnap = await tx.get(fromRef);
      final toSnap = await tx.get(toRef);

      double fromBalance = 0.0;
      double toBalance = 0.0;

      if (fromSnap.exists) {
        fromBalance = (fromSnap.data()!['balance'] as num?)?.toDouble() ?? 0.0;
      }
      if (toSnap.exists) {
        toBalance = (toSnap.data()!['balance'] as num?)?.toDouble() ?? 0.0;
      }

      if (fromBalance < amount) {
        throw Exception('Insufficient funds');
      }

      tx.set(fromRef, {'balance': fromBalance - amount}, SetOptions(merge: true));
      tx.set(toRef, {'balance': toBalance + amount}, SetOptions(merge: true));
    });
  }

  /// Convenience helper for crediting a wallet directly (e.g. top‑up by a bank)
  /// This simply increases the balance of [uid] by [amount].
  Future<void> addFunds(String uid, double amount) async {
    if (amount <= 0) return;
    final ref = _firestore.collection('wallets').doc(uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      double bal = 0.0;
      if (snap.exists) {
        bal = (snap.data()!['balance'] as num?)?.toDouble() ?? 0.0;
      }
      tx.set(ref, {'balance': bal + amount}, SetOptions(merge: true));
    });
  }
}

