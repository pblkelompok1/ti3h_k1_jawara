import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/features/dashboard/widgets/FoodProductCards.dart';
import 'package:ti3h_k1_jawara/features/dashboard/widgets/RecommendedActivityList.dart';
import 'package:ti3h_k1_jawara/features/dashboard/widgets/BannerCarousel.dart';
import '../../layout/provider/ScrollVisibilityNotifier.dart';
import '../widgets/RtContactsCards.dart';
import '../widgets/StatCards.dart';
import '../widgets/TopBarWidget.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final PageController _pageController = PageController(
    viewportFraction: 0.88, // 88% dari lebar layar
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final isVisible = ref
        .watch(scrollVisibilityProvider)
        .visible;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BannerCarousel(),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 5, left: 25, right: 25),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    RecommendedActivityList(),
                    const SizedBox(height: 40),
                    const PaymentSummaryCards(),
                    const SizedBox(height: 60),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: RecommendedFoodCards(),
              ),
              SliverToBoxAdapter(
                child: RtContactsCards(),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text('This is the end'),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ],
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
