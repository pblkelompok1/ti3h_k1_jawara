import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/auth_service_provider.dart';
import '../../../core/services/auth_service.dart';

enum SignUpState { idle, loading, success, error }

class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthService authService;

  SignUpNotifier(this.authService) : super(SignUpState.idle);

  Future<void> signUp(String email, String password) async {
    try {
      state = SignUpState.loading;
      final success = await authService.register(email, password);
      if (success) {
        state = SignUpState.success;
      } else {
        state = SignUpState.error;
      }
    } catch (_) {
      state = SignUpState.error;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = SignUpState.loading;
      final success = await authService.login(email, password);
      if (success) {
        state = SignUpState.success;
      } else {
        state = SignUpState.error;
      }
    } catch (_) {
      state = SignUpState.error;
    }
  }
}

final signUpProvider =
StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  final authService = ref.read(authServiceProvider);
  return SignUpNotifier(authService);
});
