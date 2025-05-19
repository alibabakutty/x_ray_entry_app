import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isGuest = false;
  bool _isAdmin = false;
  bool _isLoggedIn = false;

  bool get isGuest => _isGuest;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;

  // Login as guest
  void loginAsGuest() {
    _isGuest = true;
    _isAdmin = false;
    _isLoggedIn = true;
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
  void logout() {
    _isGuest = false;
    _isAdmin = false;
    _isLoggedIn = false;
    notifyListeners();
  }
}
