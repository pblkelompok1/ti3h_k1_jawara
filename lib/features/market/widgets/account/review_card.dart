import 'package:flutter/material.dart';
import '../../provider/review_provider.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final ProductReview review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary(context).withOpacity(0.2),
                child: Text(
                  review.userName[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < review.rating
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
