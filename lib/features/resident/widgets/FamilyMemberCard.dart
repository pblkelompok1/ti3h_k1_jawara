import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/resident_avatar.dart';

class FamilyMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isHead;
  final VoidCallback? onEdit;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.isHead,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = member['role'] ?? member['family_role'] ?? '-';
    final name = member['name'] ?? 'Unknown';
    final occupation = member['occupation_name'] ?? member['occupation'] ?? 'Tidak diketahui';
    final gender = member['gender'] ?? '-';

    return InkWell(
      onTap: onEdit,
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
              profilePath: member['profile_img_path']?.toString(),
              size: 60,
              enableTap: true,
            ),
            const SizedBox(width: 16),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AutoSizeText(
                          occupation,
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
                        Icons.label_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        role,
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
            
            // Edit Button
            if (isHead && onEdit != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.primary(context),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
