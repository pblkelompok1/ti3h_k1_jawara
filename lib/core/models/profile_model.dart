import 'package:ti3h_k1_jawara/core/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProfile {
  final String? name;
  final String? email;
  final String? profileImgUrl;

  UserProfile({this.name, this.email, this.profileImgUrl});
}

  /// Ambil nama, email, dan foto profil user
  Future<UserProfile?> fetchUserProfile() async {
    final authService = AuthService();
    final storage = const FlutterSecureStorage();
    final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) return null;

    // 1. Get user_id, role, email (jika ada)
    String? email;
    try {
      final meRes = await http.post(
        Uri.parse("$baseUrl/auth/me"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );
      if (meRes.statusCode == 200) {
        // Coba ambil email dari storage (sudah disimpan saat login)
        final userDataJson = await storage.read(key: "user_data");
        if (userDataJson != null) {
          final userData = jsonDecode(userDataJson);
          email = userData['email'];
        }
      }
    } catch (_) {}

    // 2. Get name & profile image
    try {
      final residentRes = await http.get(
        Uri.parse("$baseUrl/resident/me"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );
      if (residentRes.statusCode == 200) {
        final residentData = jsonDecode(residentRes.body);
        final name = residentData['name'] as String?;
        final profileImgPath = residentData['profile_img_path'] as String?;
        final profileImgUrl = profileImgPath != null ? "$baseUrl/$profileImgPath" : null;
        return UserProfile(name: name, email: email, profileImgUrl: profileImgUrl);
      }
    } catch (_) {}
    return null;
  }