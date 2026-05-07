import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Maintain conversation history for context
  final List<Map<String, String>> _conversationHistory = [];

  static const String _systemPrompt =
      "You are a calm healthcare assistant inspired by Baymax.\n\n"
      "Rules:\n"
      "- Keep responses short\n"
      "- Sound emotionally comforting\n"
      "- Ask follow-up questions naturally\n"
      "- Avoid robotic wording\n"
      "- No diagnosis\n"
      "- Suggest professional help for serious symptoms";

  Future<String> getResponse(String userMessage) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    // Add user message to history
    _conversationHistory.add({"role": "user", "content": userMessage});

    // Keep only last 10 messages to avoid token overflow
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeRange(0, _conversationHistory.length - 10);
    }

    final messages = [
      {"role": "system", "content": _systemPrompt},
      ..._conversationHistory,
    ];

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": messages,
          "max_tokens": 150,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["choices"][0]["message"]["content"] as String;

        // Add assistant reply to history
        _conversationHistory.add({"role": "assistant", "content": reply});

        return reply;
      } else {
        return "I'm having trouble connecting right now. Please try again in a moment.";
      }
    } catch (e) {
      return "I couldn't reach the server. Please check your internet connection.";
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
  }
}
