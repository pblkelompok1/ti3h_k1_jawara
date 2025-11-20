import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class PaymentSummaryCards extends StatelessWidget {
  const PaymentSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          context,
          icon: Icons.group,
          iconColor: const Color(0xFF4285F4),
          iconBgColor: const Color(0xFFE8F0FE),
          title: "Total Tunggakan",
          value: "855",
          percentage: "-4,8%",
          isPositive: false,
          color: AppColors.bgDashboardCard(context),
          onTap: () {},
        ),
        const SizedBox(width: 10),
        _buildCard(
          context,
          icon: Icons.shopping_cart_checkout_rounded,
          iconColor: const Color(0xFF9C27B0),
          iconBgColor: const Color(0xFFF3E5F5),
          title: "Checkout",
          value: "5",
          percentage: "-2,1%",
          isPositive: false,
          color: AppColors.bgDashboardCard(context),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required Color iconBgColor,
        required String title,
        required String value,
        required String percentage,
        required bool isPositive,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(width: 2, color: AppColors.softBorder(context)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            splashColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: iconColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        percentage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
