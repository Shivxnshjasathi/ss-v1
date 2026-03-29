class ChatModel {
  final String id;
  final List<String> memberIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, dynamic> metadata; // e.g., {'propertyId': '...'}

  ChatModel({
    required this.id,
    required this.memberIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberIds': memberIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'metadata': metadata,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatModel(
      id: docId,
      memberIds: List<String>.from(map['memberIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null ? DateTime.parse(map['lastMessageTime']) : DateTime.now(),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  String getOtherMemberId(String myId) {
    return memberIds.firstWhere((id) => id != myId, orElse: () => '');
  }
}
