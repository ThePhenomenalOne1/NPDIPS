import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SeedDemoDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate complete demo data: 3 shop owners + shops + orders + ledger
  Future<void> generateDemoData() async {
    try {
      debugPrint("🌱 Starting demo data generation...");

      // Create 3 demo shop owners
      final owner1 = await _createDemoOwner('owner1@dipstore.local', 'Owner One');
      final owner2 = await _createDemoOwner('owner2@dipstore.local', 'Owner Two');
      final owner3 = await _createDemoOwner('owner3@dipstore.local', 'Owner Three');

      debugPrint("✅ Created 3 demo owners");

      // Create demo shops
      final shop1 = await _createDemoShop(
        'Boutique Fashion Store',
        owner1,
        'Fashion boutique with curated collections',
        'fashion',
      );
      final shop2 = await _createDemoShop(
        'Tech Electronics Hub',
        owner2,
        'Premium electronics and gadgets',
        'electronics',
      );
      final shop3 = await _createDemoShop(
        'Artisan Coffee Roasters',
        owner3,
        'Specialty coffee from around the world',
        'food',
      );

      debugPrint("✅ Created 3 demo shops");

      // Create demo orders for each shop
      await _createDemoOrders(shop1, 5);
      await _createDemoOrders(shop2, 8);
      await _createDemoOrders(shop3, 3);

      debugPrint("✅ Created demo orders with ledger entries");

      // Create demo wallets
      await _createDemoWallets(
        [shop1, shop2, shop3],
      );

      debugPrint("✅ Created demo wallets");

      debugPrint("🎉 Demo data generation complete!");
    } catch (e) {
      debugPrint("❌ Error generating demo data: $e");
      rethrow;
    }
  }

  /// Create a demo user with ShopOwner role
  Future<String> _createDemoOwner(String email, String name) async {
    try {
      // Create user account
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'Demo@123456',
      );

      final userId = cred.user!.uid;

      // Create user document with ShopOwner role
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'email': email,
        'name': name,
        'phoneNumber': '+1234567890',
        'profileImageUrl': null,
        'role': 'ShopOwner',
        'shopId': null,
        'permissions': ['manage_shop', 'view_orders', 'manage_withdrawals'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': true,
        'isActive': true,
      });

      return userId;
    } catch (e) {
      debugPrint("Note: Owner may already exist: $e");
      // Try to get existing user
      try {
        final snapshot =
            await _firestore.collection('users').where('email', isEqualTo: email).get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.id;
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Create a demo shop
  Future<String> _createDemoShop(
    String name,
    String ownerId,
    String description,
    String category,
  ) async {
    try {
      final docRef = await _firestore.collection('shops').add({
        'name': name,
        'ownerId': ownerId,
        'category': category,
        'tagline': 'Premium $category products',
        'about': description,
        'imageUrl': 'https://via.placeholder.com/200',
        'phoneNumber': '+1234567890',
        'isFeatured': true,
        'status': 'active',
        'commissionRate': 0.10,
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Update owner's shopId
      await _firestore
          .collection('users')
          .doc(ownerId)
          .update({'shopId': docRef.id});

      return docRef.id;
    } catch (e) {
      debugPrint("Error creating demo shop: $e");
      rethrow;
    }
  }

  /// Create demo orders and ledger entries
  Future<void> _createDemoOrders(String shopId, int count) async {
    try {
      await _auth.currentUser?.reload();
      final customerId = _auth.currentUser?.uid;
      if (customerId == null) return;

      for (int i = 0; i < count; i++) {
        final subtotal = 50.0 + (i * 20).toDouble();
        final taxAmount = subtotal * 0.08;
        final platformFee = subtotal * 0.10; // 10% commission
        final total = subtotal + taxAmount;

        // Create order
        final orderRef = await _firestore.collection('orders').add({
          'customerId': customerId,
          'shopId': shopId,
          'items': [
            {
              'productId': 'product_$i',
              'productName': 'Demo Product $i',
              'quantity': 1,
              'priceAtPurchase': subtotal,
            }
          ],
          'subtotal': subtotal,
          'taxAmount': taxAmount,
          'platformFee': platformFee,
          'total': total,
          'status': 'completed',
          'paymentMethod': 'card',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: count - i)),
          ),
          'completedAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: count - i - 1)),
          ),
          'notes': null,
        });

        // Create ledger entries
        await _firestore.collection('shop_ledger').add({
          'shopId': shopId,
          'orderId': orderRef.id,
          'type': 'sale',
          'amount': subtotal,
          'description': 'Sale from demo order ${orderRef.id}',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: count - i - 1)),
          ),
          'createdBy': 'system',
        });

        await _firestore.collection('shop_ledger').add({
          'shopId': shopId,
          'orderId': orderRef.id,
          'type': 'platformFee',
          'amount': platformFee,
          'description': 'Platform fee for demo order ${orderRef.id}',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: count - i - 1)),
          ),
          'createdBy': 'system',
        });
      }
    } catch (e) {
      debugPrint("Error creating demo orders: $e");
    }
  }

  /// Create demo wallets with calculated balances
  Future<void> _createDemoWallets(List<String> shopIds) async {
    try {
      for (final shopId in shopIds) {
        // Calculate total earnings from ledger
        final ledgerSnapshot = await _firestore
            .collection('shop_ledger')
            .where('shopId', isEqualTo: shopId)
            .where('type', isEqualTo: 'sale')
            .get();

        double totalEarned = 0;
        for (final doc in ledgerSnapshot.docs) {
          totalEarned += (doc['amount'] as num).toDouble();
        }

        // Create wallet
        await _firestore.collection('shop_wallets').doc(shopId).set({
          'availableBalance': totalEarned * 0.9, // 90% available after fees
          'pendingBalance': 0.0,
          'totalWithdrawn': 0.0,
          'totalEarned': totalEarned,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Error creating demo wallets: $e");
    }
  }

  /// Clear all demo data (for testing)
  Future<void> clearDemoData() async {
    try {
      debugPrint("🗑️ Clearing demo data...");

      // Delete demo users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ShopOwner')
          .get();

      for (final doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete demo shops
      final shopsSnapshot = await _firestore.collection('shops').get();
      for (final doc in shopsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete demo orders
      final ordersSnapshot = await _firestore.collection('orders').get();
      for (final doc in ordersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete demo ledger entries
      final ledgerSnapshot = await _firestore.collection('shop_ledger').get();
      for (final doc in ledgerSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete demo wallets
      final walletsSnapshot = await _firestore.collection('shop_wallets').get();
      for (final doc in walletsSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint("✅ Demo data cleared");
    } catch (e) {
      debugPrint("Error clearing demo data: $e");
    }
  }
}
