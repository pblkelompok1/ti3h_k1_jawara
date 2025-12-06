import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/enum/auth_flow_status.dart';
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';
import '../../../core/provider/auth_service_provider.dart';

final authFlowProvider =
    AsyncNotifierProvider.autoDispose<AuthFlowNotifier, AuthFlowStatus>(
      () => AuthFlowNotifier(),
    );

class AuthFlowNotifier extends AutoDisposeAsyncNotifier<AuthFlowStatus> {
  late AuthService _authService;

  @override
  FutureOr<AuthFlowStatus> build() async {
    _authService = ref.read(authServiceProvider);

    final accessToken = await _authService.getAccessToken();
    final refreshToken = await _authService.getRefreshToken();


    if (accessToken == null || refreshToken == null) {
      return AuthFlowStatus.notLoggedIn;
    }

    // Check if user is admin
    final isAdmin = await _authService.isAdmin();
    if (isAdmin) {
      return AuthFlowStatus.admin;
    }

    // Check if user resident data is not null
    final profileComplete = await _authService.checkUserResidentData();
    if (!profileComplete) {
      return AuthFlowStatus.incompleteData;
    }     

    // Check if user is approved (checkUserApprovalStatus returns true if approved)
    final isApproved = await _authService.checkUserApprovalStatus();
    if (!isApproved) {
      // User is still pending approval
      return AuthFlowStatus.uninitialized;
    }

    return AuthFlowStatus.ready;
  }
}
