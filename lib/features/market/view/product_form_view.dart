import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/account_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;

  String _selectedCategory = "Makanan";
  bool isEdit = false;

  List<PlatformFile> _images = [];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.product != null) {
      final p = widget.product!;
      isEdit = true;

      _nameController.text = p['name'] ?? '';
      _priceController.text = p['price']?.toString() ?? '';
      _stockController.text = p['stock']?.toString() ?? '';
      _descriptionController.text = p['description'] ?? '';
      _selectedCategory = p['category'] ?? "Makanan";

      // ===== FIX BAGIAN GAMBARNYA DI SINI =====
      _images = [];

      // CASE 1 → produk lama memakai field single "image"
      if (p['image'] != null && p['image'].toString().isNotEmpty) {
        _images.add(
          PlatformFile(
            name: p['image'].toString().split('/').last,
            path: p['image'],
            size: 0,
            bytes: null,
          ),
        );
      }

      // CASE 2 → produk baru memakai list "images"
      if (p['images'] != null && p['images'] is List) {
        for (final img in p['images']) {
          _images.add(
            PlatformFile(
              name: img.toString().split('/').last,
              path: img.toString(),
              size: 0,
              bytes: null,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: kIsWeb,
      withReadStream: !kIsWeb,
    );

    if (result == null) return;

    setState(() {
      for (final f in result.files) {
        final exists = _images.any(
          (e) =>
              (e.path != null && e.path == f.path) ||
              (e.bytes != null && e.bytes == f.bytes),
        );
        if (!exists) _images.add(f);
      }
    });
  }

  void _removeImageAt(int index) {
    setState(() => _images.removeAt(index));
  }

  void _saveProduct() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Harap isi semua data dengan benar"),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    String? imageForSave;
    if (_images.isNotEmpty) {
      final f = _images.first;
      imageForSave = f.path?.isNotEmpty == true ? f.path : f.name;
    } else {
      imageForSave = widget.product?['image'] ?? '';
    }

    final productData = {
      "id":
          widget.product?['id'] ?? "UP${DateTime.now().millisecondsSinceEpoch}",
      "name": name,
      "category": _selectedCategory,
      "price": price,
      "stock": stock,
      "description": description,
      "image": imageForSave,
      "status": widget.product?['status'] ?? "active",
      "sold": widget.product?['sold'] ?? 0,
    };

    if (isEdit) {
      ref
          .read(userProductsProvider.notifier)
          .updateProduct(widget.product!['id'], productData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Produk berhasil diperbarui"),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } else {
      ref.read(userProductsProvider.notifier).addProduct(productData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Produk berhasil ditambahkan"),
          backgroundColor: Colors.green.shade600,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.bgDashboardAppHeader(context),
        elevation: 0,
        title: Text(
          isEdit ? "Edit Produk" : "Tambah Produk",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.info_outline,
              title: "Informasi Produk",
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _nameController,
              label: "Nama Produk",
              hint: "Masukkan nama produk",
              icon: Icons.inventory_2_outlined,
            ),

            _buildCategoryField(),

            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _priceController,
                    label: "Harga",
                    hint: "0",
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    prefix: "Rp ",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    controller: _stockController,
                    label: "Stok",
                    hint: "0",
                    icon: Icons.inventory_outlined,
                    keyboardType: TextInputType.number,
                    suffix: " unit",
                  ),
                ),
              ],
            ),

            _buildSectionHeader(
              icon: Icons.description_outlined,
              title: "Deskripsi Produk",
            ),

            _buildInputField(
              controller: _descriptionController,
              label: "Deskripsi",
              hint: "Jelaskan detail produk Anda...",
              icon: Icons.notes,
              maxLines: 5,
            ),

            _buildSectionHeader(icon: Icons.photo, title: "Foto Produk"),
            const SizedBox(height: 8),

            _buildImagePicker(),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEdit ? "Simpan Perubahan" : "Tambah Produk",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary(context)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefix,
    String? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryInputBox(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBorder(context)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.textSecondary(context)),
                prefixText: prefix,
                suffixText: suffix,
                border: InputBorder.none,
                hintText: hint,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: maxLines > 1 ? 16 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kategori",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryInputBox(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBorder(context)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.bgPrimaryInputBox(context),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary(context),
              ),
              items: const [
                DropdownMenuItem(value: "Makanan", child: Text("Makanan")),
                DropdownMenuItem(value: "Minuman", child: Text("Minuman")),
                DropdownMenuItem(value: "Pakaian", child: Text("Pakaian")),
                DropdownMenuItem(
                  value: "Elektronik",
                  child: Text("Elektronik"),
                ),
                DropdownMenuItem(value: "Jasa", child: Text("Jasa")),
                DropdownMenuItem(value: "Lainnya", child: Text("Lainnya")),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(
                Icons.add_a_photo,
                color: AppColors.textPrimary(context),
              ),
              label: Text(
                "Pilih Gambar",
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgPrimaryInputBox(context),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${_images.length} gambar dipilih",
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_images.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final f = _images[index];

                Widget imgWidget;

                // ==== FIX: CEK APAKAH PATH ADALAH URL ====
                bool isUrl =
                    f.path != null &&
                    (f.path!.startsWith("http://") ||
                        f.path!.startsWith("https://"));

                if (kIsWeb) {
                  // WEB MODE
                  if (f.bytes != null) {
                    imgWidget = Image.memory(
                      f.bytes!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  } else if (isUrl) {
                    imgWidget = Image.network(
                      f.path!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  } else {
                    imgWidget = _emptyImageBox();
                  }
                } else {
                  // MOBILE MODE
                  if (isUrl) {
                    imgWidget = Image.network(
                      f.path!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  } else if (f.path != null && f.path!.isNotEmpty) {
                    imgWidget = Image.file(
                      File(f.path!),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  } else if (f.bytes != null) {
                    imgWidget = Image.memory(
                      f.bytes!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  } else {
                    imgWidget = _emptyImageBox();
                  }
                }

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imgWidget,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeImageAt(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _emptyImageBox() {
    return Container(
      width: 110,
      height: 110,
      color: Colors.grey.shade300,
      child: Icon(Icons.image, size: 40, color: Colors.grey.shade500),
    );
  }
}
