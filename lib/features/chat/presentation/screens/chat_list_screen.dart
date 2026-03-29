import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.messagesLabel, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return Center(child: Text(l10n.pleaseLoginToViewMessages));
          
          final chatsAsync = ref.watch(userChatsProvider(user.uid));

          return chatsAsync.when(
            data: (chats) {
              if (chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: context.secondaryTextColor.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(l10n.noConversationsYet, style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: chats.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final otherId = chat.getOtherMemberId(user.uid);
                  final otherUserAsync = ref.watch(userProfileProvider(otherId));

                  return otherUserAsync.when(
                    data: (otherUser) => InkWell(
                      onTap: () => context.push('/chats/${chat.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              child: Text(otherUser?.name?.substring(0, 1).toUpperCase() ?? '?', 
                                         style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(otherUser?.name ?? l10n.unknownUser, 
                                           style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.primaryTextColor)),
                                      Text(timeago.format(chat.lastMessageTime), 
                                           style: TextStyle(color: context.secondaryTextColor, fontSize: 10)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat.lastMessageSenderId == user.uid ? '${l10n.youLabel}${chat.lastMessage}' : chat.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.secondaryTextColor, 
                                      fontSize: 13,
                                      fontWeight: chat.lastMessageSenderId != user.uid ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loading: () => const ListTile(leading: CircleAvatar(), title: Text('Loading...')),
                    error: (e, st) => const SizedBox(),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
