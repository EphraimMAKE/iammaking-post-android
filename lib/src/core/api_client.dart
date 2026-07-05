import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

const _baseUrl = 'https://post.iammaking.com/api/v1';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await TokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body is Map ? (body['error'] ?? body['message'] ?? 'Error ${res.statusCode}') : 'Error ${res.statusCode}';
    throw ApiException(msg.toString(), statusCode: res.statusCode);
  }

  static Future<dynamic> get(String path, {bool auth = true}) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl$path'), headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      final res = await http.post(Uri.parse('$_baseUrl$path'),
              headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  static Future<dynamic> delete(String path) async {
    try {
      final res = await http.delete(Uri.parse('$_baseUrl$path'), headers: await _headers())
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }
}
