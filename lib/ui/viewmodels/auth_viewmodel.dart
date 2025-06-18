import 'package:flutter/material.dart';
import 'package:gotrue/gotrue.dart' as gotrue;

import '../../core/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/service_locator.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = serviceLocator<AuthService>();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Convert gotrue User to our app's User model
  User? _convertUser(gotrue.User? gotrueUser) {
    if (gotrueUser == null) return null;

    return User(
      id: gotrueUser.id,
      email: gotrueUser.email ?? '',
      name: gotrueUser.userMetadata?['name'] as String? ?? '',
      // Add other fields as needed based on your User model
    );
  }

  Future<void> checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final gotrueUser = await _authService.getCurrentUser();
      _currentUser = _convertUser(gotrueUser);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gotrueUser = await _authService.login(email, password);
      _currentUser = _convertUser(gotrueUser);
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(email, password, name);
      final gotrueUser = await _authService.login(email, password);
      _currentUser = _convertUser(gotrueUser);
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}