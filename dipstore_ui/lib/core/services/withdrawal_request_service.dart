import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/withdrawal_request_model.dart';

class WithdrawalRequestService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'withdrawal_requests';

  /// Create withdrawal request
  Future<String> createWithdrawalRequest({
    required String shopOwnerId,
    required String shopId,
    required double amount,
    required String bankAccountId,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'shopOwnerId': shopOwnerId,
        'shopId': shopId,
        'amount': amount,
        'bankAccountId': bankAccountId,
        'status': 'pending',
        'rejectionReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'completedAt': null,
      });

      debugPrint("✅ Withdrawal request created: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("❌ Error creating withdrawal request: $e");
      rethrow;
    }
  }

  /// Get pending withdrawal requests (for admin)
  Stream<List<WithdrawalRequestModel>> getPendingRequests() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WithdrawalRequestModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Get withdrawal requests for a shop owner
  Stream<List<WithdrawalRequestModel>> getOwnerRequests(String shopOwnerId) {
    return _firestore
        .collection(_collection)
        .where('shopOwnerId', isEqualTo: shopOwnerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WithdrawalRequestModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Approve withdrawal request
  Future<void> approveWithdrawalRequest(
    String requestId,
    String reviewedBy,
  ) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
      });
      debugPrint("✅ Withdrawal request approved: $requestId");
    } catch (e) {
      debugPrint("❌ Error approving withdrawal request: $e");
      rethrow;
    }
  }

  /// Reject withdrawal request with reason
  Future<void> rejectWithdrawalRequest(
    String requestId,
    String rejectionReason,
    String reviewedBy,
  ) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'rejected',
        'rejectionReason': rejectionReason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
      });
      debugPrint("✅ Withdrawal request rejected: $requestId");
    } catch (e) {
      debugPrint("❌ Error rejecting withdrawal request: $e");
      rethrow;
    }
  }

  /// Mark withdrawal as completed (after payment processed)
  Future<void> completeWithdrawal(String requestId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Withdrawal completed: $requestId");
    } catch (e) {
      debugPrint("❌ Error completing withdrawal: $e");
      rethrow;
    }
  }

  /// Get single withdrawal request
  Future<WithdrawalRequestModel?> getWithdrawalRequest(String requestId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(requestId).get();
      if (doc.exists) {
        return WithdrawalRequestModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching withdrawal request: $e");
      return null;
    }
  }
}
