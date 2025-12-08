import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'pilih_pembayaran_page.dart';

class DetailTagihanPage extends StatefulWidget {
  final bool isDark;
  final String kategori;
  final String judul;
  final String amount;

  const DetailTagihanPage({
    super.key,
    required this.isDark,
    required this.kategori,
    required this.judul,
    required this.amount,
  });

  @override
  State<DetailTagihanPage> createState() => _DetailTagihanPageState();
}

class _DetailTagihanPageState extends State<DetailTagihanPage> {
  String selectedStatus = "Semua";

  final List<Map<String, dynamic>> warga = [
    { "nama": "Budi Santoso", "alamat": "Blok A - No.24", "status": "Belum Lunas" },
    { "nama": "Nur Rohman", "alamat": "Blok A - No.52", "status": "Lunas" },
    { "nama": "Siti Aminah", "alamat": "Blok B - No.11", "status": "Pending" },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    final filtered = warga.where((w) {
      if (selectedStatus == "Semua") return true;
      return w["status"] == selectedStatus;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        title: Text(
          "Detail Iuran",
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
          children: [

            // ----- HEADER -----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(widget.judul,
                          style: TextStyle(
                            color: AppColors.textPrimaryReverse(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(widget.kategori,
                          style: TextStyle(
                            color: AppColors.textPrimaryReverse(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Divider(color: AppColors.softBorder(context)),
                  const SizedBox(height: 14),

                  _row("Jumlah", widget.amount, context),
                  const SizedBox(height: 12),
                  _row("Kode Tagihan", "IR185702KX01", context),
                  const SizedBox(height: 12),
                  _row("Sudah Membayar", "2", context),
                  const SizedBox(height: 12),
                  _row("Belum Membayar", "30", context),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // FILTER STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status Pembayaran",
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.softBorder(context)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: "Semua", child: Text("Semua")),
                        DropdownMenuItem(value: "Lunas", child: Text("Lunas")),
                        DropdownMenuItem(value: "Pending", child: Text("Pending")),
                        DropdownMenuItem(value: "Belum Lunas", child: Text("Belum Lunas")),
                      ],
                      onChanged: (v) => setState(() => selectedStatus = v!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // LIST WARGA
            ...filtered.map((w) => _wargaItem(context, w)),

          ],
        ),
      ),
    );
  }

  Widget _row(String title, String val, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: AppColors.textSecondary(context))),
        Text(val, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary(context),
        )),
      ],
    );
  }

  Widget _wargaItem(BuildContext context, Map<String, dynamic> w) {
    Color color = w["status"] == "Lunas"
        ? Colors.green
        : w["status"] == "Pending"
            ? Colors.orange
            : Colors.red;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PilihPembayaranPage(
              isDark: widget.isDark,
              warga: w,
              judul: widget.judul,
              amount: widget.amount,
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary(context).withOpacity(.15),
              child: Icon(Icons.person, color: AppColors.primary(context)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w["nama"],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(w["alamat"],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      )),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                w["status"],
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
