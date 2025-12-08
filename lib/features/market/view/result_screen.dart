import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/services/predict_service.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final PredictService _predictService = PredictService();
  PredictResult? _predictResult;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }

  Future<void> _loadPrediction() async {
    try {
      final response = await _predictService.predictVegetable(widget.imagePath);
      
      if (!mounted) return;

      if (response.success && response.result != null) {
        setState(() {
          _predictResult = response.result;
          _isLoading = false;
        });
      } else {
        throw Exception(response.message ?? 'Prediksi gagal');
      }
    } catch (e) {
      debugPrint("Error loading prediction: $e");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Hasil Deteksi"),
        backgroundColor: primary,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? _buildLoadingSkeleton(primary)
          : _errorMessage != null
              ? _buildErrorState(primary)
              : _buildResultContent(primary),
    );
  }

  Widget _buildLoadingSkeleton(Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(widget.imagePath)),
          ),
          const SizedBox(height: 20),
          // Title skeleton
          Container(
            height: 32,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle skeleton
          Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          // Confidence skeleton
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
                const SizedBox(width: 10),
                Text(
                  "Menganalisis...",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Description title skeleton
          Container(
            height: 24,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          // Description lines skeleton
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memproses Gambar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(Color primary) {
    if (_predictResult == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(widget.imagePath)),
          ),
          const SizedBox(height: 20),
          Text(
            _predictResult!.formattedLabel,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _predictResult!.scientificName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  "Confidence: ${_predictResult!.confidencePercentage}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Deskripsi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _predictResult!.description,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 30),
          const Text(
            "Gambar Serupa",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: _predictResult!.similarImages.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada gambar serupa',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _predictResult!.similarImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _predictService
                          .getSimilarImageUrl(_predictResult!.similarImages[index]);
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
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
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Scan Lagi", 
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
