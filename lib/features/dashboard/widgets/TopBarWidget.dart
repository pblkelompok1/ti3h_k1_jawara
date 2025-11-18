import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/theme_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomTopBar extends ConsumerWidget {
  final bool isVisible;

  const CustomTopBar({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      top: isVisible ? 0 : -200,
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardAppHeader(context),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.primary(context).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
          ],
        ),
        child: _buildHeader(context, ref),  // ← header Dashboard masuk di sini
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            "https://i.pinimg.com/736x/5d/e7/9e/5de79ee675c983703b09a3fc637a01cd.jpg",
          ),
        ),
        const SizedBox(width: 15),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              "Hallo 👋",
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimaryDark,
              ),
              minFontSize: 8, // opsional, batas bawah font ketika mengecil
              overflow: TextOverflow.ellipsis,
            ),
            AutoSizeText(
              "Nama Pengguna",
              maxLines: 1,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: AppColors.textPrimaryDark,
          ),
          onPressed: () =>
              ref.read(themeProvider.notifier).toggleTheme(),
        ),
      ],
    );
  }
}
