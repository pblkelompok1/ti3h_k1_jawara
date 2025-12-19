import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../../features/routes.dart'; // untuk navigatorKey


/// Provider untuk AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    onTokenExpired: () {
      // Gunakan navigatorKey global agar bisa redirect
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.go('/start'); // redirect ke login page
      }
    },
  );
});

