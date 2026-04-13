import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userContact;
  final String category; // 'Construction', 'Legal', 'SiteVisit'
  final String status;   // 'Pending', 'Accepted', 'Completed'
  final Map<String, dynamic> details; // JSON bag for dynamic form fields
  final DateTime createdAt;
  final String? location; // Optional city for filtering (e.g. for Builder Agents)
  final String? city;
  final String? state;
  final String? zipCode;
  final String? fullAddress;
  final String? targetProviderId; // Optional if targeting a specific agent/provider
  final String? tenantEmail; // NEW: To link the request to the tenant's email
  final String? tenantId; // NEW: To link to the tenant's UID if they already exist

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userContact,
    required this.category,
    required this.status,
    required this.details,
    required this.createdAt,
    this.location,
    this.city,
    this.state,
    this.zipCode,
    this.fullAddress,
    this.targetProviderId,
    this.tenantEmail,
    this.tenantId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userContact': userContact,
      'category': category,
      'status': status,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'fullAddress': fullAddress,
      'targetProviderId': targetProviderId,
      'tenantEmail': tenantEmail,
      'tenantId': tenantId,
    };
  }

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceRequestModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      userContact: map['userContact'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'Pending',
      details: map['details'] ?? {},
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      location: map['location'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      fullAddress: map['fullAddress'],
      targetProviderId: map['targetProviderId'],
      tenantEmail: map['tenantEmail'],
      tenantId: map['tenantId'],
    );
  }

  ServiceRequestModel copyWith({
    String? status,
    String? tenantId,
    String? tenantEmail,
  }) {
    return ServiceRequestModel(
      id: id,
      userId: userId,
      userName: userName,
      userContact: userContact,
      category: category,
      status: status ?? this.status,
      details: details,
      createdAt: createdAt,
      location: location,
      city: city,
      state: state,
      zipCode: zipCode,
      fullAddress: fullAddress,
      targetProviderId: targetProviderId,
      tenantEmail: tenantEmail ?? this.tenantEmail,
      tenantId: tenantId ?? this.tenantId,
    );
  }
}
