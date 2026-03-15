import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/models/store_model.dart';
import 'package:flutter/foundation.dart';

class StoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stores';
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 5;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  StoreService() {
    _loadRecentSearches();
  }

  // Load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading recent searches: $e");
    }
  }

  // Add a search query to recent searches
  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      // Remove if already exists
      _recentSearches.remove(query);
      
      // Add to beginning
      _recentSearches.insert(0, query);
      
      // Keep only max items
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding recent search: $e");
    }
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      _recentSearches = [];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing recent searches: $e");
    }
  }

  // Get stream of all stores
  Stream<List<StoreModel>> getStores() {
    return _firestore.collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StoreModel.fromSnapshot(doc)).toList();
    });
  }

  // Get stream of featured stores only
  Stream<List<StoreModel>> getFeaturedStores() {
    return _firestore.collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StoreModel.fromSnapshot(doc)).toList();
    });
  }

  // Get stores owned by a specific ShopOwner
  Stream<List<StoreModel>> getStoresOwnedBy(String ownerId) {
    return _firestore.collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StoreModel.fromSnapshot(doc)).toList();
    });
  }

  // Add a new store (for ShopOwner or Superadmin)
  Future<String> addStore({
    required String name,
    required String ownerId,
    required String category,
    required String tagline,
    required String about,
    required bool isFeatured,
    String? imageUrl,
    String? phoneNumber,
    double commissionRate = 0.10,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'name': name,
        'ownerId': ownerId,
        'category': category,
        'tagline': tagline,
        'about': about,
        'isFeatured': isFeatured,
        'imageUrl': imageUrl,
        'phoneNumber': phoneNumber,
        'status': 'active',
        'commissionRate': commissionRate,
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': FieldValue.serverTimestamp(), // Auto-approve for now
      });
      return docRef.id;
    } catch (e) {
      debugPrint("Error adding store: $e");
      rethrow;
    }
  }

  // Update a store
  Future<void> updateStore(String storeId, StoreModel store) async {
    try {
      await _firestore.collection(_collection).doc(storeId).update(store.toMap());
    } catch (e) {
      debugPrint("Error updating store: $e");
      rethrow;
    }
  }

  // Delete a store (with cascade deletion of products)
  Future<void> deleteStore(String id) async {
    try {
      // Note: Cascade deletion of products should be handled by ProductService
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting store: $e");
      rethrow;
    }
  }

  // Search stores (Basic client-side filtering)
  Stream<List<StoreModel>> searchStores(String query) {
    return getStores().map((stores) => 
       stores.where((s) => 
          s.name.toLowerCase().contains(query.toLowerCase()) || 
          s.category.toLowerCase().contains(query.toLowerCase())
       ).toList()
    );
  }

  // Follow a store
  Future<void> followStore(String userId, String storeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('followed_stores')
          .doc(storeId)
          .set({
        'storeId': storeId,
        'followedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error following store: $e");
      rethrow;
    }
  }

  // Unfollow a store
  Future<void> unfollowStore(String userId, String storeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('followed_stores')
          .doc(storeId)
          .delete();
    } catch (e) {
      debugPrint("Error unfollowing store: $e");
      rethrow;
    }
  }

  // Check if a store is followed (Stream)
  Stream<bool> isStoreFollowed(String userId, String storeId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followed_stores')
        .doc(storeId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
}
