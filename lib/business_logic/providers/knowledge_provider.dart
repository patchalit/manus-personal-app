import 'package:flutter/foundation.dart';
import '../../data/models/knowledge_entry_model.dart';
import '../../data/services/local_database_service.dart';

class KnowledgeProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  
  List<KnowledgeEntryModel> _entries = [];
  String _selectedCategory = 'all';
  bool _isLoading = false;
  String? _errorMessage;

  List<KnowledgeEntryModel> get entries => _entries;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<KnowledgeEntryModel> get filteredEntries {
    if (_selectedCategory == 'all') {
      return _entries;
    }
    return _entries.where((e) => e.category == _selectedCategory).toList();
  }

  /// Load knowledge entries for a project
  Future<void> loadEntries(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _dbService.getKnowledgeEntriesByProjectId(projectId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load knowledge entries: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new knowledge entry
  Future<bool> createEntry({
    required String projectId,
    required String title,
    required String content,
    String? category,
    List<String>? tags,
    String? sourceMessageId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newEntry = KnowledgeEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        title: title,
        content: content,
        category: category,
        tags: tags ?? [],
        sourceMessageId: sourceMessageId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertKnowledgeEntry(newEntry);
      _entries.insert(0, newEntry);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create knowledge entry: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update a knowledge entry
  Future<bool> updateEntry({
    required String entryId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      final updatedEntry = entry.copyWith(
        title: title,
        content: content,
        category: category,
        tags: tags,
        updatedAt: DateTime.now(),
      );

      await _dbService.updateKnowledgeEntry(updatedEntry);
      
      final index = _entries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        _entries[index] = updatedEntry;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update knowledge entry: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a knowledge entry
  Future<bool> deleteEntry(String entryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbService.deleteKnowledgeEntry(entryId);
      _entries.removeWhere((e) => e.id == entryId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete knowledge entry: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search knowledge entries
  Future<void> searchEntries(String projectId, String query) async {
    if (query.isEmpty) {
      await loadEntries(projectId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _dbService.searchKnowledgeEntries(projectId, query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search knowledge entries: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Get entries by category
  Future<void> loadEntriesByCategory(String projectId, String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (category == 'all') {
        _entries = await _dbService.getKnowledgeEntriesByProjectId(projectId);
      } else {
        _entries = await _dbService.getKnowledgeEntriesByCategory(projectId, category);
      }
      _selectedCategory = category;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load entries by category: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all entries
  void clearEntries() {
    _entries.clear();
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
