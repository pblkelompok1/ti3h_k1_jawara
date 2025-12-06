import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';
import 'package:ti3h_k1_jawara/features/admin/data/admin_models.dart';

class AdminService {
  final AuthService authService;
  String get baseUrl => authService.baseUrl;

  AdminService(this.authService);

  // ============= PENDING REGISTRATIONS =============

  /// Get all pending registrations
  Future<List<PendingRegistration>> getPendingRegistrations() async {
    final res = await authService.sendWithAuth((token) {
      return http.get(
        Uri.parse('$baseUrl/admin/pending-registrations'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => PendingRegistration.fromJson(e)).toList();
    }

    throw Exception('Failed to load pending registrations: ${res.body}');
  }

  /// Approve user registration
  Future<bool> approveRegistration(String userId) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/users/$userId/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });

    return res.statusCode == 200;
  }

  /// Reject user registration
  Future<bool> rejectRegistration(String userId, String reason) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/users/$userId/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );
    });

    return res.statusCode == 200;
  }

  // ============= FINANCE MANAGEMENT =============

  /// Get finance summary
  Future<FinanceSummary> getFinanceSummary({
    String? month,
    String? year,
  }) async {
    final queryParams = <String, String>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;

    final uri = Uri.parse('$baseUrl/admin/finance/summary')
        .replace(queryParameters: queryParams);

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return FinanceSummary.fromJson(data);
    }

    throw Exception('Failed to load finance summary: ${res.body}');
  }

  /// Get all finance transactions
  Future<List<FinanceReport>> getFinanceTransactions({
    String? type,
    String? category,
    String? month,
    String? year,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (category != null) queryParams['category'] = category;
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;

    final uri = Uri.parse('$baseUrl/admin/finance/transactions')
        .replace(queryParameters: queryParams);

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => FinanceReport.fromJson(e)).toList();
    }

    throw Exception('Failed to load finance transactions: ${res.body}');
  }

  /// Create finance transaction
  Future<FinanceReport> createFinanceTransaction(
      Map<String, dynamic> data) async {
    final res = await authService.sendWithAuth((token) {
      return http.post(
        Uri.parse('$baseUrl/admin/finance/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });

    if (res.statusCode == 201 || res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      return FinanceReport.fromJson(responseData);
    }

    throw Exception('Failed to create transaction: ${res.body}');
  }

  /// Update finance transaction
  Future<bool> updateFinanceTransaction(
      String id, Map<String, dynamic> data) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/finance/transactions/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });

    return res.statusCode == 200;
  }

  /// Delete finance transaction
  Future<bool> deleteFinanceTransaction(String id) async {
    final res = await authService.sendWithAuth((token) {
      return http.delete(
        Uri.parse('$baseUrl/admin/finance/transactions/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    return res.statusCode == 200 || res.statusCode == 204;
  }

  // ============= RESIDENT MANAGEMENT =============

  /// Get all residents with filters
  Future<List<Map<String, dynamic>>> getResidents({
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/admin/residents')
        .replace(queryParameters: queryParams);

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }

    throw Exception('Failed to load residents: ${res.body}');
  }

  /// Update resident
  Future<bool> updateResident(String id, Map<String, dynamic> data) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/residents/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });

    return res.statusCode == 200;
  }

  /// Delete resident
  Future<bool> deleteResident(String id) async {
    final res = await authService.sendWithAuth((token) {
      return http.delete(
        Uri.parse('$baseUrl/admin/residents/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    return res.statusCode == 200 || res.statusCode == 204;
  }

  /// Change resident status
  Future<bool> changeResidentStatus(String id, String status) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/residents/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
    });

    return res.statusCode == 200;
  }

  // ============= BANNER MANAGEMENT =============

  /// Get all banners
  Future<List<BannerModel>> getBanners({String? type}) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/admin/banners')
        .replace(queryParameters: queryParams);

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => BannerModel.fromJson(e)).toList();
    }

    throw Exception('Failed to load banners: ${res.body}');
  }

  /// Create banner
  Future<BannerModel> createBanner(Map<String, dynamic> data) async {
    final res = await authService.sendWithAuth((token) {
      return http.post(
        Uri.parse('$baseUrl/admin/banners'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });

    if (res.statusCode == 201 || res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      return BannerModel.fromJson(responseData);
    }

    throw Exception('Failed to create banner: ${res.body}');
  }

  /// Update banner
  Future<bool> updateBanner(String id, Map<String, dynamic> data) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/banners/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });

    return res.statusCode == 200;
  }

  /// Delete banner
  Future<bool> deleteBanner(String id) async {
    final res = await authService.sendWithAuth((token) {
      return http.delete(
        Uri.parse('$baseUrl/admin/banners/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    return res.statusCode == 200 || res.statusCode == 204;
  }

  /// Toggle banner active status
  Future<bool> toggleBannerStatus(String id, bool isActive) async {
    final res = await authService.sendWithAuth((token) {
      return http.patch(
        Uri.parse('$baseUrl/admin/banners/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_active': isActive}),
      );
    });

    return res.statusCode == 200;
  }

  // ============= PROBLEM REPORTS =============

  /// Get all problem reports
  Future<List<ProblemReport>> getProblemReports({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/admin/reports')
        .replace(queryParameters: queryParams);

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => ProblemReport.fromJson(e)).toList();
    }

    throw Exception('Failed to load problem reports: ${res.body}');
  }

  /// Get problem report by ID
  Future<ProblemReport> getProblemReportById(String id) async {
    final res = await authService.sendWithAuth((token) {
      return http.get(
        Uri.parse('$baseUrl/admin/reports/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ProblemReport.fromJson(data);
    }

    throw Exception('Failed to load problem report: ${res.body}');
  }

  /// Update problem report status
  Future<bool> updateReportStatus(
      String id, String status, String? notes) async {
    final res = await authService.sendWithAuth((token) {
      return http.patch(
        Uri.parse('$baseUrl/admin/reports/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
          if (notes != null) 'notes': notes,
        }),
      );
    });

    return res.statusCode == 200;
  }

  /// Assign report to admin
  Future<bool> assignReport(String reportId, String adminId) async {
    final res = await authService.sendWithAuth((token) {
      return http.patch(
        Uri.parse('$baseUrl/admin/reports/$reportId/assign'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'assigned_to': adminId}),
      );
    });

    return res.statusCode == 200;
  }

  /// Add comment to report
  Future<bool> addReportComment(String reportId, String message) async {
    final res = await authService.sendWithAuth((token) {
      return http.post(
        Uri.parse('$baseUrl/admin/reports/$reportId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );
    });

    return res.statusCode == 201 || res.statusCode == 200;
  }

  // ============= LETTER REQUESTS =============

  /// Get all letter requests
  Future<List<LetterRequest>> getLetterRequests({
    String? status,
    String? letterType,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (letterType != null) queryParams['letter_type'] = letterType;

    final uri = Uri.parse('$baseUrl/admin/letters')
        .replace(queryParameters: queryParams);

    final res = await authService.sendWithAuth((token) {
      return http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => LetterRequest.fromJson(e)).toList();
    }

    throw Exception('Failed to load letter requests: ${res.body}');
  }

  /// Get letter request by ID
  Future<LetterRequest> getLetterRequestById(String id) async {
    final res = await authService.sendWithAuth((token) {
      return http.get(
        Uri.parse('$baseUrl/admin/letters/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return LetterRequest.fromJson(data);
    }

    throw Exception('Failed to load letter request: ${res.body}');
  }

  /// Approve letter request
  Future<bool> approveLetterRequest(String id, String? notes) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/letters/$id/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (notes != null) 'notes': notes,
        }),
      );
    });

    return res.statusCode == 200;
  }

  /// Reject letter request
  Future<bool> rejectLetterRequest(String id, String reason) async {
    final res = await authService.sendWithAuth((token) {
      return http.put(
        Uri.parse('$baseUrl/admin/letters/$id/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'rejection_reason': reason}),
      );
    });

    return res.statusCode == 200;
  }

  /// Update letter request status
  Future<bool> updateLetterStatus(String id, String status) async {
    final res = await authService.sendWithAuth((token) {
      return http.patch(
        Uri.parse('$baseUrl/admin/letters/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
    });

    return res.statusCode == 200;
  }

  // ============= STATISTICS =============

  /// Get admin dashboard statistics
  Future<AdminStatistics> getStatistics() async {
    final res = await authService.sendWithAuth((token) {
      return http.get(
        Uri.parse('$baseUrl/admin/statistics'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return AdminStatistics.fromJson(data);
    }

    throw Exception('Failed to load statistics: ${res.body}');
  }
}
