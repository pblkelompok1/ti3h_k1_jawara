import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/mock_admin_providers.dart';
import 'package:ti3h_k1_jawara/features/admin/widget/admin_stat_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.logout();

        if (context.mounted) {
          context.go('/auth-flow');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getFormattedDate() {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
    } catch (e) {
      return DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(adminStatisticsProviderMock);
    final financeSummaryAsync = ref.watch(financeAdminProviderMock);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatisticsProviderMock);
          ref.invalidate(financeAdminProviderMock);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary(context),
                      AppColors.primary(context).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                '${_getGreeting()} 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                minFontSize: 16,
                              ),
                              const SizedBox(height: 2),
                              AutoSizeText(
                                _getFormattedDate(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                minFontSize: 9,
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleLogout(context, ref),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Grid
                          statisticsAsync.when(
                      data: (stats) => GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        children: [
                          AdminStatCard(
                            icon: Icons.people_rounded,
                            title: 'Total Penduduk',
                            value: stats.totalResidents.toString(),
                            subtitle: '+${stats.activeUsers} aktif',
                            gradientColors: [
                              AppColors.primary(context),
                              AppColors.primary(context).withOpacity(0.7),
                            ],
                            onTap: () => context.push('/admin/residents'),
                          ),
                          AdminStatCard(
                            icon: Icons.pending_actions_rounded,
                            title: 'Registrasi Pending',
                            value: stats.pendingRegistrations.toString(),
                            subtitle: 'Menunggu approval',
                            gradientColors: const [
                              Color(0xFFFF9800),
                              Color(0xFFFFB74D),
                            ],
                            onTap: () => context.push('/admin/registrations'),
                          ),
                          AdminStatCard(
                            icon: Icons.report_problem_rounded,
                            title: 'Laporan Baru',
                            value: stats.newReportsToday.toString(),
                            subtitle: 'Hari ini',
                            gradientColors: const [
                              Color(0xFFF44336),
                              Color(0xFFE57373),
                            ],
                            onTap: () => context.push('/admin/reports'),
                          ),
                          AdminStatCard(
                            icon: Icons.mail_rounded,
                            title: 'Surat Pending',
                            value: stats.pendingLetters.toString(),
                            subtitle: 'Perlu diproses',
                            gradientColors: const [
                              Color(0xFF2196F3),
                              Color(0xFF64B5F6),
                            ],
                            onTap: () => context.push('/admin/letters'),
                          ),
                        ],
                      ),
                      loading: () => GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        children: List.generate(
                          4,
                          (index) => Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.redAccent(context),
                              ),
                              const SizedBox(height: 16),
                              AutoSizeText(
                                'Gagal memuat statistik',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Finance Summary Section
                    AutoSizeText(
                      'Ringkasan Keuangan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                    ),
                    const SizedBox(height: 16),

                    financeSummaryAsync.when(
                      data: (summary) => Column(
                        children: [
                          // Income Card
                          _buildFinanceCard(
                            context,
                            icon: Icons.trending_up_rounded,
                            label: 'Pemasukan',
                            amount: summary.totalIncome,
                            gradientColors: const [
                              Color(0xFF4CAF50),
                              Color(0xFF66BB6A),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Expense Card
                          _buildFinanceCard(
                            context,
                            icon: Icons.trending_down_rounded,
                            label: 'Pengeluaran',
                            amount: summary.totalExpense,
                            gradientColors: const [
                              Color(0xFFF44336),
                              Color(0xFFE57373),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Balance Card
                          _buildFinanceCard(
                            context,
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Saldo',
                            amount: summary.balance,
                            gradientColors: [
                              AppColors.primary(context),
                              AppColors.primary(context).withOpacity(0.7),
                            ],
                            isBalance: true,
                          ),
                          const SizedBox(height: 16),
                          // Footer Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border(context),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    'Total Transaksi: ${summary.transactionCount}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary(context),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/admin/finance'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Lihat Detail'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      loading: () => Column(
                        children: List.generate(
                          3,
                          (index) => Container(
                            height: 80,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                      error: (error, stack) => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: AutoSizeText(
                            'Gagal memuat data keuangan',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    AutoSizeText(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildQuickAction(
                          context,
                          Icons.how_to_reg_rounded,
                          'Persetujuan',
                          Colors.orange,
                          () => context.push('/admin/registrations'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.people_rounded,
                          'Penduduk',
                          AppColors.primary(context),
                          () => context.push('/admin/residents'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.run_circle,
                          'Kegiatan',
                          Colors.green,
                          () => context.push('/admin/finance'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.image_rounded,
                          'Banner',
                          Colors.purple,
                          () => context.push('/admin/banners'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.report_rounded,
                          'Laporan',
                          Colors.red,
                          () => context.push('/admin/reports'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.mail_rounded,
                          'Surat',
                          Colors.blue,
                          () => context.push('/admin/letters'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required List<Color> gradientColors,
    bool isBalance = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(amount),
                  style: TextStyle(
                    fontSize: isBalance ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  minFontSize: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              AutoSizeText(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 1,
                minFontSize: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
