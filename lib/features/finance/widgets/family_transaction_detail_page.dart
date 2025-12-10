import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class FamilyTransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> familyData;
  final String feeTitle;
  final String feeAmount;

  const FamilyTransactionDetailPage({
    super.key,
    required this.familyData,
    required this.feeTitle,
    required this.feeAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = familyData['status'] as String;
    final transactionDate = familyData['transaction_date'] as String?;
    final transactionMethod = familyData['transaction_method'] as String?;
    final evidencePath = familyData['evidence_path'] as String?;
    final amount = familyData['amount'] as double?;

    Color statusColor;
    switch (status) {
      case 'Lunas':
        statusColor = Colors.green;
        break;
      case 'Tertunda':
        statusColor = Colors.orange;
        break;
      case 'Belum Lunas':
      default:
        statusColor = Colors.red;
        break;
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
        title: Text(
          "Detail Transaksi",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softBorder(context)),
              ),
              child: Column(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  Text(
                    amount != null
                        ? 'Rp ${amount.toStringAsFixed(0)}'
                        : feeAmount,
                    style: TextStyle(
                      color: AppColors.primary(context),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feeTitle,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Family Information
            _sectionTitle("Informasi Keluarga", context),
            const SizedBox(height: 12),
            _infoCard(
              context: context,
              isDark: isDark,
              items: [
                _infoItem(
                  icon: Icons.person_outline,
                  label: "Nama Keluarga",
                  value: familyData['nama'] ?? '-',
                  context: context,
                ),
                _infoItem(
                  icon: Icons.home_outlined,
                  label: "Alamat",
                  value: familyData['alamat'] ?? '-',
                  context: context,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Transaction Information
            if (status != 'Belum Lunas') ...[
              _sectionTitle("Informasi Transaksi", context),
              const SizedBox(height: 12),
              _infoCard(
                context: context,
                isDark: isDark,
                items: [
                  if (transactionDate != null)
                    _infoItem(
                      icon: Icons.calendar_today_outlined,
                      label: "Tanggal Bayar",
                      value: transactionDate,
                      context: context,
                    ),
                  if (transactionMethod != null)
                    _infoItem(
                      icon: Icons.payment_outlined,
                      label: "Metode Pembayaran",
                      value: transactionMethod,
                      context: context,
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Evidence
              if (evidencePath != null) ...[
                _sectionTitle("Bukti Pembayaran", context),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.softBorder(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attachment_outlined,
                        color: AppColors.primary(context),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bukti Terlampir",
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              evidencePath.split('/').last,
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textSecondary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            if (status == 'Belum Lunas') ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pending_actions_outlined,
                      size: 80,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada transaksi pembayaran',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required bool isDark,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        children: items.map((item) {
          if (item == items.last) return item;
          return Column(children: [item, const SizedBox(height: 16)]);
        }).toList(),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
