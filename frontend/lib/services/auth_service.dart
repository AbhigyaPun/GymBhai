import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  // ── Login ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/member/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await _storage.write(key: 'access_token',  value: data['access']);
      await _storage.write(key: 'refresh_token', value: data['refresh']);
      await _storage.write(key: 'member',        value: jsonEncode(data['member']));
      return {'success': true, 'member': data['member']};
    } else {
      return {'success': false, 'error': data['error'] ?? 'Login failed'};
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ── Get Token (with auto refresh) ─────────────────────────────────────────
  static Future<String?> getToken() async {
    final access = await _storage.read(key: 'access_token');
    if (access == null) return null;

    // Check if token is expired
    if (_isTokenExpired(access)) {
      // Try to refresh
      final newToken = await _refreshToken();
      return newToken;
    }
    return access;
  }

  // ── Refresh Token ─────────────────────────────────────────────────────────
  static Future<String?> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: 'refresh_token');
      if (refresh == null) return null;

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];
        await _storage.write(key: 'access_token', value: newAccess);
        return newAccess;
      } else {
        // Refresh token also expired → force logout
        await logout();
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  // ── Check if JWT is expired ───────────────────────────────────────────────
  static bool _isTokenExpired(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (base64)
      String payload = parts[1];
      // Add padding if needed
      while (payload.length % 4 != 0) { payload += '='; }
      final decoded  = utf8.decode(base64Url.decode(payload));
      final data     = jsonDecode(decoded);

      // Check exp claim
      final exp = data['exp'];
      if (exp == null) return true;

      final expiry  = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now     = DateTime.now();

      // Consider expired if less than 5 minutes remaining
      return expiry.isBefore(now.add(const Duration(minutes: 5)));
    } catch (_) {
      return true;
    }
  }

  // ── Get saved member data ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getMember() async {
    final memberStr = await _storage.read(key: 'member');
    if (memberStr == null) return null;
    return jsonDecode(memberStr);
  }

  // ── Update saved member data ──────────────────────────────────────────────
  static Future<void> updateMember(Map<String, dynamic> member) async {
    await _storage.write(key: 'member', value: jsonEncode(member));
  }

  // ── Check if logged in ────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return false;

    // If access token expired, try refresh
    if (_isTokenExpired(token)) {
      final newToken = await _refreshToken();
      return newToken != null;
    }
    return true;
  }
}