import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class QRTransaksiWidget extends StatelessWidget {
  final bool isDark;
  final String amount;
  final String judul;
  final String nama;

  const QRTransaksiWidget({
    super.key,
    required this.isDark,
    required this.amount,
    required this.judul,
    required this.nama,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        children: [
          Text(
            judul,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Atas Nama: $nama",
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),

          const SizedBox(height: 20),

          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 180, color: Colors.black),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Nominal Dibayar",
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pembayaran sedang diproses..."),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary(context),
              ),
              child: Text(
                "Saya Sudah Bayar",
                style: TextStyle(
                  color: AppColors.textPrimaryReverse(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
