import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class ApprovalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Widget? badge;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final List<Widget>? additionalInfo;

  const ApprovalCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.badge,
    this.onApprove,
    this.onReject,
    this.onTap,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary(context).withOpacity(0.1),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary(context).withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary(context),
                      size: 24,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                          if (badge != null) badge!,
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (additionalInfo != null && additionalInfo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...additionalInfo!,
            ],
            if (onApprove != null || onReject != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: AppColors.redAccent(context),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            color: AppColors.redAccent(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (onReject != null && onApprove != null)
                    const SizedBox(width: 12),
                  if (onApprove != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
