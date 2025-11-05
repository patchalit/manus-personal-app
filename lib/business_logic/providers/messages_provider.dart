import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../../data/services/local_database_service.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/openai_service.dart';

class MessagesProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  final OpenAIService _openAIService = OpenAIService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isAIThinking = false;
  String? _errorMessage;
  bool _useRealAI = true; // Toggle for real AI vs simulated

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isAIThinking => _isAIThinking;
  String? get errorMessage => _errorMessage;

  /// Load messages for a project
  Future<void> loadMessages(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _dbService.getMessagesByProjectId(projectId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a message (user message)
  Future<bool> sendMessage(String projectId, String content, {String? knowledgeContext}) async {
    try {
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        sender: 'user',
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertMessage(newMessage);
      _messages.add(newMessage);
      notifyListeners();

      // Sync to Firebase
      try {
        await _firebaseService.syncMessage(newMessage);
      } catch (e) {
        print('Failed to sync message to Firebase: $e');
      }

      // Get AI response
      await _getAIResponse(projectId, content, knowledgeContext);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get AI response (real or simulated)
  Future<void> _getAIResponse(String projectId, String userMessage, String? knowledgeContext) async {
    _isAIThinking = true;
    notifyListeners();

    try {
      String aiResponse;

      if (_useRealAI) {
        // Use real OpenAI
        final conversationHistory = _buildConversationHistory();
        aiResponse = await _openAIService.sendMessage(
          message: userMessage,
          conversationHistory: conversationHistory,
          knowledgeContext: knowledgeContext,
        );
      } else {
        // Simulated response (fallback)
        await Future.delayed(const Duration(seconds: 1));
        aiResponse = _getSimulatedResponse(userMessage);
      }

      // Create Manus message
      final manusMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        sender: 'manus',
        content: aiResponse,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertMessage(manusMessage);
      _messages.add(manusMessage);

      // Sync to Firebase
      try {
        await _firebaseService.syncMessage(manusMessage);
      } catch (e) {
        print('Failed to sync Manus message to Firebase: $e');
      }

      _isAIThinking = false;
      notifyListeners();
    } catch (e) {
      print('Error getting AI response: $e');
      _isAIThinking = false;
      
      // Send error message
      final errorMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        sender: 'manus',
        content: 'Sorry, I encountered an error. Please try again.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _dbService.insertMessage(errorMessage);
      _messages.add(errorMessage);
      notifyListeners();
    }
  }

  /// Build conversation history for OpenAI context
  List<Map<String, String>> _buildConversationHistory() {
    final history = <Map<String, String>>[];
    
    // Get last 10 messages for context
    final recentMessages = _messages.length > 10
        ? _messages.sublist(_messages.length - 10)
        : _messages;
    
    for (var message in recentMessages) {
      history.add({
        'role': message.sender == 'user' ? 'user' : 'assistant',
        'content': message.content,
      });
    }
    
    return history;
  }

  /// Simulated response (fallback when OpenAI is not available)
  String _getSimulatedResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! How can I help you today?';
    } else if (lowerMessage.contains('how are you')) {
      return 'I\'m doing great! Thank you for asking. How can I assist you?';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Let me know if you need anything else.';
    } else if (lowerMessage.contains('help')) {
      return 'I\'m here to help! You can ask me questions, and I\'ll do my best to assist you. You can also use the Knowledge Base to teach me about your preferences and important information.';
    } else {
      return 'I understand. Could you tell me more about that?';
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dbService.deleteMessage(messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete message: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear all messages for a project
  Future<void> clearMessages(String projectId) async {
    try {
      await _dbService.deleteMessagesByProjectId(projectId);
      _messages.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear messages: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Sync messages from Firebase
  Future<void> syncFromFirebase(String projectId) async {
    try {
      final cloudMessages = await _firebaseService.getProjectMessages(projectId);
      
      // Merge with local messages (avoid duplicates)
      for (var cloudMessage in cloudMessages) {
        final exists = _messages.any((m) => m.id == cloudMessage.id);
        if (!exists) {
          await _dbService.insertMessage(cloudMessage);
          _messages.add(cloudMessage);
        }
      }
      
      // Sort by created date
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    } catch (e) {
      print('Failed to sync messages from Firebase: $e');
    }
  }

  /// Toggle between real AI and simulated responses
  void setUseRealAI(bool value) {
    _useRealAI = value;
    notifyListeners();
  }

  /// Test OpenAI connection
  Future<bool> testAIConnection() async {
    return await _openAIService.testConnection();
  }
}
