import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionListNotifier extends StateNotifier<List<Transaction>> {
  TransactionListNotifier() : super([]);

  void addTransaction(Transaction trx) {
    state = [trx, ...state];
  }

  Transaction getById(String id) {
    return state.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception("Transaksi tidak ditemukan"),
    );
  }
}

final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, List<Transaction>>(
      (ref) => TransactionListNotifier(),
    );

final transactionProvider = Provider.family<Transaction, String>((ref, id) {
  return ref.read(transactionListProvider.notifier).getById(id);
});

class Transaction {
  final String id;
  final String productName;
  final String sellerName;
  final int quantity;
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int total;
  final String paymentMethod;
  final String qrCodeData;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final DateTime createdAt;
  final bool isDelivery;

  Transaction({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.quantity,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.paymentMethod,
    required this.qrCodeData,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.createdAt,
    required this.isDelivery,
  });

  String getTimeRemaining() {
    final deadline = createdAt.add(const Duration(minutes: 15));
    final remaining = deadline.difference(DateTime.now());

    if (remaining.isNegative) return "Waktu habis";
    return "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
