import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_statistics.dart';
import '../models/finance_summary.dart';
import 'auth_service.dart';

class AdminDashboardService {
  final AuthService authService;
  static const String baseUrl = 'https://prefunctional-albertha-unpessimistically.ngrok-free.dev';

  AdminDashboardService(this.authService);

  /// Get admin statistics for dashboard cards
  Future<AdminStatistics> getStatistics() async {
    try {
      final token = await authService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return AdminStatistics.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error']?['message'] ?? 'Failed to load statistics');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to access this page.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']?['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }

  /// Get finance summary for dashboard
  Future<FinanceSummary> getFinanceSummary() async {
    try {
      final token = await authService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/finance/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return FinanceSummary.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error']?['message'] ?? 'Failed to load finance summary');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to access this page.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']?['message'] ?? 'Failed to load finance summary');
      }
    } catch (e) {
      throw Exception('Failed to load finance summary: $e');
    }
  }
}
