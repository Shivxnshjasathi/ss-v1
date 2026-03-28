//// Booking model for property visits
class BookingModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String? propertyImageUrl;
  final String buyerId;
  final String ownerId;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    this.propertyImageUrl,
    required this.buyerId,
    required this.ownerId,
    required this.bookingDate,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'propertyLocation': propertyLocation,
      'propertyImageUrl': propertyImageUrl,
      'buyerId': buyerId,
      'ownerId': ownerId,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      propertyId: map['propertyId'] ?? '',
      propertyTitle: map['propertyTitle'] ?? '',
      propertyLocation: map['propertyLocation'] ?? '',
      propertyImageUrl: map['propertyImageUrl'],
      buyerId: map['buyerId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      bookingDate: DateTime.parse(map['bookingDate']),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
