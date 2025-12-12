import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';
import '../../view/product_form_view.dart';

class ProductDetailView extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = product['status'] == "active";

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.bgDashboardAppHeader(context),
        foregroundColor: Colors.white,
        title: const Text("Detail Produk"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImages(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? "Aktif" : "Nonaktif",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${product['category']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          "Harga",
                          "Rp ${product['price']}",
                          Icons.attach_money,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          "Stok",
                          "${product['stock']}",
                          Icons.inventory_2_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildInfoItem(
                    context,
                    "Terjual",
                    "${product['sold'] ?? 0}",
                    Icons.shopping_cart_outlined,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product['description'] ?? "Tidak ada deskripsi",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary(context),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Toggle Status
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(userProductsProvider.notifier)
                            .toggleProductStatus(product['id']);
                        Navigator.pop(context); // kembali setelah toggle
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? Colors.orange.shade600
                            : Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        isActive ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      label: Text(
                        isActive ? "Nonaktifkan" : "Aktifkan",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // ===========================
                      //          EDIT BUTTON
                      // ===========================
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductFormScreen(product: product),
                                ),
                              );

                              if (updated == true) {
                                ref.invalidate(userProductsProvider);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.primary(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary(context),
                            ),
                            label: Text(
                              "Edit",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary(context),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Delete Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteDialog(context, ref),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Hapus",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  //   IMAGE VIEWER
  // ===========================
  Widget _buildProductImages() {
    final single = product['image'];
    final multi = product['images'];

    if (multi != null && multi is List && multi.isNotEmpty) {
      return SizedBox(
        height: 260,
        child: PageView.builder(
          itemCount: multi.length,
          itemBuilder: (context, index) {
            final img = multi[index].toString();
            return _buildImageItem(img);
          },
        ),
      );
    }

    if (single != null && single.toString().isNotEmpty) {
      return SizedBox(
        height: 260,
        width: double.infinity,
        child: _buildImageItem(single.toString()),
      );
    }

    return Container(
      height: 260,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade400),
    );
  }

  Widget _buildImageItem(String imgPath) {
    final isUrl = imgPath.startsWith("http");

    return Container(
      width: double.infinity,
      height: 260,
      color: Colors.grey.shade200,
      child: isUrl
          ? Image.network(
              imgPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            )
          : Image.file(
              File(imgPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Produk?"),
        content: Text("Produk '${product['name']}' akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(userProductsProvider.notifier)
                  .deleteProduct(product['id']);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
