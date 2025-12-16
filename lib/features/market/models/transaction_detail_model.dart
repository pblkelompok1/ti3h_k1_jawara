class TransactionDetail {
  final String productTransactionId;
  final String? address;
  final String? description;
  final String status;
  final int totalPrice;
  final String? paymentProofPath;
  final bool isCod;
  final String userId;
  final String? buyerName;
  final int transactionMethodId;
  final String? transactionMethodName;
  final List<TransactionItem> items;
  final int totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionDetail({
    required this.productTransactionId,
    this.address,
    this.description,
    required this.status,
    required this.totalPrice,
    this.paymentProofPath,
    required this.isCod,
    required this.userId,
    this.buyerName,
    required this.transactionMethodId,
    this.transactionMethodName,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      productTransactionId: json['product_transaction_id'] as String,
      address: json['address'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String,
      totalPrice: json['total_price'] as int,
      paymentProofPath: json['payment_proof_path'] as String?,
      isCod: json['is_cod'] as bool,
      userId: json['user_id'] as String,
      buyerName: json['buyer_name'] as String?,
      transactionMethodId: json['transaction_method_id'] as int,
      transactionMethodName: json['transaction_method_name'] as String?,
      items: (json['items'] as List)
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
      totalAmount: json['total_amount'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String getTimeRemaining() {
    final deadline = createdAt.add(const Duration(hours: 24));
    final remaining = deadline.difference(DateTime.now());

    if (remaining.isNegative) return "Waktu habis";
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    
    if (hours > 0) {
      return "$hours jam $minutes menit";
    }
    return "$minutes menit";
  }
}

class TransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final int priceAtTransaction;
  final int totalPrice;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtTransaction,
    required this.totalPrice,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      priceAtTransaction: json['price_at_transaction'] as int,
      totalPrice: json['total_price'] as int,
    );
  }
}
