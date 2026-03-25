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

  // Get valid token — refreshes automatically if expired
  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    // Check if token is expired
    if (_isTokenExpired(token)) {
      return await _refreshToken();
    }

    return token;
  }

  // Refresh the access token using refresh token
  static Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['access'];
        await _storage.write(key: 'access_token', value: newToken);
        return newToken;
      } else {
        // Refresh token also expired — force logout
        await logout();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Check if JWT token is expired
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode the payload (base64)
      String payload = parts[1];
      // Add padding if needed
      switch (payload.length % 4) {
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
      }

      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(payload))
      );

      final exp = decoded['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Consider expired 1 minute before actual expiry
      return DateTime.now().isAfter(
        expiryDate.subtract(const Duration(minutes: 1))
      );
    } catch (e) {
      return true;
    }
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
    if (token == null) return false;
    // Also check refresh token isn't expired
    final refreshToken = await _storage.read(key: 'refresh_token');
    return refreshToken != null;
  }
}