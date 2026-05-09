import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    _setLoading(true);
    _user = await AuthService.getMe();
    _setLoading(false);
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _error = null;
    final result = await AuthService.register(name: name, email: email, password: password);
    if (result['success'] == true) {
      _user = User.fromJson(result['user']);
      _setLoading(false);
      return true;
    }
    _error = result['message'];
    _setLoading(false);
    return false;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    final result = await AuthService.login(email: email, password: password);
    if (result['success'] == true) {
      _user = User.fromJson(result['user']);
      _setLoading(false);
      return true;
    }
    _error = result['message'];
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(String name) async {
    _setLoading(true);
    final result = await AuthService.updateProfile(name: name);
    if (result['success'] == true) {
      _user = User.fromJson(result['user']);
      _setLoading(false);
      return true;
    }
    _setLoading(false);
    return false;
  }
}
