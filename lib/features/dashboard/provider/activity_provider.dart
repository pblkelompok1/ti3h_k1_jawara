import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/models/kegiatan_model.dart';
import 'package:ti3h_k1_jawara/core/services/activity_service.dart';

// Service provider
final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService();
});

// State class for activities with pagination
class ActivityState {
  final List<KegiatanModel> activities;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int offset;

  ActivityState({
    required this.activities,
    required this.isLoading,
    required this.hasMore,
    this.error,
    required this.offset,
  });

  ActivityState copyWith({
    List<KegiatanModel>? activities,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? offset,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      offset: offset ?? this.offset,
    );
  }

  factory ActivityState.initial() {
    return ActivityState(
      activities: [],
      isLoading: false,
      hasMore: true,
      error: null,
      offset: 0,
    );
  }
}

// Activity notifier for infinite scroll
class ActivityNotifier extends StateNotifier<ActivityState> {
  final ActivityService service;
  final String? statusFilter;

  ActivityNotifier(this.service, {this.statusFilter})
      : super(ActivityState.initial());

  static const int pageSize = 10;

  Future<void> loadActivities({bool refresh = false}) async {
    if (refresh) {
      state = ActivityState.initial();
    }

    if (state.isLoading || (!refresh && !state.hasMore)) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await service.getActivities(
        status: statusFilter,
        offset: refresh ? 0 : state.offset,
        limit: pageSize,
      );

      final newActivities = result['data'] as List<KegiatanModel>;
      final totalCount = result['total_count'] as int;

      final updatedActivities = refresh
          ? newActivities
          : [...state.activities, ...newActivities];

      final newOffset = refresh ? pageSize : state.offset + pageSize;
      final hasMore = updatedActivities.length < totalCount;

      state = state.copyWith(
        activities: updatedActivities,
        isLoading: false,
        hasMore: hasMore,
        offset: newOffset,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void refresh() {
    loadActivities(refresh: true);
  }
}

// Providers for different activity statuses
final allActivitiesProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final service = ref.watch(activityServiceProvider);
  return ActivityNotifier(service);
});

final akanDatangActivitiesProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final service = ref.watch(activityServiceProvider);
  return ActivityNotifier(service, statusFilter: 'akan_datang');
});

final ongoingActivitiesProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final service = ref.watch(activityServiceProvider);
  return ActivityNotifier(service, statusFilter: 'ongoing');
});

final selesaiActivitiesProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final service = ref.watch(activityServiceProvider);
  return ActivityNotifier(service, statusFilter: 'selesai');
});

// Recommended activities provider (untuk dashboard - shows latest 4 activities)
final recommendedActivitiesProvider =
    FutureProvider<List<KegiatanModel>>((ref) async {
  final service = ref.watch(activityServiceProvider);
  final result = await service.getActivities(
    status: 'akan_datang',
    offset: 0,
    limit: 4,
  );
  return result['data'] as List<KegiatanModel>;
});

// Popular activities provider (untuk dashboard - could be based on different criteria)
final popularActivitiesProvider =
    FutureProvider<List<KegiatanModel>>((ref) async {
  final service = ref.watch(activityServiceProvider);
  final result = await service.getActivities(
    offset: 0,
    limit: 4,
  );
  return result['data'] as List<KegiatanModel>;
});
