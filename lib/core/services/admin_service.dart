import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/models/resident_registration_model.dart';
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';

class AdminService {
  final AuthService authService;
  final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";

  AdminService(this.authService);

  /// Get all resident registrations with pagination
  /// Filter by status: 'pending', 'approved', 'rejected', or null for all
  Future<ResidentRegistrationResponse> getResidentRegistrations({
    int limit = 20,
    int offset = 0,
    String? status,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/resident/users/list')
          .replace(queryParameters: queryParams);

      final response = await authService.sendWithAuth((token) {
        return http.get(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = ResidentRegistrationResponse.fromJson(data);
        
        // Filter only citizens
        final citizenData = result.data.where((user) => user.isCitizen).toList();
        
        return ResidentRegistrationResponse(
          total: citizenData.length,
          limit: result.limit,
          offset: result.offset,
          data: citizenData,
        );
      } else {
        throw Exception('Failed to load registrations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching registrations: $e');
    }
  }

  /// Get pending registrations (sorted alphabetically)
  Future<List<ResidentRegistrationModel>> getPendingRegistrations() async {
    try {
      final response = await getResidentRegistrations(limit: 100, offset: 0);
      
      final pendingUsers = response.data
          .where((user) => user.isPending && user.isCitizen)
          .toList();
      
      // Sort alphabetically by display name
      pendingUsers.sort((a, b) => 
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase())
      );
      
      return pendingUsers;
    } catch (e) {
      throw Exception('Error fetching pending registrations: $e');
    }
  }

  /// Get all other registrations (non-pending, sorted alphabetically)
  Future<List<ResidentRegistrationModel>> getOtherRegistrations({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await getResidentRegistrations(
        limit: limit,
        offset: offset,
      );
      
      final otherUsers = response.data
          .where((user) => !user.isPending && user.isCitizen)
          .toList();
      
      // Sort alphabetically by display name
      otherUsers.sort((a, b) => 
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase())
      );
      
      return otherUsers;
    } catch (e) {
      throw Exception('Error fetching other registrations: $e');
    }
  }

  /// Approve registration
  Future<void> approveRegistration(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/resident/accept/$userId')
          .replace(queryParameters: {'status': 'approved'});

      final response = await authService.sendWithAuth((token) {
        return http.put(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to approve registration');
      }
    } catch (e) {
      throw Exception('Error approving registration: $e');
    }
  }

  /// Decline/reject registration
  Future<void> declineRegistration(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/resident/decline/$userId');

      final response = await authService.sendWithAuth((token) {
        return http.put(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to decline registration');
      }
    } catch (e) {
      throw Exception('Error declining registration: $e');
    }
  }

  /// Get document URL (dummy for now until backend ready)
  String? getDocumentUrl(String? path) {
    if (path == null) return null;
    // TODO: Replace with actual document endpoint when ready
    return '$baseUrl/$path';
  }
}
