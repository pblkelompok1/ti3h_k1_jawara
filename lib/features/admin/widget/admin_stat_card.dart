import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final List<Color>? gradientColors;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trend; // For showing increase/decrease

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.gradientColors,
    this.subtitle,
    this.onTap,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary(context);
    final hasGradient = gradientColors != null && gradientColors!.length >= 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: hasGradient
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors!,
                  )
                : null,
            color: hasGradient ? null : AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: hasGradient
                    ? gradientColors![0].withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: hasGradient ? 12 : 8,
                offset: Offset(0, hasGradient ? 6 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: hasGradient ? Colors.white : AppColors.textPrimary(context),
                            height: 1,
                          ),
                          maxLines: 1,
                          minFontSize: 20,
                        ),
                        const SizedBox(height: 4),
                        AutoSizeText(
                          title,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasGradient 
                                ? Colors.white.withOpacity(0.9)
                                : AppColors.textSecondary(context),
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          minFontSize: 9,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          AutoSizeText(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 8,
                              color: hasGradient 
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.textSecondary(context),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            minFontSize: 7,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasGradient
                          ? Colors.white.withOpacity(0.2)
                          : effectiveIconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: hasGradient ? Colors.white : effectiveIconColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
