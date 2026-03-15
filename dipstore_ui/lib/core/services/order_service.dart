import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/firestore_order_model.dart';
import '../models/shop_ledger_model.dart';
import 'shop_ledger_service.dart';
import 'shop_wallet_service.dart';

class OrderService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'orders';

  /// Create a new order in Firestore
  Future<String> createOrder({
    required String customerId,
    required String shopId,
    required List<OrderItemModel> items,
    required double subtotal,
    required double taxAmount,
    required double platformFee,
    required double total,
    required String paymentMethod,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'customerId': customerId,
        'shopId': shopId,
        'items': items.map((item) => item.toMap()).toList(),
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'platformFee': platformFee,
        'total': total,
        'status': 'pending',
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': null,
        'notes': null,
      });
      debugPrint("✅ Order created: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("❌ Error creating order: $e");
      rethrow;
    }
  }

  /// Get orders for a specific customer
  Stream<List<FirestoreOrderModel>> getCustomerOrders(String customerId) {
    return _firestore.collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreOrderModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Get orders for a specific shop (for ShopOwner dashboard)
  Stream<List<FirestoreOrderModel>> getShopOrders(String shopId) {
    return _firestore.collection(_collection)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreOrderModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Update order status (e.g., mark as completed)
  /// When marked 'completed', automatically creates ledger entries
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    ShopLedgerService? ledgerService,
    ShopWalletService? walletService,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus.name,
      };

      if (newStatus == OrderStatus.completed) {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_collection).doc(orderId).update(updateData);
      debugPrint("✅ Order $orderId marked as $newStatus");

      // If marked completed, create ledger entries for shop
      if (newStatus == OrderStatus.completed &&
          ledgerService != null &&
          walletService != null) {
        final order = await getOrderById(orderId);
        if (order != null) {
          // Create sale entry
          await ledgerService.createLedgerEntry(
            shopId: order.shopId,
            orderId: orderId,
            type: LedgerEntryType.sale,
            amount: order.subtotal,
            description: "Sale from order $orderId",
            createdBy: 'system',
          );

          // Create platform fee entry
          await ledgerService.createLedgerEntry(
            shopId: order.shopId,
            orderId: orderId,
            type: LedgerEntryType.platformFee,
            amount: order.platformFee,
            description: "Platform fee for order $orderId",
            createdBy: 'system',
          );

          // Credit wallet with net amount
          await walletService.creditAvailableBalance(
            order.shopId,
            order.subtotal - order.platformFee,
          );

          debugPrint(
              "✅ Ledger entries created for order $orderId to shop ${order.shopId}");
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating order: $e");
      rethrow;
    }
  }

  /// Get a single order by ID
  Future<FirestoreOrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return FirestoreOrderModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching order: $e");
      return null;
    }
  }
}
