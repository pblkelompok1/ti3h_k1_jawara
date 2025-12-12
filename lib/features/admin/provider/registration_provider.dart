import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/models/resident_registration_model.dart';
import 'package:ti3h_k1_jawara/core/services/admin_service.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AdminService(authService);
});

// Pending Registrations Provider
final pendingRegistrationsProvider = FutureProvider<List<ResidentRegistrationModel>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getPendingRegistrations();
});

// Other Registrations Provider with Pagination State
class OtherRegistrationsNotifier extends StateNotifier<AsyncValue<List<ResidentRegistrationModel>>> {
  final AdminService adminService;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  OtherRegistrationsNotifier(this.adminService) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      _offset = 0;
      _hasMore = true;
      final data = await adminService.getOtherRegistrations(limit: _limit, offset: _offset);
      state = AsyncValue.data(data);
      _offset += _limit;
      _hasMore = data.length >= _limit;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentData = state.value ?? [];
    try {
      final newData = await adminService.getOtherRegistrations(limit: _limit, offset: _offset);
      state = AsyncValue.data([...currentData, ...newData]);
      _offset += _limit;
      _hasMore = newData.length >= _limit;
    } catch (e, stack) {
      // Keep current data on error
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  bool get hasMore => _hasMore;
}

final otherRegistrationsProvider = StateNotifierProvider<OtherRegistrationsNotifier, AsyncValue<List<ResidentRegistrationModel>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return OtherRegistrationsNotifier(adminService);
});

// Actions Provider for approve/decline
class RegistrationActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final AdminService adminService;
  final Ref ref;

  RegistrationActionsNotifier(this.adminService, this.ref) : super(const AsyncValue.data(null));

  Future<void> approveRegistration(String userId) async {
    state = const AsyncValue.loading();
    try {
      await adminService.approveRegistration(userId);
      state = const AsyncValue.data(null);
      
      // Refresh both lists
      ref.invalidate(pendingRegistrationsProvider);
      ref.read(otherRegistrationsProvider.notifier).refresh();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> declineRegistration(String userId) async {
    state = const AsyncValue.loading();
    try {
      await adminService.declineRegistration(userId);
      state = const AsyncValue.data(null);
      
      // Refresh both lists
      ref.invalidate(pendingRegistrationsProvider);
      ref.read(otherRegistrationsProvider.notifier).refresh();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final registrationActionsProvider = StateNotifierProvider<RegistrationActionsNotifier, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return RegistrationActionsNotifier(adminService, ref);
});
