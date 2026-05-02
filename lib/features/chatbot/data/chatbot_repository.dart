import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/auth/domain/user_model.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';

final chatbotRepositoryProvider = Provider((ref) => ChatbotRepository());

class ChatbotRepository {
  static const String _apiKey = 'AIzaSyDxBbtJh5KO4cLgMTy652YU8cL-rRPbXB8';

  // gemini-2.0-flash: fast, smart, cheap — perfect for a chat assistant
  static const String _modelName = 'gemini-2.0-flash';

  late GenerativeModel _model;
  ChatSession? _chat;

  ChatbotRepository() {
    _initModel(contextPrompt: null);
  }

  void _initModel({String? contextPrompt}) {
    final systemPrompt = _buildSystemPrompt(contextPrompt);
    LoggerService.i('ChatbotRepository: Initialising $_modelName');
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(systemPrompt),
    );
    // Reset chat session so next message starts with new context
    _chat = null;
  }

  // ── Build a rich system prompt that includes live app context ───────────────

  String _buildSystemPrompt(String? liveContext) {
    const base = '''
You are "Sampatti Bot", the intelligent AI assistant for **Sampatti Bazar** — India's premium real estate ecosystem.

## Your Personality
- Professional, warm, and knowledgeable
- Speak naturally like a trusted real-estate advisor, not a robot
- Use simple English; also handle Hinglish queries gracefully
- Be concise (3-5 lines max unless a detailed breakdown is needed)
- Use bullet points only when listing multiple items

## Your Expertise
- 🏠 **Property**: Buying, selling, renting in India — pricing, localities, negotiations
- 🏗 **Construction**: Architecture, interior design, home-building, material sourcing
- ⚖️ **Legal**: Sale deeds, rental agreements, property verification, RERA
- 💰 **Finance**: Home loans, EMI calculation, CIBIL score, pre-approval
- 📦 **Packers & Movers**: Distance-based pricing, packing tips, tracking
- 🛒 **Marketplace**: Building materials, furniture, home décor

## Sampatti Bazar App Features You Can Guide Users To
- **Browse Properties** → property feed with filters
- **Add Property** → list your property in minutes with AI description
- **Document Vault** → upload and manage legal docs securely
- **Chat** → talk directly to agents/owners
- **Services Hub** → construction, legal, movers, marketplace, home loans
- **EMI Calculator** → financial planning tool
- **My Properties** → manage your listings
- **Agent Portal** → for builders and agents to manage leads

## Behaviour Rules
- If asked about a specific live price or listing, say you can check the app's feed
- Always offer to help further at the end of your response
- Never make up property prices or legal facts — say "consult a verified agent"
- If user says "navigate to X" or "open X", suggest how to find it in the app
''';

    if (liveContext == null || liveContext.isEmpty) return base;

    return '$base\n## Current User Context (from app)\n$liveContext\nUse this context to personalise your responses. E.g. greet the user by name, reference their city, mention their listed properties when relevant.';
  }

  // ── Called from the screen to inject live user + property data ──────────────

  void injectContext({UserModel? user, List<PropertyModel>? myProperties}) {
    final buffer = StringBuffer();

    if (user != null) {
      buffer.writeln('- User name: ${user.name ?? "Not set"}');
      buffer.writeln('- City / Location: ${user.location ?? "Not set"}');
      buffer.writeln('- Role: ${user.role ?? "Buyer/Renter"}');
      buffer.writeln('- Phone: ${user.phoneNumber}');
      if (user.cibilScore != null) {
        buffer.writeln('- CIBIL Score: ${user.cibilScore}');
      }
      if (user.isPreApproved == true && user.preApprovalAmount != null) {
        buffer.writeln('- Pre-approved loan amount: ₹${user.preApprovalAmount!.toStringAsFixed(0)}');
      }
      if (user.trustScore != null) {
        buffer.writeln('- Trust Score: ${user.trustScore}');
      }
    }

    if (myProperties != null && myProperties.isNotEmpty) {
      buffer.writeln('- User has ${myProperties.length} listed propert${myProperties.length == 1 ? "y" : "ies"}:');
      for (final p in myProperties.take(5)) {
        buffer.writeln(
          '  • "${p.title}" — ${p.propertyType} in ${p.city} '
          '(${p.type}, ₹${_formatPrice(p.price)}, ${p.areaSqFt.toStringAsFixed(0)} sqft, '
          '${p.bedrooms}BHK)',
        );
      }
    }

    final ctx = buffer.toString().trim();
    if (ctx.isNotEmpty) {
      LoggerService.i('ChatbotRepository: Injecting user context (${ctx.length} chars)');
      _initModel(contextPrompt: ctx);
    }
  }

  String _formatPrice(double price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(1)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)} L';
    return price.toStringAsFixed(0);
  }

  // ── Core send message ────────────────────────────────────────────────────────

  Future<String> getResponse(String message) async {
    // Lazy-init the chat session (preserves full multi-turn history)
    _chat ??= _model.startChat();

    LoggerService.i('Chatbot: → $message');
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        LoggerService.w('Chatbot: Empty response from Gemini');
        return "I didn't get a response. Could you rephrase that?";
      }

      LoggerService.i('Chatbot: ← (${text.length} chars)');
      return text.trim();
    } catch (e, stack) {
      LoggerService.e('Chatbot Error', error: e, stack: stack);
      // Friendly error — reset session so next message works clean
      _chat = null;
      return "I'm having trouble connecting right now. Please try again in a moment!";
    }
  }

  /// Clear conversation history (e.g. when user taps "New Chat")
  void clearHistory() {
    _chat = null;
    LoggerService.i('Chatbot: Conversation history cleared');
  }
}
