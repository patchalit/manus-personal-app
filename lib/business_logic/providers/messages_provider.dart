import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import '../../data/services/local_database_service.dart';

class MessagesProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
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
  Future<bool> sendMessage(String projectId, String content) async {
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

      // Simulate Manus response (for now)
      await Future.delayed(const Duration(seconds: 1));
      await _sendManusResponse(projectId, content);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Simulate Manus response
  Future<void> _sendManusResponse(String projectId, String userMessage) async {
    try {
      final response = _generateManusResponse(userMessage);
      
      final manusMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        sender: 'manus',
        content: response,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertMessage(manusMessage);
      _messages.add(manusMessage);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to get Manus response: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Generate a simple Manus response (placeholder)
  String _generateManusResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! How can I help you today?';
    } else if (lowerMessage.contains('help')) {
      return 'I\'m here to help! You can ask me questions, and I\'ll do my best to assist you.';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Feel free to ask if you need anything else.';
    } else {
      return 'I understand. Let me help you with that. (This is a placeholder response. In Phase 4, I\'ll be connected to a real AI service.)';
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _dbService.deleteMessage(messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clear all messages for current project
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
