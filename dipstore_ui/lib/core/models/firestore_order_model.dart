import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,    // Order placed, awaiting payment
  paid,       // Payment received
  completed,  // Order fulfilled
  cancelled,  // Customer or shop cancelled
  refunded,   // Refund issued
}

/// Persistent order record stored in Firestore
class FirestoreOrderModel {
  final String id;
  final String customerId;
  final String shopId;
  final List<OrderItemModel> items;
  final double subtotal;          // Before tax/fees
  final double taxAmount;         // Tax (usually 5%)
  final double platformFee;       // Platform commission
  final double total;             // Final amount paid
  final OrderStatus status;
  final String paymentMethod;     // 'fib', 'nass', 'card', etc.
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  FirestoreOrderModel({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.platformFee,
    required this.total,
    this.status = OrderStatus.pending,
    required this.paymentMethod,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  factory FirestoreOrderModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirestoreOrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      shopId: data['shopId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromMap(item))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0.0).toDouble(),
      platformFee: (data['platformFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.byName(data['status'] ?? 'pending'),
      paymentMethod: data['paymentMethod'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'shopId': shopId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'platformFee': platformFee,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
    };
  }
}

/// Single item in an order
class OrderItemModel {
  final String productId;
  final String productName;
  final String productBrand;
  final double priceAtPurchase;   // Historical price (might differ from current)
  final int quantity;
  final String? productImageUrl;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productBrand,
    required this.priceAtPurchase,
    required this.quantity,
    this.productImageUrl,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productBrand: data['productBrand'] ?? '',
      priceAtPurchase: (data['priceAtPurchase'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      productImageUrl: data['productImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productBrand': productBrand,
      'priceAtPurchase': priceAtPurchase,
      'quantity': quantity,
      'productImageUrl': productImageUrl,
    };
  }

  double getLineTotal() => priceAtPurchase * quantity;
}
