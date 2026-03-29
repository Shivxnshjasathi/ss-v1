import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceItemModel {
  final String id;
  final String vendorId;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String status;
  final int sales;
  final String image;
  final DateTime createdAt;

  MarketplaceItemModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.status,
    required this.sales,
    required this.image,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'status': status,
      'sales': sales,
      'image': image,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MarketplaceItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return MarketplaceItemModel(
      id: docId,
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      status: map['status'] ?? 'In Stock',
      sales: map['sales']?.toInt() ?? 0,
      image: map['image'] ?? 'https://images.unsplash.com/photo-1590494056253-ab4fc64fbe3d?w=400&q=80',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  MarketplaceItemModel copyWith({
    String? status,
    int? sales,
  }) {
    return MarketplaceItemModel(
      id: id,
      vendorId: vendorId,
      name: name,
      category: category,
      price: price,
      unit: unit,
      status: status ?? this.status,
      sales: sales ?? this.sales,
      image: image,
      createdAt: createdAt,
    );
  }
}
