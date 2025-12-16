import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../themes/app_colors.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String imageName;

  const ImageViewer({
    super.key,
    required this.imageUrl,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        title: Text(
          imageName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        backgroundDecoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.black,
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        loadingBuilder: (context, event) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary(context),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat gambar',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
