import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';
import 'package:ti3h_k1_jawara/features/admin/model/activity_model.dart';
import 'package:ti3h_k1_jawara/features/admin/repository/activity_repository.dart';

// ============= REPOSITORY PROVIDER =============

/// Provider for Activity Repository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ActivityRepository(authService);
});

// ============= ACTIVITY LIST PROVIDER =============

/// State notifier for activities list with pagination and filters
class ActivityListNotifier
    extends StateNotifier<AsyncValue<ActivityListResponse>> {
  final ActivityRepository repository;
  
  int _offset = 0;
  final int _limit = 20;
  String? _currentNameFilter;
  String? _currentStatusFilter;
  bool _hasMore = true;

  ActivityListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  /// Load initial activities
  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    _offset = 0;
    _hasMore = true;
    
    // DEBUG: Print filter parameters
    print('🔍 [ActivityListNotifier] Loading with filters:');
    print('   - Name Filter: $_currentNameFilter');
    print('   - Status Filter: $_currentStatusFilter');
    print('   - Offset: $_offset, Limit: $_limit');
    
    try {
      final response = await repository.getActivities(
        name: _currentNameFilter,
        status: _currentStatusFilter,
        offset: _offset,
        limit: _limit,
      );
      
      // DEBUG: Print response
      print('✅ [ActivityListNotifier] Response received:');
      print('   - Total Count: ${response.totalCount}');
      print('   - Data Length: ${response.data.length}');
      if (response.data.isNotEmpty) {
        print('   - First item status: ${response.data.first.status}');
      }
      
      _hasMore = response.data.length >= _limit;
      state = AsyncValue.data(response);
    } catch (e, stack) {
      print('❌ [ActivityListNotifier] Error: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Load more activities (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentData = state.value?.data ?? [];
    _offset += _limit;

    try {
      final response = await repository.getActivities(
        name: _currentNameFilter,
        status: _currentStatusFilter,
        offset: _offset,
        limit: _limit,
      );

      _hasMore = response.data.length >= _limit;

      state = AsyncValue.data(
        ActivityListResponse(
          totalCount: response.totalCount,
          data: [...currentData, ...response.data],
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Filter by name
  Future<void> filterByName(String? name) async {
    _currentNameFilter = name;
    await loadInitial();
  }

  /// Filter by status
  Future<void> filterByStatus(String? status) async {
    print('🔄 [ActivityListNotifier] Filtering by status: "$status"');
    _currentStatusFilter = status;
    await loadInitial();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _currentNameFilter = null;
    _currentStatusFilter = null;
    await loadInitial();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadInitial();
  }

  bool get hasMore => _hasMore;
}

final activityListProvider = StateNotifierProvider<ActivityListNotifier,
    AsyncValue<ActivityListResponse>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return ActivityListNotifier(repository);
});

// ============= ACTIVITY DETAIL PROVIDER =============

/// Provider for single activity detail
final activityDetailProvider =
    FutureProvider.family<ActivityModel, String>((ref, activityId) async {
  final repository = ref.watch(activityRepositoryProvider);
  return await repository.getActivityDetail(activityId);
});

// ============= ACTIVITY BY STATUS PROVIDERS =============

/// Provider for upcoming activities
final upcomingActivitiesProvider =
    FutureProvider<ActivityListResponse>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  return await repository.getUpcomingActivities(limit: 50);
});

/// Provider for ongoing activities
final ongoingActivitiesProvider =
    FutureProvider<ActivityListResponse>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  return await repository.getOngoingActivities(limit: 50);
});

/// Provider for completed activities
final completedActivitiesProvider =
    FutureProvider<ActivityListResponse>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  return await repository.getCompletedActivities(limit: 50);
});

// ============= ACTIVITY CRUD OPERATIONS =============

/// Create activity provider
final createActivityProvider = Provider<
    Future<ActivityModel> Function(ActivityRequest)>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return (request) async {
    final result = await repository.createActivity(request);
    // Invalidate list to refresh
    ref.invalidate(activityListProvider);
    return result;
  };
});

/// Update activity provider
final updateActivityProvider = Provider<
    Future<ActivityModel> Function(String, Map<String, dynamic>)>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return (activityId, updates) async {
    final result = await repository.updateActivity(activityId, updates);
    // Invalidate both list and detail
    ref.invalidate(activityListProvider);
    ref.invalidate(activityDetailProvider(activityId));
    return result;
  };
});

/// Delete activity provider
final deleteActivityProvider =
    Provider<Future<bool> Function(String)>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return (activityId) async {
    final result = await repository.deleteActivity(activityId);
    // Invalidate list to refresh
    ref.invalidate(activityListProvider);
    return result;
  };
});

/// Upload images provider
final uploadActivityImagesProvider = Provider<
    Future<UploadImagesResponse> Function(String, List<File>)>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return (activityId, files) async {
    final result = await repository.uploadImages(activityId, files);
    // Invalidate detail to refresh images
    ref.invalidate(activityDetailProvider(activityId));
    return result;
  };
});

// ============= SEARCH PROVIDER =============

/// Search activities provider
class ActivitySearchNotifier extends StateNotifier<AsyncValue<List<ActivityModel>>> {
  final ActivityRepository repository;
  String _lastQuery = '';

  ActivitySearchNotifier(this.repository) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;

    state = const AsyncValue.loading();

    try {
      final response = await repository.searchActivities(query, limit: 50);
      state = AsyncValue.data(response.data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clear() {
    _lastQuery = '';
    state = const AsyncValue.data([]);
  }
}

final activitySearchProvider = StateNotifierProvider<ActivitySearchNotifier,
    AsyncValue<List<ActivityModel>>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return ActivitySearchNotifier(repository);
});
