import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
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

  double _balance = 0.0;
  double _incomePercent = 0.0;
  double _expensePercent = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  bool _isLoadingBalance = true;
  bool _isLoadingChart = true;
  String _currentPeriod = 'all';

  @override
  void initState() {
    super.initState();
    _loadFinanceStats(_currentPeriod);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financeService = ref.watch(financeServiceProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      body: CustomScrollView(
        slivers: [
          FinanceTopBarSliver(
            title: "Keuangan",
            rightIcon: Icons.notifications_rounded,
            onRightTap: () {},
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TagihanSection(isDark: isDark),
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
                  ),
                  const SizedBox(height: 24),
                ],
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
