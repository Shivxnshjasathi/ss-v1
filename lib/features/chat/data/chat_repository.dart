import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_model.dart';
import '../domain/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

final userChatsProvider = StreamProvider.family<List<ChatModel>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).streamUserChats(userId);
});

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).streamMessages(chatId);
});

final chatProvider = StreamProvider.family<ChatModel?, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).streamChat(chatId);
});

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromMap(doc.data(), doc.id)).toList();
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    });
  }

  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs.map((doc) {
        final message = MessageModel.fromMap(doc.data(), doc.id);
        
        // Ephemeral Photo Auto-Delete Logic
        if (message.type == MessageType.image && message.isSeen && message.seenAt != null) {
          final expirationTime = message.seenAt!.add(const Duration(hours: 24));
          if (now.isAfter(expirationTime)) {
            doc.reference.delete(); // Delete from Firestore
          }
        }
        
        return message;
      }).toList();
    });
  }

  Future<void> markMessageAsSeen(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isSeen': true,
      'seenAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<ChatModel?> streamChat(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? ChatModel.fromMap(doc.data()!, doc.id) : null);
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    final batch = _firestore.batch();
    
    // 1. Add message to sub-collection
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(messageRef, message.toMap());

    // 2. Update chat metadata
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp.toIso8601String(),
      'lastMessageSenderId': message.senderId,
    });

    await batch.commit();
  }

  Future<String> startOrGetChat(String myId, String otherId, {Map<String, dynamic>? metadata}) async {
    // 1. Check if chat already exists
    final query = await _firestore
        .collection('chats')
        .where('memberIds', arrayContains: myId)
        .get();

    for (var doc in query.docs) {
      final members = List<String>.from(doc['memberIds']);
      if (members.contains(otherId)) {
        // Update metadata if provided to keep it fresh
        if (metadata != null) {
          await doc.reference.update({'metadata': metadata});
        }
        return doc.id;
      }
    }

    // 2. Create new chat if not found
    final newChatDoc = _firestore.collection('chats').doc();
    final chat = ChatModel(
      id: newChatDoc.id,
      memberIds: [myId, otherId],
      lastMessage: 'Chat Started',
      lastMessageTime: DateTime.now(),
      lastMessageSenderId: '',
      metadata: metadata ?? {},
    );

    await newChatDoc.set(chat.toMap());
    return newChatDoc.id;
  }
}
