import 'package:cloud_firestore/cloud_firestore.dart';

enum WithdrawalStatus {
  pending,      // Submitted, awaiting admin review
  approved,     // Approved, can proceed
  rejected,     // Admin rejected
  completed,    // Money transferred
  failed,       // Transfer failed
}

/// Request from ShopOwner to withdraw money
class WithdrawalRequestModel {
  final String id;
  final String shopOwnerId;       // User ID of ShopOwner
  final String shopId;
  final double amount;
  final WithdrawalStatus status;
  final String? bankAccountId;    // Bank details (sensitive, in real app)
  final String? rejectionReason;  // Why it was rejected
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;       // Superadmin who reviewed
  final DateTime? completedAt;

  WithdrawalRequestModel({
    required this.id,
    required this.shopOwnerId,
    required this.shopId,
    required this.amount,
    this.status = WithdrawalStatus.pending,
    this.bankAccountId,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.completedAt,
  });

  factory WithdrawalRequestModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WithdrawalRequestModel(
      id: doc.id,
      shopOwnerId: data['shopOwnerId'] ?? '',
      shopId: data['shopId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      status: WithdrawalStatus.values.byName(data['status'] ?? 'pending'),
      bankAccountId: data['bankAccountId'],
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'],
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopOwnerId': shopOwnerId,
      'shopId': shopId,
      'amount': amount,
      'status': status.name,
      'bankAccountId': bankAccountId,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
