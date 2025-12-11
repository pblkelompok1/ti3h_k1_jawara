import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/market/provider/product_provider.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProductView extends ConsumerWidget {
  const ProductView({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productByIdProvider(productId));
    final quantity = ref.watch(quantityProvider(productId));

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produk Tidak Ditemukan')),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    final PageController imageController = PageController();
    int currentImageIndex = 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery with Page Indicator
                StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: PageView.builder(
                                controller: imageController,
                                itemCount: product.images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: Image.network(
                                      product.images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          size: 100,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Page Indicator Dots
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: currentImageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Product Title and Actions
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name & Nominal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                  minFontSize: 18,
                                  maxFontSize: 24,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Seller
                                AutoSizeText(
                                  product.seller,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  minFontSize: 14,
                                  maxFontSize: 18,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade700,
                                      size: 20,
                                    ),
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          /// Nominal
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.softBorder(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryBorder(context),
                                width: 1,
                              ),
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
                                      ref
                                          .read(
                                            quantityProvider(
                                              productId,
                                            ).notifier,
                                          )
                                          .state--;
                                    }
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                                    if (quantity < product.stock) {
                                      ref
                                          .read(
                                            quantityProvider(
                                              productId,
                                            ).notifier,
                                          )
                                          .state++;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Line Divider
                      SizedBox(
                        height: 2,
                        width: double.infinity,
                        child: Container(color: AppColors.softBorder(context)),
                      ),
                      const SizedBox(height: 16),
                      // Kategori
                      Text(
                        'Bumbu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'blablabal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                      const SizedBox(height: 24),
                      // More Details
                      ...product.moreDetail.map(
                        (detail) => Padding(
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),

          // Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgDashboardAppHeader(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
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
                    // Quantity Controls
                    const SizedBox(width: 16),
                    // Price and Buy Button
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currencyFormatter.format(
                                    product.price * quantity,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Cart Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Buy Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Handle buy action
                                  GoRouter.of(
                                    context,
                                  ).push('/checkout/${product.id}/{$quantity}');
                                },
                                icon: const Icon(
                                  Icons.shopping_bag,
                                  color: Color(0xFF40513B),
                                ),
                                label: const Text(
                                  'Beli',
                                  style: TextStyle(
                                    color: Color(0xFF40513B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
