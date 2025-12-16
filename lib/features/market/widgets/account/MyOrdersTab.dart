import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import '../../models/transaction_detail_model.dart';
import '../../view/transaction_view.dart';
import '../../helpers/status_helper.dart';
import 'buyer_order_detail_screen.dart';

// State provider for selected filter tab
final myOrdersFilterProvider = StateProvider<String>((ref) => 'semua');

class MyOrdersTab extends ConsumerWidget {
  const MyOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(currentUserIdProvider);
    final selectedFilter = ref.watch(myOrdersFilterProvider);

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

        final ordersAsync = ref.watch(myOrdersProvider(userId));

        return ordersAsync.when(
          data: (orders) {
            // Filter orders by selected status
            final filteredOrders = _filterOrders(orders, selectedFilter);
            return Column(
              children: [
                _buildFilterTabs(context, ref, selectedFilter),
                Expanded(
                  child: _buildContent(context, ref, filteredOrders, userId),
                ),
              ],
            );
          },
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

  List<TransactionDetail> _filterOrders(
    List<TransactionDetail> orders,
    String filter,
  ) {
    if (filter == 'semua') return orders;

    return orders.where((order) {
      // Normalize status to handle both backend formats (BELUM_DIBAYAR or Belum Dibayar)
      final normalizedStatus = StatusHelper.formatStatus(order.status);

      switch (filter) {
        case 'belum_bayar':
          return normalizedStatus == 'Belum Dibayar';
        case 'proses':
          return normalizedStatus == 'Proses' ||
              normalizedStatus == 'Siap Diambil' ||
              normalizedStatus == 'Sedang Dikirim';
        case 'selesai':
          return normalizedStatus == 'Selesai';
        case 'batal':
          return normalizedStatus == 'Ditolak';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildFilterTabs(
    BuildContext context,
    WidgetRef ref,
    String selectedFilter,
  ) {
    final filters = [
      {
        'key': 'semua',
        'label': 'Semua',
        'icon': Icons.all_inclusive,
        'color': Colors.blueGrey,
      },
      {
        'key': 'belum_bayar',
        'label': 'Belum Bayar',
        'icon': Icons.payment,
        'color': const Color(0xFFFF6B35),
      },
      {
        'key': 'proses',
        'label': 'Diproses',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'key': 'selesai',
        'label': 'Selesai',
        'icon': Icons.check_circle,
        'color': const Color(0xFF2ECC71),
      },
      {
        'key': 'batal',
        'label': 'Dibatalkan',
        'icon': Icons.cancel,
        'color': const Color(0xFFE74C3C),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        border: Border(
          bottom: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter['key'];
            final filterColor = filter['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : filterColor,
                    ),
                    const SizedBox(width: 6),
                    Text(filter['label'] as String),
                  ],
                ),
                onSelected: (selected) {
                  ref.read(myOrdersFilterProvider.notifier).state =
                      filter['key'] as String;
                },
                selectedColor: filterColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : filterColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
                backgroundColor: isSelected
                    ? filterColor
                    : filterColor.withOpacity(0.1),
                side: BorderSide(color: filterColor, width: isSelected ? 2 : 1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<TransactionDetail> orders,
    String userId,
  ) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myOrdersProvider(userId));
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
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: AppColors.textSecondary(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
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
          ref.invalidate(myOrdersProvider(userId));
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _OrderCard(
            order: orders[index],
            onTap: () => _handleOrderTap(context, orders[index]),
          );
        },
      ),
    );
  }

  void _handleOrderTap(BuildContext context, TransactionDetail order) {
    // Normalize status to handle both backend formats
    final normalizedStatus = StatusHelper.formatStatus(order.status);

    if (normalizedStatus == 'Belum Dibayar') {
      // Redirect ke screen transaksi untuk pembayaran (screen setelah checkout)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TransactionView(transactionId: order.productTransactionId),
        ),
      );
    } else {
      // Status lain: Tampilkan detail readonly (buyer tidak bisa update status)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyerOrderDetailScreen(order: order),
        ),
      );
    }
  }
}

class _OrderCard extends ConsumerWidget {
  final TransactionDetail order;
  final VoidCallback? onTap;

  const _OrderCard({required this.order, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    // Normalize status to handle both backend formats
    final normalizedStatus = StatusHelper.formatStatus(order.status);
    final canCancel =
        normalizedStatus ==
        'Belum Dibayar'; // Only pending orders can be cancelled

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBorder(context)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_OrderStatusBadge(status: order.status)],
            ),
            const SizedBox(height: 12),

            if (firstItem != null) ...[
              Text(
                firstItem.productName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('${order.items.length} item'),
            ],

            const SizedBox(height: 12),
            Divider(color: AppColors.softBorder(context)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:'),
                Text(
                  'Rp ${_formatPrice(order.totalAmount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${order.transactionMethodName ?? 'Unknown'} • ${_formatDate(order.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
                if (canCancel)
                  TextButton(
                    onPressed: () => _showCancelDialog(context, ref, order),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Batalkan'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    TransactionDetail order,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan ini?\\n\\nID: ${order.productTransactionId}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cancelOrder(context, ref, order);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(
    BuildContext context,
    WidgetRef ref,
    TransactionDetail order,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) throw Exception('User not found');

      final cancelFunction = ref.read(
        cancelTransactionProvider({
          'transactionId': order.productTransactionId,
          'userId': userId,
        }),
      );

      await cancelFunction();

      if (!context.mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pesanan berhasil dibatalkan'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final gradient = StatusHelper.getStatusGradient(status);
    final label = StatusHelper.getStatusLabel(status);
    final icon = StatusHelper.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
