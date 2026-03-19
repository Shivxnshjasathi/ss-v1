class UserModel {
  final String id;
  final String phoneNumber;
  final String role; // seeker, owner, partner, admin
  final String? name;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.role,
    this.name,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'seeker',
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'role': role,
      'name': name,
      'profileImageUrl': profileImageUrl,
    };
  }
}
