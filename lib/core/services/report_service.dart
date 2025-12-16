import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/report/models/report_model.dart';

class ReportService {
  static const String baseUrl = 'https://presumptive-renee-uncircled.ngrok-free.dev';
  final storage = const FlutterSecureStorage();

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new report
  Future<ReportModel> createReport(CreateReportRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/reports');
      final headers = await _getHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReportModel.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to create report');
      }
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  /// Get all reports with filters
  Future<ReportListResponse> getReports({
    String? category,
    String? status,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/reports').replace(
        queryParameters: queryParams,
      );
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReportListResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to get reports');
      }
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  /// Get report by ID
  Future<ReportModel> getReportById(String reportId) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/$reportId');
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReportModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Report not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to get report');
      }
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  /// Update report (full update)
  Future<ReportModel> updateReport(
    String reportId,
    UpdateReportRequest request,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/$reportId');
      final headers = await _getHeaders();

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReportModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Report not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to update report');
      }
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  /// Update report status only
  Future<ReportModel> updateReportStatus(
    String reportId,
    ReportStatus status,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/$reportId/status').replace(
        queryParameters: {'status': status.name},
      );
      final headers = await _getHeaders();

      final response = await http.patch(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReportModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Report not found');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Invalid status');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to update status');
      }
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  /// Upload evidence files
  Future<ReportModel> uploadEvidence(
    String reportId,
    List<File> files,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/$reportId/evidence');
      final token = await storage.read(key: 'access_token');

      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add files
      for (final file in files) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReportModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Report not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to upload evidence');
      }
    } catch (e) {
      throw Exception('Failed to upload evidence: $e');
    }
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/$reportId');
      final headers = await _getHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Report not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to delete report');
      }
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  /// Build full URL for evidence image
  String getEvidenceUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$baseUrl/$imagePath';
  }
}
