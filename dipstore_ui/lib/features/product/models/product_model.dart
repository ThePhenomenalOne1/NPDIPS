import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String? description;
  final String? storeId; 
  final String? category; // Added category
  final bool isPopular;
  final bool isSellingFast;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    this.description,
    this.storeId,
    this.category,
    this.isPopular = false,
    this.isSellingFast = false,
    required this.createdAt,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'],
      storeId: data['storeId'],
      category: data['category'],
      isPopular: data['isPopular'] ?? false,
      isSellingFast: data['isSellingFast'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'storeId': storeId,
      'category': category,
      'isPopular': isPopular,
      'isSellingFast': isSellingFast,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
