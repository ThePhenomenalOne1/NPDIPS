import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String name;
  final String ownerId;         // ✨ NEW: ShopOwner user ID
  final String category;
  final String tagline;
  final String about;
  final String? imageUrl;
  final String? phoneNumber;
  final bool isFeatured;
  final String status;          // 'active', 'suspended', 'pending_approval'
  final double commissionRate;  // Platform commission (e.g., 0.10 = 10%)
  final DateTime createdAt;
  final DateTime? approvedAt;

  StoreModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.category,
    required this.tagline,
    required this.about,
    this.imageUrl,
    this.phoneNumber,
    this.isFeatured = false,
    this.status = 'active',
    this.commissionRate = 0.10,
    required this.createdAt,
    this.approvedAt,
  });

  factory StoreModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      category: data['category'] ?? '',
      tagline: data['tagline'] ?? '',
      about: data['about'] ?? '',
      imageUrl: data['imageUrl'],
      phoneNumber: data['phoneNumber'],
      isFeatured: data['isFeatured'] ?? false,
      status: data['status'] ?? 'active',
      commissionRate: (data['commissionRate'] ?? 0.10).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'category': category,
      'tagline': tagline,
      'about': about,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'isFeatured': isFeatured,
      'status': status,
      'commissionRate': commissionRate,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }
}
