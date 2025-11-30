import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

typedef LogoutRedirect = void Function();

class ResidentService {
  final baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev";
  late AuthService _authService;

  ResidentService(AuthService authService) {
    _authService = authService;
  }

  Future<List<Map<String, dynamic>>> getFamilyList({String? name}) async {
    final queryParams = name != null && name.isNotEmpty
        ? '?name=$name'
        : '';
    
    final url = Uri.parse("$baseUrl/resident-utils/family/list$queryParams");

    try {
      final response = await http.get(
        url,
        headers: {"accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns a list of families
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('Failed to load family list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching family list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOccupationList({String? name}) async {
    final queryParams = name != null && name.isNotEmpty
        ? '?name=$name'
        : '';
    
    final url = Uri.parse("$baseUrl/resident-utils/occupation/list$queryParams");

    try {
      final response = await http.get(
        url,
        headers: {"accept": "application/json"},
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
        throw Exception('Failed to load occupation list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching occupation list: $e');
    }
  }

  Future<Map<String, dynamic>> createResidentSubmission({
    required String name,
    required String nik,
    required String placeOfBirth,
    required String dateOfBirth,
    required String gender,
    required String familyRole,
    required String familyId,
    required String occupationId,
    required File ktpFile,
    required File kkFile,
    required File birthCertificateFile,
    String? phone,
    String? religion,
    String? domicileStatus,
    String? status,
    String? bloodType,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final uri = Uri.parse("$baseUrl/auth/resident/submissions");

    final request = http.MultipartRequest("POST", uri);

    // **HEADER WAJIB ADA**
    request.headers["Authorization"] = "Bearer $token";

    // Form fields
    request.fields["name"] = name;
    request.fields["nik"] = nik;
    request.fields["place_of_birth"] = placeOfBirth;
    request.fields["date_of_birth"] = dateOfBirth;
    request.fields["gender"] = gender;
    request.fields["family_role"] = familyRole;
    request.fields["family_id"] = familyId;
    request.fields["occupation_id"] = occupationId;
    if (phone != null) request.fields["phone"] = phone;
    if (religion != null) request.fields["religion"] = religion;
    if (domicileStatus != null) request.fields["domicile_status"] = domicileStatus;
    if (bloodType != null) request.fields["blood_type"] = bloodType;
    if (status != null) request.fields["status"] = status;

    // Files
    request.files.add(await http.MultipartFile.fromPath("ktp_file", ktpFile.path));
    request.files.add(await http.MultipartFile.fromPath("kk_file", kkFile.path));
    request.files.add(await http.MultipartFile.fromPath("birth_certificate_file", birthCertificateFile.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(respStr);
    } else {
      throw Exception("Failed: ${response.statusCode} → $respStr");
    }
  }
}
