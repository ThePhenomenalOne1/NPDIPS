import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      debugPrint("Starting database seeding...");

      // Clear existing data before seeding to avoid duplicates
      await clearDatabase();

      // Seed stores and get their IDs
      final storeIds = await _seedStores();

      // Seed products for each store
      await _seedProducts(storeIds);

      debugPrint("Database seeding completed successfully!");
    } catch (e) {
      debugPrint("Error seeding database: $e");
      rethrow;
    }
  }

  Future<void> clearDatabase() async {
    try {
      debugPrint("Clearing seed data...");
      
      // Delete all products
      final products = await _firestore.collection('products').get();
      for (var doc in products.docs) {
        await doc.reference.delete();
      }
      
      // Delete all stores
      final stores = await _firestore.collection('stores').get();
      for (var doc in stores.docs) {
        await doc.reference.delete();
      }

      debugPrint("Database cleared successfully!");
    } catch (e) {
      debugPrint("Error clearing database: $e");
      rethrow;
    }
  }

  Future<Map<String, String>> _seedStores() async {
    // Hardcoded seed data has been removed per user request.
    return {};
  }

  Future<void> _seedProducts(Map<String, String> storeIds) async {
    // Hardcoded seed data has been removed per user request.
  }
}
