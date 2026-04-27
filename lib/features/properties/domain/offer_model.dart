import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String propertyId;
  final String buyerId;
  final String ownerId;
  final double amount;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    required this.ownerId,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'buyerId': buyerId,
      'ownerId': ownerId,
      'amount': amount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map, String id) {
    return OfferModel(
      id: id,
      propertyId: map['propertyId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
