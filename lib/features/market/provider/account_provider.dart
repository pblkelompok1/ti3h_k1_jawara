import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountModeProvider = StateProvider<String>((ref) => "toko");

final accountSelectedTabProvider = StateProvider<int>((ref) => 0);

// ==================== USER PRODUCTS PROVIDER ====================
class UserProductsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  UserProductsNotifier() : super(_dummyProducts);

  static final _dummyProducts = [
    {
      'id': 'UP001',
      'name': 'Nasi Goreng Special',
      'price': 25000,
      'stock': 50,
      'category': 'Makanan',
      'description': 'Nasi goreng dengan telur, ayam, dan sayuran',
      'image': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
      'status': 'active',
      'sold': 45,
    },
    {
      'id': 'UP002',
      'name': 'Kue Brownies Coklat',
      'price': 35000,
      'stock': 20,
      'category': 'Makanan',
      'description': 'Brownies coklat premium dengan topping kacang',
      'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c',
      'status': 'active',
      'sold': 30,
    },
    {
      'id': 'UP003',
      'name': 'Kemeja Batik Pria',
      'price': 150000,
      'stock': 0,
      'category': 'Pakaian',
      'description': 'Kemeja batik motif klasik, bahan katun premium',
      'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf',
      'status': 'inactive',
      'sold': 12,
    },
  ];

  void addProduct(Map<String, dynamic> product) {
    state = [...state, product];
  }

  void updateProduct(String id, Map<String, dynamic> updatedProduct) {
    state = [
      for (final product in state)
        if (product['id'] == id) updatedProduct else product,
    ];
  }

  void deleteProduct(String id) {
    state = state.where((product) => product['id'] != id).toList();
  }

  void toggleProductStatus(String id) {
    state = [
      for (final product in state)
        if (product['id'] == id)
          {
            ...product,
            'status': product['status'] == 'active' ? 'inactive' : 'active',
          }
        else
          product,
    ];
  }
}

final userProductsProvider =
    StateNotifierProvider<UserProductsNotifier, List<Map<String, dynamic>>>(
      (ref) => UserProductsNotifier(),
    );

// ==================== ACTIVE TRANSACTIONS PROVIDER ====================
final activeTransactionsProvider = StateProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return [
    {
      'id': 'TRX001',
      'product_name': 'Sepatu Olahraga',
      'buyer_name': 'Ahmad Fauzi',
      'price': 250000,
      'quantity': 1,
      'total': 250000,
      'status': 'pending',
      'date': '2025-12-01 10:30',
      'payment_method': 'Transfer Bank',
    },
    {
      'id': 'TRX002',
      'product_name': 'Tahu Telor',
      'buyer_name': 'Siti Rahayu',
      'price': 15000,
      'quantity': 2,
      'total': 30000,
      'status': 'processing',
      'date': '2025-12-01 09:15',
      'payment_method': 'Cash',
    },
    {
      'id': 'TRX003',
      'product_name': 'Nasi Goreng Special',
      'buyer_name': 'Budi Santoso',
      'price': 25000,
      'quantity': 3,
      'total': 75000,
      'status': 'ready',
      'date': '2025-12-01 08:45',
      'payment_method': 'E-Wallet',
    },
  ];
});

// ==================== TRANSACTION HISTORY PROVIDER ====================
final transactionHistoryProvider = StateProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return [
    {
      'id': 'TRX099',
      'product_name': 'Brownies Coklat',
      'buyer_name': 'Dewi Lestari',
      'price': 35000,
      'quantity': 2,
      'total': 70000,
      'status': 'completed',
      'date': '2025-11-30 16:20',
      'payment_method': 'Transfer Bank',
    },
    {
      'id': 'TRX098',
      'product_name': 'Kemeja Batik',
      'buyer_name': 'Eko Wijaya',
      'price': 150000,
      'quantity': 1,
      'total': 150000,
      'status': 'completed',
      'date': '2025-11-29 14:10',
      'payment_method': 'Cash',
    },
    {
      'id': 'TRX097',
      'product_name': 'Sepatu Casual',
      'buyer_name': 'Maya Sari',
      'price': 180000,
      'quantity': 1,
      'total': 180000,
      'status': 'completed',
      'date': '2025-11-28 11:30',
      'payment_method': 'E-Wallet',
    },
    {
      'id': 'TRX096',
      'product_name': 'Nasi Goreng Special',
      'buyer_name': 'Rudi Hartono',
      'price': 25000,
      'quantity': 4,
      'total': 100000,
      'status': 'cancelled',
      'date': '2025-11-27 10:15',
      'payment_method': 'Transfer Bank',
    },
  ];
});

// ==================== MY ORDERS PROVIDER (as buyer) ====================
final myOrdersProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'ORD001',
      'product_name': 'Tahu Telor Warjo',
      'seller_name': 'Warung Pak Warjo',
      'price': 20000,
      'quantity': 2,
      'total': 40000,
      'status': 'pending',
      'date': '2025-12-01 11:00',
      'payment_method': 'E-Wallet',
    },
    {
      'id': 'ORD002',
      'product_name': 'Baju Koko',
      'seller_name': 'Toko Busana Muslim',
      'price': 120000,
      'quantity': 1,
      'total': 120000,
      'status': 'processing',
      'date': '2025-11-30 15:30',
      'payment_method': 'Transfer Bank',
    },
  ];
});
