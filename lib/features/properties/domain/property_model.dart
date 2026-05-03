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
  final List<String> amenities;
  final DateTime createdAt;
  final bool isVerified;
  final bool isZeroBrokerage;
  final int? builtIn;
  final double? lotSizeSqFt;
  final double? latitude;
  final double? longitude;
  final String? street;
  final String? areaName;
  final String? videoUrl;
  final String? panoramaUrl;
  final Map<String, String>? vaultDocuments;

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
    this.amenities = const [],
    required this.createdAt,
    this.isVerified = false,
    this.isZeroBrokerage = false,
    this.builtIn,
    this.lotSizeSqFt,
    this.latitude,
    this.longitude,
    this.street,
    this.areaName,
    this.videoUrl,
    this.panoramaUrl,
    this.vaultDocuments,
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
      'amenities': amenities,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'isZeroBrokerage': isZeroBrokerage,
      'builtIn': builtIn,
      'lotSizeSqFt': lotSizeSqFt,
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'areaName': areaName,
      'videoUrl': videoUrl,
      'panoramaUrl': panoramaUrl,
      'vaultDocuments': vaultDocuments,
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
      amenities: List<String>.from(map['amenities'] ?? []),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      isZeroBrokerage: map['isZeroBrokerage'] ?? false,
      builtIn: map['builtIn']?.toInt(),
      lotSizeSqFt: map['lotSizeSqFt']?.toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      street: map['street'],
      areaName: map['areaName'],
      videoUrl: map['videoUrl'],
      panoramaUrl: map['panoramaUrl'],
      vaultDocuments: map['vaultDocuments'] != null ? Map<String, String>.from(map['vaultDocuments']) : null,
    );
  }
}
