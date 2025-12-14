import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import '../provider/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String initialCategory;

  const ProductListScreen({super.key, required this.initialCategory});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late String selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {'label': 'Semua', 'icon': Icons.apps},
    {'label': 'Makanan', 'icon': Icons.restaurant},
    {'label': 'Pakaian', 'icon': Icons.checkroom},
    {'label': 'Bahan Masak', 'icon': Icons.soup_kitchen},
    {'label': 'Jasa', 'icon': Icons.build},
    {'label': 'Elektronik', 'icon': Icons.electrical_services},
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory =
        categories.any((c) => c['label'] == widget.initialCategory)
        ? widget.initialCategory
        : 'Semua';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productRepositoryProvider).getAllProducts();

    // Filter by category
    var filteredProducts = selectedCategory == 'Semua'
        ? products
        : products.where((p) {
            return p.kategori.isNotEmpty &&
                p.kategori.first.toLowerCase() ==
                    selectedCategory.toLowerCase();
          }).toList();

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.bgDashboardAppHeader(context),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(selectedCategory),
          ),

          // Sticky Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchDelegate(child: _buildSearchBar()),
          ),

          // Category Filter
          SliverToBoxAdapter(child: _buildCategoryFilter()),

          // Products Grid
          filteredProducts.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(
                        context: context,
                        product: product,
                      );
                    }, childCount: filteredProducts.length),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.bgPrimaryInputBox(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.softBorder(context), width: 1),
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
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari produk...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 14,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final c = categories[index];
          final label = c['label'] as String;
          final icon = c['icon'] as IconData;
          final isActive = label == selectedCategory;

          return _buildCategoryItem(
            icon: icon,
            label: label,
            isActive: isActive,
            onTap: () => setState(() => selectedCategory = label),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    Color accentColor;

    switch (label) {
      case 'Makanan':
        accentColor = const Color(0xFF4CAF50);
        break;
      case 'Pakaian':
        accentColor = const Color(0xFF2196F3);
        break;
      case 'Bahan Masak':
        accentColor = const Color(0xFFFF9800);
        break;
      case 'Jasa':
        accentColor = const Color(0xFFE91E63);
        break;
      case 'Elektronik':
        accentColor = const Color(0xFF9C27B0);
        break;
      default:
        accentColor = const Color(0xFF607D8B);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor.withOpacity(0.15)
                    : AppColors.bgDashboardCard(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(isActive ? 1 : 0.5),
                  width: isActive ? 2 : 1.5,
                ),
              ),
              child: Icon(icon, size: 22, color: accentColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? accentColor : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required Product product,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.softBorder(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgDashboardCard(
                        context,
                      ).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.stock > 0
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.stock > 0 ? "Stok ${product.stock}" : "Habis",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      product.name,
                      maxLines: 2,
                      minFontSize: 14,
                      maxFontSize: 17,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                        height: 1.25,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "Rp ${product.price}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary(context),
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
}

// Sticky Search Delegate
class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchDelegate({required this.child});

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
