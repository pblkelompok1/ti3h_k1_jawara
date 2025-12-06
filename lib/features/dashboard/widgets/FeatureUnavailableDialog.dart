import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class FeatureUnavailableDialog {
  static void show(
    BuildContext context, {
    String? title,
    String? message,
    IconData? icon,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ?? const Color(0xFFFF9800)).withOpacity(0.1),
                  border: Border.all(
                    color: (iconColor ?? const Color(0xFFFF9800)).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon ?? Icons.construction_rounded,
                  size: 40,
                  color: iconColor ?? const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title ?? 'Fitur Belum Tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message ??
                    'Maaf, fitur ini sedang dalam tahap pengembangan dan akan segera hadir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 28),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4285F4).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: const Color(0xFF4285F4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kami akan segera menghadirkan fitur ini untuk Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor ?? const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
