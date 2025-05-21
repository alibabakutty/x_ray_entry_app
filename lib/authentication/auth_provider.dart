import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart'; // Import your Auth class

class AuthProvider extends ChangeNotifier {
  final Auth _auth = Auth();

  bool _isGuest = false;
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  String? _username;
  String? _email;

  bool get isGuest => _isGuest;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;
  User? get currentUser => _auth.currentUser;

  // Initialize auth state
  AuthProvider() {
    _auth.authStateChanges.listen((User? user) {
      if (user != null) {
        _isLoggedIn = true;
        // You might want to add logic here to determine if it's admin or guest
        _loadUserData(user.uid);
      } else {
        _isLoggedIn = false;
        _isAdmin = false;
        _isGuest = false;
        _username = null;
        _email = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    _username = await _auth.getUserName(uid);
    _email = currentUser?.email;
    notifyListeners();
  }

  // Login with email and password
  Future<void> loginWithEmail({
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      await _auth.signIn(email: email, password: password);
      _isLoggedIn = true;
      _isAdmin = isAdmin;
      _isGuest = !isAdmin;
      if (currentUser != null) {
        await _loadUserData(currentUser!.uid);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Create new account
  Future<void> createAccount({
    required String username,
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      await _auth.createUserAccount(
        username: username,
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _isAdmin = isAdmin;
      _isGuest = !isAdmin;
      _username = username;
      _email = email;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Login as guest
  void loginAsGuest() {
    _isGuest = true;
    _isAdmin = false;
    _isLoggedIn = true;
    _username = 'Guest';
    _email = null;
    notifyListeners();
  }

  // Login as admin
  void loginAsAdmin() {
    _isGuest = false;
    _isAdmin = true;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _isGuest = false;
    _isAdmin = false;
    _isLoggedIn = false;
    _username = null;
    _email = null;
    notifyListeners();
  }

  // Get username (you can use this if you prefer to load it on demand)
  Future<String?> getUsername() async {
    if (currentUser != null) {
      _username = await _auth.getUserName(currentUser!.uid);
      notifyListeners();
      return _username;
    }
    return null;
  }
}
