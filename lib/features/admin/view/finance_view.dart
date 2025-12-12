import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
import '../../finance/widgets/pie_dashboard.dart';
import '../../finance/widgets/search_transaction.dart';
import '../../finance/widgets/add_action_bottomsheet.dart';
import '../../finance/widgets/balance_text_loading.dart';

class AdminFinanceView extends ConsumerStatefulWidget {
  const AdminFinanceView({super.key});

  @override
  ConsumerState<AdminFinanceView> createState() => _AdminFinanceViewState();
}

class _AdminFinanceViewState extends ConsumerState<AdminFinanceView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  VoidCallback? _refreshSearch;
  Function(String)? _onSearchChanged;

  double _balance = 0.0;
  double _incomePercent = 0.0;
  double _expensePercent = 0.0;

  bool _isLoadingBalance = true;
  bool _isLoadingChart = true;
  String _currentPeriod = 'all';

  // Search state
  bool _isSearchActive = false;
  String _selectedFilter = 'Keuangan';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFinanceStats(_currentPeriod);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _onSearchChanged?.call('');
      }
    });
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
      final balanceData = await financeService.getBalance(period: period);

      final totalIncome = balanceData['total_income'] as double;
      final totalExpense = balanceData['total_expense'] as double;
      final total = totalIncome + totalExpense;

      setState(() {
        _balance = balanceData['total_balance'] as double;
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
    await _loadFinanceStats(_currentPeriod);
    _refreshSearch?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financeService = ref.watch(financeServiceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary(context),
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Kembali',
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: _isSearchActive
                          ? Container(
                              key: const ValueKey('search'),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary(context).withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary(context).withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primary(context),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Cari transaksi...',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      style: TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      onChanged: (value) {
                                        _onSearchChanged?.call(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: _toggleSearch,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.redAccent(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: AppColors.redAccent(context),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              key: const ValueKey('title'),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary(context),
                                          AppColors.primary(context).withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary(context).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Keuangan Admin',
                                          style: TextStyle(
                                            color: AppColors.textPrimary(context),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          'Kelola keuangan RT',
                                          style: TextStyle(
                                            color: AppColors.textSecondary(context),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary(context).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.search_rounded,
                                        color: AppColors.primary(context),
                                        size: 22,
                                      ),
                                      onPressed: _toggleSearch,
                                      tooltip: 'Cari transaksi',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshAll,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 24, bottom: 100),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Balance Section
                    Row(
                      children: [
                        Text(
                          "Total Saldo RT",
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
                    
                    // Pie Chart
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
                    const SizedBox(height: 24),
                    
                    // Search Transaction
                    SearchTransaction(
                      isDark: isDark,
                      financeService: financeService,
                      parentScrollController: _scrollController,
                      onRefreshCallback: (callback) => _refreshSearch = callback,
                      searchController: _searchController,
                      initialFilter: _selectedFilter,
                      onSearchCallback: (callback) => _onSearchChanged = callback,
                      onFilterChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      showSearchField: false,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddActionBottomSheet.show(context),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
    );
  }
}

// Filter Time Widget
class FilterTime extends StatelessWidget {
  final bool isDark;
  final Function(String) onPeriodChanged;

  const FilterTime({
    super.key,
    required this.isDark,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.filter_list_rounded,
        color: AppColors.primary(context),
        size: 20,
      ),
      onSelected: onPeriodChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('Semua')),
        const PopupMenuItem(value: 'today', child: Text('Hari Ini')),
        const PopupMenuItem(value: 'week', child: Text('Minggu Ini')),
        const PopupMenuItem(value: 'month', child: Text('Bulan Ini')),
        const PopupMenuItem(value: 'year', child: Text('Tahun Ini')),
      ],
    );
  }
}

// Legend Item Widget
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}
