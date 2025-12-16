import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/themes/app_colors.dart';

class FamilyListCard extends StatelessWidget {
  final Map<String, dynamic> family;
  final VoidCallback onTap;

  const FamilyListCard({
    super.key,
    required this.family,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final familyName = family['family_name']?.toString() ?? '-';
    final headOfFamily = family['head_of_family']?.toString();
    final address = family['address']?.toString();
    final rtName = family['rt_name']?.toString() ?? '-';
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: isDark ? 4 : 1,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.family_restroom,
            size: 28,
            color: AppColors.primary(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: AutoSizeText(
            familyName,
            maxLines: 1,
            minFontSize: 14,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Head of family
            if (headOfFamily != null && headOfFamily.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: AppColors.textSecondary(context).withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: AutoSizeText(
                        headOfFamily,
                        maxLines: 1,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Address - max 1 line with ellipsis
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.textSecondary(context).withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: AutoSizeText(
                    address?.isEmpty ?? true ? 'Alamat belum diisi' : address!,
                    maxLines: 1,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                      fontStyle: address?.isEmpty ?? true ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // RT badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rtName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary(context),
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}
