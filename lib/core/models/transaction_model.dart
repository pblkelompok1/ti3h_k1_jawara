class TransactionModel {
  final String name;
  final double amount;
  final String category;
  final String transactionDate;
  final String evidencePath;

  TransactionModel({
    required this.name,
    required this.amount,
    required this.category,
    required this.transactionDate,
    required this.evidencePath,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      transactionDate: json['transaction_date'] as String,
      evidencePath: json['evidence_path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'transaction_date': transactionDate,
      'evidence_path': evidencePath,
    };
  }

  bool get isIncome => amount > 0;
  
  bool get isExpense => amount < 0;

  String get formattedAmount {
    final absAmount = amount.abs();
    return (isIncome ? '+ Rp ' : '- Rp ') + absAmount.toStringAsFixed(0);
  }

  // Menentukan tipe transaksi berdasarkan category
  String get type {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('iuran:')) {
      return 'iuran';
    } else if (lowerCategory.contains('otomasi:') || 
               lowerCategory.contains('otomatis')) {
      return 'otomasi';
    }
    return 'keuangan';
  }

  // Mengambil kategori tanpa prefix "iuran:" atau "otomasi:"
  String get displayCategory {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.startsWith('iuran:')) {
      return category.substring(6).trim();
    } else if (lowerCategory.startsWith('otomasi:')) {
      return category.substring(8).trim();
    }
    return category;
  }

  TransactionModel copyWith({
    String? name,
    double? amount,
    String? category,
    String? transactionDate,
    String? evidencePath,
  }) {
    return TransactionModel(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      transactionDate: transactionDate ?? this.transactionDate,
      evidencePath: evidencePath ?? this.evidencePath,
    );
  }
}

class TransactionListResponse {
  final int total;
  final int limit;
  final int offset;
  final List<TransactionModel> data;

  TransactionListResponse({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      data: (json['data'] as List)
          .map((item) => TransactionModel.fromJson(item))
          .toList(),
    );
  }

  bool get hasMore => offset + limit < total;
}
