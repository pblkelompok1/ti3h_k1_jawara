import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.90);
  int _page = 0;

  final List<_BannerData> banners = [];

  @override
  void initState() {
    super.initState();
    banners.addAll([
      _BannerData(
        title: 'Selamat Datang! 👋',
        subtitle: 'Semoga harimu menyenangkan',
        icon: Icons.waving_hand_rounded,
      ),
      _BannerData(
        title: 'Pembaruan Terbaru 🚀',
        subtitle: 'Lihat fitur-fitur terbaru',
        icon: Icons.rocket_launch_rounded,
      ),
      _BannerData(
        title: 'Tetap Produktif 💪',
        subtitle: 'Selesaikan tugasmu hari ini',
        icon: Icons.task_alt_rounded,
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => AnimatedScale(
              scale: _page == i ? 1.0 : 0.94,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: _buildBannerCard(context, banners[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicator(context),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, _BannerData banner) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.03),
              ),
            ),
          ),
          // Decorative dots
          Positioned(
            top: 20,
            right: 30,
            child: _buildDecorativeDot(primaryColor, 8),
          ),
          Positioned(
            bottom: 30,
            right: 50,
            child: _buildDecorativeDot(primaryColor, 12),
          ),
          Positioned(
            top: 50,
            left: 30,
            child: _buildDecorativeDot(primaryColor, 6),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    banner.icon,
                    size: 40,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        banners.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _page == i ? 28 : 8,
          decoration: BoxDecoration(
            color: _page == i
                ? AppColors.primary(context)
                : AppColors.softBorder(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;

  _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
