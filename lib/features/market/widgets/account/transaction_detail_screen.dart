import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

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

  String _statusLabel(String? status) {
    switch (status) {
      case 'processing':
        return 'Diproses';
      case 'ready':
        return 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Menunggu';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'processing':
        return Colors.orange;
      case 'ready':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethod = _safeString(transaction['payment_method']);
    final status = _safeString(transaction['status']);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.bgDashboardAppHeader(context),
        foregroundColor: Colors.white,
        title: const Text('Detail Transaksi'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(context, status),
                const SizedBox(height: 20),

                _buildProductCard(context),
                const SizedBox(height: 20),

                _buildInfoSection(
                  context,
                  title: 'Informasi Pemesan',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.person,
                      label: 'Nama',
                      value: _safeString(transaction['buyer_name']),
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Alamat',
                      value: _safeString(transaction['buyer_address']),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildPaymentSection(context, paymentMethod),

                const SizedBox(height: 20),

                _buildOrderSummary(context),

                const SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomButton(context, status),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            'Status: ${_statusLabel(status)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              _safeString(transaction['product_image'], fallback: ''),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safeString(transaction['product_name']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_safeInt(transaction['quantity'])} item',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rp ${_formatPrice(_safeInt(transaction['total']))}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
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

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.softBorder(context)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, String paymentMethod) {
    return _buildInfoSection(
      context,
      title: 'Pembayaran',
      icon: Icons.payment,
      children: [
        if (paymentMethod == 'COD')
          _buildInfoRow(
            context,
            icon: Icons.handshake,
            label: 'Metode Pembayaran',
            value: 'COD (Bayar di Tempat)',
          )
        else ...[
          _buildInfoRow(
            context,
            icon: Icons.credit_card,
            label: 'Metode Pembayaran',
            value: paymentMethod,
          ),
          const SizedBox(height: 12),
          if (_safeString(transaction['payment_proof']).isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _safeString(transaction['payment_proof']),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            'Jumlah Item',
            '${_safeInt(transaction['quantity'])} item',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Tanggal Transaksi',
            _safeString(transaction['date']),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.softBorder(context)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                'Rp ${_formatPrice(_safeInt(transaction['total']))}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, String status) {
    String buttonText;
    IconData buttonIcon;
    Color buttonColor;

    switch (status) {
      case 'pending':
        buttonText = 'Proses Pesanan';
        buttonIcon = Icons.receipt_long;
        buttonColor = Colors.orange.shade600;
        break;
      case 'processing':
        buttonText = 'Tandai Siap';
        buttonIcon = Icons.check_circle;
        buttonColor = Colors.blue.shade600;
        break;
      case 'ready':
        buttonText = 'Selesaikan Transaksi';
        buttonIcon = Icons.done_all;
        buttonColor = Colors.green.shade600;
        break;
      default:
        buttonText = 'Tutup';
        buttonIcon = Icons.close;
        buttonColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status transaksi diperbarui ke: $buttonText'),
                  backgroundColor: buttonColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: Icon(buttonIcon, color: Colors.white),
            label: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
