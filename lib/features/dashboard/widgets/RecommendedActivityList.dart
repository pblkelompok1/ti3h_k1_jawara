import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

// 1. Provider untuk toggle antara recommendation dan popular
final activityTypeProvider = StateProvider<ActivityType>(
  (ref) => ActivityType.recommendation,
);

enum ActivityType { recommendation, popular }

class RecommendedActivityList extends ConsumerWidget {
  const RecommendedActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(activityTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        // 2. Title selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kegiatan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary(context),
              ),
            ),
            _buildSubTitleSelector(context, ref, selectedType),
          ],
        ),
        // Garis full width
        Container(
          width: double.infinity,
          height: 1.2,
          color: AppColors.softBorder(context), // atau Colors.grey.shade300
        ),
        // 3. Placeholder container untuk list view
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://i.pinimg.com/736x/5d/e7/9e/5de79ee675c983703b09a3fc637a01cd.jpg",
          title: 'Kegiatan Gotong Royong',
          date: 'date',
          viewers: 312,
        ),
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://i.pinimg.com/736x/5d/e7/9e/5de79ee675c983703b09a3fc637a01cd.jpg",
          title: 'Kegiatan Gotong Royong Mayat Jokowi',
          date: 'date',
          viewers: 312,
        ),
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://i.pinimg.com/736x/5d/e7/9e/5de79ee675c983703b09a3fc637a01cd.jpg",
          title: 'Kegiatan Gotong Royong Mayat Jokowi',
          date: 'date',
          viewers: 312,
        ),
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://i.pinimg.com/736x/5d/e7/9e/5de79ee675c983703b09a3fc637a01cd.jpg",
          title: 'Kegiatan Gotong Royong Mayat Jokowi',
          date: 'date',
          viewers: 312,
        ),
        // Tambahan: teks “Lihat semua”
        GestureDetector(
          onTap: () {
            // navigasi ke halaman daftar kegiatan
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Lihat semua",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary(context),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildSubTitleSelector(
    BuildContext context,
    WidgetRef ref,
    ActivityType selectedType,
  ) {
    return Row(
      children: [
        _buildTitle(
          context,
          ref,
          "Terbaru",
          ActivityType.recommendation,
          selectedType,
        ),
        const SizedBox(width: 24),
        _buildTitle(
          context,
          ref,
          "Populer",
          ActivityType.popular,
          selectedType,
        ),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    WidgetRef ref,
    String title,
    ActivityType type,
    ActivityType selectedType,
  ) {
    final isActive = type == selectedType;

    // Hitung lebar teks
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;

    return GestureDetector(
      onTap: () {
        ref.read(activityTypeProvider.notifier).state = type;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppColors.primary(context),
            ),
            width: isActive ? textWidth : 0, // Lebar dinamis sesuai teks
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required BuildContext context,
    required String imageUrl,
    required String title,
    required String date,
    required int viewers,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image persegi tumpul
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        // Column info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul
              AutoSizeText(
                title,
                maxLines: 2,
                minFontSize: 15,
                maxFontSize: 24,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              // Row tanggal & viewers
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      AutoSizeText(
                        date,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye_rounded,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      AutoSizeText(
                        viewers.toString(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
