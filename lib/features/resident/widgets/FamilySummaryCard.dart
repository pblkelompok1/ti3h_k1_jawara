import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class FamilySummaryCard extends StatelessWidget {
  final String familyName;
  final String headName;
  final int memberCount;
  final bool isHead;

  const FamilySummaryCard({
    super.key,
    required this.familyName,
    required this.headName,
    required this.memberCount,
    required this.isHead,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      familyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kepala: $headName',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isHead)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Kepala',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Total Anggota:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '$memberCount Orang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
}
