import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _authService.getToken();
      _user = await _authService.getUser();
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation de l\'authentification: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginResponse = await _authService.login(email, password);
      _user = loginResponse.user;
      _token = await _authService.getToken();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } 
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    
    try{
      await _authService.logout();
    }finally{
      _user = null;
      _token = null;
      _error = null;
      _isLoading = false;
      notifyListeners();  
    }
  }

  // CLear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}