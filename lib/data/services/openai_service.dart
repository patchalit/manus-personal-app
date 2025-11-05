import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  // OpenAI API Configuration
  // TODO: Replace with your OpenAI API key
  // Get your key from: https://platform.openai.com/api-keys
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini'; // Cost-effective model

  /// Send a message to OpenAI and get a response
  /// 
  /// Parameters:
  /// - [message]: The user's message
  /// - [conversationHistory]: Previous messages for context (optional)
  /// - [knowledgeContext]: Knowledge base entries for context (optional)
  /// 
  /// Returns: AI response as a string
  Future<String> sendMessage({
    required String message,
    List<Map<String, String>>? conversationHistory,
    String? knowledgeContext,
  }) async {
    try {
      // Build messages array
      final messages = <Map<String, String>>[];

      // System message with knowledge context
      String systemMessage = '''You are Manus, a helpful and friendly AI assistant. 
You are part of the Manus Personal App, designed to help users manage their projects and knowledge.

Your personality:
- Friendly and approachable
- Clear and concise
- Helpful and proactive
- Professional but warm

Guidelines:
- Always respond in the same language as the user's message
- Keep responses concise but informative
- If you don't know something, admit it honestly
- Offer to help with related tasks when appropriate''';

      if (knowledgeContext != null && knowledgeContext.isNotEmpty) {
        systemMessage += '\n\nKnowledge Base Context:\n$knowledgeContext';
      }

      messages.add({
        'role': 'system',
        'content': systemMessage,
      });

      // Add conversation history (last 10 messages for context)
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.length > 10
            ? conversationHistory.sublist(conversationHistory.length - 10)
            : conversationHistory;
        messages.addAll(recentHistory);
      }

      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      // Make API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        return aiResponse.trim();
      } else {
        print('OpenAI API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return _getErrorResponse(response.statusCode);
      }
    } catch (e) {
      print('Error calling OpenAI API: $e');
      return 'Sorry, I encountered an error while processing your message. Please try again.';
    }
  }

  /// Get a response based on knowledge base entries
  /// 
  /// This method helps Manus learn from the knowledge base and provide
  /// contextual responses based on what the user has taught it.
  Future<String> askWithKnowledge({
    required String question,
    required List<String> knowledgeEntries,
  }) async {
    final knowledgeContext = knowledgeEntries.join('\n\n');
    
    return await sendMessage(
      message: question,
      knowledgeContext: knowledgeContext,
    );
  }

  /// Generate a summary of a conversation
  Future<String> summarizeConversation(List<String> messages) async {
    final conversationText = messages.join('\n');
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that creates concise summaries of conversations.',
            },
            {
              'role': 'user',
              'content': 'Please summarize this conversation in 2-3 sentences:\n\n$conversationText',
            },
          ],
          'temperature': 0.5,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'Unable to generate summary.';
      }
    } catch (e) {
      print('Error generating summary: $e');
      return 'Unable to generate summary.';
    }
  }

  /// Extract knowledge from a conversation
  /// 
  /// This helps automatically identify important information that should
  /// be saved to the knowledge base.
  Future<List<String>> extractKnowledge(String conversation) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''Extract key learnings, insights, preferences, or important information from this conversation.
Return each item as a separate line starting with "- ".
Only extract information that would be useful to remember for future conversations.''',
            },
            {
              'role': 'user',
              'content': conversation,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Parse the response into a list
        return content
            .split('\n')
            .where((line) => line.trim().startsWith('-'))
            .map((line) => line.trim().substring(1).trim())
            .where((line) => line.isNotEmpty)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error extracting knowledge: $e');
      return [];
    }
  }

  /// Get error response based on status code
  String _getErrorResponse(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Authentication error. Please check the API key.';
      case 429:
        return 'Rate limit exceeded. Please try again in a moment.';
      case 500:
      case 503:
        return 'OpenAI service is temporarily unavailable. Please try again later.';
      default:
        return 'Sorry, I encountered an error (code: $statusCode). Please try again.';
    }
  }

  /// Test the OpenAI connection
  Future<bool> testConnection() async {
    try {
      final response = await sendMessage(message: 'Hello!');
      return response.isNotEmpty && !response.contains('error');
    } catch (e) {
      return false;
    }
  }
}
