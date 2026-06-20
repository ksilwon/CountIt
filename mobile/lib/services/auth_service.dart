import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        await _saveToken(data['token']);
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Błąd rejestracji',
      };
    } catch (_) {
      return {'success': false, 'message': 'Błąd połączenia z serwerem'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        await _saveToken(data['token']);
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Nieprawidłowy email lub hasło',
      };
    } catch (_) {
      return {'success': false, 'message': 'Błąd połączenia z serwerem'};
    }
  }

  static Future<User?> getMe() async {
    final headers = await _authHeaders();
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: headers);
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body)['user']);
    }
    return null;
  }

  static Future<Map<String, dynamic>> updateProfile({String? name, String? avatarUrl}) async {
    final headers = await _authHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: headers,
      body: jsonEncode({if (name != null) 'name': name, if (avatarUrl != null) 'avatarUrl': avatarUrl}),
    );
    return jsonDecode(res.body);
  }
}
