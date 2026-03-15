class WalletModel {
  final String userId;
  final double balance;

  WalletModel({required this.userId, required this.balance});

  factory WalletModel.fromMap(String id, Map<String, dynamic> data) {
    return WalletModel(
      userId: id,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, Object> toMap() {
    return {
      'balance': balance,
    };
  }
}
