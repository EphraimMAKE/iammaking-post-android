import '../core/api_client.dart';
import '../models/user.dart';

class AuthService {
  static Future<({String token, User user})> login(String email, String password) async {
    final data = await ApiClient.post('/auth/login', {'email': email, 'password': password}, auth: false);
    return (token: data['token'] as String, user: User.fromJson(data['user'] as Map<String, dynamic>));
  }

  static Future<User> me() async {
    final data = await ApiClient.get('/auth/me');
    return User.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> logout() async {
    try { await ApiClient.post('/auth/logout', {}); } catch (_) {}
  }
}
