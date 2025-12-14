import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/models/kegiatan_model.dart';

class ActivityService {
  final baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev";

  /// Fetch activities with pagination and optional filters
  /// Returns a map with 'total_count' and 'data' (list of KegiatanModel)
  Future<Map<String, dynamic>> getActivities({
    String? name,
    String? status,
    int offset = 0,
    int limit = 10,
  }) async {
    // Build query parameters
    final queryParams = {
      'offset': offset.toString(),
      'limit': limit.toString(),
    };

    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse("$baseUrl/activity/").replace(
      queryParameters: queryParams,
    );

    final res = await http.get(
      uri,
      headers: {"accept": "application/json"},
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final totalCount = data['total_count'] as int;
      final activitiesJson = data['data'] as List;

      final activities = activitiesJson
          .map((json) => KegiatanModel.fromJson(json))
          .toList();

      return {
        'total_count': totalCount,
        'data': activities,
      };
    } else {
      throw Exception('Failed to load activities: ${res.statusCode}');
    }
  }

  /// Fetch activity by ID
  Future<KegiatanModel?> getActivityById(String activityId) async {
    try {
      final uri = Uri.parse("$baseUrl/activity/$activityId");

      final res = await http.get(
        uri,
        headers: {"accept": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return KegiatanModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
