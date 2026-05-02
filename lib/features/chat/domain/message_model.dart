enum MessageType { text, image }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final bool isSeen;
  final DateTime? seenAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.isSeen = false,
    this.seenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'imageUrl': imageUrl,
      'isSeen': isSeen,
      'seenAt': seenAt?.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      type: MessageType.values.byName(map['type'] ?? 'text'),
      imageUrl: map['imageUrl'],
      isSeen: map['isSeen'] ?? false,
      seenAt: map['seenAt'] != null ? DateTime.parse(map['seenAt']) : null,
    );
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageType? type,
    String? imageUrl,
    bool? isSeen,
    DateTime? seenAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isSeen: isSeen ?? this.isSeen,
      seenAt: seenAt ?? this.seenAt,
    );
  }
}
