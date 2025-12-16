import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/resident_avatar.dart';

class ResidentListCard extends StatelessWidget {
  final Map<String, dynamic> resident;
  final VoidCallback onTap;

  const ResidentListCard({
    super.key,
    required this.resident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = resident['name'] ?? resident['family_name'] ?? 'Unknown';
    final familyName = resident['family_name'] ?? resident['name'] ?? '-';
    final occupation = resident['occupation_name'] ?? 'Tidak diketahui';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.softBorder(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ResidentAvatar(
              profilePath: resident['profile_img_path']?.toString(),
              size: 60,
              enableTap: true,
            ),
            const SizedBox(width: 16),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          name,
                          maxLines: 1,
                          minFontSize: 14,
                          maxFontSize: 16,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AutoSizeText(
                          familyName,
                          maxLines: 1,
                          minFontSize: 11,
                          maxFontSize: 13,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          occupation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Arrow Icon
            Column(
              children: [
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
