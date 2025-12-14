import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ProfileService {
  final AuthService _auth;
  final String baseUrl;

  ProfileService(this._auth) : baseUrl = _auth.baseUrl;

  Future<Map<String, dynamic>> getMyResident() async {
    final url = Uri.parse("$baseUrl/resident/me");

    final res = await _auth.sendWithAuth((token) {
      return http
          .get(url, headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          })
          .timeout(const Duration(seconds: 15));
    });

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception("Gagal ambil profile (${res.statusCode}): ${res.body}");
  }

  Future<List<Map<String, dynamic>>> getOccupationList() async {
    final url = Uri.parse("$baseUrl/resident-utils/occupation/list");

    final res = await _auth.sendWithAuth((token) {
      return http
          .get(url, headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          })
          .timeout(const Duration(seconds: 15));
    });

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) return decoded.cast<Map<String, dynamic>>();
      if (decoded is Map && decoded["data"] is List) {
        return (decoded["data"] as List).cast<Map<String, dynamic>>();
      }
      throw Exception("Format response occupation tidak sesuai: ${res.body}");
    }

    throw Exception("Gagal ambil occupation (${res.statusCode}): ${res.body}");
  }

  Future<Map<String, dynamic>> updateMyResident({
    required String? religion,
    required String? phone,
    required String? bloodType,
    required int? occupationId,
  }) async {
    final url = Uri.parse("$baseUrl/resident/me");

    final payload = <String, dynamic>{
      if (religion != null) "religion": religion,
      if (phone != null) "phone": phone,
      if (bloodType != null) "blood_type": bloodType,
      if (occupationId != null) "occupation_id": occupationId,
    };

    final res = await _auth.sendWithAuth((token) {
      return http
          .patch(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
    });

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception("Gagal update profile (${res.statusCode}): ${res.body}");
  }

  Future<Map<String, dynamic>> uploadProfileImage(File file) async {
    final url = Uri.parse("$baseUrl/resident/me/profile-image");

    // ✅ Multipart juga lewat sendWithAuth supaya auto-refresh jika 401
    final res = await _auth.sendWithAuth((token) async {
      final req = http.MultipartRequest("POST", url);
      req.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      req.files.add(await http.MultipartFile.fromPath("file", file.path));

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();

      return http.Response(
        body,
        streamed.statusCode,
        headers: streamed.headers,
        request: streamed.request,
      );
    });

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception("Gagal upload foto (${res.statusCode}): ${res.body}");
  }
}
