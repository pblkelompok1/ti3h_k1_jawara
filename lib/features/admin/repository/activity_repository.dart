import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';
import 'package:ti3h_k1_jawara/features/admin/model/activity_model.dart';

/// Repository for Activity Management API
/// Implements all endpoints from ACTIVITY_API_FRONTEND.md
class ActivityRepository {
  final AuthService authService;
  String get baseUrl => authService.baseUrl;

  ActivityRepository(this.authService);

  /// Convert display status to database format for query params
  String? _convertStatusToDbFormat(String? status) {
    if (status == null || status.isEmpty) return null;
    
    switch (status) {
      case 'Akan Datang':
        return 'akan_datang';
      case 'Ongoing':
        return 'ongoing';
      case 'Selesai':
        return 'selesai';
      default:
        return status.toLowerCase().replaceAll(' ', '_');
    }
  }

  // ============= GET ALL ACTIVITIES =============

  /// Get all activities with pagination and filters
  /// 
  /// Parameters:
  /// - name: Filter by activity name (LIKE search)
  /// - status: Filter by status (LIKE search)
  /// - offset: Skip items (pagination)
  /// - limit: Items per page (default: 10)
  Future<ActivityListResponse> getActivities({
    String? name,
    String? status,
    int offset = 0,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (status != null && status.isNotEmpty) {
      // Convert display format to database format for query
      final dbStatus = _convertStatusToDbFormat(status);
      if (dbStatus != null) {
        queryParams['status'] = dbStatus;
      }
    }

    final uri = Uri.parse('$baseUrl/activity')
        .replace(queryParameters: queryParams);

    // DEBUG: Print API call details
    print('🌐 [ActivityRepository] API Call:');
    print('   - URL: $uri');
    print('   - Query Params: $queryParams');

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ActivityListResponse.fromJson(data);
    }

    throw Exception('Failed to load activities: ${res.body}');
  }

  // ============= GET ACTIVITY DETAIL =============

  /// Get detailed information of specific activity
  Future<ActivityModel> getActivityDetail(String activityId) async {
    final res = await authService.sendWithAuth((token) {
      return http.get(
        Uri.parse('$baseUrl/activity/$activityId'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ActivityModel.fromJson(data);
    }

    if (res.statusCode == 404) {
      throw Exception('Activity not found');
    }

    throw Exception('Failed to load activity detail: ${res.body}');
  }

  // ============= CREATE ACTIVITY =============

  /// Create new activity (Admin only)
  Future<ActivityModel> createActivity(ActivityRequest request) async {
    final url = '$baseUrl/activity/';
    final requestBody = request.toJson();
    
    // DEBUG: Print request details
    print('📝 [ActivityRepository] Create Activity:');
    print('   - URL: $url');
    print('   - Request Body: $requestBody');
    
    final res = await authService.sendWithAuth((token) {
      return http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
    });

    // DEBUG: Print response
    print('   - Status Code: ${res.statusCode}');
    print('   - Response Body: ${res.body}');

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return ActivityModel.fromJson(data);
    }

    throw Exception('Failed to create activity: ${res.body}');
  }

  // ============= UPDATE ACTIVITY =============

  /// Update existing activity (Admin only)
  /// All fields are optional
  Future<ActivityModel> updateActivity(
    String activityId,
    Map<String, dynamic> updates,
  ) async {
    final url = '$baseUrl/activity/$activityId';
    
    // DEBUG: Print request details
    print('✏️ [ActivityRepository] Update Activity:');
    print('   - URL: $url');
    print('   - Updates: $updates');
    
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );
    });

    // DEBUG: Print response
    print('   - Status Code: ${res.statusCode}');
    print('   - Response Body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ActivityModel.fromJson(data);
    }

    if (res.statusCode == 404) {
      throw Exception('Activity not found');
    }

    throw Exception('Failed to update activity: ${res.body}');
  }

  // ============= DELETE ACTIVITY =============

  /// Delete activity (Admin only)
  Future<bool> deleteActivity(String activityId) async {
    final url = '$baseUrl/activity/$activityId';
    
    // DEBUG: Print request details
    print('🗑️ [ActivityRepository] Delete Activity:');
    print('   - URL: $url');
    
    final res = await authService.sendWithAuth((token) {
      return http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 204) {
      return true;
    }

    if (res.statusCode == 404) {
      throw Exception('Activity not found');
    }

    throw Exception('Failed to delete activity: ${res.body}');
  }

  // ============= UPLOAD IMAGES =============

  /// Upload multiple preview images for activity (Admin only)
  /// Max 10 images
  /// Allowed types: JPEG, JPG, PNG, WEBP
  Future<UploadImagesResponse> uploadImages(
    String activityId,
    List<File> files,
  ) async {
    if (files.isEmpty) {
      throw Exception('No files to upload');
    }

    if (files.length > 10) {
      throw Exception('Maximum 10 images allowed');
    }

    final token = await authService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token');
    }

    final url = '$baseUrl/activity/$activityId/upload-images';
    
    // DEBUG: Print request details
    print('🖼️ [ActivityRepository] Upload Images:');
    print('   - URL: $url');
    print('   - Image count: ${files.length}');
    
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Add all files
    for (final file in files) {
      final multipartFile = await http.MultipartFile.fromPath(
        'files',
        file.path,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UploadImagesResponse.fromJson(data);
    }

    if (response.statusCode == 404) {
      throw Exception('Activity not found');
    }

    if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Bad request');
    }

    throw Exception('Failed to upload images: ${response.body}');
  }

  // ============= HELPER METHODS =============

  /// Get full image URL from relative path
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$baseUrl/$path';
  }

  /// Search activities by name
  Future<ActivityListResponse> searchActivities(
    String query, {
    int limit = 20,
  }) async {
    return getActivities(name: query, limit: limit);
  }

  /// Get activities by status
  Future<ActivityListResponse> getActivitiesByStatus(
    String status, {
    int offset = 0,
    int limit = 10,
  }) async {
    return getActivities(status: status, offset: offset, limit: limit);
  }

  /// Get upcoming activities
  Future<ActivityListResponse> getUpcomingActivities({
    int offset = 0,
    int limit = 10,
  }) async {
    return getActivitiesByStatus('Akan Datang', offset: offset, limit: limit);
  }

  /// Get ongoing activities
  Future<ActivityListResponse> getOngoingActivities({
    int offset = 0,
    int limit = 10,
  }) async {
    return getActivitiesByStatus('Ongoing', offset: offset, limit: limit);
  }

  /// Get completed activities
  Future<ActivityListResponse> getCompletedActivities({
    int offset = 0,
    int limit = 10,
  }) async {
    return getActivitiesByStatus('Selesai', offset: offset, limit: limit);
  }
}
