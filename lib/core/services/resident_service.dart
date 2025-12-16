import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/family_model.dart';
import '../models/resident_model.dart';

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

  /// Get list of residents with optional filters
  Future<Map<String, dynamic>> getResidentList({
    String? name,
    String? familyId,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String>[];
    
    if (name != null && name.isNotEmpty) {
      queryParams.add('name=$name');
    }
    if (familyId != null && familyId.isNotEmpty) {
      queryParams.add('family_id=$familyId');
    }
    queryParams.add('limit=$limit');
    queryParams.add('offset=$offset');
    
    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final url = Uri.parse("$baseUrl/resident/list$queryString");

    try {
      final response = await http.get(
        url,
        headers: {"accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'total': data['total'] as int? ?? 0,
          'limit': data['limit'] as int? ?? limit,
          'offset': data['offset'] as int? ?? offset,
          'data': data['data'] != null 
              ? (data['data'] as List)
                  .map((item) => ResidentModel.fromJson(item).toMap())
                  .toList()
              : [],
        };
      } else {
        throw Exception('Failed to load resident list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching resident list: $e');
    }
  }

  /// Get current user's family ID
  Future<String?> getUserFamilyId() async {
    return await _authService.getFamilyId();
  }

  /// Get residents of current user's family
  Future<List<Map<String, dynamic>>> getMyFamilyResidents({String? name}) async {
    try {
      final familyId = await getUserFamilyId();
      if (familyId == null) {
        return [];
      }

      final result = await getResidentList(
        name: name,
        familyId: familyId,
        limit: 100, // Get all family members
      );

      return List<Map<String, dynamic>>.from(result['data'] ?? []);
    } catch (e) {
      throw Exception('Error fetching family residents: $e');
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

  /// Update resident data (partial update)
  Future<Map<String, dynamic>> updateResident({
    required String residentId,
    String? name,
    String? phone,
    String? placeOfBirth,
    String? dateOfBirth,
    String? gender,
    String? familyRole,
    String? religion,
    String? bloodType,
    int? occupationId,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final url = Uri.parse("$baseUrl/resident/$residentId");

    // Build update data, only include non-null values
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (placeOfBirth != null) updateData['place_of_birth'] = placeOfBirth;
    if (dateOfBirth != null) updateData['date_of_birth'] = dateOfBirth;
    if (gender != null) updateData['gender'] = gender;
    if (familyRole != null) updateData['family_role'] = familyRole;
    if (religion != null) updateData['religion'] = religion;
    if (bloodType != null) updateData['blood_type'] = bloodType;
    if (occupationId != null) updateData['occupation_id'] = occupationId;

    try {
      final response = await http.put(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update resident: ${response.statusCode} → ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating resident: $e');
    }
  }

  /// Upload resident profile image
  Future<Map<String, dynamic>> uploadProfileImage({
    required String residentId,
    required File imageFile,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final uri = Uri.parse("$baseUrl/resident/$residentId/profile");
    final request = http.MultipartRequest("PUT", uri);

    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(respStr);
    } else {
      throw Exception("Failed to upload profile image: ${response.statusCode} → $respStr");
    }
  }

  /// Upload resident KTP image
  Future<Map<String, dynamic>> uploadKtpImage({
    required String residentId,
    required File imageFile,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final uri = Uri.parse("$baseUrl/resident/$residentId/ktp");
    final request = http.MultipartRequest("PUT", uri);

    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(respStr);
    } else {
      throw Exception("Failed to upload KTP image: ${response.statusCode} → $respStr");
    }
  }

  /// Complete update for resident - handles profile, KTP upload and data update
  Future<Map<String, dynamic>> updateResidentComplete({
    required String residentId,
    File? profileImage,
    File? ktpImage,
    String? name,
    String? phone,
    String? placeOfBirth,
    String? gender,
    String? familyRole,
    String? religion,
    String? bloodType,
    int? occupationId,
  }) async {
    try {
      final results = <String, dynamic>{};

      // 1. Upload profile image if provided
      if (profileImage != null) {
        final profileResult = await uploadProfileImage(
          residentId: residentId,
          imageFile: profileImage,
        );
        results['profile_upload'] = profileResult;
      }

      // 2. Upload KTP image if provided
      if (ktpImage != null) {
        final ktpResult = await uploadKtpImage(
          residentId: residentId,
          imageFile: ktpImage,
        );
        results['ktp_upload'] = ktpResult;
      }

      // 3. Update resident data
      final updateResult = await updateResident(
        residentId: residentId,
        name: name,
        phone: phone,
        placeOfBirth: placeOfBirth,
        gender: gender,
        familyRole: familyRole,
        religion: religion,
        bloodType: bloodType,
        occupationId: occupationId,
      );
      results['data_update'] = updateResult;

      return {
        'success': true,
        'message': 'Resident berhasil diupdate',
        'results': results,
      };
    } catch (e) {
      throw Exception('Error updating resident complete: $e');
    }
  }
}
