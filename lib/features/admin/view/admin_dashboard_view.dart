import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/mock_admin_providers.dart';
import 'package:ti3h_k1_jawara/features/admin/widget/admin_stat_card.dart';
import 'package:intl/intl.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(adminStatisticsProviderMock);
    final financeSummaryAsync = ref.watch(financeAdminProviderMock);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Dashboard Admin',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatisticsProviderMock);
          ref.invalidate(financeAdminProviderMock);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    AdminStatCard(
                      icon: Icons.people,
                      title: 'Total Penduduk',
                      value: stats.totalResidents.toString(),
                      subtitle: '+${stats.activeUsers} aktif',
                      onTap: () => context.push('/admin/residents'),
                    ),
                    AdminStatCard(
                      icon: Icons.pending_actions,
                      title: 'Registrasi Pending',
                      value: stats.pendingRegistrations.toString(),
                      iconColor: Colors.orange,
                      onTap: () => context.push('/admin/registrations'),
                    ),
                    AdminStatCard(
                      icon: Icons.report_problem,
                      title: 'Laporan Baru',
                      value: stats.newReportsToday.toString(),
                      iconColor: Colors.red,
                      onTap: () => context.push('/admin/reports'),
                    ),
                    AdminStatCard(
                      icon: Icons.mail,
                      title: 'Surat Pending',
                      value: stats.pendingLetters.toString(),
                      iconColor: Colors.blue,
                      onTap: () => context.push('/admin/letters'),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
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
                        Text(
                          'Gagal memuat statistik',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Finance Summary Section
              Text(
                'Ringkasan Keuangan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),

              financeSummaryAsync.when(
                data: (summary) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildFinanceRow(
                        context,
                        'Pemasukan',
                        summary.totalIncome,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                      const Divider(height: 24),
                      _buildFinanceRow(
                        context,
                        'Pengeluaran',
                        summary.totalExpense,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                      const Divider(height: 24),
                      _buildFinanceRow(
                        context,
                        'Saldo',
                        summary.balance,
                        AppColors.primary(context),
                        Icons.account_balance_wallet,
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Transaksi: ${summary.transactionCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/admin/finance'),
                            child: const Text('Lihat Detail'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Gagal memuat data keuangan',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _buildQuickAction(
                    context,
                    Icons.how_to_reg,
                    'Persetujuan',
                    () => context.push('/admin/registrations'),
                  ),
                  _buildQuickAction(
                    context,
                    Icons.people,
                    'Penduduk',
                    () => context.push('/admin/residents'),
                  ),
                  _buildQuickAction(
                    context,
                    Icons.attach_money,
                    'Keuangan',
                    () => context.push('/admin/finance'),
                  ),
                  _buildQuickAction(
                    context,
                    Icons.image,
                    'Banner',
                    () => context.push('/admin/banners'),
                  ),
                  _buildQuickAction(
                    context,
                    Icons.report,
                    'Laporan',
                    () => context.push('/admin/reports'),
                  ),
                  _buildQuickAction(
                    context,
                    Icons.mail,
                    'Surat',
                    () => context.push('/admin/letters'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceRow(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        Text(
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(amount),
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border(context),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary(context),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
