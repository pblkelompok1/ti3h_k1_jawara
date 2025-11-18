import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _page = 0;

  final List<_BannerData> banners = [];

  @override
  void initState() {
    super.initState();
    banners.addAll([
      _BannerData(
        title: 'Welcome Back! 👋',
        subtitle: 'Have a great day ahead',
      ),
      _BannerData(
        title: 'New Updates 🚀',
        subtitle: 'Check out the latest features',
      ),
      _BannerData(
        title: 'Stay Productive 💪',
        subtitle: 'Complete your tasks today',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 130),
        _buildCarousel(context),
        const SizedBox(height: 12),
        _buildIndicator(context),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        itemCount: banners.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (_, i) => AnimatedScale(
          scale: _page == i ? 1.0 : 0.96,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary(context),
                  AppColors.primary(context).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banners[i].title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  banners[i].subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          width: _page == i ? 24 : 8,
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

  _BannerData({required this.title, required this.subtitle});
}
