import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

// provider
final activityTypeProvider = StateProvider<ActivityType>(
      (ref) => ActivityType.recommendation,
);

enum ActivityType { recommendation, popular }

class RecommendedFoodCards extends ConsumerStatefulWidget {
  const RecommendedFoodCards({super.key});

  @override
  ConsumerState<RecommendedFoodCards> createState() =>
      _RecommendedFoodCardsState();
}

class _RecommendedFoodCardsState
    extends ConsumerState<RecommendedFoodCards> {
  final PageController _pageController =
  PageController(viewportFraction: 0.88);

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(activityTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Makanan Cepat Sehat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),

        // Separator line
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            width: double.infinity,
            height: 1.2,
            color: AppColors.softBorder(context),
          ),
        ),

        // PageView Cards
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: 3, // jumlah halaman (bukan jumlah card)
            itemBuilder: (context, pageIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCard("Card ${pageIndex * 2}"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCard("Card ${pageIndex * 2 + 1}"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final bool isActive = _currentPage == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary(context)
                    : AppColors.softBorder(context),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        // Button: Lihat Semua
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(top: 6, right: 25),
              child: Text(
                "Lihat semua",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 30,)
      ],
    );
  }

  Widget _buildCard(String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: AppColors.softBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar kotak dengan border radius
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 110,
                width: double.infinity,
                color: Colors.grey.shade300, // placeholder
                child: Image.network(
                  "https://images.unsplash.com/photo-1551218808-94e220e084d2",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Judul
            Text(
              "Nama Makanan $label",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            // Harga (lebih kecil & samar)
            Text(
              "Rp 25.000",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
