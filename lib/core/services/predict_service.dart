import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictService {
  final String baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";

  /// Predict vegetable from image file
  /// 
  /// Parameters:
  /// - imagePath: The path to the image file to predict
  /// 
  /// Returns PredictResponse containing prediction result
  Future<PredictResponse> predictVegetable(String imagePath) async {
    try {
      final uri = Uri.parse('$baseUrl/ai/predict');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['accept'] = 'application/json';

      // Add image file
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan: $imagePath');
      }

      final imageFile = await http.MultipartFile.fromPath(
        'image',
        imagePath,
      );
      request.files.add(imageFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PredictResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to predict: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error predicting vegetable: $e');
    }
  }

  /// Get full URL for similar images
  /// 
  /// Backend returns relative paths like: /storage/vegetable_images/bunga_kol/bunga_kol_1.jpg
  /// This method converts them to full URLs using /files/ endpoint with proper encoding
  String getSimilarImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) {
      return relativePath; // Already a full URL
    }
    // Ensure path starts with /
    final normalizedPath = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    // Encode the path for URL
    final encodedPath = Uri.encodeComponent(normalizedPath);
    return '$baseUrl/files/$encodedPath';
  }
}

class PredictResponse {
  final bool success;
  final PredictResult? result;
  final String? message;

  PredictResponse({
    required this.success,
    this.result,
    this.message,
  });

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      success: json['success'] as bool? ?? false,
      result: json['result'] != null 
          ? PredictResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'result': result?.toJson(),
      'message': message,
    };
  }
}

class PredictResult {
  final String label;
  final double confidence;
  final String description;
  final String scientificName;
  final List<String> similarImages;

  PredictResult({
    required this.label,
    required this.confidence,
    required this.description,
    required this.scientificName,
    required this.similarImages,
  });

  factory PredictResult.fromJson(Map<String, dynamic> json) {
    return PredictResult(
      label: json['label'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      scientificName: json['scientific_name'] as String? ?? '',
      similarImages: json['similar_images'] != null
          ? List<String>.from(json['similar_images'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'description': description,
      'scientific_name': scientificName,
      'similar_images': similarImages,
    };
  }

  /// Helper untuk mendapatkan confidence dalam bentuk persentase
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(0)}%';

  /// Helper untuk mendapatkan label yang sudah diformat (replace underscore dengan spasi dan capitalize)
  String get formattedLabel {
    return label
        .split('_')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}
