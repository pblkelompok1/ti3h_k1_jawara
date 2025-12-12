import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';

// Tabs
import '../widgets/account/MyProductsTab.dart';
import '../widgets/account/ActiveTransactionsTab.dart';
import '../widgets/account/TransactionHistoryTab.dart';
import '../widgets/account/MyOrdersTab.dart';

// Provider
import '../provider/account_provider.dart';

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});

  @override
  ConsumerState<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  bool _isAnimating = false;
  void _navigateToPage(int page) {
    if (!mounted) return;
    if (_isAnimating) return;

    // jika _pageController belum diinisialisasi / belum punya klien, langsung jump
    if (!(_pageController.hasClients)) {
      _pageController.jumpToPage(page);
      return;
    }

    setState(() => _isAnimating = true);

    _pageController
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          if (!mounted) return;
          setState(() => _isAnimating = false);
        });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(initialPage: 0);

    // Sync page dengan mode
    _pageController.addListener(() {
      if (_isAnimating) return;

      final page = _pageController.page ?? 0;
      if (page < 0.5 && ref.read(accountModeProvider) != "toko") {
        ref.read(accountModeProvider.notifier).state = "toko";
      } else if (page >= 0.5 && ref.read(accountModeProvider) != "keranjang") {
        ref.read(accountModeProvider.notifier).state = "keranjang";
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(accountModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          _buildHeader(context, mode),

          const SizedBox(height: 20),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              children: [_buildTokoPage(), const MyOrdersTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String mode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgDashboardAppHeader(context),
            AppColors.bgDashboardAppHeader(context).withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(context).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LEFT ICON + TITLE
            Row(
              children: [
                // Main icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    mode == "toko"
                        ? Icons.storefront_rounded
                        : Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Title
                Text(
                  mode == "toko" ? "Toko Saya" : "Pesanan Saya",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(accountModeProvider.notifier).state = "toko";
                      _navigateToPage(0);
                    },
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 22,
                      color: mode == "toko"
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(width: 14),

                  GestureDetector(
                    onTap: () {
                      ref.read(accountModeProvider.notifier).state =
                          "keranjang";
                      _navigateToPage(1);
                    },
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 22,
                      color: mode == "keranjang"
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokoPage() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.bgDashboardCard(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.softBorder(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary(context),
              borderRadius: BorderRadius.circular(11),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary(context),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: const [
              Tab(text: "Produk Saya"),
              Tab(text: "Transaksi"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              MyProductsTab(),
              ActiveTransactionsTab(),
              TransactionHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}
