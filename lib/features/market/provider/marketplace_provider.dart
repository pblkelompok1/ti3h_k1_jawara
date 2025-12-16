import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/marketplace_service.dart';
import '../models/marketplace_product_model.dart';
import '../models/product_rating_model.dart';
import 'dart:async';

// Service Provider
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService();
});

// Search Query State
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected Category State
final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

// Products State
class ProductsState {
  final List<MarketplaceProduct> products;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentOffset;

  ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentOffset = 0,
  });

  ProductsState copyWith({
    List<MarketplaceProduct>? products,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentOffset,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

// Products Notifier
class ProductsNotifier extends StateNotifier<ProductsState> {
  final MarketplaceService _service;
  final String? category;
  final String? searchQuery;

  ProductsNotifier(this._service, {this.category, this.searchQuery})
      : super(ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final offset = refresh ? 0 : state.currentOffset;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final response = await _service.getProducts(
        name: searchQuery,
        category: category,
        limit: 20,
        offset: offset,
      );

      final newProducts = refresh ? response.data : [...state.products, ...response.data];
      
      state = state.copyWith(
        products: newProducts,
        isLoading: false,
        hasMore: response.data.length >= 20,
        currentOffset: offset + response.data.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }

  Future<void> loadMore() async {
    await loadProducts(refresh: false);
  }
}

// Search Products Provider (controlled manually to avoid repeated requests)
class SearchProductsNotifier extends StateNotifier<ProductsState> {
  final MarketplaceService _service;
  String? _lastSearchQuery;

  SearchProductsNotifier(this._service) : super(ProductsState());

  Future<void> searchProducts(String query) async {
    // Skip if same query
    if (_lastSearchQuery == query && state.products.isNotEmpty) return;
    
    _lastSearchQuery = query;
    
    if (query.isEmpty) {
      state = ProductsState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final response = await _service.getProducts(
        name: query,
        limit: 20,
        offset: 0,
      );

      state = state.copyWith(
        products: response.data,
        isLoading: false,
        hasMore: response.data.length >= 20,
        currentOffset: response.data.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = ProductsState();
    _lastSearchQuery = null;
  }
}

final searchProductsProvider = StateNotifierProvider<SearchProductsNotifier, ProductsState>((ref) {
  final service = ref.watch(marketplaceServiceProvider);
  return SearchProductsNotifier(service);
});

// Recommendation Products Provider (sorted by view_count, limit 10)
final recommendationProductsProvider = FutureProvider<List<MarketplaceProduct>>((ref) async {
  final service = ref.watch(marketplaceServiceProvider);
  
  try {
    final response = await service.getProducts(limit: 50);
    
    // Sort by view_count descending and take top 10
    final sortedProducts = List<MarketplaceProduct>.from(response.data)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    
    return sortedProducts.take(10).toList();
  } catch (e) {
    throw Exception('Failed to load recommendations: $e');
  }
});

// Quick Food Products Provider (Makanan category, sorted by view_count, limit 10)
final quickFoodProductsProvider = FutureProvider<List<MarketplaceProduct>>((ref) async {
  final service = ref.watch(marketplaceServiceProvider);
  
  try {
    final response = await service.getProducts(
      category: 'Makanan',
      limit: 50,
    );
    
    // Sort by view_count descending and take top 10
    final sortedProducts = List<MarketplaceProduct>.from(response.data)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    
    return sortedProducts.take(10).toList();
  } catch (e) {
    throw Exception('Failed to load food products: $e');
  }
});

// All Products for Grid (with infinite scroll)
class AllProductsNotifier extends StateNotifier<ProductsState> {
  final MarketplaceService _service;

  AllProductsNotifier(this._service) : super(ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final offset = refresh ? 0 : state.currentOffset;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final response = await _service.getProducts(
        limit: 20,
        offset: offset,
      );

      final newProducts = refresh ? response.data : [...state.products, ...response.data];
      
      state = state.copyWith(
        products: newProducts,
        isLoading: false,
        hasMore: response.data.length >= 20,
        currentOffset: (offset + response.data.length).toInt(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }

  Future<void> loadMore() async {
    await loadProducts(refresh: false);
  }
}

final allProductsProvider = StateNotifierProvider<AllProductsNotifier, ProductsState>((ref) {
  final service = ref.watch(marketplaceServiceProvider);
  return AllProductsNotifier(service);
});

// Product Detail Provider
final productDetailProvider = FutureProvider.family<MarketplaceProduct, String>((ref, productId) async {
  final service = ref.watch(marketplaceServiceProvider);
  
  try {
    final product = await service.getProductById(productId);
    // Increment view count in background
    service.incrementViewCount(productId);
    return product;
  } catch (e) {
    throw Exception('Failed to load product: $e');
  }
});

// Product Ratings Provider
final productRatingsProvider = FutureProvider.family<List<ProductRating>, String>((ref, productId) async {
  final service = ref.watch(marketplaceServiceProvider);
  
  try {
    return await service.getProductRatings(productId);
  } catch (e) {
    throw Exception('Failed to load ratings: $e');
  }
});

// Transaction Methods Provider
final transactionMethodsProvider = FutureProvider((ref) async {
  final service = ref.watch(marketplaceServiceProvider);
  
  try {
    return await service.getTransactionMethods(activeOnly: true);
  } catch (e) {
    throw Exception('Failed to load transaction methods: $e');
  }
});

// Quantity Provider (for product detail to checkout)
final quantityProvider = StateProvider.family<int, String>((ref, productId) => 1);
