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
  List<String> _originalImagePaths = []; // Track original API paths
  Set<String> _deletedImagePaths = {}; // Track deleted API paths

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
      
      // Validate category - set to Makanan if invalid
      final validCategories = ["Makanan", "Pakaian", "Bahan Masak", "Jasa", "Elektronik", "Lainnya"];
      final category = p['category'] ?? "Makanan";
      _selectedCategory = validCategories.contains(category) ? category : "Makanan";

      // Load existing images from API paths
      _images = [];
      _originalImagePaths = [];

      print('🔍 Loading existing product images:');
      print('  Product data: ${p.keys.toList()}');
      print('  image field: ${p['image']}');
      print('  images field: ${p['images']}');

      // PRIORITAS: Load dari list 'images' dulu (lebih lengkap)
      if (p['images'] != null && p['images'] is List && (p['images'] as List).isNotEmpty) {
        // CASE 1: Produk punya array images (data baru)
        print('  ✅ Found ${(p['images'] as List).length} images in list');
        for (final img in p['images']) {
          final imagePath = img.toString();
          print('    - $imagePath');
          _images.add(
            PlatformFile(
              name: imagePath.split('/').last,
              path: imagePath, // API path
              size: 0,
              bytes: null,
            ),
          );
          _originalImagePaths.add(imagePath);
        }
      } else if (p['image'] != null && p['image'].toString().isNotEmpty) {
        // CASE 2: Produk hanya punya single image (data lama)
        final imagePath = p['image'].toString();
        print('  ✅ Found single image: $imagePath');
        _images.add(
          PlatformFile(
            name: imagePath.split('/').last,
            path: imagePath,
            size: 0,
            bytes: null,
          ),
        );
        _originalImagePaths.add(imagePath);
      }
      
      print('  📦 Total _originalImagePaths: ${_originalImagePaths.length}');
      print('  📦 Total _images: ${_images.length}');
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
    setState(() {
      final removedImage = _images[index];
      
      // If it's an original API image, track it as deleted
      if (removedImage.path != null && _originalImagePaths.contains(removedImage.path)) {
        print('🗑️ Deleting image: ${removedImage.path}');
        _deletedImagePaths.add(removedImage.path!);
        print('   Total deleted: ${_deletedImagePaths.length}');
      } else {
        print('➖ Removing new local image (not from API)');
      }
      
      _images.removeAt(index);
      print('📦 Remaining images: ${_images.length}');
    });
  }

  Future<void> _saveProduct() async {
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

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get current user ID
      final userIdAsync = await ref.read(currentUserIdProvider.future);
      if (userIdAsync == null) {
        throw Exception('User tidak ditemukan');
      }

      // POLA SEDERHANA: Pisahkan foto lama (API) dan foto baru (lokal)
      List<String> remainingApiImages = []; // Foto lama yang tidak dihapus
      List<String> newFilesToUpload = [];   // Foto baru yang perlu diupload
      
      for (var img in _images) {
        if (img.path != null && img.path!.isNotEmpty) {
          // Cek apakah ini foto ASLI dari API (ada di _originalImagePaths)
          bool isOriginalApiImage = _originalImagePaths.contains(img.path);
          
          if (isOriginalApiImage) {
            // Foto lama dari API - JANGAN upload lagi, hanya track untuk imagePaths
            if (!_deletedImagePaths.contains(img.path)) {
              remainingApiImages.add(img.path!);
            }
          } else {
            // Foto baru dari file picker - INI yang perlu diupload
            newFilesToUpload.add(img.path!);
          }
        }
      }

      final service = ref.read(marketplaceServiceProvider);
      String? productId;
      
      if (isEdit) {
        productId = widget.product!['id'];
        
        print('🔄 EDIT MODE: Product ID = $productId');
        print('  📁 Remaining API images: ${remainingApiImages.length}');
        for (var img in remainingApiImages) {
          print('    - $img');
        }
        print('  🆕 New files to upload: ${newFilesToUpload.length}');
        for (var file in newFilesToUpload) {
          print('    - $file');
        }
        print('  🗑️ Deleted images: ${_deletedImagePaths.length}');
        print('  📦 _originalImagePaths tracked: ${_originalImagePaths.length}');
        for (var path in _originalImagePaths) {
          print('    - $path');
        }
        
        // STEP 1: Update data produk saja (TANPA images_path)
        // Pola SAMA dengan create - kirim null
        print('  ⬆️ Step 1: Update product data (imagePaths: null)');
        await service.updateProduct(
          productId: productId!,
          userId: userIdAsync,
          name: name,
          category: _selectedCategory,
          price: price,
          stock: stock,
          description: description,
          imagePaths: null, // ✅ SAMA SEPERTI CREATE
        );
        print('  ✅ Step 1 done');
        
        // STEP 2: Jika ada foto yang dihapus, WAJIB update images_path
        if (_deletedImagePaths.isNotEmpty) {
          // Foto yang tersisa setelah delete
          List<String> allImagePaths = [...remainingApiImages];
          
          print('  ⬆️ Step 2: Update images_path with ${allImagePaths.length} images');
          print('  📤 Sending to backend:');
          for (var path in allImagePaths) {
            print('     ✅ KEEP: $path');
          }
          print('  🗑️ Backend should delete:');
          for (var path in _deletedImagePaths) {
            print('     ❌ DELETE: $path');
          }
          
          // Update dengan images_path yang benar
          final updatedProduct = await service.updateProduct(
            productId: productId,
            userId: userIdAsync,
            name: name,
            category: _selectedCategory,
            price: price,
            stock: stock,
            description: description,
            imagePaths: allImagePaths, // Foto yang tersisa setelah delete
          );
          
          print('  ✅ Step 2 done');
          print('  📦 Backend returned images_path: ${updatedProduct.imagesPath.length}');
          for (var path in updatedProduct.imagesPath) {
            print('     - $path');
          }
        }
      } else {
        // Create new product - POLA STANDAR
        print('➕ CREATE MODE: Creating new product');
        print('  🆕 New files to upload: ${newFilesToUpload.length}');
        
        final newProduct = await service.createProduct(
          userId: userIdAsync,
          name: name,
          category: _selectedCategory,
          price: price,
          stock: stock,
          description: description,
          imagePaths: null, // ✅ NULL untuk create
        );
        productId = newProduct.productId;
        print('  ✅ Product created with ID: $productId');
      }
      
      // STEP 3: Upload foto baru (untuk create DAN edit)
      if (newFilesToUpload.isNotEmpty && productId != null) {
        try {
          print('📤 Uploading ${newFilesToUpload.length} new images...');
          for (int i = 0; i < newFilesToUpload.length; i++) {
            print('  Image ${i + 1}: ${newFilesToUpload[i]}');
          }
          
          await service.uploadProductImages(
            productId: productId,
            userId: userIdAsync,
            filePaths: newFilesToUpload,
          );
          print('✅ Upload successful!');
        } catch (e) {
          print('❌ Upload failed: $e');
          
          // Extract clean error message
          String errorMsg = e.toString();
          if (errorMsg.contains('Exception: ')) {
            errorMsg = errorMsg.replaceFirst('Exception: ', '');
          }
          if (errorMsg.contains('Error uploading images: ')) {
            errorMsg = errorMsg.replaceFirst('Error uploading images: ', '');
          }
          
          // Show error to user but don't block
          if (mounted) {
            // Close loading dialog first
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Produk tersimpan, tapi foto gagal diupload',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorMsg,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade700,
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
            
            // Invalidate and return success
            ref.invalidate(userProductsProvider);
            Navigator.pop(context, true);
            return; // Exit early
          }
        }
      }

      // Invalidate products provider to refresh list
      ref.invalidate(userProductsProvider);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(isEdit ? 'Produk berhasil diperbarui!' : 'Produk berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Return true to indicate success
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error saving product: $e');
      
      // Extract clean error message
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❌ Gagal menyimpan produk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMsg,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
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
                DropdownMenuItem(value: "Pakaian", child: Text("Pakaian")),
                DropdownMenuItem(value: "Bahan Masak", child: Text("Bahan Masak")),
                DropdownMenuItem(value: "Jasa", child: Text("Jasa")),
                DropdownMenuItem(value: "Elektronik", child: Text("Elektronik")),
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
                final service = ref.read(marketplaceServiceProvider);

                Widget imgWidget;

                // Check if it's an API path or full URL
                // API paths: 'storage/default/product/xxx.jpg' or 'uploads/xxx.jpg'
                bool isApiPath = f.path != null && 
                    (f.path!.contains('storage/') || f.path!.contains('uploads/'));
                bool isFullUrl = f.path != null && 
                    (f.path!.startsWith("http://") || f.path!.startsWith("https://"));

                if (kIsWeb) {
                  // WEB MODE
                  if (f.bytes != null) {
                    imgWidget = Image.memory(
                      f.bytes!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  } else if (isApiPath) {
                    // Use getImageUrl to get full URL from API path
                    final imageUrl = service.getImageUrl(f.path!);
                    print('  🖼️ [WEB] Loading API image: ${f.path!} -> $imageUrl');
                    imgWidget = Image.network(
                      imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('  ❌ [WEB] Failed to load image: $imageUrl');
                        return _emptyImageBox();
                      },
                    );
                  } else if (isFullUrl) {
                    imgWidget = Image.network(
                      f.path!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _emptyImageBox(),
                    );
                  } else {
                    imgWidget = _emptyImageBox();
                  }
                } else {
                  // MOBILE MODE
                  if (isApiPath) {
                    // Use getImageUrl to get full URL from API path
                    final imageUrl = service.getImageUrl(f.path!);
                    print('  🖼️ Loading API image: ${f.path!} -> $imageUrl');
                    imgWidget = Image.network(
                      imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('  ❌ Failed to load image: $imageUrl');
                        print('     Error: $error');
                        return _emptyImageBox();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
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
                    );
                  } else if (isFullUrl) {
                    imgWidget = Image.network(
                      f.path!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _emptyImageBox(),
                    );
                  } else if (f.path != null && f.path!.isNotEmpty) {
                    // Local file picked by user
                    imgWidget = Image.file(
                      File(f.path!),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _emptyImageBox(),
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
