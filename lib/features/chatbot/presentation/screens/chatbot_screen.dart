import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/services/google_cloud_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/features/chatbot/data/chatbot_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
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
  bool _contextInjected = false;

  // Track translated messages: index -> translated text
  final Map<int, String> _translatedMessages = {};
  final Map<int, bool> _showTranslation = {};

  @override
  void initState() {
    super.initState();
    // Inject context after first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _injectAppContext());
  }

  Future<void> _injectAppContext() async {
    if (_contextInjected) return;
    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) return;

      // Fetch user's own listed properties (max 5 for context)
      final propertiesAsync = ref.read(propertiesByOwnerProvider(user.uid));
      final myProperties = propertiesAsync.value ?? [];

      ref.read(chatbotRepositoryProvider).injectContext(
        user: user,
        myProperties: myProperties,
      );
      _contextInjected = true;

      // Update the greeting with the user's name
      if (mounted && user.name != null && user.name!.isNotEmpty) {
        setState(() {
          _messages[0]['text'] =
              'Namaste, ${user.name!.split(' ').first}! 🙏\nI\'m your Sampatti Bot — your personal real estate advisor.\nAsk me anything about properties, loans, legal docs, or movers!'
              '${myProperties.isNotEmpty ? '\n\nI can see you have ${myProperties.length} listed propert${myProperties.length == 1 ? "y" : "ies"} — ask me about them anytime.' : ''}';
        });
      }
    } catch (e) {
      // Context injection is best-effort; chat still works without it
    }
  }

  void _clearChat() {
    ref.read(chatbotRepositoryProvider).clearHistory();
    setState(() {
      _messages
        ..clear()
        ..add({
          'role': 'ai',
          'text': 'New conversation started!\nHow can I help you today?',
          'time': _getCurrentTime(),
        });
      _translatedMessages.clear();
      _showTranslation.clear();
      _contextInjected = false;
    });
    // Re-inject context for the fresh session
    _injectAppContext();
  }

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

    final user = ref.read(currentUserDataProvider).value;
    final repo = ref.read(chatbotRepositoryProvider);

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': _getCurrentTime()});
      FirebaseAnalytics.instance.logEvent(
      name: 'chatbot_message_sent',
      parameters: {'message_length': text.length},
    );

    _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Persist to Firebase if user is logged in
    if (user != null) {
      repo.saveMessage(userId: user.uid, text: text, role: 'user');
    }

    try {
      final response = await repo.getResponse(text);
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'ai',
          'text': response.text.trim(),
          'data': response.data,
          'dataType': response.dataType,
          'time': _getCurrentTime(),
        });
      });
      _scrollToBottom();

      // Persist AI response to Firebase
      if (user != null) {
        repo.saveMessage(userId: user.uid, text: response.text, role: 'ai');
      }
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
    FirebaseAnalytics.instance.logEvent(
      name: 'chatbot_translate_message',
      parameters: {'message_index': index},
    );

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sampatti Bot',
              style: TextStyle(
                color: context.primaryTextColor,
                fontWeight: FontWeight.w900,
                fontSize: 18.sp,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Text('Gemini 2.5 • Active', style: TextStyle(color: Colors.green, fontSize: 10.sp, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined, color: context.iconColor, size: 20.w),
            tooltip: 'New Chat',
            onPressed: _clearChat,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.scaffoldColor,
              context.scaffoldColor.withValues(alpha: 0.95),
              context.scaffoldColor.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildChatBubble(_messages[index], index);
                },
              ),
            ),
            _buildInputArea(),
          ],
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

    if (!isUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIMessage(displayText, msg['time'] ?? '', index, isTranslated),
          if (msg['data'] != null) _buildDataContent(msg['data'], msg['dataType']),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 24.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGradientStart, AppTheme.primaryGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.w),
                  topRight: Radius.circular(20.w),
                  bottomLeft: Radius.circular(20.w),
                  bottomRight: Radius.circular(4.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                displayText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text, String time, int index, bool isTranslated) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 12.w),
              ),
              SizedBox(width: 8.w),
              Text(
                'Sampatti Bot',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: context.primaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _buildTranslateButton(index, isTranslated),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 32.w, top: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: text.trim(),
                  shrinkWrap: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: context.primaryTextColor.withValues(alpha: 0.9),
                      fontSize: 13.5.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    strong: const TextStyle(fontWeight: FontWeight.bold),
                    em: const TextStyle(fontStyle: FontStyle.italic),
                    listBullet: TextStyle(color: AppTheme.primaryBlue, fontSize: 13.5.sp),
                    pPadding: EdgeInsets.zero,
                  ),
                ),
                if (isTranslated)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      '• Translated from original',
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) {
      return 'Contact for price';
    }
    double p = 0;
    if (price is String) {
      p = double.tryParse(price) ?? 0;
    } else if (price is num) {
      p = price.toDouble();
    }
    
    if (p >= 10000000) return '${(p / 10000000).toStringAsFixed(1)} Cr';
    if (p >= 100000) return '${(p / 100000).toStringAsFixed(1)} L';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(1)} K';
    return p.toStringAsFixed(0);
  }

  Widget _buildTranslateButton(int index, bool isTranslated) {
    return GestureDetector(
      onTap: () => _translateMessage(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.translate, size: 10.w, color: Colors.grey),
            SizedBox(width: 4.w),
            Text(
              isTranslated ? 'Original' : 'Translate',
              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent(List<dynamic> data, String? type) {
    if (type == 'property') {
      return Container(
        height: 180.h,
        margin: EdgeInsets.only(left: 36.w, bottom: 24.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index] as Map<String, dynamic>;
            return Container(
              width: 140.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
                    child: Container(
                      height: 80.h,
                      width: double.infinity,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      child: item['images'] != null && (item['images'] as List).isNotEmpty
                          ? Image.network(
                              (item['images'] as List).first,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Icon(Icons.home_outlined, color: AppTheme.primaryBlue, size: 30.w),
                            )
                          : Icon(Icons.home_outlined, color: AppTheme.primaryBlue, size: 30.w),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? 'Property',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '₹${_formatPrice(item['price'])}',
                              style: TextStyle(fontSize: 10.sp, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            if (item['id'] != null) {
                              FirebaseAnalytics.instance.logEvent(
                                name: 'chatbot_property_viewed',
                                parameters: {
                                  'property_id': item['id'],
                                  'property_title': item['title'] ?? 'Unknown',
                                },
                              );
                              context.push('/properties/detail/${item['id']}');
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            alignment: Alignment.center,
                            child: Text('VIEW', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (type == 'service') {
      return Column(
        children: data.map((s) {
          final item = s as Map<String, dynamic>;
          return Container(
            margin: EdgeInsets.only(left: 36.w, bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  child: const Icon(Icons.build_circle_outlined, color: Colors.orange),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['serviceType'] ?? 'Service Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                      Text('Status: ${item['status'] ?? 'Pending'}', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12.w, color: Colors.grey),
              ],
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0.h, left: 8.w),
      child: Row(
        children: [
          SizedBox(
            width: 12.w,
            height: 12.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue.withValues(alpha: 0.5)),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'TYPING...',
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

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickActions(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(30.w),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Ask Sampatti Bot...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryGradientStart, AppTheme.primaryGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_upward, color: Colors.white, size: 20.w),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Powered by Gemini 2.5 • Official AI Advisor',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withValues(alpha: 0.7),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final user = ref.watch(currentUserDataProvider).value;
    final city = user?.location ?? 'Indore';

    final chips = [
      (Icons.search, 'Search properties in $city'),
      (Icons.assignment_outlined, 'Track my services'),
      (Icons.calendar_today, 'My bookings'),
      (Icons.account_balance_wallet_outlined, 'Check loan status'),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: SizedBox(
        height: 36.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: chips.map((c) {
            return GestureDetector(
              onTap: () {
                FirebaseAnalytics.instance.logEvent(
                  name: 'chatbot_quick_action_clicked',
                  parameters: {'action_label': c.$2},
                );
                _messageController.text = c.$2;
                _sendMessage();
              },
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                  border: Border.all(color: context.borderColor),
                  color: context.cardColor.withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(c.$1, size: 14.w, color: AppTheme.primaryBlue),
                    SizedBox(width: 6.w),
                    Text(
                      c.$2,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: context.secondaryTextColor),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
