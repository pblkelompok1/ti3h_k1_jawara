import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
import '../../layout/provider/ScrollVisibilityNotifier.dart';
import '../widgets/tagihan_section.dart';
import '../widgets/pie_dashboard.dart';
import '../widgets/search_transaction.dart';
import '../widgets/finance_topbar.dart';
import '../widgets/add_action_bottomsheet.dart';
import '../widgets/balance_text_loading.dart';

class FinanceView extends ConsumerStatefulWidget {
  const FinanceView({super.key});

  @override
  ConsumerState<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends ConsumerState<FinanceView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  VoidCallback? _refreshTagihan;
  VoidCallback? _refreshSearch;
  Function(String)? _onSearchChanged;
  Function(String)? _onFilterChanged;

  double _balance = 0.0;
  double _incomePercent = 0.0;
  double _expensePercent = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  bool _isLoadingBalance = true;
  bool _isLoadingChart = true;
  String _currentPeriod = 'all';

  // Sticky search bar state
  bool _isStickyBarVisible = false;
  String _selectedFilter = 'Keuangan';
  final double _stickyThreshold = 600.0;

  @override
  void initState() {
    super.initState();

    // Add scroll listener for header visibility
    _scrollController.addListener(_onScroll);

    // Defer heavy operations to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFinanceStats(_currentPeriod);
    });
  }

  double _lastScrollPosition = 0.0;

  void _onScroll() {
    if (_scrollController.hasClients) {
      final currentScroll = _scrollController.offset;
      final visibility = ref.read(scrollVisibilityProvider);

      // Sticky search bar visibility
      final shouldShowSticky = currentScroll > _stickyThreshold;
      if (_isStickyBarVisible != shouldShowSticky) {
        setState(() {
          _isStickyBarVisible = shouldShowSticky;
        });
      }

      // Header visibility - only allow showing when sticky bar is not visible
      if (!_isStickyBarVisible) {
        if (currentScroll > _lastScrollPosition && currentScroll > 50) {
          visibility.hide();
        } else if (currentScroll < _lastScrollPosition) {
          visibility.show();
        }
      } else {
        // Always hide header when sticky bar is visible
        visibility.hide();
      }

      _lastScrollPosition = currentScroll;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFinanceStats(String period) async {
    setState(() {
      _isLoadingBalance = true;
      _isLoadingChart = true;
      _currentPeriod = period;
    });

    try {
      final financeService = ref.read(financeServiceProvider);

      // Load balance data from new endpoint
      final balanceData = await financeService.getBalance(period: period);

      final totalIncome = balanceData['total_income'] as double;
      final totalExpense = balanceData['total_expense'] as double;
      final total = totalIncome + totalExpense;

      setState(() {
        _balance = balanceData['total_balance'] as double;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        _incomePercent = total == 0 ? 0 : (totalIncome / total) * 100;
        _expensePercent = total == 0 ? 0 : (totalExpense / total) * 100;
        _isLoadingBalance = false;
        _isLoadingChart = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBalance = false;
        _isLoadingChart = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _refreshAll() async {
    // Refresh finance stats
    await _loadFinanceStats(_currentPeriod);

    // Refresh tagihan section
    _refreshTagihan?.call();

    // Refresh search/transaction list
    _refreshSearch?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financeService = ref.watch(financeServiceProvider);
    final isVisible = ref.watch(scrollVisibilityProvider).visible;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshAll,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 130, bottom: 100),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TagihanSection(
                      isDark: isDark,
                      financeService: ref.read(financeServiceProvider),
                      onRefreshCallback: (callback) =>
                          _refreshTagihan = callback,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "Total Saldo",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const Spacer(),
                        FilterTime(
                          isDark: isDark,
                          onPeriodChanged: (period) {
                            _loadFinanceStats(period);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingBalance)
                      const BalanceTextLoading()
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Rp ${_balance.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    PieDashboard(
                      isDark: isDark,
                      income: _incomePercent,
                      expense: _expensePercent,
                      isLoading: _isLoadingChart,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LegendItem(
                          color: AppColors.primary(context),
                          label: "Pemasukan",
                        ),
                        const SizedBox(width: 25),
                        LegendItem(
                          color: AppColors.redAccent(context),
                          label: "Pengeluaran",
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SearchTransaction(
                      isDark: isDark,
                      financeService: financeService,
                      parentScrollController: _scrollController,
                      onRefreshCallback: (callback) =>
                          _refreshSearch = callback,
                      searchController: _searchController,
                      initialFilter: _selectedFilter,
                      onSearchCallback: (callback) =>
                          _onSearchChanged = callback,
                      onFilterCallback: (callback) =>
                          _onFilterChanged = callback,
                      onFilterChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // TOP APPBAR dengan animasi slide
          FinanceTopBar(isVisible: isVisible),

          // STICKY SEARCH BAR with Filter Tabs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              offset: _isStickyBarVisible ? Offset.zero : const Offset(0, -1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isStickyBarVisible ? 1.0 : 0.0,
                child: Container(
                  padding: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari transaksi...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.textSecondary(context),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.bgDashboardCard(
                                    context,
                                  ).withOpacity(0.5)
                                : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            _onSearchChanged?.call(value);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: ['Keuangan', 'Iuran'].map((label) {
                            final active = _selectedFilter == label;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = label;
                                });
                                _onFilterChanged?.call(label);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: active
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: active
                                            ? AppColors.textPrimary(context)
                                            : AppColors.textSecondary(context),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 30,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? AppColors.primary(context)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => AddActionBottomSheet.show(context),
          backgroundColor: AppColors.primary(context),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah'),
        ),
      ),
    );
  }
}
