import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/features/dashboard/widgets/FoodProductCards.dart';
import 'package:ti3h_k1_jawara/features/dashboard/widgets/RecommendedActivityList.dart';
import 'package:ti3h_k1_jawara/features/dashboard/widgets/BannerCarousel.dart';
import '../../layout/provider/ScrollVisibilityNotifier.dart';
import '../widgets/RtContactsCards.dart';
import '../widgets/TopBarWidget.dart';
import '../widgets/QuickActionsWidget.dart';
import '../../../core/themes/app_colors.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVisible = ref.watch(scrollVisibilityProvider).visible;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 130, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BannerCarousel(),
                const SizedBox(height: 24),
                const QuickActionsWidget(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const RecommendedActivityList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const RecommendedFoodCards(),
                const SizedBox(height: 32),
                const RtContactsCards(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // TOP APPBAR
          CustomTopBar(
            isVisible: isVisible,
          ),
        ],
      ),
    );
  }
}
