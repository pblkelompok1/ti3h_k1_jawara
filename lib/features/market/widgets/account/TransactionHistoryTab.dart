import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import '../../models/transaction_detail_model.dart';
import 'transaction_detail_screen.dart';
import '../../helpers/status_helper.dart';

class TransactionHistoryTab extends ConsumerWidget {
  const TransactionHistoryTab({super.key});

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

        final historyAsync = ref.watch(transactionHistoryProvider(userId));

        return historyAsync.when(
          data: (history) => _buildContent(context, ref, history),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<TransactionDetail> history,
  ) {
    if (history.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          final userId = await ref.read(currentUserIdProvider.future);
          if (userId != null) {
            ref.invalidate(transactionHistoryProvider(userId));
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
                    Icons.history_rounded,
                    size: 80,
                    color: AppColors.textSecondary(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat',
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
          ref.invalidate(transactionHistoryProvider(userId));
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = history[index];
          return _HistoryCard(item: item);
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TransactionDetail item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Normalize status to handle both backend formats
    final normalizedStatus = StatusHelper.formatStatus(item.status);
    final isCompleted = normalizedStatus == 'Selesai';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBorder(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: isCompleted
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'Selesai' : 'Dibatalkan',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Product Name
              Text(
                item.items.isNotEmpty ? item.items.first.productName : '-',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Buyer
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.buyerName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Divider
              Container(height: 1, color: AppColors.softBorder(context)),

              const SizedBox(height: 14),

              // Quantity and Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 16,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.items.length} item',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${_formatPrice(item.totalAmount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Payment Method and Date
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 14,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.transactionMethodName ?? 'Unknown',

                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // View Detail Button
              Container(
                width: double.infinity,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary(context).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final priceInt = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
