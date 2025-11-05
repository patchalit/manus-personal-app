import 'package:flutter/foundation.dart';
import '../../data/models/project_model.dart';
import '../../data/services/local_database_service.dart';

class ProjectsProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  
  List<ProjectModel> _projects = [];
  ProjectModel? _currentProject;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProjectModel> get projects => _projects;
  ProjectModel? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all projects for a user
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _dbService.getProjectsByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load projects: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new project
  Future<bool> createProject(String userId, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProject = ProjectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertProject(newProject);
      _projects.insert(0, newProject);
      _currentProject = newProject;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create project: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update a project
  Future<bool> updateProject(String projectId, String newName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final project = _projects.firstWhere((p) => p.id == projectId);
      final updatedProject = project.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );

      await _dbService.updateProject(updatedProject);
      
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = updatedProject;
      }

      if (_currentProject?.id == projectId) {
        _currentProject = updatedProject;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a project
  Future<bool> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbService.deleteProject(projectId);
      await _dbService.deleteMessagesByProjectId(projectId);
      await _dbService.deleteFilesByProjectId(projectId);
      await _dbService.deleteKnowledgeEntriesByProjectId(projectId);

      _projects.removeWhere((p) => p.id == projectId);

      if (_currentProject?.id == projectId) {
        _currentProject = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete project: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set current project
  void setCurrentProject(ProjectModel project) {
    _currentProject = project;
    notifyListeners();
  }

  /// Clear current project
  void clearCurrentProject() {
    _currentProject = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
