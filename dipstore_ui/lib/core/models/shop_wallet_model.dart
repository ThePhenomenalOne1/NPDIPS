import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks financial balance for a shop
/// Mirrors real-world accounting with available, pending, and withdrawn amounts
class ShopWalletModel {
  final String shopId;
  final double availableBalance;    // Money ready to withdraw
  final double pendingBalance;      // Money from pending/completed orders (not yet settled)
  final double totalWithdrawn;      // Cumulative amount withdrawn
  final double totalEarned;         // Cumulative gross revenue
  final DateTime lastUpdated;

  ShopWalletModel({
    required this.shopId,
    this.availableBalance = 0.0,
    this.pendingBalance = 0.0,
    this.totalWithdrawn = 0.0,
    this.totalEarned = 0.0,
    required this.lastUpdated,
  });

  factory ShopWalletModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShopWalletModel(
      shopId: doc.id,
      availableBalance: (data['availableBalance'] ?? 0.0).toDouble(),
      pendingBalance: (data['pendingBalance'] ?? 0.0).toDouble(),
      totalWithdrawn: (data['totalWithdrawn'] ?? 0.0).toDouble(),
      totalEarned: (data['totalEarned'] ?? 0.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'totalWithdrawn': totalWithdrawn,
      'totalEarned': totalEarned,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
