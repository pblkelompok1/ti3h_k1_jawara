import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'transaction_tile.dart';

import 'finance_detail_page.dart';
import 'iuran_detail_page.dart';
import 'otomasi_detail_page.dart';

class SearchTransaction extends StatefulWidget {
  final bool isDark;
  final List<Map<String, dynamic>> transaksi;

  const SearchTransaction({
    super.key,
    required this.isDark,
    required this.transaksi,
  });

  @override
  State<SearchTransaction> createState() => _SearchTransactionState();
}

class _SearchTransactionState extends State<SearchTransaction> {
  final TextEditingController controller = TextEditingController();
  String searchQuery = "";
  String selectedFilter = "Keuangan";

  void filterSearch(String value) =>
      setState(() => searchQuery = value.toLowerCase());

  void changeFilter(String filter) => setState(() => selectedFilter = filter);

  void _openDetail(Map<String, dynamic> t) {
    switch (t["type"]) {
      case "iuran":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IuranDetailPage(data: t)),
        );
        break;

      case "otomasi":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IuranOtomatisDetailPage(data: t)),
        );
        break;

      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FinanceDetailPage(data: t)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.transaksi.where((t) {
      final title = (t['title'] ?? '').toString().toLowerCase();
      final type = (t['type'] ?? '').toString();

      bool matchSearch = title.contains(searchQuery);

      bool matchFilter =
          selectedFilter == 'Keuangan' && type == 'keuangan' ||
          selectedFilter == 'Iuran' && type == 'iuran' ||
          selectedFilter == 'Otomasi' && type == 'otomasi';

      return matchSearch && matchFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: filterSearch,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgPrimaryInputBox(context),
            hintText: 'Cari transaksi...',
            prefixIcon: Icon(
              Icons.search,
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _buildFilterTabs(context),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          Center(
            child: Text(
              'Tidak ada transaksi',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          )
        else
          Column(
            children: filtered.map((t) {
              final compactMode = t["type"] != "keuangan";

              return Container(
                margin: EdgeInsets.only(
                  bottom: (t["type"] == "iuran" || t["type"] == "otomasi")
                      ? 30
                      : 10,
                ),
                child: TransactionTile(
                  title: t['title'] ?? '-',
                  time: t['time'] ?? '-',
                  category: t['category'] ?? '-',
                  amount:
                      (t['isIncome'] == true ? '+ Rp ' : '- Rp ') +
                      (t['amount'] is num
                          ? (t['amount'] as num).toStringAsFixed(0)
                          : (t['amount']?.toString() ?? '0')),
                  isIncome: t['isIncome'] == true,
                  compact: compactMode || t["type"] != "keuangan",
                  onTap: () => _openDetail(t),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final tabs = ['Keuangan', 'Iuran', 'Otomasi'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (_, i) {
          final label = tabs[i];
          final active = selectedFilter == label;

          return GestureDetector(
            onTap: () => changeFilter(label),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
