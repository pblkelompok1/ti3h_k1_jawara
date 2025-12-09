import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'qr_transaksi_page.dart';

class PilihPembayaranPage extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> warga;
  final String judul;
  final String amount;

  const PilihPembayaranPage({
    super.key,
    required this.isDark,
    required this.warga,
    required this.judul,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary(context)),
        title: Text("Pilih Pembayaran",
            style: TextStyle(color: AppColors.textPrimary(context))),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _tile(
              context,
              title: "Upload Bukti",
              icon: Icons.upload_file_rounded,
              color: Colors.blue,
              onTap: () {
                // buat page upload sendiri kalau mau
              },
            ),

            const SizedBox(height: 18),

            _tile(
              context,
              title: "Bayar via QR",
              icon: Icons.qr_code_rounded,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRTransaksiWidget(
                      isDark: isDark,
                      amount: amount,
                      judul: judul,
                      nama: warga["nama"],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(.2),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 18),

            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
