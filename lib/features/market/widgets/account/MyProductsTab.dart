import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../provider/account_provider.dart';

class MyProductsTab extends ConsumerWidget {
  const MyProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(userProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Add Product Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: () => _showProductFormDialog(context, ref, null),
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

        // Product List
        Expanded(
          child: products.isEmpty
              ? Center(
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
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan produk pertama Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onEdit: () => _showProductFormDialog(context, ref, product),
                      onDelete: () => _showDeleteConfirmation(context, ref, product['id']),
                      onToggleStatus: () => ref.read(userProductsProvider.notifier).toggleProductStatus(product['id']),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showProductFormDialog(BuildContext context, WidgetRef ref, Map<String, dynamic>? product) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: product),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProductsProvider.notifier).deleteProduct(productId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produk berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = product['status'] == 'active';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.softBorder(context),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Aktif' : 'Nonaktif',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),

                // Category
                Text(
                  product['category'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),

                // Price & Stock
                Row(
                  children: [
                    Text(
                      'Rp ${product['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stok: ${product['stock']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sold Count
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Terjual: ${product['sold']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Toggle Status
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleStatus,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isActive ? Colors.orange : Colors.green,
                          side: BorderSide(
                            color: isActive ? Colors.orange : Colors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          size: 18,
                        ),
                        label: Text(
                          isActive ? 'Nonaktifkan' : 'Aktifkan',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Edit Button
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary(context),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary(context).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Delete Button
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
    );
  }
}

class _ProductFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;

  const _ProductFormDialog({this.product});

  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  String _selectedCategory = 'Makanan';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _priceController = TextEditingController(text: widget.product?['price']?.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?['stock']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?['description'] ?? '');
    _selectedCategory = widget.product?['category'] ?? 'Makanan';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                DropdownMenuItem(value: 'Pakaian', child: Text('Pakaian')),
                DropdownMenuItem(value: 'Elektronik', child: Text('Elektronik')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: Text(isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga harus diisi')),
      );
      return;
    }

    final productData = {
      'id': widget.product?['id'] ?? 'UP${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameController.text,
      'category': _selectedCategory,
      'price': int.tryParse(_priceController.text) ?? 0,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'description': _descriptionController.text,
      'status': widget.product?['status'] ?? 'active',
      'sold': widget.product?['sold'] ?? 0,
      'image': widget.product?['image'] ?? '',
    };

    if (widget.product != null) {
      ref.read(userProductsProvider.notifier).updateProduct(widget.product!['id'], productData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui')),
      );
    } else {
      ref.read(userProductsProvider.notifier).addProduct(productData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan')),
      );
    }

    Navigator.of(context).pop();
  }
}
