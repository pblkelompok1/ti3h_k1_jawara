import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class RtContactsCards extends StatelessWidget {
  const RtContactsCards({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Text(
            'Hubungi Pengurus',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary(context),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Container(height: 1.2, color: AppColors.softBorder(context)),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return _buildCard("Card $index", context);
            },
          ),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildCard(String label, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.4, color: AppColors.softBorder(context)),
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
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://images.unsplash.com/photo-1551218808-94e220e084d2",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10),

            AutoSizeText(
              "Nama rsdM ih ii ji jij ij iakanan $label",
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),

            AutoSizeText(
              "Rp 25.000",
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
