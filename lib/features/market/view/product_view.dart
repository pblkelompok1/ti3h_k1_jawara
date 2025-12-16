import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../provider/marketplace_provider.dart';
import '../models/marketplace_product_model.dart';
import '../models/product_rating_model.dart';

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

  List<ProductRating> _applyRatingFilter(List<ProductRating> reviews) {
    final activeRatings = _ratingFilter.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeRatings.isEmpty) return reviews;

    return reviews
        .where((r) => activeRatings.contains(r.ratingValue))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final ratingsAsync = ref.watch(productRatingsProvider(widget.productId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: AppColors.bgDashboardAppHeader(context),
        foregroundColor: Colors.white,
      ),
      body: productAsync.when(
        data: (product) => Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(product),
                  _buildProductInfo(product),
                  _buildRatingsSection(ratingsAsync),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _buildBottomBar(context, product),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildImageGallery(MarketplaceProduct product) {
    final service = ref.read(marketplaceServiceProvider);
    final images = product.imagesPath;
    
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: images.isEmpty
                  ? Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 100),
                    )
                  : PageView.builder(
                      controller: _imageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          service.getImageUrl(images[index]),
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
          if (images.isNotEmpty) _buildPageIndicator(images.length),
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
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(MarketplaceProduct product) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(product),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildDescription(product),
          const SizedBox(height: 24),
          _buildMoreDetails(product),
        ],
      ),
    );
  }

  Widget _buildProductHeader(MarketplaceProduct product) {
    final quantity = ref.watch(quantityProvider(widget.productId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    product.sellerName ?? 'Penjual',
                    maxLines: 1,
                    minFontSize: 14,
                    maxFontSize: 18,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildQuantitySelector(product, quantity),
          ],
        ),
        const SizedBox(height: 8),
        _buildRatingRow(product),
        const SizedBox(height: 12),
        Text(
          'Rp ${product.price}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuantitySelector(MarketplaceProduct product, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softBorder(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder(context), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: AppColors.textPrimary(context),
              size: 20,
            ),
            onPressed: quantity > 1
                ? () => ref.read(quantityProvider(widget.productId).notifier).state--
                : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: AppColors.textPrimary(context),
              size: 20,
            ),
            onPressed: quantity < product.stock
                ? () => ref.read(quantityProvider(widget.productId).notifier).state++
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(MarketplaceProduct product) {
    final rating = product.averageRating ?? 0.0;
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber.shade700, size: 20),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '• ${product.viewCount} dilihat',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }



  Widget _buildDivider() {
    return Container(
      height: 2,
      width: double.infinity,
      color: AppColors.softBorder(context),
    );
  }

  Widget _buildDescription(MarketplaceProduct product) {
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

  Widget _buildMoreDetails(MarketplaceProduct product) {
    final detail = product.moreDetail;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Tambahan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Berat', detail.weight),
        _buildDetailRow('Kondisi', detail.condition),
        _buildDetailRow('Brand', detail.brand),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(AsyncValue<List<ProductRating>> ratingsAsync) {
    return ratingsAsync.when(
      data: (ratings) {
        final filteredRatings = _applyRatingFilter(ratings);
        
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ulasan Pembeli (${ratings.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildRatingFilter(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              filteredRatings.isEmpty
                  ? Text(
                      ratings.isEmpty 
                          ? 'Belum ada ulasan' 
                          : 'Tidak ada ulasan untuk filter ini',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    )
                  : Column(
                      children: filteredRatings
                          .map((rating) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildRatingCard(rating),
                              ))
                          .toList(),
                    ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(25),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(25),
        child: Text(
          'Gagal memuat ulasan',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      ),
    );
  }
  
  Widget _buildRatingCard(ProductRating rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary(context).withValues(alpha: 0.1),
                child: Text(
                  rating.userName?.isNotEmpty == true
                      ? rating.userName![0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.userName ?? 'User',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating.ratingValue
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(rating.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rating.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rating.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
          selectedColor: Colors.amber.withValues(alpha: 0.18), // highlight emas
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

  Widget _buildBottomBar(BuildContext context, MarketplaceProduct product) {
    final quantity = ref.watch(quantityProvider(widget.productId));
    final totalPrice = product.price * quantity;
    
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
              color: Colors.black.withValues(alpha: 0.1),
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
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp $totalPrice',
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
              _buildBuyButton(product),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        onPressed: () {
          // TODO: Implement add to cart
        },
      ),
    );
  }

  Widget _buildBuyButton(MarketplaceProduct product) {
    final quantity = ref.read(quantityProvider(widget.productId));
    return ElevatedButton.icon(
      onPressed: () {
        context.push('/checkout/${product.productId}/$quantity');
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
