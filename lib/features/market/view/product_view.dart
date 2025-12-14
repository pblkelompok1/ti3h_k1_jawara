import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/market/provider/product_provider.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../provider/review_provider.dart';
import '../widgets/account/review_card.dart';

class ProductView extends ConsumerStatefulWidget {
  const ProductView({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<ProductView> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  final Map<int, bool> _ratingFilter = {
    5: false,
    4: false,
    3: false,
    2: false,
    1: false,
  };

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<ProductReview> _applyRatingFilter(List<ProductReview> reviews) {
    final activeRatings = _ratingFilter.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeRatings.isEmpty) return reviews;

    return reviews
        .where((r) => activeRatings.contains(r.rating.round()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));
    final quantity = ref.watch(quantityProvider(widget.productId));

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produk Tidak Ditemukan')),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, product),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(product),
                _buildProductInfo(product, quantity),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildBottomBar(context, product, quantity),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Product product) {
    return AppBar(
      title: Text(
        product.kategori.first,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.bgDashboardCard(context),
      foregroundColor: AppColors.textPrimary(context),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildImageGallery(Product product) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _imageController,
                itemCount: product.images.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    product.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 100),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildPageIndicator(product.images.length),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentImageIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentImageIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product, int quantity) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(product, quantity),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildDescription(product),
          const SizedBox(height: 24),
          _buildMoreDetails(product),
          const SizedBox(height: 24),
          _buildReviewSection(product),
        ],
      ),
    );
  }

  Widget _buildProductHeader(Product product, int quantity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                product.name,
                maxLines: 2,
                minFontSize: 18,
                maxFontSize: 24,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              AutoSizeText(
                product.seller,
                maxLines: 1,
                minFontSize: 14,
                maxFontSize: 18,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              _buildRatingRow(product),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildQuantitySelector(quantity),
      ],
    );
  }

  Widget _buildRatingRow(Product product) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber.shade700, size: 20),
        const SizedBox(width: 4),
        Text(
          '${product.rating}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount} Review)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softBorder(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder(context), width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: AppColors.textPrimary(context),
              size: 24,
            ),
            onPressed: () {
              if (quantity > 1) {
                ref.read(quantityProvider(widget.productId).notifier).state--;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: AppColors.textPrimary(context),
              size: 24,
            ),
            onPressed: () {
              final product = ref.read(productByIdProvider(widget.productId));
              if (product != null && quantity < product.stock) {
                ref.read(quantityProvider(widget.productId).notifier).state++;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      width: double.infinity,
      color: AppColors.softBorder(context),
    );
  }

  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDetails(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: product.moreDetail.map((detail) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail['title']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail['description']!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewSection(Product product) {
    final reviews = ref.watch(productReviewsProvider(widget.productId));
    final filteredReviews = _applyRatingFilter(reviews);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ulasan Pembeli (${filteredReviews.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildRatingFilter(),
        const SizedBox(height: 16),
        filteredReviews.isEmpty
            ? Text(
                'Tidak ada ulasan untuk filter ini',
                style: TextStyle(color: AppColors.textSecondary(context)),
              )
            : Column(
                children: filteredReviews
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewCard(review: review),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _ratingFilter.keys.map((star) {
        final isSelected = _ratingFilter[star]!;

        return FilterChip(
          showCheckmark: false,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber.shade600, // ⭐ SELALU EMAS
              ),
              const SizedBox(width: 4),
              Text(
                '$star',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary(context)
                      : AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          selected: isSelected,
          selectedColor: Colors.amber.withOpacity(0.18), // highlight emas
          backgroundColor: AppColors.bgDashboardCard(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Colors.amber.shade600
                  : AppColors.softBorder(context),
            ),
          ),
          onSelected: (value) {
            setState(() => _ratingFilter[star] = value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product, int quantity) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardAppHeader(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Harga',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormatter.format(product.price * quantity),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildCartButton(),
              const SizedBox(width: 8),
              _buildBuyButton(product, quantity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildBuyButton(Product product, int quantity) {
    return ElevatedButton.icon(
      onPressed: () {
        context.push('/checkout/${product.id}/$quantity');
      },
      icon: const Icon(Icons.shopping_bag, color: Color(0xFF40513B)),
      label: const Text(
        'Beli',
        style: TextStyle(color: Color(0xFF40513B), fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
