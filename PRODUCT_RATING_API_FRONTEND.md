# ⭐ Product Rating API - Flutter Frontend Documentation

> **For Copilot AI Assistant**: This document provides complete API integration guide for Product Rating System in Flutter application. User can rate products after transaction status is **SELESAI** (completed).

---

## 📋 Quick Overview

**Product Rating System** allows buyers to give 1-5 star ratings and reviews after completing their purchase (transaction status = `SELESAI`).

**Base URL:** `http://your-api-domain.com/api/v1/marketplace`

**Flow:**
1. User completes transaction (status: `SELESAI`)
2. User can rate each product in the transaction
3. Rating saved with star value (1-5) and optional description
4. Ratings visible to all users on product page
5. User can update/delete their own rating

**Business Rules:**
- ⚠️ User can only rate products from **completed transactions** (`SELESAI`)
- 🚫 User cannot rate same product twice (one rating per product per user)
- ✅ User can update/delete their own rating
- ⭐ Rating value: 1-5 stars

---

## 🎯 API Endpoints Summary

| Method | Endpoint | Purpose | Condition |
|--------|----------|---------|-----------|
| POST | `/products/{product_id}/ratings` | Create rating | Transaction SELESAI |
| GET | `/products/{product_id}/ratings` | Get product ratings | Public |
| GET | `/ratings/my-ratings` | Get my ratings | User |
| PUT | `/ratings/{rating_id}` | Update my rating | Owner only |
| DELETE | `/ratings/{rating_id}` | Delete my rating | Owner only |

---

## 📦 Data Models (Dart)

### 1. Rating Model

```dart
class ProductRating {
  final String ratingId;
  final String productId;
  final String userId;
  final String? userName;
  final int ratingValue; // 1-5
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductRating({
    required this.ratingId,
    required this.productId,
    required this.userId,
    this.userName,
    required this.ratingValue,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      ratingId: json['rating_id'],
      productId: json['product_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      ratingValue: json['rating_value'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'rating_value': ratingValue,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get hasDescription => description != null && description!.isNotEmpty;
  
  String get starDisplay => '⭐' * ratingValue;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
```

---

### 2. Rating Create/Update Request

```dart
class RatingCreateRequest {
  final int ratingValue;
  final String? description;

  RatingCreateRequest({
    required this.ratingValue,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating_value': ratingValue,
      'description': description,
    };
  }

  // Validation
  bool isValid() {
    return ratingValue >= 1 && ratingValue <= 5;
  }
}

class RatingUpdateRequest {
  final int? ratingValue;
  final String? description;

  RatingUpdateRequest({
    this.ratingValue,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (ratingValue != null) data['rating_value'] = ratingValue;
    if (description != null) data['description'] = description;
    return data;
  }

  bool get hasChanges => ratingValue != null || description != null;
}
```

---

## 🔌 API Service Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RatingApiService {
  final String baseUrl;
  final String? authToken;

  RatingApiService({
    required this.baseUrl,
    this.authToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ==================== Create Rating ====================
  
  Future<ProductRating> createRating({
    required String productId,
    required String userId,
    required RatingCreateRequest ratingData,
  }) async {
    if (!ratingData.isValid()) {
      throw Exception('Rating value must be between 1 and 5');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/products/$productId/ratings?user_id=$userId'),
      headers: _headers,
      body: json.encode(ratingData.toJson()),
    );

    if (response.statusCode == 200) {
      return ProductRating.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'You have already rated this product');
    } else {
      throw Exception('Failed to create rating: ${response.body}');
    }
  }

  // ==================== Get Product Ratings ====================
  
  Future<List<ProductRating>> getProductRatings(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/ratings'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductRating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ratings: ${response.body}');
    }
  }

  // ==================== Get My Ratings ====================
  
  Future<List<ProductRating>> getMyRatings(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ratings/my-ratings?user_id=$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductRating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load my ratings: ${response.body}');
    }
  }

  // ==================== Update Rating ====================
  
  Future<ProductRating> updateRating({
    required String ratingId,
    required String userId,
    required RatingUpdateRequest ratingData,
  }) async {
    if (!ratingData.hasChanges) {
      throw Exception('No changes to update');
    }

    if (ratingData.ratingValue != null && 
        (ratingData.ratingValue! < 1 || ratingData.ratingValue! > 5)) {
      throw Exception('Rating value must be between 1 and 5');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/ratings/$ratingId?user_id=$userId'),
      headers: _headers,
      body: json.encode(ratingData.toJson()),
    );

    if (response.statusCode == 200) {
      return ProductRating.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Rating not found or unauthorized');
    } else {
      throw Exception('Failed to update rating: ${response.body}');
    }
  }

  // ==================== Delete Rating ====================
  
  Future<void> deleteRating({
    required String ratingId,
    required String userId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId?user_id=$userId'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete rating: ${response.body}');
    }
  }

  // ==================== Check If User Can Rate ====================
  
  Future<bool> canUserRateProduct({
    required String productId,
    required String userId,
  }) async {
    try {
      // Get my ratings to check if already rated
      final myRatings = await getMyRatings(userId);
      
      // Check if product is already rated
      final hasRated = myRatings.any((rating) => rating.productId == productId);
      
      return !hasRated;
    } catch (e) {
      return true; // Assume can rate if error checking
    }
  }

  // ==================== Get Average Rating ====================
  
  Future<Map<String, dynamic>> getProductRatingStats(String productId) async {
    try {
      final ratings = await getProductRatings(productId);
      
      if (ratings.isEmpty) {
        return {
          'average': 0.0,
          'total': 0,
          'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final total = ratings.length;
      final sum = ratings.fold<int>(0, (sum, rating) => sum + rating.ratingValue);
      final average = sum / total;

      // Count distribution
      final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var rating in ratings) {
        distribution[rating.ratingValue] = (distribution[rating.ratingValue] ?? 0) + 1;
      }

      return {
        'average': double.parse(average.toStringAsFixed(1)),
        'total': total,
        'distribution': distribution,
      };
    } catch (e) {
      return {
        'average': 0.0,
        'total': 0,
        'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }
}
```

---

## 🎨 Flutter Widget Examples

### 1. Create Rating Dialog (After Transaction Completed)

```dart
class CreateRatingDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final String userId;

  CreateRatingDialog({
    required this.productId,
    required this.productName,
    required this.userId,
  });

  @override
  _CreateRatingDialogState createState() => _CreateRatingDialogState();
}

class _CreateRatingDialogState extends State<CreateRatingDialog> {
  final RatingApiService _apiService = RatingApiService(
    baseUrl: 'http://your-api-domain.com/api/v1/marketplace',
    authToken: 'your-auth-token',
  );

  int _selectedRating = 5;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      final ratingRequest = RatingCreateRequest(
        ratingValue: _selectedRating,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
      );

      await _apiService.createRating(
        productId: widget.productId,
        userId: widget.userId,
        ratingData: ratingRequest,
      );

      setState(() => _isSubmitting = false);
      
      Navigator.of(context).pop(true); // Return success
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Beri Rating'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.productName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Bagaimana pengalaman Anda?'),
            SizedBox(height: 8),
            // Star rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starValue),
                  child: Icon(
                    starValue <= _selectedRating 
                        ? Icons.star 
                        : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Ulasan (Opsional)',
                hintText: 'Ceritakan pengalaman Anda...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          child: _isSubmitting
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Kirim'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
```

---

### 2. Rating Button in Transaction Detail (Only if SELESAI)

```dart
class TransactionItemWithRating extends StatelessWidget {
  final String productId;
  final String productName;
  final String transactionStatus;
  final String userId;
  final bool hasRated;

  TransactionItemWithRating({
    required this.productId,
    required this.productName,
    required this.transactionStatus,
    required this.userId,
    required this.hasRated,
  });

  bool get canRate => transactionStatus == 'SELESAI' && !hasRated;

  Future<void> _showRatingDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateRatingDialog(
        productId: productId,
        productName: productName,
        userId: userId,
      ),
    );

    if (result == true) {
      // Refresh or update UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terima kasih atas penilaian Anda!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            if (canRate)
              ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context),
                icon: Icon(Icons.star, size: 20),
                label: Text('Beri Rating'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              )
            else if (hasRated)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '✓ Sudah diberi rating',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              )
            else
              Text(
                'Rating tersedia setelah transaksi selesai',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

### 3. Product Ratings List

```dart
class ProductRatingsScreen extends StatefulWidget {
  final String productId;

  ProductRatingsScreen({required this.productId});

  @override
  _ProductRatingsScreenState createState() => _ProductRatingsScreenState();
}

class _ProductRatingsScreenState extends State<ProductRatingsScreen> {
  final RatingApiService _apiService = RatingApiService(
    baseUrl: 'http://your-api-domain.com/api/v1/marketplace',
    authToken: 'your-auth-token',
  );

  List<ProductRating>? _ratings;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() => _isLoading = true);

    try {
      final ratings = await _apiService.getProductRatings(widget.productId);
      final stats = await _apiService.getProductRatingStats(widget.productId);

      setState(() {
        _ratings = ratings;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Rating & Ulasan')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ratings == null || _ratings!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Rating & Ulasan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada rating'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Rating & Ulasan')),
      body: Column(
        children: [
          // Rating summary
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Average rating
                Column(
                  children: [
                    Text(
                      _stats!['average'].toString(),
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (_stats!['average'] as double).round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_stats!['total']} rating',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 24),
                // Rating distribution
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      final count = _stats!['distribution'][star] ?? 0;
                      final percentage = _stats!['total'] > 0
                          ? (count / _stats!['total'] * 100).round()
                          : 0;

                      return Row(
                        children: [
                          Text('$star'),
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation(Colors.amber),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('$count'),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Ratings list
          Expanded(
            child: ListView.builder(
              itemCount: _ratings!.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final rating = _ratings![index];
                return _buildRatingCard(rating);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(ProductRating rating) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    rating.userName?.substring(0, 1).toUpperCase() ?? 'U',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.userName ?? 'Anonymous',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.ratingValue
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          SizedBox(width: 8),
                          Text(
                            rating.timeAgo,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (rating.hasDescription) ...[
              SizedBox(height: 8),
              Text(rating.description!),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### 4. My Ratings Screen (User's Own Ratings)

```dart
class MyRatingsScreen extends StatefulWidget {
  final String userId;

  MyRatingsScreen({required this.userId});

  @override
  _MyRatingsScreenState createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final RatingApiService _apiService = RatingApiService(
    baseUrl: 'http://your-api-domain.com/api/v1/marketplace',
    authToken: 'your-auth-token',
  );

  List<ProductRating>? _myRatings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRatings();
  }

  Future<void> _loadMyRatings() async {
    setState(() => _isLoading = true);

    try {
      final ratings = await _apiService.getMyRatings(widget.userId);
      setState(() {
        _myRatings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _editRating(ProductRating rating) async {
    final result = await showDialog<RatingUpdateRequest>(
      context: context,
      builder: (context) => EditRatingDialog(rating: rating),
    );

    if (result != null) {
      try {
        await _apiService.updateRating(
          ratingId: rating.ratingId,
          userId: widget.userId,
          ratingData: result,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating berhasil diupdate')),
        );

        _loadMyRatings(); // Reload
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteRating(ProductRating rating) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Rating'),
        content: Text('Yakin ingin menghapus rating ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteRating(
          ratingId: rating.ratingId,
          userId: widget.userId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating berhasil dihapus')),
        );

        _loadMyRatings(); // Reload
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Rating Saya')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_myRatings == null || _myRatings!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Rating Saya')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada rating'),
              SizedBox(height: 8),
              Text(
                'Rating akan muncul setelah Anda memberi rating pada produk',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Rating Saya')),
      body: RefreshIndicator(
        onRefresh: _loadMyRatings,
        child: ListView.builder(
          itemCount: _myRatings!.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final rating = _myRatings![index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product ID: ${rating.productId}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating.ratingValue
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              Text(
                                rating.timeAgo,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editRating(rating);
                            } else if (value == 'delete') {
                              _deleteRating(rating);
                            }
                          },
                        ),
                      ],
                    ),
                    if (rating.hasDescription) ...[
                      SizedBox(height: 8),
                      Text(rating.description!),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

### 5. Edit Rating Dialog

```dart
class EditRatingDialog extends StatefulWidget {
  final ProductRating rating;

  EditRatingDialog({required this.rating});

  @override
  _EditRatingDialogState createState() => _EditRatingDialogState();
}

class _EditRatingDialogState extends State<EditRatingDialog> {
  late int _selectedRating;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.rating.ratingValue;
    _descriptionController = TextEditingController(
      text: widget.rating.description ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Rating'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starValue),
                  child: Icon(
                    starValue <= _selectedRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Ulasan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final updateRequest = RatingUpdateRequest(
              ratingValue: _selectedRating != widget.rating.ratingValue 
                  ? _selectedRating 
                  : null,
              description: _descriptionController.text != widget.rating.description
                  ? _descriptionController.text
                  : null,
            );

            Navigator.pop(context, updateRequest);
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
```

---

## 🎯 Complete Flow Example

### Transaction Completed → Rate Product Flow

```dart
class CompletedTransactionScreen extends StatelessWidget {
  final String transactionId;
  final String userId;

  CompletedTransactionScreen({
    required this.transactionId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi Selesai')),
      body: FutureBuilder<TransactionDetail>(
        future: _loadTransactionDetail(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final transaction = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Transaction info
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 64),
                      SizedBox(height: 8),
                      Text(
                        'Transaksi Selesai',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('Terima kasih atas pembelian Anda!'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Product items with rating button
              ...transaction.items.map((item) {
                return FutureBuilder<bool>(
                  future: _checkIfRated(item.productId),
                  builder: (context, ratingSnapshot) {
                    final hasRated = ratingSnapshot.data ?? false;

                    return TransactionItemWithRating(
                      productId: item.productId,
                      productName: item.productName,
                      transactionStatus: transaction.status,
                      userId: userId,
                      hasRated: hasRated,
                    );
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Future<TransactionDetail> _loadTransactionDetail() async {
    // Load transaction from API
    // Implementation depends on your transaction API
    throw UnimplementedError();
  }

  Future<bool> _checkIfRated(String productId) async {
    final apiService = RatingApiService(
      baseUrl: 'http://your-api-domain.com/api/v1/marketplace',
      authToken: 'your-auth-token',
    );

    return !(await apiService.canUserRateProduct(
      productId: productId,
      userId: userId,
    ));
  }
}
```

---

## 🔥 Error Handling

### Common Errors

```dart
class RatingErrorHandler {
  static String handleError(dynamic error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('already rated')) {
      return 'Anda sudah memberikan rating untuk produk ini';
    } else if (errorMessage.contains('not found')) {
      return 'Rating tidak ditemukan';
    } else if (errorMessage.contains('unauthorized')) {
      return 'Anda tidak memiliki akses untuk mengubah rating ini';
    } else if (errorMessage.contains('between 1 and 5')) {
      return 'Rating harus antara 1-5 bintang';
    } else if (errorMessage.contains('No internet')) {
      return 'Tidak ada koneksi internet';
    } else {
      return 'Terjadi kesalahan: $errorMessage';
    }
  }

  static void showErrorSnackbar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(handleError(error)),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
```

---

## 🎨 Reusable Widget: Star Rating Display

```dart
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int totalRatings;
  final double size;
  final bool showCount;

  StarRatingDisplay({
    required this.rating,
    this.totalRatings = 0,
    this.size = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          );
        }),
        if (showCount) ...[
          SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)} ($totalRatings)',
            style: TextStyle(fontSize: size * 0.75),
          ),
        ],
      ],
    );
  }
}

// Usage:
StarRatingDisplay(rating: 4.5, totalRatings: 120)
```

---

## 🎨 Reusable Widget: Star Rating Input

```dart
class StarRatingInput extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final double size;

  StarRatingInput({
    this.initialRating = 5,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  _StarRatingInputState createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() => _currentRating = starValue);
            widget.onRatingChanged(starValue);
          },
          child: Icon(
            starValue <= _currentRating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}

// Usage:
StarRatingInput(
  initialRating: 5,
  onRatingChanged: (rating) => print('Rating: $rating'),
)
```

---

## 📱 State Management with Provider

```dart
class RatingProvider extends ChangeNotifier {
  final RatingApiService _apiService;

  RatingProvider(this._apiService);

  List<ProductRating>? _productRatings;
  List<ProductRating>? _myRatings;
  Map<String, dynamic>? _ratingStats;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductRating>? get productRatings => _productRatings;
  List<ProductRating>? get myRatings => _myRatings;
  Map<String, dynamic>? get ratingStats => _ratingStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProductRatings(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _productRatings = await _apiService.getProductRatings(productId);
      _ratingStats = await _apiService.getProductRatingStats(productId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyRatings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myRatings = await _apiService.getMyRatings(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRating({
    required String productId,
    required String userId,
    required RatingCreateRequest ratingData,
  }) async {
    try {
      await _apiService.createRating(
        productId: productId,
        userId: userId,
        ratingData: ratingData,
      );

      // Reload ratings
      await loadProductRatings(productId);
      await loadMyRatings(userId);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRating({
    required String ratingId,
    required String userId,
    required RatingUpdateRequest ratingData,
  }) async {
    try {
      await _apiService.updateRating(
        ratingId: ratingId,
        userId: userId,
        ratingData: ratingData,
      );

      // Reload my ratings
      await loadMyRatings(userId);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRating({
    required String ratingId,
    required String userId,
  }) async {
    try {
      await _apiService.deleteRating(
        ratingId: ratingId,
        userId: userId,
      );

      // Reload my ratings
      await loadMyRatings(userId);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool hasUserRated(String productId) {
    if (_myRatings == null) return false;
    return _myRatings!.any((rating) => rating.productId == productId);
  }
}
```

---

## 📚 Dependencies Required

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1  # For state management
  intl: ^0.18.1     # For date formatting (optional)
```

---

## ✅ Implementation Checklist

### Backend Validation:
- [ ] Verify transaction is SELESAI before allowing rating
- [ ] Check user hasn't already rated product
- [ ] Validate rating value (1-5)

### Frontend Implementation:
- [ ] Copy all Dart models
- [ ] Create RatingApiService
- [ ] Update baseUrl with your API domain
- [ ] Implement authentication token handling
- [ ] Create rating dialog after transaction completed
- [ ] Add rating button in transaction detail (only for SELESAI)
- [ ] Create product ratings list screen
- [ ] Create my ratings screen with edit/delete
- [ ] Implement star rating input widget
- [ ] Add loading indicators
- [ ] Handle all error cases
- [ ] Test rating creation after completed transaction
- [ ] Test edit/delete own rating
- [ ] Test viewing product ratings
- [ ] Ensure user can't rate twice

### Business Logic:
- [ ] Only show "Beri Rating" button when status = SELESAI
- [ ] Disable button if user already rated
- [ ] Show "Sudah diberi rating" badge
- [ ] Calculate and display average rating on product
- [ ] Show rating distribution (5 star, 4 star, etc.)

---

## 🎯 API Response Examples

### Success: Create Rating (200)
```json
{
  "rating_id": "abc123-def456",
  "product_id": "prod-uuid",
  "user_id": "user-uuid",
  "user_name": "John Doe",
  "rating_value": 5,
  "description": "Produk sangat bagus!",
  "created_at": "2024-01-15T10:00:00",
  "updated_at": "2024-01-15T10:00:00"
}
```

### Error: Already Rated (400)
```json
{
  "detail": "You have already rated this product"
}
```

### Error: Rating Not Found (404)
```json
{
  "detail": "Rating not found or unauthorized"
}
```

---

**Ready to integrate!** 🚀 All code examples are production-ready and follow the pattern that rating can only be created after transaction status is **SELESAI**.
