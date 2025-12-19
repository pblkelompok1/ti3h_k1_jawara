import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/market/models/marketplace_product_model.dart';
import '../../features/market/models/product_rating_model.dart';
import '../../features/market/models/transaction_method_model.dart';
import '../../features/market/models/transaction_detail_model.dart';

class MarketplaceService {
  static const String baseUrl = 'https://prefunctional-albertha-unpessimistically.ngrok-free.dev';
  
  /// Get products with filters
  /// 
  /// [name] - Optional product name search
  /// [category] - Optional category filter (Makanan, Pakaian, Bahan Masak, Jasa, Elektronik)
  /// [limit] - Number of items per page (default: 20)
  /// [offset] - Number of items to skip (default: 0)
  Future<ProductsResponse> getProducts({
    String? name,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }
      
      if (category != null && category.isNotEmpty && category != 'Semua') {
        queryParams['category'] = category;
      }
      
      final uri = Uri.parse('$baseUrl/marketplace/products').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
  
  /// Get product detail by ID
  Future<MarketplaceProduct> getProductById(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products/$productId');
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MarketplaceProduct.fromJson(jsonData);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
  
  /// Increment product view count
  Future<void> incrementViewCount(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products/$productId/view');
      
      await http.post(
        uri,
        headers: {'accept': 'application/json'},
      );
    } catch (e) {
      // Silent fail - view count increment is not critical
    }
  }
  
  /// Get product ratings
  Future<List<ProductRating>> getProductRatings(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products/$productId/ratings');
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData
            .map((item) => ProductRating.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load ratings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ratings: $e');
    }
  }
  
  /// Get transaction methods
  Future<List<TransactionMethod>> getTransactionMethods({bool? activeOnly}) async {
    try {
      final queryParams = <String, String>{};
      if (activeOnly != null) {
        queryParams['active_only'] = activeOnly.toString();
      }
      
      final uri = Uri.parse('$baseUrl/marketplace/transaction-methods').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData
            .map((item) => TransactionMethod.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load transaction methods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transaction methods: $e');
    }
  }
  
  /// Create transaction
  Future<Map<String, dynamic>> createTransaction({
    required String userId,
    required String productId,
    required int quantity,
    required int transactionMethodId,
    required String address,
    String? description,
  }) async {
    try {
      // Add user_id as query parameter
      final uri = Uri.parse('$baseUrl/marketplace/transactions').replace(
        queryParameters: {'user_id': userId},
      );
      
      final body = {
        'items': [
          {
            'product_id': productId,
            'quantity': quantity,
          }
        ],
        'transaction_method_id': transactionMethodId,
        'address': address,
        if (description != null && description.isNotEmpty) 'description': description,
      };
      
      print('Creating transaction with:');
      print('URL: $uri');
      print('Body: ${json.encode(body)}');
      
      final response = await http.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Try to parse as JSON, fallback to plain text
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to create transaction: ${response.statusCode}');
        } catch (_) {
          // If JSON parse fails, use response body as is
          throw Exception('Failed to create transaction (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }
  
  /// Get transaction detail by ID
  Future<TransactionDetail> getTransactionById({
    required String transactionId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/transactions/$transactionId').replace(
        queryParameters: {'user_id': userId},
      );

      print('Fetching transaction:');
      print('URL: $uri');

      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TransactionDetail.fromJson(jsonData);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to load transaction: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to load transaction (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
    }
  }

  /// Upload payment proof for transaction
  Future<Map<String, dynamic>> uploadPaymentProof({
    required String transactionId,
    required String userId,
    required String filePath,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/transactions/$transactionId/payment-proof').replace(
        queryParameters: {'user_id': userId},
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers['accept'] = 'application/json';
      
      // Add file
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      print('Uploading payment proof:');
      print('URL: $uri');
      print('File: $filePath');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to upload payment proof: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to upload payment proof (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error uploading payment proof: $e');
    }
  }

  /// Get full image URL from path
  String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$baseUrl/$imagePath';
  }

  /// Upload product images
  Future<List<String>> uploadProductImages({
    required String productId,
    required String userId,
    required List<String> filePaths,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products/$productId/images').replace(
        queryParameters: {'user_id': userId},
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers['accept'] = 'application/json';
      
      // Add multiple files
      for (final filePath in filePaths) {
        final file = await http.MultipartFile.fromPath('files', filePath);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final product = MarketplaceProduct.fromJson(jsonData);
        return product.imagesPath; // Return updated images_path
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to upload images: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to upload images (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  // ==================== SELLER ENDPOINTS ====================
  
  /// Create new product
  Future<MarketplaceProduct> createProduct({
    required String userId,
    required String name,
    required String category,
    required int price,
    required int stock,
    required String description,
    List<String>? imagePaths,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products').replace(
        queryParameters: {'user_id': userId},
      );
      
      final body = {
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'description': description,
        if (imagePaths != null && imagePaths.isNotEmpty) 'images_path': imagePaths,
      };
      
      final response = await http.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MarketplaceProduct.fromJson(jsonData);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to create product: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to create product (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }
  
  /// Update existing product
  Future<MarketplaceProduct> updateProduct({
    required String productId,
    required String userId,
    required String name,
    required String category,
    required int price,
    required int stock,
    required String description,
    List<String>? imagePaths,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products/$productId').replace(
        queryParameters: {'user_id': userId},
      );
      
      final body = {
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'description': description,
        // PENTING: Kirim imagePaths bahkan jika array kosong []
        // null = tidak update images, [] = hapus semua, [path1, path2] = set ke ini
        if (imagePaths != null) 'images_path': imagePaths,
      };
      
      print('🌐 UPDATE PRODUCT API CALL:');
      print('   URI: $uri');
      print('   Body: ${json.encode(body)}');
      
      final response = await http.put(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('   Response: ${response.statusCode}');
      print('   Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MarketplaceProduct.fromJson(jsonData);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to update product: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to update product (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }
  
  /// Get seller's products (My Products)
  Future<ProductsResponse> getMyProducts({
    required String userId,
    String? name,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }
      
      if (category != null && category.isNotEmpty && category != 'Semua') {
        queryParams['category'] = category;
      }
      
      final uri = Uri.parse('$baseUrl/marketplace/products/my-products/list').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load my products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching my products: $e');
    }
  }

  /// Toggle product status (active/inactive)
  Future<Map<String, dynamic>> toggleProductStatus({
    required String productId,
    required String userId,
    required String status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/products/$productId/status').replace(
        queryParameters: {
          'user_id': userId,
          'status': status,
        },
      );
      
      final response = await http.patch(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to toggle product status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling product status: $e');
    }
  }

  /// Get seller's transactions with filter
  Future<TransactionsResponse> getSellerTransactions({
    required String userId,
    String? type, // 'active' or 'history'
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      final uri = Uri.parse('$baseUrl/marketplace/transactions/sales').replace(
        queryParameters: queryParams,
      );
      
      print('🌐 GET $uri');
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📦 Data: ${jsonData.toString().substring(0, jsonData.toString().length > 200 ? 200 : jsonData.toString().length)}...');
        return TransactionsResponse.fromJson(jsonData);
      } else {
        print('❌ Response body: ${response.body}');
        throw Exception('Failed to load seller transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('Error fetching seller transactions: $e');
    }
  }

  /// Get buyer's transactions (My Orders)
  Future<TransactionsResponse> getBuyerTransactions({
    required String userId,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      final uri = Uri.parse('$baseUrl/marketplace/transactions').replace(
        queryParameters: queryParams,
      );
      
      print('🌐 GET $uri');
      
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📦 Data: ${jsonData.toString().substring(0, jsonData.toString().length > 200 ? 200 : jsonData.toString().length)}...');
        return TransactionsResponse.fromJson(jsonData);
      } else {
        print('❌ Response body: ${response.body}');
        throw Exception('Failed to load buyer transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('Error fetching buyer transactions: $e');
    }
  }

  /// Update transaction status (seller only)
  /// 
  /// Status must be in UPPERCASE with UNDERSCORE format:
  /// - BELUM_DIBAYAR
  /// - PROSES
  /// - SIAP_DIAMBIL
  /// - SEDANG_DIKIRIM
  /// - SELESAI
  /// - DITOLAK
  Future<TransactionDetail> updateTransactionStatus({
    required String transactionId,
    required String userId,
    required String status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/transactions/$transactionId/status').replace(
        queryParameters: {'user_id': userId},
      );
      
      final body = {'status': status};
      
      print('🔄 UPDATE TRANSACTION STATUS:');
      print('   URI: $uri');
      print('   Status (Backend Format): $status');
      print('   Expected format: UPPERCASE with UNDERSCORE (e.g., SIAP_DIAMBIL)');
      
      final response = await http.put(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('   Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TransactionDetail.fromJson(jsonData);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to update status: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to update status (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error updating transaction status: $e');
    }
  }

  /// Cancel transaction (buyer only)
  Future<TransactionDetail> cancelTransaction({
    required String transactionId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/transactions/$transactionId/cancel').replace(
        queryParameters: {'user_id': userId},
      );
      
      print('❌ CANCEL TRANSACTION:');
      print('   URI: $uri');
      
      final response = await http.post(
        uri,
        headers: {'accept': 'application/json'},
      );
      
      print('   Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TransactionDetail.fromJson(jsonData);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['detail'] ?? 'Failed to cancel transaction: ${response.statusCode}');
        } catch (_) {
          throw Exception('Failed to cancel transaction (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error cancelling transaction: $e');
    }
  }
}

// Response wrapper for transactions list
class TransactionsResponse {
  final int total;
  final List<TransactionDetail> data;

  TransactionsResponse({
    required this.total,
    required this.data,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      total: json['total'] as int,
      data: (json['data'] as List)
          .map((item) => TransactionDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
