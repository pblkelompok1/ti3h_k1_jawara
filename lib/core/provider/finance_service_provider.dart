import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/finance_service.dart';
import 'auth_service_provider.dart';

/// Provider untuk FinanceService
final financeServiceProvider = Provider<FinanceService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return FinanceService(authService: authService);
});
