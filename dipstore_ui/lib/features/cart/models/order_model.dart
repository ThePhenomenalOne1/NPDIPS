enum OrderStatus { pending, completed, cancelled }

class OrderModel {
  final String id;
  final String businessName;
  final String productName;
  final String productSubtitle;
  final double price;
  final int quantity;
  final String? imageUrl;
  final DateTime timestamp;
  final OrderStatus status;
  final String paymentMethod;
  final String orderId;

  OrderModel({
    required this.id,
    required this.businessName,
    required this.productName,
    required this.productSubtitle,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.timestamp,
    this.status = OrderStatus.pending,
    required this.paymentMethod,
    required this.orderId,
  });
}
