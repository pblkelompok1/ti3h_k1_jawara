import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

import 'StatCards.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  final List<Map<String, dynamic>> _actions = const [
    {
      'title': 'Iuran Warga',
      'subtitle': 'Bayar iuran bulanan',
      'icon': Icons.payment_rounded,
      'color': Color(0xFF4285F4),
      'path': '/finance',
    },
    {
      'title': 'Lapor Masalah',
      'subtitle': 'Laporkan keluhan',
      'icon': Icons.report_problem_rounded,
      'color': Color(0xFFF44336),
      'path': '/lapor-masalah',
    },
    {
      'title': 'Jadwal Ronda',
      'subtitle': 'Cek jadwal keamanan',
      'icon': Icons.schedule_rounded,
      'color': Color(0xFF9C27B0),
      'path': '/resident',
    },
    {
      'title': 'Info Warga',
      'subtitle': 'Data kependudukan',
      'icon': Icons.people_alt_rounded,
      'color': Color(0xFF00BCD4),
      'path': '/resident',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akses Cepat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          SizedBox(height: 16,),
          const PaymentSummaryCards(),
          SizedBox(height: 12,),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              return _buildActionCard(
                context,
                isDark: isDark,
                title: _actions[index]['title']!,
                subtitle: _actions[index]['subtitle']!,
                icon: _actions[index]['icon']!,
                color: _actions[index]['color']!,
                path: _actions[index]['path']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String path,
  }) {
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
