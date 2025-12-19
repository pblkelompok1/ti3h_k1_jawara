import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RTService {
  final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
  late AuthService _authService;

  RTService(AuthService authService) {
    _authService = authService;
  }

  /// Get list of RT
  Future<List<Map<String, dynamic>>> getRTList() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse("$baseUrl/rt/");

    try {
      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('Failed to get RT list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting RT list: $e');
    }
  }
}
