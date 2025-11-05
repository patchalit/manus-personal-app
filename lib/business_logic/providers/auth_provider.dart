import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../data/models/user_model.dart';
import '../../data/services/local_database_service.dart';
import '../../data/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useFirebase = true; // Toggle for Firebase vs Local-only

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize and listen to Firebase auth state changes
  void initializeAuth() {
    _firebaseService.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        // User signed in, load from Firestore or create local
        await _loadUserFromFirebase(firebaseUser);
      } else {
        // User signed out
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Load user from Firebase and sync to local database
  Future<void> _loadUserFromFirebase(firebase_auth.User firebaseUser) async {
    try {
      // Try to get user from Firestore
      UserModel? user = await _firebaseService.getUser(firebaseUser.uid);
      
      if (user == null) {
        // Create user document in Firestore if it doesn't exist
        await _firebaseService.createUserDocument(
          firebaseUser.uid,
          firebaseUser.email!,
          firebaseUser.displayName ?? 'User',
        );
        user = await _firebaseService.getUser(firebaseUser.uid);
      }
      
      if (user != null) {
        // Save to local database
        await _dbService.insertUser(user);
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from Firebase: $e');
    }
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        // Firebase authentication
        await _firebaseService.signInWithEmailPassword(email, password);
        // User will be loaded via authStateChanges listener
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Local-only authentication (fallback)
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
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
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
      if (_useFirebase) {
        // Firebase authentication
        await _firebaseService.signUpWithEmailPassword(email, password, displayName);
        // User will be loaded via authStateChanges listener
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Local-only authentication (fallback)
        final existingUser = await _dbService.getUserByEmail(email);
        if (existingUser != null) {
          _errorMessage = 'User already exists. Please sign in.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

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
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (_useFirebase) {
        await _firebaseService.signOut();
      }
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Sign out failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load current user from local database (for offline mode)
  Future<void> loadCurrentUser() async {
    try {
      final users = await _dbService.getAllUsers();
      if (users.isNotEmpty) {
        _currentUser = users.first;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile(String displayName) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        displayName: displayName,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
        syncedAt: _currentUser!.syncedAt,
      );

      await _dbService.updateUser(updatedUser);
      
      if (_useFirebase) {
        await _firebaseService.updateUser(updatedUser);
      }

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Update profile failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get user-friendly error messages from Firebase error codes
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication error: $code';
    }
  }

  /// Toggle between Firebase and local-only mode
  void setUseFirebase(bool value) {
    _useFirebase = value;
    notifyListeners();
  }
}
