import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';
import 'package:ti3h_k1_jawara/features/admin/data/admin_service.dart';
import 'package:ti3h_k1_jawara/features/admin/data/admin_models.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AdminService(authService);
});

// ============= STATISTICS PROVIDER =============

final adminStatisticsProvider =
    FutureProvider<AdminStatistics>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getStatistics();
});

// ============= PENDING REGISTRATIONS PROVIDER =============

class PendingRegistrationsNotifier
    extends StateNotifier<AsyncValue<List<PendingRegistration>>> {
  final AdminService _adminService;

  PendingRegistrationsNotifier(this._adminService)
      : super(const AsyncValue.loading()) {
    loadRegistrations();
  }

  Future<void> loadRegistrations() async {
    state = const AsyncValue.loading();
    try {
      final registrations = await _adminService.getPendingRegistrations();
      state = AsyncValue.data(registrations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> approveRegistration(String userId) async {
    try {
      final success = await _adminService.approveRegistration(userId);
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
      final success = await _adminService.rejectRegistration(userId, reason);
      if (success) {
        await loadRegistrations();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

final pendingRegistrationsProvider = StateNotifierProvider<
    PendingRegistrationsNotifier, AsyncValue<List<PendingRegistration>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return PendingRegistrationsNotifier(adminService);
});

// ============= FINANCE PROVIDER =============

class FinanceAdminNotifier extends StateNotifier<AsyncValue<List<FinanceReport>>> {
  final AdminService _adminService;
  String? _currentType;
  String? _currentCategory;
  String? _currentMonth;
  String? _currentYear;

  FinanceAdminNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions({
    String? type,
    String? category,
    String? month,
    String? year,
  }) async {
    _currentType = type ?? _currentType;
    _currentCategory = category ?? _currentCategory;
    _currentMonth = month ?? _currentMonth;
    _currentYear = year ?? _currentYear;

    state = const AsyncValue.loading();
    try {
      final transactions = await _adminService.getFinanceTransactions(
        type: _currentType,
        category: _currentCategory,
        month: _currentMonth,
        year: _currentYear,
      );
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> createTransaction(Map<String, dynamic> data) async {
    try {
      await _adminService.createFinanceTransaction(data);
      await loadTransactions();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      final success = await _adminService.updateFinanceTransaction(id, data);
      if (success) {
        await loadTransactions();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final success = await _adminService.deleteFinanceTransaction(id);
      if (success) {
        await loadTransactions();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void clearFilters() {
    _currentType = null;
    _currentCategory = null;
    _currentMonth = null;
    _currentYear = null;
    loadTransactions();
  }
}

final financeAdminProvider =
    StateNotifierProvider<FinanceAdminNotifier, AsyncValue<List<FinanceReport>>>(
  (ref) {
    final adminService = ref.watch(adminServiceProvider);
    return FinanceAdminNotifier(adminService);
  },
);

final financeSummaryProvider = FutureProvider.family<FinanceSummary, Map<String, String?>>(
  (ref, params) async {
    final adminService = ref.watch(adminServiceProvider);
    return await adminService.getFinanceSummary(
      month: params['month'],
      year: params['year'],
    );
  },
);

// ============= RESIDENT ADMIN PROVIDER =============

class ResidentAdminNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final AdminService _adminService;
  String? _currentStatus;
  String? _currentSearch;

  ResidentAdminNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadResidents();
  }

  Future<void> loadResidents({String? status, String? search}) async {
    _currentStatus = status ?? _currentStatus;
    _currentSearch = search ?? _currentSearch;

    state = const AsyncValue.loading();
    try {
      final residents = await _adminService.getResidents(
        status: _currentStatus,
        search: _currentSearch,
      );
      state = AsyncValue.data(residents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateResident(String id, Map<String, dynamic> data) async {
    try {
      final success = await _adminService.updateResident(id, data);
      if (success) {
        await loadResidents();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteResident(String id) async {
    try {
      final success = await _adminService.deleteResident(id);
      if (success) {
        await loadResidents();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeStatus(String id, String status) async {
    try {
      final success = await _adminService.changeResidentStatus(id, status);
      if (success) {
        await loadResidents();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void clearFilters() {
    _currentStatus = null;
    _currentSearch = null;
    loadResidents();
  }
}

final residentAdminProvider = StateNotifierProvider<ResidentAdminNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return ResidentAdminNotifier(adminService);
});

// ============= BANNER PROVIDER =============

class BannerAdminNotifier extends StateNotifier<AsyncValue<List<BannerModel>>> {
  final AdminService _adminService;
  String? _currentType;

  BannerAdminNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadBanners();
  }

  Future<void> loadBanners({String? type}) async {
    _currentType = type ?? _currentType;

    state = const AsyncValue.loading();
    try {
      final banners = await _adminService.getBanners(type: _currentType);
      state = AsyncValue.data(banners);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> createBanner(Map<String, dynamic> data) async {
    try {
      await _adminService.createBanner(data);
      await loadBanners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBanner(String id, Map<String, dynamic> data) async {
    try {
      final success = await _adminService.updateBanner(id, data);
      if (success) {
        await loadBanners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBanner(String id) async {
    try {
      final success = await _adminService.deleteBanner(id);
      if (success) {
        await loadBanners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStatus(String id, bool isActive) async {
    try {
      final success = await _adminService.toggleBannerStatus(id, isActive);
      if (success) {
        await loadBanners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

final bannerAdminProvider =
    StateNotifierProvider<BannerAdminNotifier, AsyncValue<List<BannerModel>>>(
  (ref) {
    final adminService = ref.watch(adminServiceProvider);
    return BannerAdminNotifier(adminService);
  },
);

// ============= PROBLEM REPORTS PROVIDER =============

class ProblemReportsNotifier
    extends StateNotifier<AsyncValue<List<ProblemReport>>> {
  final AdminService _adminService;
  String? _currentStatus;

  ProblemReportsNotifier(this._adminService)
      : super(const AsyncValue.loading()) {
    loadReports();
  }

  Future<void> loadReports({String? status}) async {
    _currentStatus = status ?? _currentStatus;

    state = const AsyncValue.loading();
    try {
      final reports = await _adminService.getProblemReports(status: _currentStatus);
      state = AsyncValue.data(reports);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateStatus(String id, String status, String? notes) async {
    try {
      final success = await _adminService.updateReportStatus(id, status, notes);
      if (success) {
        await loadReports();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> assignReport(String reportId, String adminId) async {
    try {
      final success = await _adminService.assignReport(reportId, adminId);
      if (success) {
        await loadReports();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addComment(String reportId, String message) async {
    try {
      return await _adminService.addReportComment(reportId, message);
    } catch (e) {
      return false;
    }
  }
}

final problemReportsProvider =
    StateNotifierProvider<ProblemReportsNotifier, AsyncValue<List<ProblemReport>>>(
  (ref) {
    final adminService = ref.watch(adminServiceProvider);
    return ProblemReportsNotifier(adminService);
  },
);

final problemReportDetailProvider =
    FutureProvider.family<ProblemReport, String>((ref, id) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getProblemReportById(id);
});

// ============= LETTER REQUESTS PROVIDER =============

class LetterRequestsNotifier extends StateNotifier<AsyncValue<List<LetterRequest>>> {
  final AdminService _adminService;
  String? _currentStatus;
  String? _currentLetterType;

  LetterRequestsNotifier(this._adminService)
      : super(const AsyncValue.loading()) {
    loadLetters();
  }

  Future<void> loadLetters({String? status, String? letterType}) async {
    _currentStatus = status ?? _currentStatus;
    _currentLetterType = letterType ?? _currentLetterType;

    state = const AsyncValue.loading();
    try {
      final letters = await _adminService.getLetterRequests(
        status: _currentStatus,
        letterType: _currentLetterType,
      );
      state = AsyncValue.data(letters);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> approveLetter(String id, String? notes) async {
    try {
      final success = await _adminService.approveLetterRequest(id, notes);
      if (success) {
        await loadLetters();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectLetter(String id, String reason) async {
    try {
      final success = await _adminService.rejectLetterRequest(id, reason);
      if (success) {
        await loadLetters();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLetterStatus(String id, String status) async {
    try {
      final success = await _adminService.updateLetterStatus(id, status);
      if (success) {
        await loadLetters();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void clearFilters() {
    _currentStatus = null;
    _currentLetterType = null;
    loadLetters();
  }
}

final letterRequestsProvider =
    StateNotifierProvider<LetterRequestsNotifier, AsyncValue<List<LetterRequest>>>(
  (ref) {
    final adminService = ref.watch(adminServiceProvider);
    return LetterRequestsNotifier(adminService);
  },
);

final letterRequestDetailProvider =
    FutureProvider.family<LetterRequest, String>((ref, id) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getLetterRequestById(id);
});

// ============= FILTER STATE PROVIDERS =============

final financeFilterTypeProvider = StateProvider<String?>((ref) => null);
final financeFilterCategoryProvider = StateProvider<String?>((ref) => null);
final financeFilterMonthProvider = StateProvider<String?>((ref) => null);
final financeFilterYearProvider = StateProvider<String?>((ref) => null);

final residentSearchQueryProvider = StateProvider<String>((ref) => '');
final residentFilterStatusProvider = StateProvider<String?>((ref) => null);

final reportFilterStatusProvider = StateProvider<String?>((ref) => null);
final letterFilterStatusProvider = StateProvider<String?>((ref) => null);
final letterFilterTypeProvider = StateProvider<String?>((ref) => null);

final bannerFilterTypeProvider = StateProvider<String?>((ref) => null);
