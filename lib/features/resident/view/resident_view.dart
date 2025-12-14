import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import '../widgets/ResidentTopBar.dart';
import '../widgets/MyFamilySection.dart';
import '../widgets/ResidentsSection.dart';
import '../widgets/FamiliesSection.dart';

class ResidentView extends ConsumerStatefulWidget {
  const ResidentView({super.key});

  @override
  ConsumerState<ResidentView> createState() => _ResidentViewState();
}

class _ResidentViewState extends ConsumerState<ResidentView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(selectedTabProvider.notifier).state = _tabController.index;
      }
    });

    // Initial data fetch for My Family
    Future.microtask(() => 
      ref.read(myFamilyProvider.notifier).fetchMyFamily()
    );
  }

  Future<void> _handleRefresh() async {
    final currentTab = _tabController.index;
    
    // Refresh data based on current tab
    switch (currentTab) {
      case 0: // Keluarga Saya
        await ref.read(myFamilyProvider.notifier).fetchMyFamily();
        break;
      case 1: // Warga
        await ref.read(residentListProvider.notifier).fetchResidents();
        break;
      case 2: // Keluarga
        // Families data is static for now, but can be extended later
        await Future.delayed(const Duration(milliseconds: 500));
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              const SizedBox(height: 130), // Space for top bar
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.softBorder(context),
                    width: 1.5,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary(context),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Keluarga Saya'),
                    Tab(text: 'Warga'),
                    Tab(text: 'Keluarga'),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tab Content with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppColors.primary(context),
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      MyFamilySection(),
                      ResidentsSection(),
                      FamiliesSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Top Bar
          ResidentTopBar(
            onSearchPressed: _showSearchDialog,
            onRefreshPressed: _handleRefresh,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.primary(context),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Gunakan kolom pencarian di masing-masing tab untuk mencari data warga atau keluarga.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
