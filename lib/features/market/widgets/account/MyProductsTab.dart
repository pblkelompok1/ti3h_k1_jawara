import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import '../../view/product_form_view.dart';
import '../../models/marketplace_product_model.dart';
import 'product_detail_view.dart';

class MyProductsTab extends ConsumerWidget {
  const MyProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(currentUserIdProvider);

    return userIdAsync.when(
      data: (userId) {
        if (userId == null) {
          return Center(
            child: Text(
              'User tidak ditemukan',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          );
        }

        final productsAsync = ref.watch(userProductsProvider(userId));
        
        return productsAsync.when(
          data: (products) => _buildContent(context, ref, products, userId),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading user: $error',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<MarketplaceProduct> products, String userId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Tambah Produk Baru',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: products.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _ProductCardSimple(
                      product: products[index],
                      userId: userId,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.textSecondary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada produk',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCardSimple extends ConsumerWidget {
  final MarketplaceProduct product;
  final String userId;
  
  const _ProductCardSimple({
    required this.product,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = product.status == 'active';
    final marketplaceService = ref.read(marketplaceServiceProvider);
    final String? imageUrl = product.imagesPath.isNotEmpty ? product.imagesPath.first : null;
    final fullImageUrl = imageUrl != null ? marketplaceService.getImageUrl(imageUrl) : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailView(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBorder(context), width: 1),
        ),
        child: Row(
          children: [
            // ===================== IMAGE =====================
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(fullImageUrl),
            ),

            const SizedBox(width: 14),

            // ===================== INFO ======================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Rp ${product.price}",
                    style: TextStyle(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        "Stok: ${product.stock}",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Terjual: ${product.soldCount}",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===================== STATUS BADGE =====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? "Aktif" : "Nonaktif",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UNIVERSAL IMAGE LOADER (network only for now)
  Widget _buildImage(String? url) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade200,
      child: url == null || url.isEmpty
          ? Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 34)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
