import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User?      get user   => _user;
  String?    get error  => _error;
  bool get isLoading    => _status == AuthStatus.unknown;

  Future<void> init() async {
    final token = await TokenStorage.read();
    if (token == null) { _status = AuthStatus.unauthenticated; notifyListeners(); return; }
    try {
      final userJson = await TokenStorage.readUser();
      if (userJson != null) _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      _user ??= await AuthService.me();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await TokenStorage.clear();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null; notifyListeners();
    try {
      final result = await AuthService.login(email, password);
      await TokenStorage.write(result.token);
      await TokenStorage.writeUser(jsonEncode(result.user.toJson()));
      _user   = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString(); notifyListeners(); return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    await TokenStorage.clear();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
