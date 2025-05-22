import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:x_ray_entry_app/authentication/auth.dart';

class AuthProvider extends ChangeNotifier {
  final Auth _auth;
  User? _currentUser;
  bool _isExecutive = false;
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  String? _username;
  String? _email;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider({Auth? auth}) : _auth = auth ?? Auth() {
    _initAuthState();
  }

  // Getters
  bool get isExecutive => _isExecutive;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Initialize auth state listener
  void _initAuthState() {
    _auth.authStateChanges.listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        _isLoggedIn = true;
        await _loadUserData(user.uid);
      } else {
        _resetState();
      }
      notifyListeners();
    });
  }

  // Reset all state variables
  void _resetState() {
    _isLoggedIn = false;
    _isAdmin = false;
    _isExecutive = false;
    _username = null;
    _email = null;
    _errorMessage = null;
    _currentUser = null;
  }

  // Load user data from Firestore or other sources
  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      _username = await _auth.getUserName(uid);
      _email = _currentUser?.email;

      // Determine user role - you might want to fetch this from your database
      // For now using the existing flags
      _isAdmin = _isAdmin; // Preserve existing value
      _isExecutive = !_isAdmin;
    } catch (e) {
      _errorMessage = 'Failed to load user data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.signIn(email: email, password: password);
      _isLoggedIn = true;
      _isAdmin = isAdmin;
      _isExecutive = !isAdmin;

      if (_currentUser != null) {
        await _loadUserData(_currentUser!.uid);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new account
  Future<bool> createAccount({
    required String username,
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.createUserAccount(
        username: username,
        email: email,
        password: password,
      );

      _isLoggedIn = true;
      _isAdmin = isAdmin;
      _isExecutive = !isAdmin;
      _username = username;
      _email = email;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Account creation failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login as guest/executive
  Future<void> loginAsExecutive() async {
    _isExecutive = true;
    _isAdmin = false;
    _isLoggedIn = true;
    _email = null;
    notifyListeners();
  }

  // Login as admin
  Future<void> loginAsAdmin() async {
    _isExecutive = false;
    _isAdmin = true;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signOut();
      _resetState();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper to get user-friendly error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
