import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/event.dart';
import '../models/settlement.dart';
import 'auth_service.dart';

class EventService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<Event>> getEvents({String? category}) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl/events${category != null ? '?category=$category' : ''}');
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body)['events'];
      return data.map((e) => Event.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> getEventDetail(String eventId) async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/events/$eventId'), headers: headers);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return {
        'event': Event.fromJson(data['event']),
        'settlements': (data['settlements'] as List).map((s) => Settlement.fromJson(s)).toList(),
      };
    }
    throw Exception(data['message'] ?? 'Błąd ładowania wydarzenia');
  }

  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required List<String> participantIds,
    String locationName = 'Warszawa',
    double latitude = 52.2297,
    double longitude = 21.0122,
  }) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'participants': participantIds,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    return jsonDecode(res.body);
  }
}

class SettlementService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<Map<String, dynamic>> claim(String settlementId) async {
    final headers = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/settlements/$settlementId/claim'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> confirm(String settlementId) async {
    final headers = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/settlements/$settlementId/confirm'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> reject(String settlementId) async {
    final headers = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/settlements/$settlementId/reject'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<List<Settlement>> getMySettlements() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/settlements/my'), headers: headers);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body)['settlements'];
      return data.map((s) => Settlement.fromJson(s)).toList();
    }
    return [];
  }
}

class FriendService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<dynamic>> getFriends() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/friends'), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body)['friends'];
    return [];
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/users/search?q=$query'), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body)['users'];
    return [];
  }

  static Future<Map<String, dynamic>> sendRequest(String userId) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$baseUrl/friends/request'),
      headers: headers,
      body: jsonEncode({'userId': userId}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> acceptRequest(String friendshipId) async {
    final headers = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/friends/accept/$friendshipId'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getPendingRequests() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl/friends/pending'), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body)['pending'];
    return [];
  }
}

class DashboardService {
  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {};
  }
}
