import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  AppUser? user;
  bool isLoading = false;
  String? error;

  AuthViewModel(this._authService) {
    _authService.userStream().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      final newUser = await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      user = newUser;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();
      final u = await _authService.signInWithEmail(email: email, password: password);
      user = u;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    error = null;
    notifyListeners();
  }

}
