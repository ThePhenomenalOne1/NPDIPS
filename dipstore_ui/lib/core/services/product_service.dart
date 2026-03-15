import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/product/models/product_model.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Get stream of all products
  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    });
  }

  // Get products by store ID
  Stream<List<ProductModel>> getProductsByStore(String storeId) {
    return _firestore.collection(_collection)
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    });
  }

  // Get fast selling products
  Stream<List<ProductModel>> getSellingFastProducts() {
    return _firestore.collection(_collection)
        .where('isSellingFast', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    });
  }

  // Get popular products
  Stream<List<ProductModel>> getPopularProducts() {
     return _firestore.collection(_collection)
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    });
  }
  
  // Search products
  Stream<List<ProductModel>> searchProducts(String query) {
     // Basic client-side filtering for demo purposes since Firestore native search is limited
     return getProducts().map((products) => 
        products.where((p) => 
           p.name.toLowerCase().contains(query.toLowerCase()) || 
           p.brand.toLowerCase().contains(query.toLowerCase())
        ).toList()
     );
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
     try {
        await _firestore.collection(_collection).add(product.toMap());
     } catch (e) {
        debugPrint("Error adding product: $e");
        rethrow;
     }
  }

  // Update product
  Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(productId).update(product.toMap());
    } catch (e) {
      debugPrint("Error updating product: $e");
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      debugPrint("Error deleting product: $e");
      rethrow;
    }
  }

  // Delete all products for a store (cascade deletion)
  Future<void> deleteProductsByStore(String storeId) async {
    try {
      final querySnapshot = await _firestore.collection(_collection)
          .where('storeId', isEqualTo: storeId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error deleting products for store: $e");
      rethrow;
    }
  }
}
