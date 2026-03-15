import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/product/models/review_model.dart';

class ReviewService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  // Get reviews for a specific target (product or store)
  Stream<List<ReviewModel>> getReviews(String targetId) {
    return _firestore.collection(_collection)
        .where('targetId', isEqualTo: targetId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
      // Sort client-side to avoid needing a Firestore composite index
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  // Add a new review
  Future<void> addReview(ReviewModel review) async {
    try {
      
      // Check if user already reviewed this target
      final existingDocs = await _firestore.collection(_collection)
          .where('targetId', isEqualTo: review.targetId)
          .where('userId', isEqualTo: review.userId)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        throw Exception("You have already rated this item.");
      }

      await _firestore.collection(_collection).add(review.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding review: $e");
      rethrow;
    }
  }

  // Get average rating for a target
  Stream<double> getAverageRating(String targetId) {
    return _firestore.collection(_collection)
        .where('targetId', isEqualTo: targetId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['rating'] ?? 0.0);
      }
      return total / snapshot.docs.length;
    });
  }
}
