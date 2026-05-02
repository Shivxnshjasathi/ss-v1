import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/features/chat/domain/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isUploading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final user = ref.read(currentUserDataProvider).value;
        if (user == null) return;

        final file = File(image.path);
        final fileName = 'chat_${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final refStorage = FirebaseStorage.instance.ref().child(fileName);
        
        await refStorage.putFile(file);
        final url = await refStorage.getDownloadURL();

        final message = MessageModel(
          id: '',
          senderId: user.uid,
          text: 'Shared a photo',
          imageUrl: url,
          type: MessageType.image,
          timestamp: DateTime.now(),
        );

        await ref.read(chatRepositoryProvider).sendMessage(widget.chatId, message);
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    final message = MessageModel(
      id: '',
      senderId: user.uid,
      text: text,
      timestamp: DateTime.now(),
    );

    _messageController.clear();
    await ref.read(chatRepositoryProvider).sendMessage(widget.chatId, message);

    _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final chatAsync = ref.watch(userChatsProvider(userAsync.value?.uid ?? ''));

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: chatAsync.when(
          data: (chats) {
            final chat = chats.firstWhere((c) => c.id == widget.chatId, orElse: () => chats.first);
            final otherId = chat.getOtherMemberId(userAsync.value?.uid ?? '');
            final otherUserAsync = ref.watch(userProfileProvider(otherId));

            return otherUserAsync.when(
              data: (otherUser) => Row(
                children: [
                  CircleAvatar(
                    radius: 18.w,
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    child: Text(otherUser?.name?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(otherUser?.name ?? 'User',
                        style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900, fontSize: 15.sp)),
                      Text('Online', style: TextStyle(color: Colors.green, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              loading: () => Text('Chat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
              error: (_, st) => Text('Chat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
            );
          },
          loading: () => Text('Chat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
          error: (_, st) => Text('Chat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
        ),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please log in'));

          return Column(
            children: [
              chatAsync.when(
                data: (chats) {
                  final chat = chats.firstWhere((c) => c.id == widget.chatId, orElse: () => chats.first);
                  return _ContextCard(metadata: chat.metadata);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, st) => const SizedBox.shrink(),
              ),
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.messageSquare, size: 48.w, color: context.secondaryTextColor.withValues(alpha: 0.1)),
                            SizedBox(height: 16.h),
                            Text('Say hello!', style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == user.uid;
                        
                        // Ephemeral Logic: Mark as seen if it's an image from other person
                        if (!isMe && message.type == MessageType.image && !message.isSeen) {
                          ref.read(chatRepositoryProvider).markMessageAsSeen(widget.chatId, message.id);
                        }

                        return _MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ),
              SafeArea(child: _buildInputArea(context)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h, top: 12.h),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        border: Border(top: BorderSide(color: context.borderColor, width: 0.5.w)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _pickAndSendImage,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: _isUploading 
                ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2))
                : Icon(LucideIcons.plus, color: AppTheme.primaryBlue, size: 18.w),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                style: TextStyle(color: context.primaryTextColor, fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: context.secondaryTextColor.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
              child: Icon(LucideIcons.send, color: Colors.white, size: 18.w),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isImage = message.type == MessageType.image;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: isImage ? EdgeInsets.all(4.w) : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryBlue : (context.isDarkMode ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.w),
            topRight: Radius.circular(20.w),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.w),
                child: CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  placeholder: (context, url) => Container(height: 200.h, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Text(message.text, style: TextStyle(color: isMe ? Colors.white : context.primaryTextColor, fontSize: 14.sp, fontWeight: FontWeight.w500)),
            
            Padding(
              padding: EdgeInsets.only(top: 4.h, left: 8.w, right: 8.w, bottom: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(timeago.format(message.timestamp), 
                    style: TextStyle(color: isMe ? Colors.white.withValues(alpha: 0.7) : context.secondaryTextColor, fontSize: 8.sp)),
                  if (isImage) ...[
                    SizedBox(width: 8.w),
                    Icon(LucideIcons.clock, size: 10.sp, color: isMe ? Colors.white70 : Colors.grey),
                    SizedBox(width: 4.w),
                    Text('Expires 24h after seen', style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCard extends ConsumerWidget {
  final Map<String, dynamic> metadata;
  const _ContextCard({required this.metadata});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (metadata.isEmpty) return const SizedBox.shrink();

    final propertyId = metadata['propertyId'];
    final type = metadata['type'];
    final category = metadata['category'];

    if (propertyId != null) {
      final propertyAsync = ref.watch(propertyProvider(propertyId));
      return propertyAsync.when(
        data: (property) {
          if (property == null) return const SizedBox.shrink();
          return Container(
            margin: EdgeInsets.all(12.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.w),
                  child:
                      property.imageUrls.isNotEmpty &&
                          property.imageUrls.first.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: property.imageUrls.first,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              LucideIcons.imageOff,
                              color: Colors.grey,
                              size: 20.w,
                            ),
                          ),
                        )
                      : Container(
                          width: 60.w,
                          height: 60.h,
                          color: Colors.grey[200],
                          child: Icon(
                            LucideIcons.image,
                            color: Colors.grey,
                            size: 20.w,
                          ),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: context.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '₹${property.price.toInt()}',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/properties/${property.id}');
                  },
                  child: Text('View', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, st) => const SizedBox.shrink(),
      );
    }

    if (type == 'service') {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.info, color: AppTheme.primaryBlue, size: 18.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Inquiry regarding: $category',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
