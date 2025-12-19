import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FamilyService {
  final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
  late AuthService _authService;

  FamilyService(AuthService authService) {
    _authService = authService;
  }

  /// Create new family
  Future<Map<String, dynamic>> createFamily({
    required String familyName,
    required int rtId,
    String? kkPath,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse("$baseUrl/family/");

    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "family_name": familyName,
          "kk_path": kkPath ?? "storage/default/document/1.pdf",
          "status": "active",
          "rt_id": rtId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create family: ${response.statusCode} → ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating family: $e');
    }
  }

  /// Get family list with filters
  Future<Map<String, dynamic>> getFamilyList({
    int? rtId,
    String? status,
    String? familyName,
    int offset = 0,
    int limit = 10,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final queryParams = <String>[];
    if (rtId != null) queryParams.add('rt_id=$rtId');
    if (status != null) queryParams.add('status=$status');
    if (familyName != null && familyName.isNotEmpty) {
      queryParams.add('family_name=$familyName');
    }
    queryParams.add('offset=$offset');
    queryParams.add('limit=$limit');

    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final url = Uri.parse("$baseUrl/family/$queryString");

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
        throw Exception('Failed to get family list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting family list: $e');
    }
  }

  /// Get family by ID
  Future<Map<String, dynamic>> getFamilyById(String familyId) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse("$baseUrl/family/$familyId");

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
        throw Exception('Failed to get family: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting family: $e');
    }
  }
}
