import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/marketplace_service.dart';
import '../../../core/provider/auth_service_provider.dart';
import '../models/marketplace_product_model.dart';
import '../models/transaction_detail_model.dart';

final accountModeProvider = StateProvider<String>((ref) => "toko");

final accountSelectedTabProvider = StateProvider<int>((ref) => 0);

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService();
});

// Provider to get current user ID
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = await authService.getCurrentUser();
  return user?.id;
});

// Provider to get seller's products from API
final userProductsProvider = FutureProvider.family<List<MarketplaceProduct>, String>((ref, userId) async {
  final service = ref.watch(marketplaceServiceProvider);
  try {
    final response = await service.getMyProducts(userId: userId);
    return response.data;
  } catch (e) {
    print('Error loading user products: $e');
    return [];
  }
});

// Provider for toggling product status
final toggleProductStatusProvider = Provider.family<Future<void> Function(String status), Map<String, String>>((ref, params) {
  return (String status) async {
    final service = ref.read(marketplaceServiceProvider);
    final productId = params['productId']!;
    final userId = params['userId']!;
    
    try {
      await service.toggleProductStatus(
        productId: productId,
        userId: userId,
        status: status,
      );
      // Refresh the products list
      ref.invalidate(userProductsProvider);
    } catch (e) {
      print('Error toggling product status: $e');
      rethrow;
    }
  };
});

// Provider to get seller's active transactions from API
final activeTransactionsProvider = FutureProvider.family<List<TransactionDetail>, String>((ref, userId) async {
  final service = ref.watch(marketplaceServiceProvider);
  try {
    print('🔄 Loading active transactions for seller: $userId');
    final response = await service.getSellerTransactions(
      userId: userId,
      type: 'active', // Get only active transactions (Belum Dibayar, Proses, Siap Diambil, Sedang Dikirim)
    );
    print('✅ Active transactions loaded: ${response.data.length} items');
    if (response.data.isNotEmpty) {
      print('   First transaction: ${response.data.first.productTransactionId} - ${response.data.first.status}');
    }
    return response.data;
  } catch (e) {
    print('❌ Error loading active transactions: $e');
    return [];
  }
});

// Provider for updating transaction status
final updateTransactionStatusProvider = Provider.family<Future<void> Function(String status), Map<String, String>>((ref, params) {
  return (String status) async {
    final service = ref.read(marketplaceServiceProvider);
    final transactionId = params['transactionId']!;
    final userId = params['userId']!;
    
    print('🔄 PROVIDER updateTransactionStatus');
    print('   Transaction ID: $transactionId');
    print('   User ID: $userId');
    print('   Status: "$status"');
    
    try {
      await service.updateTransactionStatus(
        transactionId: transactionId,
        userId: userId,
        status: status,
      );
      // Refresh the transactions list
      ref.invalidate(activeTransactionsProvider);
      ref.invalidate(transactionHistoryProvider);
    } catch (e) {
      print('❌ Error updating transaction status: $e');
      rethrow;
    }
  };
});

// Provider for cancelling transaction (buyer)
final cancelTransactionProvider = Provider.family<Future<void> Function(), Map<String, String>>((ref, params) {
  return () async {
    final service = ref.read(marketplaceServiceProvider);
    final transactionId = params['transactionId']!;
    final userId = params['userId']!;
    
    try {
      await service.cancelTransaction(
        transactionId: transactionId,
        userId: userId,
      );
      // Refresh the transactions list
      ref.invalidate(myOrdersProvider);
    } catch (e) {
      print('Error cancelling transaction: $e');
      rethrow;
    }
  };
});

// Provider to get seller's transaction history from API
final transactionHistoryProvider = FutureProvider.family<List<TransactionDetail>, String>((ref, userId) async {
  final service = ref.watch(marketplaceServiceProvider);
  try {
    print('🔄 Loading transaction history for seller: $userId');
    final response = await service.getSellerTransactions(
      userId: userId,
      type: 'history', // Get only history transactions (Selesai, Ditolak)
    );
    print('✅ Transaction history loaded: ${response.data.length} items');
    if (response.data.isNotEmpty) {
      print('   First transaction: ${response.data.first.productTransactionId} - ${response.data.first.status}');
    }
    return response.data;
  } catch (e) {
    print('❌ Error loading transaction history: $e');
    return [];
  }
});

// Provider to get buyer's orders from API
final myOrdersProvider = FutureProvider.family<List<TransactionDetail>, String>((ref, userId) async {
  final service = ref.watch(marketplaceServiceProvider);
  try {
    print('🔄 Loading orders for buyer: $userId');
    final response = await service.getBuyerTransactions(userId: userId);
    print('✅ Buyer orders loaded: ${response.data.length} items');
    if (response.data.isNotEmpty) {
      print('   First order: ${response.data.first.productTransactionId} - ${response.data.first.status}');
    }
    return response.data;
  } catch (e) {
    print('❌ Error loading my orders: $e');
    return [];
  }
});