import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  // Login member
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/member/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Save tokens
      await _storage.write(key: 'access_token', value: data['access']);
      await _storage.write(key: 'refresh_token', value: data['refresh']);
      await _storage.write(key: 'member', value: jsonEncode(data['member']));
      return {'success': true, 'member': data['member']};
    } else {
      return {'success': false, 'error': data['error'] ?? 'Login failed'};
    }
  }

  // Logout
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Get saved token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Get saved member data
  static Future<Map<String, dynamic>?> getMember() async {
    final memberStr = await _storage.read(key: 'member');
    if (memberStr == null) return null;
    return jsonDecode(memberStr);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}