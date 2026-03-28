class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String type; // e.g., 'Rent', 'Sale', 'PG'
  final String propertyType; // e.g., 'Apartment', 'Villa', 'Commercial'
  final double price;
  final String location; // Detailed address
  final String city;
  final int bedrooms;
  final int bathrooms;
  final double areaSqFt;
  final List<String> imageUrls;
  final DateTime createdAt;
  final bool isVerified;
  final bool isZeroBrokerage;
  final int? builtIn;
  final double? lotSizeSqFt;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.propertyType,
    required this.price,
    required this.location,
    required this.city,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqFt,
    required this.imageUrls,
    required this.createdAt,
    this.isVerified = false,
    this.isZeroBrokerage = false,
    this.builtIn,
    this.lotSizeSqFt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'type': type,
      'propertyType': propertyType,
      'price': price,
      'location': location,
      'city': city,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaSqFt': areaSqFt,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'isZeroBrokerage': isZeroBrokerage,
      'builtIn': builtIn,
      'lotSizeSqFt': lotSizeSqFt,
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PropertyModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      propertyType: map['propertyType'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      bedrooms: map['bedrooms']?.toInt() ?? 0,
      bathrooms: map['bathrooms']?.toInt() ?? 0,
      areaSqFt: (map['areaSqFt'] ?? 0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      isZeroBrokerage: map['isZeroBrokerage'] ?? false,
      builtIn: map['builtIn']?.toInt(),
      lotSizeSqFt: map['lotSizeSqFt']?.toDouble(),
    );
  }
}
