import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/report_service.dart';
import '../models/report_model.dart';

// Service provider
final reportServiceProvider = Provider((ref) => ReportService());

// Report list provider with filters
final reportListProvider = FutureProvider.family<ReportListResponse, ReportFilterParams>(
  (ref, params) async {
    final service = ref.watch(reportServiceProvider);
    return service.getReports(
      category: params.category,
      status: params.status,
      search: params.search,
      limit: params.limit,
      offset: params.offset,
    );
  },
);

// Single report provider
final reportDetailProvider = FutureProvider.family<ReportModel, String>(
  (ref, reportId) async {
    final service = ref.watch(reportServiceProvider);
    return service.getReportById(reportId);
  },
);

// Report filter state provider
final reportFilterProvider = StateNotifierProvider<ReportFilterNotifier, ReportFilterParams>(
  (ref) => ReportFilterNotifier(),
);

// Admin statistics provider
final adminReportStatsProvider = FutureProvider<ReportStatistics>((ref) async {
  final service = ref.watch(reportServiceProvider);
  
  // Fetch all reports to calculate statistics (max limit is 100)
  final allReports = await service.getReports(limit: 100);
  
  final unsolved = allReports.data.where((r) => r.status == ReportStatus.unsolved).length;
  final inProgress = allReports.data.where((r) => r.status == ReportStatus.inprogress).length;
  final solved = allReports.data.where((r) => r.status == ReportStatus.solved).length;
  
  final byCategory = <ReportCategory, int>{};
  for (final category in ReportCategory.values) {
    byCategory[category] = allReports.data.where((r) => r.category == category).length;
  }
  
  return ReportStatistics(
    total: allReports.total,
    unsolved: unsolved,
    inProgress: inProgress,
    solved: solved,
    byCategory: byCategory,
  );
});

// Filter parameters class
class ReportFilterParams {
  final String? category;
  final String? status;
  final String? search;
  final int limit;
  final int offset;

  ReportFilterParams({
    this.category,
    this.status,
    this.search,
    this.limit = 20,
    this.offset = 0,
  });

  ReportFilterParams copyWith({
    String? category,
    String? status,
    String? search,
    int? limit,
    int? offset,
  }) {
    return ReportFilterParams(
      category: category ?? this.category,
      status: status ?? this.status,
      search: search ?? this.search,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportFilterParams &&
        other.category == category &&
        other.status == status &&
        other.search == search &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return Object.hash(category, status, search, limit, offset);
  }
}

// Filter state notifier
class ReportFilterNotifier extends StateNotifier<ReportFilterParams> {
  ReportFilterNotifier() : super(ReportFilterParams());

  void setCategory(String? category) {
    state = state.copyWith(category: category, offset: 0);
  }

  void setStatus(String? status) {
    state = state.copyWith(status: status, offset: 0);
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search, offset: 0);
  }

  void setOffset(int offset) {
    state = state.copyWith(offset: offset);
  }

  void reset() {
    state = ReportFilterParams();
  }
}

// Statistics class
class ReportStatistics {
  final int total;
  final int unsolved;
  final int inProgress;
  final int solved;
  final Map<ReportCategory, int> byCategory;

  ReportStatistics({
    required this.total,
    required this.unsolved,
    required this.inProgress,
    required this.solved,
    required this.byCategory,
  });
}

// Report actions notifier for create, update, delete
class ReportActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ReportService _service;
  final Ref _ref;

  ReportActionsNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<ReportModel> createReport(CreateReportRequest request) async {
    state = const AsyncValue.loading();
    try {
      final report = await _service.createReport(request);
      state = const AsyncValue.data(null);
      // Invalidate list to refresh
      _ref.invalidate(reportListProvider);
      _ref.invalidate(adminReportStatsProvider);
      return report;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<ReportModel> updateReport(String reportId, UpdateReportRequest request) async {
    state = const AsyncValue.loading();
    try {
      final report = await _service.updateReport(reportId, request);
      state = const AsyncValue.data(null);
      // Invalidate to refresh
      _ref.invalidate(reportListProvider);
      _ref.invalidate(reportDetailProvider(reportId));
      _ref.invalidate(adminReportStatsProvider);
      return report;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<ReportModel> updateStatus(String reportId, ReportStatus status) async {
    state = const AsyncValue.loading();
    try {
      final report = await _service.updateReportStatus(reportId, status);
      state = const AsyncValue.data(null);
      // Invalidate to refresh
      _ref.invalidate(reportListProvider);
      _ref.invalidate(reportDetailProvider(reportId));
      _ref.invalidate(adminReportStatsProvider);
      return report;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteReport(reportId);
      state = const AsyncValue.data(null);
      // Invalidate to refresh
      _ref.invalidate(reportListProvider);
      _ref.invalidate(adminReportStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final reportActionsProvider = StateNotifierProvider<ReportActionsNotifier, AsyncValue<void>>(
  (ref) => ReportActionsNotifier(ref.watch(reportServiceProvider), ref),
);
