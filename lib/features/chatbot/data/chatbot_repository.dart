import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/auth/domain/user_model.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final chatbotRepositoryProvider = Provider((ref) => ChatbotRepository());

class ChatbotResponse {
  final String text;
  final List<dynamic>? data;
  final String? dataType;

  ChatbotResponse({required this.text, this.data, this.dataType});
}

class ChatbotRepository {
  late TemplateGenerativeModel _model;
  TemplateChatSession? _chat;
  Map<String, dynamic> _templateVariables = {};

  // Tool definitions specifically for Server-Side Templates
  final List<TemplateTool> _tools = [
    TemplateTool.functionDeclarations(
      [
        TemplateFunctionDeclaration(
          'get_user_bookings',
          parameters: {
            'userId': JSONSchema.string(description: 'Optional user ID.'),
          },
        ),
        TemplateFunctionDeclaration(
          'get_service_requests',
          parameters: {
            'userId': JSONSchema.string(description: 'Optional user ID.'),
          },
        ),
        TemplateFunctionDeclaration(
          'query_live_database',
          parameters: {
            'city': JSONSchema.string(description: 'Filter by city name.'),
            'type': JSONSchema.string(description: 'Property type (e.g. Apartment, Villa).'),
            'maxPrice': JSONSchema.number(description: 'Maximum price in Rupees.'),
          },
          optionalParameters: ['city', 'type', 'maxPrice'],
        ),
      ],
    ),
  ];

  ChatbotRepository() {
    _initModel(contextMap: null);
  }

  void _initModel({Map<String, dynamic>? contextMap}) {
    LoggerService.i('ChatbotRepository: Initialising via Firebase AI Server Template');
    
    final ai = FirebaseAI.vertexAI(auth: FirebaseAuth.instance); 
    
    _model = ai.templateGenerativeModel();
    _templateVariables = contextMap ?? {};
    
    _chat = _model.startChat(
      "sampatti-bot-template",
      inputs: _templateVariables,
      tools: _tools,
    );
  }

  // ── Database Context Management ─────────────────────────────────────────────
  // Called from the screen to inject live user + property data ──────────────

  void injectContext({UserModel? user, List<PropertyModel>? myProperties}) {
    // We MUST provide defaults for all keys defined in the Firebase Console Schema
    // to avoid "malformed input" errors if values are null.
    final Map<String, dynamic> context = {
      'userName': user?.name ?? "User",
      'userCity': user?.location ?? "Unknown",
      'userRole': user?.role ?? "Buyer/Renter",
      'isPreApproved': user?.isPreApproved ?? false,
      'properties': [], 
    };

    if (myProperties != null && myProperties.isNotEmpty) {
      context['properties'] = myProperties.take(5).map((p) => {
        'title': p.title,
        'price': _formatPrice(p.price),
      }).toList();
    }

    LoggerService.i('ChatbotRepository: Injecting verified database context map');
    _templateVariables = context;
    _initModel(contextMap: context);
  }

  String _formatPrice(double price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(1)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} L';
    return price.toStringAsFixed(0);
  }

  // ── Core send message ────────────────────────────────────────────────────────

  Future<ChatbotResponse> getResponse(String message) async {
    LoggerService.i('Chatbot: → $message');
    
    List<dynamic>? capturedData;
    String? capturedType;
    
    try {
      // Inputs are handled by the session initialized in _initModel
      var response = await _chat!.sendMessage(Content.text(message));
      
      // Safety check: Ensure we have candidates before processing
      if (response.candidates.isEmpty) {
        LoggerService.w('Chatbot: AI returned no candidates.');
        return ChatbotResponse(text: "I'm sorry, I'm having trouble processing that. Could you try again?");
      }

      // ── Handle Function Calling Loop ───────────────────────────────────────
      while (response.candidates.isNotEmpty && 
             response.candidates.first.content.parts.any((p) => p is FunctionCall)) {
        final parts = response.candidates.first.content.parts;
        final functionCalls = parts.whereType<FunctionCall>();
        
        final responses = <FunctionResponse>[];
        
        for (final call in functionCalls) {
          LoggerService.i('Chatbot: Database Query → ${call.name}(${call.args})');
          final result = await _executeFunction(call.name, call.args);
          
          // Store the raw data for the UI to display as cards
          if (result.containsKey('properties')) {
            capturedData = result['properties'];
            capturedType = 'property';
          } else if (result.containsKey('requests')) {
            capturedData = result['requests'];
            capturedType = 'service';
          } else if (result.containsKey('bookings')) {
            capturedData = result['bookings'];
            capturedType = 'booking';
          }
          
          responses.add(FunctionResponse(call.name, result));
        }
        
        // Send the database results back to the model
        response = await _chat!.sendMessage(Content.functionResponses(responses));
      }

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        LoggerService.w('Chatbot: Empty response from Gemini');
        return ChatbotResponse(text: "I didn't get a response. Could you rephrase that?");
      }

      LoggerService.i('Chatbot: ← (${text.length} chars)');
      return ChatbotResponse(
        text: text.trim(),
        data: capturedData,
        dataType: capturedType,
      );
    } catch (e, stack) {
      LoggerService.e('Chatbot Error', error: e, stack: stack);
      _chat = null;
      return ChatbotResponse(text: "I'm having trouble connecting right now. Please try again in a moment!");
    }
  }

  /// Clear conversation history (e.g. when user taps "New Chat")
  void clearHistory() {
    _chat = null;
    LoggerService.i('Chatbot: Conversation history cleared');
  }

  // ── Firestore Persistence ──────────────────────────────────────────────────

  Future<void> saveMessage({
    required String userId,
    required String text,
    required String role,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ai_chats')
          .add({
        'text': text,
        'role': role,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerService.e('Failed to save AI message to Firestore', error: e);
    }
  }

  Stream<QuerySnapshot> getChatStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ai_chats')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ── Database Function Handlers ─────────────────────────────────────────────

  Future<Map<String, dynamic>> _executeFunction(String name, Map<String, dynamic> args) async {
    try {
      switch (name) {
        case 'get_user_bookings':
          final userId = args['userId'] as String;
          final snapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .get();
          return {
            'bookings': snapshot.docs.map((d) => d.data()).toList(),
            'count': snapshot.size,
          };

        case 'get_service_requests':
          final userId = args['userId'] as String;
          final snapshot = await FirebaseFirestore.instance
              .collection('service_requests')
              .where('userId', isEqualTo: userId)
              .get();
          return {
            'requests': snapshot.docs.map((d) => d.data()).toList(),
            'count': snapshot.size,
          };

        case 'query_live_database':
        case 'search_properties':
        case 'find_houses': // Handle all variations for compatibility
          String? city = args['city']?.toString();
          final type = args['type']?.toString();
          
          if (city != null && city.isNotEmpty) {
            city = city[0].toUpperCase() + city.substring(1).toLowerCase();
          }
          
          Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('properties');
          if (city != null && city != 'Unknown') query = query.where('city', isEqualTo: city);
          if (type != null) query = query.where('type', isEqualTo: type);
          
          final snapshot = await query.limit(10).get();
          
          if (snapshot.docs.isEmpty) {
            LoggerService.w('Chatbot: No matches for $city, returning global featured list');
            final fallback = await FirebaseFirestore.instance
                .collection('properties')
                .orderBy('createdAt', descending: true)
                .limit(6)
                .get();
            
            return {
              'properties': fallback.docs.map((d) => d.data()).toList(),
              'isFallback': true,
              'message': 'Showing featured Sampatti Bazar listings instead of $city.',
            };
          }

          return {
            'properties': snapshot.docs.map((d) => d.data()).toList(),
            'count': snapshot.size,
          };

        default:
          return {'error': 'Function not found'};
      }
    } catch (e) {
      LoggerService.e('Tool Execution Error', error: e);
      return {'error': e.toString()};
    }
  }
}
