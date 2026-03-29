import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

final chatbotRepositoryProvider = Provider((ref) => ChatbotRepository());

class ChatbotRepository {
  // Provided API Key
  static const String _apiKey = 'AIzaSyAc4n2xMNIlrVahhNcDXUFxAAxlqnq8o3A';

  late final GenerativeModel _model;
  ChatSession? _chat;

  ChatbotRepository() {
    LoggerService.i('Initializing ChatbotRepository with Gemini 1.5 Flash...');
    _model = GenerativeModel(
      model: 'gemini-3.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are "Sampatti Bot", the elite digital assistant for Sampatti Bazar, India\'s premier Real Estate Super App. '
        'Your goal is to provide expert, high-end guidance on all real estate and home-related services. '
        'Sampatti Bazar features include: '
        '1. Property Marketplace: Buying, renting, and selling premium properties. '
        '2. Construction Services: Architecture, Interior Design, and end-to-end Home Construction. '
        '3. Materials Marketplace: Sourcing high-quality building materials like cement, steel, and sand. '
        '4. Legal Aid: Property document verification and legal consultation. '
        '5. Home Loans: EMI calculations and eligibility checks. '
        '6. Movers & Packers: Reliable relocation services with live tracking. '
        '7. Site Visits: Seamlessly scheduling property visits. '
        'Always sound professional, helpful, and premium. Use concise formatting. '
        'If users ask about pricing or specific property details not in the chat, invite them to explore the respective module in the app.',
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
