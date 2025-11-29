import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final email = prefs.getString('email');
    final name = prefs.getString('name');
    final role = prefs.getString('role');

    if (userId != null && email != null && role != null) {
      _user = User(
        id: userId,
        email: email,
        name: name ?? '',
        role: role,
      );
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _user = await _apiService.login(email, password);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _user!.id);
      await prefs.setString('email', _user!.email);
      await prefs.setString('name', _user!.name);
      await prefs.setString('role', _user!.role);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name, String role) async {
    try {
      _user = await _apiService.register(email, password, name, role);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _user!.id);
      await prefs.setString('email', _user!.email);
      await prefs.setString('name', _user!.name);
      await prefs.setString('role', _user!.role);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
