import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class IuranWargaView extends StatelessWidget {
  const IuranWargaView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iuran Pribadi'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceCard(isDark: isDark),
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
            ..._dummyBills.map((bill) => _BillTile(bill: bill, isDark: isDark)).toList(),
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
            _HistoryPlaceholder(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final bool isDark;
  const _BalanceCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/dana-pribadi'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  Text(
                    'Rp 300.000',
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
                  Text('Tagihan jatuh tempo', style: TextStyle(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 4),
                  Text('10 Des 2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      )),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.flash_on, color: Colors.green),
                label: const Text('Bayar sekarang'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  final Map<String, String> bill;
  final bool isDark;

  const _BillTile({required this.bill, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = bill['status'] ?? '';
    final isLate = status.toLowerCase() == 'terlambat';
    final isWaiting = status.toLowerCase() == 'menunggu';

    final badgeColor = isLate
        ? Colors.red.shade100
        : isWaiting
            ? Colors.orange.shade100
            : Colors.green.shade100;
    final badgeTextColor = isLate
        ? Colors.red.shade800
        : isWaiting
            ? Colors.orange.shade800
            : Colors.green.shade800;

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
                  bill['title'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill['due'] ?? '',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                    Text(
                      bill['amount'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
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
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _dummyBills = [
  {
    'title': 'Iuran Kebersihan - Des',
    'due': 'Jatuh tempo: 10 Des 2025',
    'amount': 'Rp 150.000',
    'status': 'Terlambat',
  },
  {
    'title': 'Keamanan Bulanan',
    'due': 'Jatuh tempo: 15 Des 2025',
    'amount': 'Rp 100.000',
    'status': 'Menunggu',
  },
  {
    'title': 'Iuran Kas RT',
    'due': 'Jatuh tempo: 20 Des 2025',
    'amount': 'Rp 50.000',
    'status': 'Menunggu',
  },
];
