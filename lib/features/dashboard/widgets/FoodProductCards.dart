import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/market/provider/marketplace_provider.dart';
import 'package:ti3h_k1_jawara/features/market/models/marketplace_product_model.dart';
import 'package:ti3h_k1_jawara/features/market/view/product_list_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RecommendedFoodCards extends ConsumerStatefulWidget {
  const RecommendedFoodCards({super.key});

  @override
  ConsumerState<RecommendedFoodCards> createState() =>
      _RecommendedFoodCardsState();
}

class _RecommendedFoodCardsState
    extends ConsumerState<RecommendedFoodCards> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quickFoodAsync = ref.watch(quickFoodProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Makanan Cepat Sehat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            width: double.infinity,
            height: 1.2,
            color: AppColors.softBorder(context),
          ),
        ),
        const SizedBox(height: 20),

        // Food Products List
        SizedBox(
          height: 120,
          child: quickFoodAsync.when(
            data: (foodProducts) {
              if (foodProducts.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada produk makanan cepat',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: foodProducts.length,
                itemBuilder: (context, index) {
                  final product = foodProducts[index];
                  return _buildFoodListItem(product: product);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Gagal memuat produk',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // View All Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(initialCategory: 'Makanan'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                foregroundColor: AppColors.primaryLight,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodListItem({
    required MarketplaceProduct product,
  }) {
    final service = ref.read(marketplaceServiceProvider);
    final imageUrl = product.imagesPath.isNotEmpty 
        ? service.getImageUrl(product.imagesPath.first) 
        : '';
    
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.push('/product/${product.productId}');
        service.incrementViewCount(product.productId);
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBorder(context), width: 1.3),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 120,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: AppColors.softBorder(context),
                          child: Icon(
                            Icons.fastfood_rounded,
                            size: 40,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.softBorder(context),
                        child: Icon(
                          Icons.fastfood_rounded,
                          size: 40,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    AutoSizeText(
                      product.name,
                      maxLines: 2,
                      minFontSize: 11,
                      maxFontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Rating & Stock
                    Row(
                      children: [
                        if (product.averageRating != null) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.averageRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Price
                    AutoSizeText(
                      'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                          )}',
                      maxLines: 1,
                      minFontSize: 10,
                      maxFontSize: 13,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
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
