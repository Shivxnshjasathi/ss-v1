
class DocumentModel {
  final String id;
  final String userId;
  final String name;
  final String url;
  final String type;
  final DateTime uploadedAt;

  DocumentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'url': url,
      'type': type,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? '',
      uploadedAt: map['uploadedAt'] != null 
          ? DateTime.parse(map['uploadedAt']) 
          : DateTime.now(),
    );
  }
}
