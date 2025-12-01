import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/account_provider.dart';
import '../widgets/account/MyProductsTab.dart';
import '../widgets/account/ActiveTransactionsTab.dart';
import '../widgets/account/TransactionHistoryTab.dart';
import '../widgets/account/MyOrdersTab.dart';

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});

  @override
  ConsumerState<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(accountSelectedTabProvider.notifier).state =
            _tabController.index;
      }
    });
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
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Top Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgDashboardAppHeader(context),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Profile Info
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.textPrimaryDark,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akun Saya',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Current User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

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
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Produk Saya'),
                Tab(text: 'Transaksi'),
                Tab(text: 'Riwayat'),
                Tab(text: 'Pesanan'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MyProductsTab(),
                ActiveTransactionsTab(),
                TransactionHistoryTab(),
                MyOrdersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
