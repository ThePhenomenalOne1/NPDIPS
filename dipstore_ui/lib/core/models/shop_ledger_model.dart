import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single financial transaction for a shop
/// Immutable record used for accounting and audit trail
enum LedgerEntryType {
  sale,                // Order completed = money in
  platformFee,         // Platform commission deducted
  refund,              // Refund to customer
  withdrawal,          // Owner withdrew money
  manualAdjustment,    // Admin adjustment
}

class ShopLedgerModel {
  final String id;
  final String shopId;
  final String orderId;            // Associated order (if applicable)
  final LedgerEntryType type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String? createdBy;         // User who created entry

  ShopLedgerModel({
    required this.id,
    required this.shopId,
    required this.orderId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.createdBy,
  });

  factory ShopLedgerModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShopLedgerModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      orderId: data['orderId'] ?? '',
      type: LedgerEntryType.values.byName(data['type'] ?? 'sale'),
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'orderId': orderId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}
