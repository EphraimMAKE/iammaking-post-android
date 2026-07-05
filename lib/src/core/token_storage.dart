import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kToken = 'api_token';
const _kUser  = 'user_json';

class TokenStorage {
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void>   write(String token) => _s.write(key: _kToken, value: token);
  static Future<String?> read()             => _s.read(key: _kToken);
  static Future<void>   delete()            => _s.delete(key: _kToken);

  static Future<void>   writeUser(String json) => _s.write(key: _kUser, value: json);
  static Future<String?> readUser()            => _s.read(key: _kUser);
  static Future<void>   clear()               async {
    await _s.delete(key: _kToken);
    await _s.delete(key: _kUser);
  }
}
