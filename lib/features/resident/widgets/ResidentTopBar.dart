import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/themes/app_colors.dart';

class ResidentTopBar extends ConsumerWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback? onRefreshPressed;

  const ResidentTopBar({
    super.key,
    required this.onSearchPressed,
    this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardAppHeader(context),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildHeader(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Icon Container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_alt,
            color: AppColors.textPrimaryDark,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        // Title Column
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                "Data Warga",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w500,
                ),
                minFontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              AutoSizeText(
                "Kelola Warga RT",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
                minFontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Refresh Button
        if (onRefreshPressed != null)
          InkWell(
            onTap: onRefreshPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.textPrimaryDark,
                size: 22,
              ),
            ),
          ),
        if (onRefreshPressed != null) const SizedBox(width: 8),
        // Search Button
        InkWell(
          onTap: onSearchPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimaryDark,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
