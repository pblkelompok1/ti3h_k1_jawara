import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/themes/app_colors.dart';

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
    final status = member['status'] ?? 'pending';
    final role = member['role'] ?? '-';
    final name = member['name'] ?? 'Unknown';
    final occupation = member['occupation'] ?? '-';
    final gender = member['gender'] ?? '-';

    Color statusColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Disetujui';
        break;
      case 'pending':
        statusColor = const Color(0xFFFF9800);
        statusText = 'Pending';
        break;
      case 'rejected':
        statusColor = AppColors.redAccentLight;
        statusText = 'Ditolak';
        break;
      default:
        statusColor = AppColors.textSecondary(context);
        statusText = status;
    }

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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                gender.toLowerCase() == 'laki-laki' 
                    ? Icons.man_rounded 
                    : Icons.woman_rounded,
                color: AppColors.primary(context),
                size: 32,
              ),
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
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
