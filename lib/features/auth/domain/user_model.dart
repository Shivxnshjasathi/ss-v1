class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name;
  final String? location;
  final String? role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.location,
    this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'location': location,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'],
      location: map['location'],
      role: map['role'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? location,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      location: location ?? this.location,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
