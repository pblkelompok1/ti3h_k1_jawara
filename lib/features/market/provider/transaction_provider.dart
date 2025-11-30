import 'package:flutter_riverpod/flutter_riverpod.dart';

// Transaction model
class Transaction {
  final String id;
  final String paymentMethod;
  final DateTime paymentDeadline;
  final String productName;
  final String sellerName;
  final int quantity;
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int total;
  final String address;
  final String phoneNumber;
  final String qrCodeData;

  Transaction({
    required this.id,
    required this.paymentMethod,
    required this.paymentDeadline,
    required this.productName,
    required this.sellerName,
    required this.quantity,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.address,
    required this.phoneNumber,
    required this.qrCodeData,
  });

  // Calculate time remaining until deadline
  String getTimeRemaining() {
    final now = DateTime.now();
    final difference = paymentDeadline.difference(now);
    
    if (difference.isNegative) {
      return "Expired";
    }

    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;
    
    return "$minutes Menit $seconds Detik";
  }

  // Check if payment is still valid
  bool isPaymentValid() {
    return DateTime.now().isBefore(paymentDeadline);
  }
}

// Provider for transaction
final transactionProvider = Provider.family<Transaction, String>((ref, transactionId) {
  // In a real app, this would fetch from API/database
  // For now, returning dummy data
  return Transaction(
    id: transactionId,
    paymentMethod: 'Gopay',
    paymentDeadline: DateTime.now().add(const Duration(minutes: 10)),
    productName: 'Soto Enak Ala Madura',
    sellerName: 'Ibu Titik Masmuri',
    quantity: 5,
    subtotal: 100000,
    deliveryFee: 5000,
    serviceFee: 1000,
    total: 900000,
    address: 'Sudasoyono Muhdi (+62 9123 1923)\nBlok B - No. 4',
    phoneNumber: '+62 9123 1923',
    qrCodeData: 'QRIS Gopay', // This would be actual QRIS data in production
  );
});

// Provider to track countdown timer
final countdownProvider = StateProvider.family<String, String>((ref, transactionId) {
  final transaction = ref.watch(transactionProvider(transactionId));
  return transaction.getTimeRemaining();
});
