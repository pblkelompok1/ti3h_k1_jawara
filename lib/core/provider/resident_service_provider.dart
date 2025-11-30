import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/resident_service.dart';
import 'auth_service_provider.dart';

final residentServiceProvider = Provider<ResidentService>((ref) {
  final AuthService authService = ref.read(authServiceProvider);
  return ResidentService(authService);
});
