import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/shop_wallet_model.dart';

class ShopWalletService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'shop_wallets';

  /// Initialize a wallet for a new shop
  Future<void> createShopWallet(String shopId) async {
    try {
      await _firestore.collection(_collection).doc(shopId).set({
        'availableBalance': 0.0,
        'pendingBalance': 0.0,
        'totalWithdrawn': 0.0,
        'totalEarned': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Shop wallet created for $shopId");
    } catch (e) {
      debugPrint("❌ Error creating shop wallet: $e");
      rethrow;
    }
  }

  /// Get wallet balance stream for shop
  Stream<ShopWalletModel?> getShopWalletStream(String shopId) {
    return _firestore.collection(_collection).doc(shopId).snapshots().map((doc) {
      if (doc.exists) {
        return ShopWalletModel.fromSnapshot(doc);
      }
      return null;
    });
  }

  /// Get wallet balance once
  Future<ShopWalletModel?> getShopWallet(String shopId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(shopId).get();
      if (doc.exists) {
        return ShopWalletModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching shop wallet: $e");
      return null;
    }
  }

  /// Credit available balance (from completed orders)
  Future<void> creditAvailableBalance(String shopId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collection).doc(shopId);
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final currentBalance =
              (doc['availableBalance'] as num?)?.toDouble() ?? 0.0;
          final totalEarned =
              (doc['totalEarned'] as num?)?.toDouble() ?? 0.0;

          transaction.update(docRef, {
            'availableBalance': currentBalance + amount,
            'totalEarned': totalEarned + amount,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
      debugPrint("✅ Credited $amount to $shopId");
    } catch (e) {
      debugPrint("❌ Error crediting balance: $e");
      rethrow;
    }
  }

  /// Debit available balance (for withdrawal)
  Future<void> debitAvailableBalance(String shopId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collection).doc(shopId);
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final currentBalance =
              (doc['availableBalance'] as num?)?.toDouble() ?? 0.0;

          if (currentBalance < amount) {
            throw Exception('Insufficient funds');
          }

          transaction.update(docRef, {
            'availableBalance': currentBalance - amount,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
      debugPrint("✅ Debited $amount from $shopId");
    } catch (e) {
      debugPrint("❌ Error debiting balance: $e");
      rethrow;
    }
  }

  /// Record withdrawal as completed
  Future<void> recordWithdrawal(String shopId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collection).doc(shopId);
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final totalWithdrawn =
              (doc['totalWithdrawn'] as num?)?.toDouble() ?? 0.0;

          transaction.update(docRef, {
            'totalWithdrawn': totalWithdrawn + amount,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
      debugPrint("✅ Withdrawal recorded for $shopId: $amount");
    } catch (e) {
      debugPrint("❌ Error recording withdrawal: $e");
      rethrow;
    }
  }
}
