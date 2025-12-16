class ProductRating {
  final String ratingId;
  final String productId;
  final String userId;
  final String? userName;
  final int ratingValue;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductRating({
    required this.ratingId,
    required this.productId,
    required this.userId,
    this.userName,
    required this.ratingValue,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      ratingId: json['rating_id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      ratingValue: json['rating_value'] as int,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
}
