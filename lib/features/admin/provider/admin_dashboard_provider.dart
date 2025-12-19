import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_statistics.dart';
import '../../../core/models/finance_summary.dart';
import '../../../core/services/admin_dashboard_service.dart';
import '../../../core/provider/auth_service_provider.dart';

// Provider for AdminDashboardService
final adminDashboardServiceProvider = Provider<AdminDashboardService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AdminDashboardService(authService);
});

// Provider for Admin Statistics
final adminStatisticsProvider = FutureProvider.autoDispose<AdminStatistics>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return await service.getStatistics();
});

// Provider for Finance Summary
final financeSummaryProvider = FutureProvider.autoDispose<FinanceSummary>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return await service.getFinanceSummary();
});
