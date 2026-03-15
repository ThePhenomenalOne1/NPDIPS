import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/shop_ledger_model.dart';

class ShopLedgerService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'shop_ledger';

  /// Create a ledger entry
  Future<String> createLedgerEntry({
    required String shopId,
    String? orderId,
    required LedgerEntryType type,
    required double amount,
    required String description,
    required String createdBy,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'shopId': shopId,
        'orderId': orderId,
        'type': type.toString().split('.').last,
        'amount': amount,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      });

      debugPrint("✅ Ledger entry created: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("❌ Error creating ledger entry: $e");
      rethrow;
    }
  }

  /// Get shop ledger stream (for dashboard)
  Stream<List<ShopLedgerModel>> getShopLedgerStream(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopLedgerModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Get total earnings for shop
  Future<double> getTotalEarnings(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .where('type', isEqualTo: 'sale')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      debugPrint("Error calculating total earnings: $e");
      return 0.0;
    }
  }

  /// Get total fees paid
  Future<double> getTotalFeesPaid(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .where('type', isEqualTo: 'platformFee')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      debugPrint("Error calculating total fees: $e");
      return 0.0;
    }
  }

  /// Get recent ledger entries (last N)
  Future<List<ShopLedgerModel>> getRecentEntries(String shopId,
      {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ShopLedgerModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint("Error fetching recent entries: $e");
      return [];
    }
  }
}
