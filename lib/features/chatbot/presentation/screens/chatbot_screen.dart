import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/services/google_cloud_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/features/chatbot/data/chatbot_repository.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text':
          'Welcome to Sampatti Bazar!\nI\'m your digital assistant.\nHow can I help you\nstreamline your real estate\njourney today?',
      'time': '09:00 AM',
    },
  ];

  bool _isTyping = false;

  // Track translated messages: index -> translated text
  final Map<int, String> _translatedMessages = {};
  final Map<int, bool> _showTranslation = {};

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': _getCurrentTime()});
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await ref
          .read(chatbotRepositoryProvider)
          .getResponse(text);
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text': response,
          'time': _getCurrentTime(),
        });
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text':
              "I'm sorry, I'm having bit of trouble connecting to our Sampatti systems. Please try again.",
          'time': _getCurrentTime(),
        });
      });
    }
  }

  Future<void> _translateMessage(int index) async {
    if (_translatedMessages.containsKey(index)) {
      // Already translated, just toggle visibility
      setState(() {
        _showTranslation[index] = !(_showTranslation[index] ?? false);
      });
      return;
    }

    final originalText = _messages[index]['text'] ?? '';
    // Detect: if it looks like Hindi (has Devanagari chars), translate to English. Otherwise translate to Hindi.
    final bool hasHindi = RegExp(r'[\u0900-\u097F]').hasMatch(originalText);
    final targetLang = hasHindi ? 'en' : 'hi';

    final translated = await GoogleCloudService.translateText(originalText, targetLang);
    if (mounted) {
      setState(() {
        _translatedMessages[index] = translated;
        _showTranslation[index] = true;
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    int hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.scaffoldColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.iconColor,
            size: 20.w,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Sampatti Bot',
          style: TextStyle(
            color: context.primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 24.0.w),
              child: Text(
                'Online',
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: 24.0.w,
                vertical: 16.0.h,
              ),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      _buildDateBadge(),
                      SizedBox(height: 24.h),
                      _buildChatBubble(_messages[index], index),
                    ],
                  );
                }

                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                return _buildChatBubble(_messages[index], index);
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(
        'TODAY',
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w900,
          color: context.primaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, int index) {
    final isUser = msg['role'] == 'user';
    final bool isTranslated = _showTranslation[index] ?? false;
    final String displayText = isTranslated
        ? (_translatedMessages[index] ?? msg['text'] ?? '')
        : (msg['text'] ?? '');

    return Padding(
      padding: EdgeInsets.only(bottom: 24.0.h),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppTheme.primaryBlue,
                size: 16.w,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0.w),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryBlue : context.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.w),
                      topRight: Radius.circular(16.w),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayText,
                        style: TextStyle(
                          color: isUser ? Colors.white : context.primaryTextColor,
                          fontSize: 13.sp,
                          height: 1.5.h,
                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (isTranslated)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.translate,
                                size: 10.w,
                                color: isUser ? Colors.white70 : Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Translated',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontStyle: FontStyle.italic,
                                  color: isUser ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg['time'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Translate button for every message
                    GestureDetector(
                      onTap: () => _translateMessage(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isTranslated
                              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                              : context.surfaceColor,
                          borderRadius: BorderRadius.circular(4.w),
                          border: Border.all(
                            color: isTranslated ? AppTheme.primaryBlue : context.borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.translate,
                              size: 10.w,
                              color: isTranslated ? AppTheme.primaryBlue : Colors.grey,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              isTranslated ? 'Original' : 'Translate',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: isTranslated ? AppTheme.primaryBlue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUser) SizedBox(width: 24.w),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0.h),
      child: Row(
        children: [
          Icon(Icons.more_horiz, color: Colors.grey, size: 24.w),
          SizedBox(width: 8.w),
          Text(
            'SAMPATTI BOT IS THINKING....',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1.h, color: context.borderColor),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), size: 14.w),
            ],
          ),
        ),
        SizedBox(
          height: 44.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            children: [
              _buildActionChip(Icons.calculate_outlined, 'EMI Calculator'),
              SizedBox(width: 12.w),
              _buildActionChip(Icons.local_shipping_outlined, 'Track Mover'),
              SizedBox(width: 12.w),
              _buildActionChip(Icons.description_outlined, 'Schedule Visit'),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        _messageController.text = label;
        _sendMessage();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.w, color: AppTheme.primaryBlue),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11.sp,
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: context.primaryTextColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white, size: 18.w),
                      onPressed: _sendMessage,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gemini Powered Intelligence • Cloud Translation • Secure Encryption',
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
