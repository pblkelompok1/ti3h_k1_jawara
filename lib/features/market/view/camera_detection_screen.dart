import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'result_screen.dart';

class CameraDetectionScreen extends StatefulWidget {
  const CameraDetectionScreen({super.key});

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: picked.path),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: picked.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Deteksi Sayur"),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 90,
              color: AppColors.primary(context),
            ),

            const SizedBox(height: 20),

            Text(
              "Ambil atau pilih gambar sayur",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Kamera Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
              label: const Text(
                "Ambil Foto",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Galeri Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                side: BorderSide(color: AppColors.primary(context), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _pickFromGallery,
              icon: Icon(Icons.photo_library,
                  size: 28, color: AppColors.primary(context)),
              label: Text(
                "Pilih dari Galeri",
                style: TextStyle(fontSize: 18, color: AppColors.primary(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
