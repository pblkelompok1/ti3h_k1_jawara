import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../models/transaction_detail_model.dart';
import '../../helpers/status_helper.dart';

/// Read-only order detail screen for buyers
/// Shows order information without update status functionality
class BuyerOrderDetailScreen extends ConsumerWidget {
  final TransactionDetail order;

  const BuyerOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Center(
              child: _buildStatusBadge(order.status),
            ),
            const SizedBox(height: 24),

            // Order Info Card
            _buildCard(
              context,
              title: 'Informasi Pesanan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('ID Transaksi', order.productTransactionId),
                  const Divider(height: 24),
                  _buildInfoRow('Tanggal', _formatDate(order.createdAt)),
                  const Divider(height: 24),
                  _buildInfoRow('Metode Pembayaran',
                      order.transactionMethodName ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Seller Info Card
            _buildCard(
              context,
              title: 'Informasi Penjual',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nama Toko', order.buyerName ?? '-'),
                  const Divider(height: 24),
                  _buildInfoRow('Alamat', order.address ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items Card
            _buildCard(
              context,
              title: 'Item Pesanan',
              child: Column(
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image Placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.softBorder(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x Rp ${_formatPrice(item.priceAtTransaction)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Subtotal: Rp ${_formatPrice(item.totalPrice)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Summary Card
            _buildCard(
              context,
              title: 'Ringkasan Pembayaran',
              child: Column(
                children: [
                  _buildPriceRow(
                    context,
                    'Total Harga',
                    order.totalAmount,
                  ),
                  const Divider(height: 24),
                  _buildPriceRow(
                    context,
                    'TOTAL',
                    order.totalAmount,
                    isBold: true,
                    color: AppColors.primary(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Proof if exists
            if (order.paymentProofPath != null) ...[
              _buildCard(
                context,
                title: 'Bukti Pembayaran',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.paymentProofPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: AppColors.softBorder(context),
                        child: Center(
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final gradient = StatusHelper.getStatusGradient(status);
    final label = StatusHelper.getStatusLabel(status);
    final icon = StatusHelper.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    int amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppColors.textPrimary(context),
          ),
        ),
        Text(
          'Rp ${_formatPrice(amount)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
