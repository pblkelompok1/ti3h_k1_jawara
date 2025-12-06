import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';

class MarketMainScreen extends ConsumerStatefulWidget {
  const MarketMainScreen({super.key});

  @override
  ConsumerState<MarketMainScreen> createState() => _MarketMainScreenState();
}

class _MarketMainScreenState extends ConsumerState<MarketMainScreen>
    with SingleTickerProviderStateMixin {
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );
  final ScrollController _scrollController = ScrollController();
  int _currentBannerPage = 0;
  bool _isSearchBarSticky = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _onScroll() {
    // Trigger sticky search bar after scrolling 120 pixels
    final shouldStick = _scrollController.offset > 120;

    if (shouldStick != _isSearchBarSticky) {
      setState(() => _isSearchBarSticky = shouldStick);

      // Animate slide
      if (shouldStick) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildScrollingAppBar()),

              // Search Bar
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              SliverToBoxAdapter(child: _buildBannerSection()),
              SliverToBoxAdapter(child: _buildCategoriesSection()),
              SliverToBoxAdapter(child: _buildRecommendationSection()),
              SliverToBoxAdapter(child: _buildQuickFoodSection()),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                  child: Text(
                    'Produk Lokal Lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildLocalProductsGrid(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          // Sticky Search Bar with slide animation
          SlideTransition(
            position: _slideAnimation,
            child: _buildStickySearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollingAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDashboardAppHeader(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            // Store Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.store_mall_directory_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Title
            const Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Account Icon
            IconButton(
              onPressed: () => context.push('/account'),
              icon: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgPrimaryInputBox(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.softBorder(context),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondary(context),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Cari Produk',
                      ),
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryInputBox(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.softBorder(context),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.tune,
              color: AppColors.textPrimary(context),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimaryInputBox(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.softBorder(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        Icons.search,
                        color: AppColors.textSecondary(context),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari Produk',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimaryInputBox(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.softBorder(context),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.tune,
                  color: AppColors.textPrimary(context),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Column(
      children: [
        const SizedBox(height: 15),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: 3,
            onPageChanged: (index) {
              setState(() => _currentBannerPage = index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: index == 0
                    ? () => context.push('/camera-detection')
                    : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [const Color(0xFF2D3A2E), AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 20,
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 210, 220, 208),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'AI POWERED',
                            style: TextStyle(
                              color: Color.fromARGB(255, 47, 61, 51),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'DETEKSI SAYURMU!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Cek Jenis Sayur dari Kamera 📷',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'MULAI SCAN',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
        const SizedBox(height: 12),
        // Banner Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentBannerPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentBannerPage == index
                    ? AppColors.primary(context)
                    : AppColors.softBorder(context),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {
        'icon': Icons.restaurant,
        'label': 'Makanan',
        'color': const Color(0xFFE8F5E9),
      },
      {
        'icon': Icons.checkroom,
        'label': 'Pakaian',
        'color': const Color(0xFFE3F2FD),
      },
      {
        'icon': Icons.soup_kitchen,
        'label': 'Bahan Masak',
        'color': const Color(0xFFFFF3E0),
      },
      {
        'icon': Icons.build,
        'label': 'Jasa',
        'color': const Color(0xFFFCE4EC)
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: categories.map((cat) {
              return _buildCategoryItem(
                icon: cat['icon'] as IconData,
                label: cat['label'] as String,
                color: cat['color'] as Color,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    // Determine accent color based on category
    Color accentColor;
    if (label == 'Makanan') {
      accentColor = const Color(0xFF4CAF50); // Green
    } else if (label == 'Pakaian') {
      accentColor = const Color(0xFF2196F3); // Blue
    } else if (label == 'Bahan Masak') {
      accentColor = const Color(0xFFFF9800); // Orange
    } else {
      accentColor = const Color(0xFFE91E63); // Pink for Jasa
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bgDashboardCard(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withOpacity(0.5),
                width: 1.5,
              ),

            ),
            child: Icon(
              icon,
              size: 24,
              color: accentColor.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rekomendasi Untukmu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                final productId = index == 0 ? '2' : '1';
                return _buildProductCard(
                  productId: productId,
                  title: index == 0 ? 'Tahu Telor Warjo' : 'Sepatu Tidak Skena',
                  price: index == 0 ? 'Rp. 20.000' : 'Rp. 90.000',
                  imageUrl: index == 0
                      ? 'https://images.unsplash.com/photo-1551218808-94e220e084d2'
                      : 'https://images.unsplash.com/photo-1549298916-b41d501d3772',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFoodSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Makan Enak Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                final items = [
                  {'title': 'Pecel Buk Lintang', 'price': 'Rp. 15.000'},
                  {
                    'title':
                        'Sate Kecap Pak Bambang Super Pedes Makmur Nan jaya',
                    'price': 'Rp. 25.000',
                  },
                  {'title': 'Soto Enak Ala Madura', 'price': 'Rp. 30.000'},
                ];
                final item = items[index % items.length];
                return _buildFoodListItem(
                  title: item['title']!,
                  price: item['price']!,
                  rating: 4.5,
                  reviews: 16,
                  imageUrl:
                      'https://images.unsplash.com/photo-1551218808-94e220e084d2',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String productId,
    required String title,
    required String price,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () => context.push('/product/$productId'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBorder(context), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 12,
                      maxFontSize: 14,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    AutoSizeText(
                      price,
                      maxLines: 1,
                      minFontSize: 11,
                      maxFontSize: 13,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodListItem({
    required String title,
    required String price,
    required double rating,
    required int reviews,
    required String imageUrl,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder(context), width: 1.5),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey.shade300,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.fastfood, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 16,
                    maxFontSize: 17,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AutoSizeText(
                          '$rating ($reviews Review)',
                          maxLines: 1,
                          minFontSize: 9,
                          maxFontSize: 11,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AutoSizeText(
                    price,
                    maxLines: 1,
                    minFontSize: 11,
                    maxFontSize: 13,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverGrid _buildLocalProductsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final productId = index % 2 == 0 ? '2' : '1';
        return _buildProductCard(
          productId: productId,
          title: index % 2 == 0 ? 'Tahu Telor Warjo' : 'Sepatu Tidak Skena',
          price: index % 2 == 0 ? 'Rp. 20.000' : 'Rp. 90.000',
          imageUrl: index % 2 == 0
              ? 'https://images.unsplash.com/photo-1551218808-94e220e084d2'
              : 'https://images.unsplash.com/photo-1549298916-b41d501d3772',
        );
      }, childCount: 8),
    );
  }
}
