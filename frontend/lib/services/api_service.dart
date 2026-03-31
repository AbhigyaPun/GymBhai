import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiService {
  // ── GET ───────────────────────────────────────────────────────────────────
  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      headers: _headers(token),
    );

    // If still 401 after refresh → token truly expired
    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }
    return response;
  }

  // ── POST ──────────────────────────────────────────────────────────────────
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }
    return response;
  }

  // ── PUT ───────────────────────────────────────────────────────────────────
  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> body) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }
    return response;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  static Future<http.Response> delete(String endpoint) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      headers: _headers(token),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }
    return response;
  }

  // ── Headers ───────────────────────────────────────────────────────────────
  static Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type':  'application/json',
  };
}