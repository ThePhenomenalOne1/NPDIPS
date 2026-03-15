class CartItemModel {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  int quantity;
  final String? imageUrl;
  final String? storeId;
  final String? storeName; // Added for display
  final DateTime? timestamp;

  CartItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    this.storeId,
    this.storeName,
    this.timestamp,
  });

  double get total => price * quantity;
}
