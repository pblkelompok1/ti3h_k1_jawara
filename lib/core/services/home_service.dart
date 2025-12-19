import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HomeService {
  final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
  late AuthService _authService;

  HomeService(AuthService authService) {
    _authService = authService;
  }

  /// Create new home
  Future<Map<String, dynamic>> createHome({
    required String homeName,
    required String homeAddress,
    required String familyId,
    String? status,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse("$baseUrl/home/");

    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "home_name": homeName,
          "home_address": homeAddress,
          "status": status ?? "active",
          "family_id": familyId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create home: ${response.statusCode} → ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating home: $e');
    }
  }

  /// Get home list with filters
  Future<Map<String, dynamic>> getHomeList({
    String? status,
    String? homeName,
    String? familyId,
    int? rtId,
    int offset = 0,
    int limit = 10,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final queryParams = <String>[];
    if (status != null) queryParams.add('status=$status');
    if (homeName != null && homeName.isNotEmpty) {
      queryParams.add('home_name=$homeName');
    }
    if (familyId != null) queryParams.add('family_id=$familyId');
    if (rtId != null) queryParams.add('rt_id=$rtId');
    queryParams.add('offset=$offset');
    queryParams.add('limit=$limit');

    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final url = Uri.parse("$baseUrl/home/$queryString");

    try {
      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get home list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting home list: $e');
    }
  }

  /// Get home by ID
  Future<Map<String, dynamic>> getHomeById(int homeId) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse("$baseUrl/home/$homeId");

    try {
      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get home: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting home: $e');
    }
  }
}
