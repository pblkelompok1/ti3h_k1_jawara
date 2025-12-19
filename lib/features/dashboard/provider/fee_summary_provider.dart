import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/models/fee_summary_model.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';

import '../../../core/provider/auth_service_provider.dart';

// State for Fee Summary
class FeeSummaryState {
  final FeeSummaryModel? data;
  final bool isLoading;
  final String? error;

  FeeSummaryState({this.data, this.isLoading = false, this.error});

  FeeSummaryState copyWith({
    FeeSummaryModel? data,
    bool? isLoading,
    String? error,
  }) {
    return FeeSummaryState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier for Fee Summary
class FeeSummaryNotifier extends StateNotifier<FeeSummaryState> {
  final Ref ref;

  FeeSummaryNotifier(this.ref) : super(FeeSummaryState());

  Future<void> loadFeeSummary() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get user ID from auth service
      final authService = ref.read(authServiceProvider);
      final user = await authService.getCurrentUser();

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch fee summary
      final financeService = ref.read(financeServiceProvider);
      final summary = await financeService.getFeeSummary(user.id);

      state = state.copyWith(data: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    loadFeeSummary();
  }
}

// Provider for Fee Summary
final feeSummaryProvider =
    StateNotifierProvider<FeeSummaryNotifier, FeeSummaryState>((ref) {
      return FeeSummaryNotifier(ref);
    });
