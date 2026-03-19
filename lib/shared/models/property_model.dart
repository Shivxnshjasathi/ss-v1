class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price; // Rent or Sale price
  final String propertyType; // Flat, Villa, Plot, PG
  final String transactionType; // Rent, Sale
  final int bhk;
  final String furnishing; // Fully, Semi, Unfurnished
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final String address;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.propertyType,
    required this.transactionType,
    required this.bhk,
    required this.furnishing,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json, String id) {
    return PropertyModel(
      id: id,
      ownerId: json['ownerId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      propertyType: json['propertyType'] ?? 'Flat',
      transactionType: json['transactionType'] ?? 'Rent',
      bhk: json['bhk'] ?? 1,
      furnishing: json['furnishing'] ?? 'Unfurnished',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'propertyType': propertyType,
      'transactionType': transactionType,
      'bhk': bhk,
      'furnishing': furnishing,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
