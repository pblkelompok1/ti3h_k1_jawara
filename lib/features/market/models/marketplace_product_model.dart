class MarketplaceProduct {
  final String productId;
  final String name;
  final int price;
  final String category;
  final int stock;
  final int viewCount;
  final String description;
  final MoreDetail moreDetail;
  final List<String> imagesPath;
  final String userId;
  final String? sellerName;
  final double? averageRating;
  final int totalRatings;
  final String? status;
  final int soldCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketplaceProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.viewCount,
    required this.description,
    required this.moreDetail,
    required this.imagesPath,
    required this.userId,
    this.sellerName,
    this.averageRating,
    required this.totalRatings,
    this.status,
    required this.soldCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
      stock: json['stock'] as int,
      viewCount: json['view_count'] as int? ?? 0,
      description: json['description'] as String,
      moreDetail: json['more_detail'] != null 
          ? MoreDetail.fromJson(json['more_detail'] as Map<String, dynamic>)
          : MoreDetail(weight: '-', condition: '-', brand: '-'),
      imagesPath: json['images_path'] != null 
          ? List<String>.from(json['images_path'] as List)
          : [],
      userId: json['user_id'] as String,
      sellerName: json['seller_name'] as String?,
      averageRating: json['average_rating'] as double?,
      totalRatings: json['total_ratings'] as int? ?? 0,
      status: json['status'] as String?,
      soldCount: json['sold_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'view_count': viewCount,
      'description': description,
      'more_detail': moreDetail.toJson(),
      'images_path': imagesPath,
      'user_id': userId,
      'seller_name': sellerName,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'status': status,
      'sold_count': soldCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  void operator [](String other) {}
}

class MoreDetail {
  final String weight;
  final String condition;
  final String brand;

  MoreDetail({
    required this.weight,
    required this.condition,
    required this.brand,
  });

  factory MoreDetail.fromJson(Map<String, dynamic> json) {
    return MoreDetail(
      weight: json['weight'] as String,
      condition: json['condition'] as String,
      brand: json['brand'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'condition': condition,
      'brand': brand,
    };
  }
}

class ProductsResponse {
  final int total;
  final List<MarketplaceProduct> data;

  ProductsResponse({
    required this.total,
    required this.data,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      total: json['total'] as int,
      data: (json['data'] as List)
          .map((item) => MarketplaceProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
