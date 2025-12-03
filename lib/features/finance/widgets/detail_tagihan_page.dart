import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'detail_pembayaran_page.dart';

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
    {
      "nama": "Budi Santoso",
      "alamat": "Blok A - No.24",
      "desc": "Iuran 1",
      "status": "Belum Lunas",
    },
    {
      "nama": "Nur Rohman",
      "alamat": "Blok A - No.52",
      "desc": "Iuran 2",
      "status": "Lunas",
    },
    {
      "nama": "Siti Aminah",
      "alamat": "Blok B - No.11",
      "desc": "Iuran 3",
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    final filteredWarga = warga.where((w) {
      if (selectedStatus == "Semua") return true;
      return w["status"] == selectedStatus;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        iconTheme: IconThemeData(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
        title: Text(
          "Detail Iuran",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.softBorderDark
                      : AppColors.softBorderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.judul,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimaryReverse(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.kategori,
                          style: TextStyle(
                            color: AppColors.textPrimaryReverse(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Divider(thickness: 0.8, color: AppColors.softBorder(context)),

                  const SizedBox(height: 14),

                  detailRow("Jumlah", widget.amount, isDark),
                  const SizedBox(height: 12),

                  detailRow("Kode Tagihan", "IR185702KX01", isDark),
                  const SizedBox(height: 12),

                  detailRow("Sudah Membayar", "2", isDark),
                  const SizedBox(height: 12),

                  detailRow("Belum Membayar", "30", isDark),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status Pembayaran",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.softBorder(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: "Semua", child: Text("Semua")),
                        DropdownMenuItem(value: "Lunas", child: Text("Lunas")),
                        DropdownMenuItem(
                          value: "Pending",
                          child: Text("Pending"),
                        ),
                        DropdownMenuItem(
                          value: "Belum Lunas",
                          child: Text("Belum Lunas"),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() => selectedStatus = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            ...filteredWarga.map((w) {
              return wargaItem(
                context,
                isDark: isDark,
                nama: w["nama"],
                alamat: w["alamat"],
                desc: w["desc"],
                status: w["status"],
              );
            }),

            if (filteredWarga.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  "Tidak ada data.",
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Container(height: 1, color: Colors.grey.withOpacity(0.2)),
  );

  Widget detailRow(String title, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget wargaItem(
    BuildContext context, {
    required String nama,
    required String alamat,
    required String desc,
    required String status,
    required bool isDark,
  }) {
    Color badgeColor;
    switch (status) {
      case "Lunas":
        badgeColor = Colors.green;
        break;
      case "Pending":
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = Colors.red;
    }

    return InkWell(
      onTap: () {
        if (status == "Lunas") {
          showDetailPembayaranSheet(
            context,
            isDark: isDark,
            nama: nama,
            phone: "+62 812381239",
            desc: desc,
            address: alamat,
            imagePath: "",
            verified: true,
          );
        } else if (status == "Belum Lunas") {
          showReminderSheet(
            context,
            name: nama,
            address: alamat,
            isDark: isDark,
          );
        } else {
          showPendingSheet(
            context,
            isDark: isDark,
            nama: nama,
            address: alamat,
            desc: desc,
          );
        }
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary(context).withOpacity(0.15),
              child: Icon(
                Icons.person,
                size: 28,
                color: AppColors.primary(context),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alamat,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
