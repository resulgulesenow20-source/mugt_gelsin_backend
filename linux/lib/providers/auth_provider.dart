import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void toggleAuth() {
    _isLoggedIn = !_isLoggedIn;
    notifyListeners(); // Giriş durumunu tüm sayfalara haber verir
  }
}
