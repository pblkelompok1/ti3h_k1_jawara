import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class BalanceTextLoading extends StatelessWidget {
  const BalanceTextLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.textSecondary(context).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
