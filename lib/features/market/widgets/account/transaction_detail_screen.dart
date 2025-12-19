import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import '../../models/transaction_detail_model.dart';
import '../../helpers/status_helper.dart';
import '../../enums/transaction_status.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionDetail transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstItem = transaction.items.isNotEmpty
        ? transaction.items.first
        : null;

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
                _buildStatusBadge(context),
                const SizedBox(height: 20),
                if (firstItem != null) _buildProductCard(context, firstItem),
                const SizedBox(height: 20),
                _buildInfoSection(context),
                const SizedBox(height: 20),
                _buildPaymentSection(context),
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
            child: _buildBottomButton(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final normalizedStatus = StatusHelper.formatStatus(transaction.status);
    final color = StatusHelper.getStatusColor(normalizedStatus);
    final gradient = StatusHelper.getStatusGradient(normalizedStatus);
    final icon = StatusHelper.getStatusIcon(normalizedStatus);
    final label = StatusHelper.getStatusLabel(normalizedStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, TransactionItem item) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
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
                '${item.quantity} item x Rp ${_formatPrice(item.priceAtTransaction)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const Spacer(),
              Text(
                'Rp ${_formatPrice(item.totalPrice)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
          if (transaction.items.length > 1) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${transaction.items.length - 1} produk lainnya',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Text(
                'Informasi Pembeli',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            icon: Icons.person,
            label: 'Nama',
            value: transaction.buyerName ?? 'Unknown',
          ),
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: 'Alamat',
            value: transaction.address ?? 'Ambil di tempat',
          ),
          if (transaction.description != null &&
              transaction.description!.isNotEmpty)
            _buildInfoRow(
              context,
              icon: Icons.note,
              label: 'Catatan',
              value: transaction.description!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSectionBase(
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

  Widget _buildPaymentSection(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Text(
                'Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            icon: transaction.isCod ? Icons.handshake : Icons.credit_card,
            label: 'Metode Pembayaran',
            value: transaction.isCod
                ? 'COD (Bayar di Tempat)'
                : (transaction.transactionMethodName ?? 'Unknown'),
          ),
          if (!transaction.isCod && transaction.paymentProofPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                transaction.paymentProofPath!,
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
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final dateStr =
        '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}';

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
            '${transaction.items.length} item',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Tanggal Transaksi', dateStr),
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
                'Rp ${_formatPrice(transaction.totalAmount)}',
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

  Widget _buildBottomButton(BuildContext context, WidgetRef ref) {
    final status = transaction.status;
    final normalizedStatus = StatusHelper.formatStatus(status);

    // Completed or cancelled transactions - show disabled button
    if (normalizedStatus == 'Selesai' || normalizedStatus == 'Ditolak') {
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
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                normalizedStatus == 'Selesai'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: Colors.white,
              ),
              label: Text(
                normalizedStatus == 'Selesai'
                    ? 'Transaksi Selesai'
                    : 'Transaksi Dibatalkan',
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

    final nextStatus = _getNextStatus(status);
    final nextLabel = _getNextStatusLabel(status);
    final buttonColor = _getButtonColor(nextStatus);
    final buttonIcon = _getStatusIcon(nextStatus);
    final buttonText = _getButtonText(status);

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
              _showUpdateStatusConfirmation(
                context,
                ref,
                nextStatus,
                nextLabel,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(buttonIcon, color: Colors.white, size: 22),
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

  String _getButtonText(String currentStatus) {
    final normalizedStatus = StatusHelper.formatStatus(currentStatus);
    switch (normalizedStatus) {
      case 'Belum Dibayar':
        return 'Proses Pesanan';
      case 'Proses':
        return 'Kirim Pesanan';
      case 'Siap Diambil':
        return 'Kirim Pesanan';
      case 'Sedang Dikirim':
        return 'Selesaikan Transaksi';
      default:
        return 'Update Status';
    }
  }

  void _showUpdateStatusConfirmation(
    BuildContext context,
    WidgetRef ref,
    String nextStatus,
    String nextLabel,
  ) {
    final normalizedStatus = StatusHelper.formatStatus(transaction.status);
    final currentStatusLabel = StatusHelper.getStatusLabel(normalizedStatus);
    final currentStatusColor = StatusHelper.getStatusColor(normalizedStatus);
    final description = _getStatusChangeDescription(transaction.status);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _getButtonColor(nextStatus)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Konfirmasi Update Status',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status akan diubah dari:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: currentStatusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: currentStatusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: currentStatusColor),
                  const SizedBox(width: 8),
                  Text(
                    currentStatusLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: currentStatusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getButtonColor(nextStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getButtonColor(nextStatus).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: _getButtonColor(nextStatus),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nextLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getButtonColor(nextStatus),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _updateTransactionStatus(context, ref, nextStatus, nextLabel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(nextStatus),
            ),
            icon: Icon(_getStatusIcon(nextStatus), size: 18),
            label: const Text('Ya, Update'),
          ),
        ],
      ),
    );
  }

  String _getStatusChangeDescription(String currentStatus) {
    final normalizedStatus = StatusHelper.formatStatus(currentStatus);
    switch (normalizedStatus) {
      case 'Belum Dibayar':
        return 'Konfirmasi bahwa pembayaran sudah diterima dan pesanan siap diproses.';
      case 'Proses':
        return 'Pesanan telah dikemas dan siap dikirim ke pembeli.';
      case 'Siap Diambil':
        return 'Pesanan telah siap dan dapat diambil pembeli atau dikirim.';
      case 'Sedang Dikirim':
        return 'Pembeli telah menerima pesanan dengan baik. Transaksi akan diselesaikan.';
      default:
        return 'Status transaksi akan diupdate.';
    }
  }

  Future<void> _updateTransactionStatus(
    BuildContext context,
    WidgetRef ref,
    String nextStatus,
    String nextLabel,
  ) async {
    print('🔄 UPDATE TRANSACTION STATUS CALLED');
    print('   Current Status: ${transaction.status}');
    print('   Next Status: $nextStatus');
    print('   Next Label: $nextLabel');
    print('   Transaction ID: ${transaction.productTransactionId}');
    print('   Buyer User ID (from transaction): ${transaction.userId}');

    // Get current logged-in user (seller)
    final currentUserId = await ref.read(currentUserIdProvider.future);
    if (currentUserId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: User tidak ditemukan'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    print('   Seller User ID (logged in): $currentUserId');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call API to update status - use seller ID, not buyer ID
      final updateFunction = ref.read(
        updateTransactionStatusProvider({
          'transactionId': transaction.productTransactionId,
          'userId': currentUserId, // Use seller ID (current logged-in user)
        }),
      );

      // Convert backend format to enum, then get next status
      // transaction.status is already in backend format (e.g., "PROSES")
      final currentStatusEnum = TransactionStatus.fromBackend(transaction.status);
      final nextStatusEnum = currentStatusEnum.getNextStatus();
      
      if (nextStatusEnum == null) {
        throw Exception('Cannot update status from ${transaction.status}');
      }
      
      final backendStatus = nextStatusEnum.backendValue;
      print('📤 Calling updateFunction with backend format: $backendStatus');
      await updateFunction(backendStatus);

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah ke: $nextLabel'),
          backgroundColor: Colors.green.shade600,
        ),
      );

      // Refresh lists and close detail
      ref.invalidate(activeTransactionsProvider);
      ref.invalidate(transactionHistoryProvider);
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update status: $e'),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _getNextStatus(String currentStatus) {
    print('🔀 _getNextStatus called with: "$currentStatus"');
    final normalizedStatus = StatusHelper.formatStatus(currentStatus);
    print('   → Normalized: "$normalizedStatus"');

    // Use enum to determine next status
    final currentStatusEnum = TransactionStatus.fromDisplayText(normalizedStatus);
    final nextStatusEnum = currentStatusEnum.getNextStatus();
    
    final nextStatus = nextStatusEnum?.displayText ?? normalizedStatus;
    print('   → Next status: "$nextStatus"');
    return nextStatus;
  }

  String _getNextStatusLabel(String currentStatus) {
    final next = _getNextStatus(currentStatus);
    return StatusHelper.getStatusLabel(next);
  }

  Color _getButtonColor(String status) {
    return StatusHelper.getStatusColor(status);
  }

  IconData _getStatusIcon(String status) {
    return StatusHelper.getStatusIcon(status);
  }
}
