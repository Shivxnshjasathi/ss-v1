import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

final chatbotRepositoryProvider = Provider((ref) => ChatbotRepository());

class ChatbotRepository {
  // Using the same key as other Google Cloud Services
  static const String _apiKey = 'AIzaSyDxBbtJh5KO4cLgMTy652YU8cL-rRPbXB8';

  late final GenerativeModel _model;
  ChatSession? _chat;

  ChatbotRepository() {
    LoggerService.i('Initializing ChatbotRepository with Gemini 1.5 Flash...');
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are "Sampatti Bot", the sophisticated AI assistant for Sampatti Bazar, India\'s leading real estate ecosystem. '
        'Your personality is professional, intelligent, and warm. You provide expert advice on property, construction, and lifestyle. '
        'Core Knowledge: '
        '- Property: Expert in buying, selling, and renting premium Indian properties. '
        '- Construction: Advice on architecture, interior design, and end-to-end home building. '
        '- Materials: Guidance on sourcing quality building materials (steel, cement, sand). '
        '- Legal: Expert in property verification, documentation, and legal compliance in India. '
        '- Finance: Deep understanding of home loans, EMIs, and eligibility. '
        '- Logistics: Handling relocation and movers & packers with live tracking. '
        'Style: '
        '- Use a premium, helpful tone. '
        '- Use bullet points for complex info. '
        '- Mention Sampatti Bazar features naturally in conversation. '
        '- If you don\'t know something specific (like a live property price without checking), politely invite the user to use the search or service modules in the app. '
        '- Keep responses concise but comprehensive.',
      ),
    );
  }

  Future<String> getResponse(String message) async {
    _chat ??= _model.startChat();

    LoggerService.i('Chatbot: Sending message: $message');
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null) {
        LoggerService.w('Chatbot: Received empty response from Gemini.');
        return "I'm sorry, I couldn't process that request. How else can I help you today?";
      }

      LoggerService.i('Chatbot: Received response (${text.length} chars)');
      return text;
    } catch (e, stack) {
      LoggerService.e('Chatbot Error: $e', error: e, stack: stack);
      return "I'm having a bit of trouble connecting to the Sampatti network. Please try again in a moment.";
    }
  }
}
