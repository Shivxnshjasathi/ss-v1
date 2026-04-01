class UserModel {
  final String uid;
  final String phoneNumber;
  final String email;
  final String? name;
  final String? location;
  final String? role;
  final DateTime createdAt;
  
  // Rating/Trust Score fields
  final double? trustScore;
  final int? totalDeals;
  final int? ratingCount;

  // Mortgage Pre-Approval fields
  final bool? isPreApproved;
  final double? preApprovalAmount;
  final int? cibilScore;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.email,
    this.name,
    this.location,
    this.role,
    required this.createdAt,
    this.trustScore,
    this.totalDeals,
    this.ratingCount,
    this.isPreApproved,
    this.preApprovalAmount,
    this.cibilScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
      'name': name,
      'location': location,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'trustScore': trustScore,
      'totalDeals': totalDeals,
      'ratingCount': ratingCount,
      'isPreApproved': isPreApproved,
      'preApprovalAmount': preApprovalAmount,
      'cibilScore': cibilScore,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      location: map['location'],
      role: map['role'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      trustScore: (map['trustScore'] as num?)?.toDouble(),
      totalDeals: map['totalDeals'] as int?,
      ratingCount: map['ratingCount'] as int?,
      isPreApproved: map['isPreApproved'] as bool?,
      preApprovalAmount: (map['preApprovalAmount'] as num?)?.toDouble(),
      cibilScore: map['cibilScore'] as int?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? email,
    String? name,
    String? location,
    String? role,
    DateTime? createdAt,
    double? trustScore,
    int? totalDeals,
    int? ratingCount,
    bool? isPreApproved,
    double? preApprovalAmount,
    int? cibilScore,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      name: name ?? this.name,
      location: location ?? this.location,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      trustScore: trustScore ?? this.trustScore,
      totalDeals: totalDeals ?? this.totalDeals,
      ratingCount: ratingCount ?? this.ratingCount,
      isPreApproved: isPreApproved ?? this.isPreApproved,
      preApprovalAmount: preApprovalAmount ?? this.preApprovalAmount,
      cibilScore: cibilScore ?? this.cibilScore,
    );
  }
}
