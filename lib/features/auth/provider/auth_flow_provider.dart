import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/enum/auth_flow_status.dart';
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';
import '../../../core/provider/auth_service_provider.dart';

final authFlowProvider =
    AsyncNotifierProvider<AuthFlowNotifier, AuthFlowStatus>(
      () => AuthFlowNotifier(),
    );

class AuthFlowNotifier extends AsyncNotifier<AuthFlowStatus> {
  late AuthService _authService;

  // @override
  FutureOr<AuthFlowStatus> build() async {
    _authService = ref.read(authServiceProvider);

    final accessToken = await _authService.getAccessToken();
    final refreshToken = await _authService.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      print('object: ------- Not Logged In -----');
      print(await _authService.getAccessToken());
      return AuthFlowStatus.notLoggedIn;
    }

    final profileComplete = await _checkUserProfile();
    if (!profileComplete) {
      print('object: ------- Data Incomplete -----');
      print(await _authService.getAccessToken());
      return AuthFlowStatus.incompleteData;
    }     

    final isPending = await _checkIsUserPending();
    if (isPending) {
      print('object: ------- User Pending -----');
      print(await _authService.getAccessToken());
      return AuthFlowStatus.uninitialized;
    }

    print('object: ------- Ready -----');
    print(await _authService.getAccessToken());
    return AuthFlowStatus.ready;
  }

  Future<bool> _checkUserProfile() async {
    try {
      final res = await _authService.sendWithAuth((token) {
        return http.get(
          Uri.parse("${_authService.baseUrl}/auth/check_resident_data"),
          headers: {"Authorization": "Bearer $token"},
        );
      });

      print('[DEBUG] check_resident_data status: [33m${res.statusCode}[0m');
      print('[DEBUG] check_resident_data body: [36m${res.body}[0m');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('[DEBUG] check_resident_data parsed: $data');
        return data['has_resident_data'] ?? false;
      }
      return false;
    } catch (e) {
      print('[ERROR] check_resident_data: $e');
      return false;
    }
  }

  Future<bool> _checkIsUserPending() async {
    try {
      final res = await _authService.sendWithAuth((token) {
        return http.get(
          Uri.parse("${_authService.baseUrl}/auth/check_user_status"),
          headers: {"Authorization": "Bearer $token"},
        );
      });

      print('[DEBUG] check_user_status status: [33m${res.statusCode}[0m');
      print('[DEBUG] check_user_status body: [36m${res.body}[0m');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('[DEBUG] check_user_status parsed: $data');
        return data['is_pending'] ?? false;
      }
      return false;
    } catch (e) {
      print('[ERROR] check_user_status: $e');
      return false;
    }
  }
}
