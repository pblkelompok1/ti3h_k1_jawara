import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountModeProvider = StateProvider<String>((ref) => "toko");

final accountSelectedTabProvider = StateProvider<int>((ref) => 0);

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

class ActiveTransactionsNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  ActiveTransactionsNotifier() : super(_dummy);

  static final _dummy = [
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
    {
      'id': 'TRX004',
      'product_name': 'Kue Brownies Coklat',
      'buyer_name': 'Rina Wijaya',
      'price': 35000,
      'quantity': 2,
      'total': 70000,
      'status': 'processing',
      'date': '2025-12-01 11:20',
      'payment_method': 'Transfer Bank',
    },
    {
      'id': 'TRX005',
      'product_name': 'Kemeja Batik Pria',
      'buyer_name': 'Hendra Gunawan',
      'price': 150000,
      'quantity': 1,
      'total': 150000,
      'status': 'pending',
      'date': '2025-12-01 12:00',
      'payment_method': 'E-Wallet',
    },
  ];

  void updateStatus(String id, String status) {
    state = state.map((t) {
      if (t['id'] == id) {
        return {...t, 'status': status};
      }
      return t;
    }).toList();
  }

  void removeById(String id) {
    state = state.where((t) => t['id'] != id).toList();
  }
}

final activeTransactionsProvider =
    StateNotifierProvider<
      ActiveTransactionsNotifier,
      List<Map<String, dynamic>>
    >((ref) => ActiveTransactionsNotifier());

class MyOrder {
  final String id;
  final String productName;
  final String sellerName;
  final int price;
  final int quantity;
  final int total;
  final String status;
  final String paymentMethod;
  final DateTime date;

  MyOrder({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.price,
    required this.quantity,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.date,
  });
}

class MyOrdersNotifier extends StateNotifier<List<MyOrder>> {
  MyOrdersNotifier() : super([]);

  void addOrder(MyOrder order) {
    state = [order, ...state];
  }
}

final myOrdersProvider = StateNotifierProvider<MyOrdersNotifier, List<MyOrder>>(
  (ref) => MyOrdersNotifier(),
);

class TransactionHistoryNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  TransactionHistoryNotifier() : super([]);

  void addTransaction(Map<String, dynamic> transaction) {
    state = [transaction, ...state];
  }
}

final transactionHistoryProvider =
    StateNotifierProvider<
      TransactionHistoryNotifier,
      List<Map<String, dynamic>>
    >((ref) => TransactionHistoryNotifier());
