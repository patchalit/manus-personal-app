import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/local_database_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Sign in with email and password (local only for now)
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if user exists in local database
      final user = await _dbService.getUserByEmail(email);
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'User not found. Please sign up first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Sign in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = await _dbService.getUserByEmail(email);
      
      if (existingUser != null) {
        _errorMessage = 'User already exists. Please sign in.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbService.insertUser(newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Load current user from local storage
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final users = await _dbService.getAllUsers();
      if (users.isNotEmpty) {
        _currentUser = users.first; // Get the first user for now
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(String displayName) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        updatedAt: DateTime.now(),
      );

      await _dbService.updateUser(updatedUser);
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
