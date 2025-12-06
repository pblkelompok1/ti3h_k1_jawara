import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/features/admin/data/mock_admin_service.dart';
import 'package:ti3h_k1_jawara/features/admin/data/admin_models.dart';

// Mock Service Provider
final mockAdminServiceProvider = Provider<MockAdminService>((ref) {
  return MockAdminService();
});

// Statistics Provider Mock
final adminStatisticsProviderMock = FutureProvider<AdminStatistics>((ref) async {
  final service = ref.watch(mockAdminServiceProvider);
  return await service.getStatistics();
});

// Pending Registrations Notifier Mock
class PendingRegistrationsNotifierMock
    extends StateNotifier<AsyncValue<List<PendingRegistration>>> {
  final MockAdminService _service;

  PendingRegistrationsNotifierMock(this._service)
      : super(const AsyncValue.loading()) {
    loadRegistrations();
  }

  Future<void> loadRegistrations() async {
    state = const AsyncValue.loading();
    try {
      final registrations = await _service.getPendingRegistrations();
      state = AsyncValue.data(registrations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> approveRegistration(String userId) async {
    try {
      final success = await _service.approveRegistration(userId);
      if (success) {
        await loadRegistrations();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRegistration(String userId, String reason) async {
    try {
      final success = await _service.rejectRegistration(userId, reason);
      if (success) {
        await loadRegistrations();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

// Pending Registrations Provider Mock
final pendingRegistrationsProviderMock = StateNotifierProvider<
    PendingRegistrationsNotifierMock, AsyncValue<List<PendingRegistration>>>((ref) {
  final service = ref.watch(mockAdminServiceProvider);
  return PendingRegistrationsNotifierMock(service);
});

// Finance Admin Provider Mock (returns FinanceSummary)
final financeAdminProviderMock = 
    FutureProvider<FinanceSummary>((ref) async {
  final service = ref.watch(mockAdminServiceProvider);
  return await service.getFinanceSummary();
});

// Finance Filter Provider Mock
final financeFilterProviderMock = 
    StateProvider<Map<String, String?>>((ref) => {});

// Finance Transactions Provider Mock
final financeTransactionsProviderMock = 
    FutureProvider<List<FinanceReport>>((ref) async {
  final service = ref.watch(mockAdminServiceProvider);
  final filters = ref.watch(financeFilterProviderMock);
  return await service.getFinanceTransactions(filters: filters);
});
