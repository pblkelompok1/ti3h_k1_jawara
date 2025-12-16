import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class PlaceholderSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PlaceholderSection({
    super.key,
    this.title = 'Fitur dalam Pengembangan',
    this.subtitle = 'Fitur ini sedang dalam tahap pengembangan',
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary(context).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
