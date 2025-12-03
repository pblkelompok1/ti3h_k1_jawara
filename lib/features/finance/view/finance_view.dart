import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

import '../widgets/tagihan_section.dart';
import '../widgets/pie_dashboard.dart';
import '../widgets/search_transaction.dart';
import '../widgets/finance_topbar.dart';
import '../widgets/add_action_bottomsheet.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> transaksi = [
      {
        "title": "Dana Desa",
        "time": "2 hari lalu",
        "category": "Operasional",
        "type": "keuangan",
        "amount": 3000000.0,
        "isIncome": true,
      },
      {
        "title": "Pembelian ATK",
        "time": "1 hari lalu",
        "category": "Pengeluaran Umum",
        "type": "keuangan",
        "amount": 1500000.0,
        "isIncome": false,
      },
      {
        "title": "Perayaan 17 Agustus",
        "time": "5 jam lalu",
        "category": "Kegiatan Desa",
        "type": "keuangan",
        "amount": 200000.0,
        "isIncome": false,
      },

      {
        "title": "Iuran Kebersihan",
        "time": "1 jam lalu",
        "category": "Iuran Mingguan",
        "type": "iuran",
        "amount": 5000.0,
        "isIncome": true,
      },
      {
        "title": "Iuran Keamanan",
        "time": "2 jam lalu",
        "category": "Iuran Bulanan",
        "type": "iuran",
        "amount": 10000.0,
        "isIncome": true,
      },
      {
        "title": "Kas RT",
        "time": "3 jam lalu",
        "category": "Iuran Rutin",
        "type": "iuran",
        "amount": 15000.0,
        "isIncome": true,
      },

      {
        "title": "Iuran Kebersihan Otomatis",
        "time": "1 menit lalu",
        "category": "Kebersihan",
        "type": "otomasi",
        "amount": 5000.0,
        "isIncome": true,
        "isAuto": true,
      },
      {
        "title": "Iuran Sampah Otomatis",
        "time": "10 menit lalu",
        "category": "Sampah",
        "type": "otomasi",
        "amount": 7000.0,
        "isIncome": true,
        "isAuto": true,
      },
    ];

    double income = transaksi
        .where((t) => t["isIncome"] == true)
        .fold(0.0, (sum, t) => sum + t["amount"]);

    double expense = transaksi
        .where((t) => t["isIncome"] == false)
        .fold(0.0, (sum, t) => sum + t["amount"]);

    double total = income + expense;

    double incomePercent = total == 0 ? 0 : (income / total) * 100;
    double expensePercent = total == 0 ? 0 : (expense / total) * 100;

    double balance = income - expense;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      body: Column(
        children: [
          FinanceTopBar(
            title: "Keuangan",
            rightIcon: Icons.notifications_rounded,
            onRightTap: () {},
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TagihanSection(isDark: isDark),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Text(
                        "Total Saldo",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const Spacer(),
                      FilterTime(isDark: isDark),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rp ${balance.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  PieDashboard(
                    isDark: isDark,
                    income: incomePercent,
                    expense: expensePercent,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LegendItem(
                        color: AppColors.primary(context),
                        label: "Pemasukan",
                      ),
                      const SizedBox(width: 25),
                      LegendItem(
                        color: AppColors.redAccent(context),
                        label: "Pengeluaran",
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SearchTransaction(isDark: isDark, transaksi: transaksi),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => AddActionBottomSheet.show(context),
          backgroundColor: AppColors.primary(context),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah'),
        ),
      ),
    );
  }
}
