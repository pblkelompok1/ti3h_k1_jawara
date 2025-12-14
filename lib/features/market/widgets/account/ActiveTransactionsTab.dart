import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import 'transaction_detail_screen.dart';

class ActiveTransactionsTab extends ConsumerWidget {
  const ActiveTransactionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(activeTransactionsProvider);

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada transaksi aktif',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi yang sedang berlangsung akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionCard(transaction: transaction);
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionCard({required this.transaction});

  String _safeString(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;
    if (value is String && value.isEmpty) return fallback;
    return value.toString();
  }

  int _safeInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _safeString(transaction['id']),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                _StatusBadge(status: transaction['status'] as String?),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.network(
                      _safeString(transaction['product_image'], fallback: ''),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _safeString(transaction['product_name']),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pembeli: ${_safeString(transaction['buyer_name'])}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: AppColors.softBorder(context)),
            const SizedBox(height: 12),

            _DetailRow(
              icon: Icons.shopping_cart_outlined,
              label: 'Jumlah',
              value: '${_safeInt(transaction['quantity'])} item',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.payment_rounded,
              label: 'Total',
              value: 'Rp ${_formatPrice(_safeInt(transaction['total']))}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Pembayaran',
              value: _safeString(transaction['payment_method']),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Waktu',
              value: _safeString(transaction['date']),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TransactionDetailScreen(transaction: transaction),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kelola Transaksi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;

  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final safeStatus = status ?? 'pending';

    late Color color;
    late String label;

    switch (safeStatus) {
      case 'processing':
        color = Colors.blue;
        label = 'Diproses';
        break;
      case 'ready':
        color = Colors.green;
        label = 'Siap';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary(context)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
