import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/models/fee_transaction_model.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
import 'package:ti3h_k1_jawara/features/dashboard/provider/fee_summary_provider.dart';

class IuranWargaView extends ConsumerStatefulWidget {
  const IuranWargaView({super.key});

  @override
  ConsumerState<IuranWargaView> createState() => _IuranWargaViewState();
}

class _IuranWargaViewState extends ConsumerState<IuranWargaView> {
  List<FeeTransactionModel> _unpaidFees = [];
  List<FeeTransactionModel> _paidFees = [];
  bool _isLoadingUnpaid = true;
  bool _isLoadingPaid = true;
  String? _errorUnpaid;
  String? _errorPaid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeeSummary();
      _loadUnpaidFees();
      _loadPaidFees();
    });
  }

  Future<void> _loadFeeSummary() async {
    ref.read(feeSummaryProvider.notifier).loadFeeSummary();
  }

  Future<void> _loadUnpaidFees() async {
    setState(() {
      _isLoadingUnpaid = true;
      _errorUnpaid = null;
    });

    try {
      final financeService = ref.read(financeServiceProvider);
      final result = await financeService.getFeeTransactions(
        status: 'unpaid',
        limit: 50,
      );

      setState(() {
        _unpaidFees = result.data;
        _isLoadingUnpaid = false;
      });
    } catch (e) {
      setState(() {
        _errorUnpaid = e.toString();
        _isLoadingUnpaid = false;
      });
    }
  }

  Future<void> _loadPaidFees() async {
    setState(() {
      _isLoadingPaid = true;
      _errorPaid = null;
    });

    try {
      final financeService = ref.read(financeServiceProvider);
      final result = await financeService.getFeeTransactions(
        status: 'paid',
        limit: 10,
      );

      setState(() {
        _paidFees = result.data;
        _isLoadingPaid = false;
      });
    } catch (e) {
      setState(() {
        _errorPaid = e.toString();
        _isLoadingPaid = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadFeeSummary(), _loadUnpaidFees(), _loadPaidFees()]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryState = ref.watch(feeSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iuran Pribadi'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceCard(isDark: isDark, summaryState: summaryState),
              const SizedBox(height: 16),
              Text(
                'Tagihan Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildUnpaidSection(isDark),
              const SizedBox(height: 24),
              Text(
                'Riwayat Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildPaidSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnpaidSection(bool isDark) {
    if (_isLoadingUnpaid) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorUnpaid != null) {
      return _buildErrorCard(isDark, _errorUnpaid!, _loadUnpaidFees);
    }

    if (_unpaidFees.isEmpty) {
      return _buildEmptyCard(
        isDark,
        icon: Icons.check_circle_outline,
        title: 'Tidak ada tagihan aktif',
        subtitle: 'Semua tagihan sudah dibayar',
      );
    }

    return Column(
      children: _unpaidFees
          .map((fee) => _BillTile(fee: fee, isDark: isDark))
          .toList(),
    );
  }

  Widget _buildPaidSection(bool isDark) {
    if (_isLoadingPaid) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorPaid != null) {
      return _buildErrorCard(isDark, _errorPaid!, _loadPaidFees);
    }

    if (_paidFees.isEmpty) {
      return _HistoryPlaceholder(isDark: isDark);
    }

    return Column(
      children: _paidFees
          .map((fee) => _PaidTile(fee: fee, isDark: isDark))
          .toList(),
    );
  }

  Widget _buildErrorCard(bool isDark, String error, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final bool isDark;
  final FeeSummaryState summaryState;

  const _BalanceCard({required this.isDark, required this.summaryState});

  @override
  Widget build(BuildContext context) {
    final totalAmount = summaryState.data?.formattedAmount ?? 'Rp 0';
    final totalCount = summaryState.data?.totalUnpaidCount ?? 0;
    final isLoading = summaryState.isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Tunggakan',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 4),
                  isLoading
                      ? Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      : Text(
                          totalAmount,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_outlined, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jumlah tagihan',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 4),
                  isLoading
                      ? Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      : Text(
                          '$totalCount tagihan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  final FeeTransactionModel fee;
  final bool isDark;

  const _BillTile({required this.fee, required this.isDark});

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  DateTime? _parseTransactionDate() {
    if (fee.transactionDate == null) return null;
    try {
      return DateTime.parse(fee.transactionDate!);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionDate = _parseTransactionDate();
    final dateText = transactionDate != null
        ? _formatDate(transactionDate)
        : 'Tanggal tidak tersedia';

    // For unpaid, we check if it's overdue based on transaction_date
    // If transaction_date is in the past, it's overdue
    final isOverdue =
        transactionDate != null &&
        transactionDate.isBefore(DateTime.now()) &&
        fee.status == 'unpaid';

    final badgeColor = isOverdue ? Colors.red.shade100 : Colors.orange.shade100;
    final badgeTextColor = isOverdue
        ? Colors.red.shade800
        : Colors.orange.shade800;
    final statusText = isOverdue ? 'Terlambat' : 'Menunggu';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.feeName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Jatuh tempo: $dateText',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(fee.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaidTile extends StatelessWidget {
  final FeeTransactionModel fee;
  final bool isDark;

  const _PaidTile({required this.fee, required this.isDark});

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  DateTime? _parseTransactionDate() {
    if (fee.transactionDate == null) return null;
    try {
      return DateTime.parse(fee.transactionDate!);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionDate = _parseTransactionDate();
    final dateText = transactionDate != null
        ? _formatDate(transactionDate)
        : '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.feeName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Dibayar: $dateText',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(fee.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPlaceholder extends StatelessWidget {
  final bool isDark;
  const _HistoryPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.history, color: Color(0xFF6D4C41)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada riwayat pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transaksi yang sudah dibayar akan muncul di sini',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
