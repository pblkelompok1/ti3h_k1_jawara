import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class FinanceTopBar extends StatelessWidget {
  final String title;
  final IconData rightIcon;
  final VoidCallback? onRightTap;

  const FinanceTopBar({
    super.key,
    required this.title,
    this.rightIcon = Icons.person_outline_rounded,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDashboardAppHeader(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          right: 20,
          left: 20,
          bottom: 16,
          top: 60,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            IconButton(
              onPressed: onRightTap,
              icon: Icon(rightIcon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
