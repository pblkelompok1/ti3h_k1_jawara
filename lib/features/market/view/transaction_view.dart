import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/market/provider/transaction_provider.dart';

class TransactionView extends ConsumerWidget {
  const TransactionView({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionProvider(transactionId));

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.bgTransaction(context),
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        centerTitle: true,
        backgroundColor: AppColors.bgDashboardCard(context),
        foregroundColor: AppColors.textPrimary(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
              context,
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayar Dalam',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.getTimeRemaining(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _card(
              context,
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.productName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              transaction.sellerName,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('x ${transaction.quantity}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _row(
                    context,
                    'Subtotal',
                    currency.format(transaction.subtotal),
                  ),
                  _row(
                    context,
                    'Pengiriman',
                    currency.format(transaction.deliveryFee),
                  ),
                  _row(
                    context,
                    'Biaya Layanan',
                    currency.format(transaction.serviceFee),
                  ),
                  const Divider(),
                  _row(
                    context,
                    'Total',
                    currency.format(transaction.total),
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= ADDRESS =================
            _card(
              context,
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.recipientName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(transaction.recipientPhone),
                        Text(transaction.recipientAddress),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _card(
              context,
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment),
                      const SizedBox(width: 12),
                      Text(
                        transaction.paymentMethod,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (transaction.qrCodeData.isNotEmpty)
                    QrImageView(
                      data: transaction.qrCodeData,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: child,
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
