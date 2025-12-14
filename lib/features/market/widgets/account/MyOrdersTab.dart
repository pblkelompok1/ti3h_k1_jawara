import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';

class MyOrdersTab extends ConsumerWidget {
  const MyOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    if (orders.isEmpty) {
      return Center(
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
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index]);
      },
    );
  }
  
}
class _OrderCard extends StatelessWidget {
  final MyOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            order.sellerName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(order.productName),

          const SizedBox(height: 12),
          Divider(color: AppColors.softBorder(context)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah: ${order.quantity}'),
              Text(
                'Rp ${order.total}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            '${order.paymentMethod} • ${order.date.toLocal().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
class _OrderStatusBadge extends StatelessWidget {
  final String status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Menunggu';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Diproses';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
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

