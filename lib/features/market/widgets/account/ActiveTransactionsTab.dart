import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import '../../models/transaction_detail_model.dart';
import 'transaction_detail_screen.dart';

class ActiveTransactionsTab extends ConsumerWidget {
  const ActiveTransactionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(currentUserIdProvider);

    return userIdAsync.when(
      data: (userId) {
        if (userId == null) {
          return Center(
            child: Text(
              'User tidak ditemukan',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          );
        }

        final transactionsAsync = ref.watch(activeTransactionsProvider(userId));
        
        return transactionsAsync.when(
          data: (transactions) => _buildContent(context, ref, transactions),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading user: $error',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<TransactionDetail> transactions) {
    if (transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          final userId = await ref.read(currentUserIdProvider.future);
          if (userId != null) {
            ref.invalidate(activeTransactionsProvider(userId));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                    'Tarik ke bawah untuk refresh',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = await ref.read(currentUserIdProvider.future);
        if (userId != null) {
          ref.invalidate(activeTransactionsProvider(userId));
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _TransactionCard(transaction: transaction);
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionDetail transaction;

  const _TransactionCard({required this.transaction});

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstItem = transaction.items.isNotEmpty ? transaction.items.first : null;

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _StatusBadge(status: transaction.status),
              ],
            ),

            const SizedBox(height: 12),
            if (firstItem != null) ...[
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.shopping_bag, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.productName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pembeli: ${transaction.buyerName ?? 'Unknown'}',

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
            ],

            const SizedBox(height: 16),
            Divider(color: AppColors.softBorder(context)),
            const SizedBox(height: 12),

            _DetailRow(
              icon: Icons.shopping_cart_outlined,
              label: 'Total Item',
              value: '${transaction.items.length} item',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.payment_rounded,
              label: 'Total',
              value: 'Rp ${_formatPrice(transaction.totalAmount)}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Pembayaran',
              value: transaction.transactionMethodName ?? 'Unknown',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Waktu',
              value: _formatDateTime(transaction.createdAt),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailScreen(
                        transaction: transaction,
                      ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;

    switch (status.toLowerCase()) {
      case 'proses':
      case 'processing':
        color = Colors.blue;
        label = 'Diproses';
        break;
      case 'siap diambil':
      case 'ready':
        color = Colors.green;
        label = 'Siap';
        break;
      case 'sedang dikirim':
      case 'shipping':
        color = Colors.purple;
        label = 'Dikirim';
        break;
      case 'belum dibayar':
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
