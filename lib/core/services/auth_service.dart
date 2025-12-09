import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/models/user_model.dart';

typedef LogoutRedirect = void Function();

class AuthService {
  final storage = const FlutterSecureStorage();
  final baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev";

  LogoutRedirect? onTokenExpired; // ditambahkan

  AuthService({this.onTokenExpired});

  /// Stream yang terus menerus mengecek status approval user setiap 3 detik
  /// Mengembalikan true jika user sudah diapprove (is_pending = false)
  Stream<bool?> checkUserApprovalStream() async* {
    while (true) {
      try {
        final isApproved = await checkUserApprovalStatus();
        yield isApproved;
        print('[DEBUG]: is approved: $isApproved');
      } catch (e) {
        yield null;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      await storage.write(key: "access_token", value: data["access_token"]);
      await storage.write(key: "refresh_token", value: data["refresh_token"]);

      // Store user info including role
      if (data["user"] != null) {
        await storage.write(key: "user_data", value: jsonEncode(data["user"]));
      }

      return true;
    }

    return false;
  }

  Future<bool> register(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/signup");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      // Jika backend mengembalikan status 201 CREATED atau 200 OK
      return true;
    } else {
      // Bisa baca pesan error dari backend jika perlu
      final data = jsonDecode(res.body);
      final message = data['detail'] ?? 'Registration failed';
      throw Exception(message);
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: "access_token");
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: "refresh_token");
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  Future<UserModel?> getCurrentUser() async {
    final userDataJson = await storage.read(key: "user_data");
    if (userDataJson == null) return null;

    try {
      final userData = jsonDecode(userDataJson);
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  Future<http.Response> sendWithAuth(
    Future<http.Response> Function(String accessToken) requestFn,
  ) async {
    final accessToken = await getAccessToken();

    // request pertama
    var res = await requestFn(accessToken!);

    if (res.statusCode != 401) {
      return res;
    }

    // access token expired → refresh token
    final newAccessToken = await refreshAccessToken();
    if (newAccessToken == null) {
      await logout();
      throw Exception("Session expired");
    }

    // retry request
    return await requestFn(newAccessToken);
  }

  /// ===================================================
  /// Example use of sendWithAuth function for using endpoint with token

  // final res = await auth.sendWithAuth((token) {
  //   return http.get(
  //     Uri.parse("$baseUrl/resident"),
  //     headers: {"Authorization": "Bearer $token"},
  //   );
  // });

  /// ===================================================
  Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();

    final res = await http.post(
      Uri.parse("$baseUrl/auth/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await storage.write(key: "access_token", value: data["access_token"]);
      return data["access_token"];
    }

    await logout();

    // trigger redirect
    onTokenExpired?.call();

    return null;
  }

  Future<bool> checkUserResidentData() async {
    try {
      final res = await sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/auth/check_resident_data"),
          headers: {"Authorization": "Bearer $token"},
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['has_resident_data'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is approved (not pending anymore)
  /// Returns true if user is approved (is_pending = false)
  Future<bool> checkUserApprovalStatus() async {
    try {
      final res = await sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/auth/check_user_status"),
          headers: {"Authorization": "Bearer $token"},
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final isPending = data['is_pending'] ?? true;
        return !isPending; // Return true if user is approved
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get family ID of current user
  /// Returns family_id string from /auth/family endpoint
  Future<String?> getFamilyId() async {
    try {
      final res = await sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/auth/family"),
          headers: {"Authorization": "Bearer $token"},
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['family_id'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint("Error getting family ID: $e");
      return null;
    }
  }
}
