class FeeTransactionModel {
  final int feeTransactionId;
  final String? transactionDate;
  final String feeId;
  final String feeName;
  final String feeCategory;
  final double amount;
  final String? transactionMethod;
  final String status;
  final String familyId;
  final String? familyName;
  final String? evidencePath;

  FeeTransactionModel({
    required this.feeTransactionId,
    this.transactionDate,
    required this.feeId,
    required this.feeName,
    required this.feeCategory,
    required this.amount,
    this.transactionMethod,
    required this.status,
    required this.familyId,
    this.familyName,
    this.evidencePath,
  });

  factory FeeTransactionModel.fromJson(Map<String, dynamic> json) {
    return FeeTransactionModel(
      feeTransactionId: json['fee_transaction_id'] as int,
      transactionDate: json['transaction_date'] as String?,
      feeId: json['fee_id'] as String,
      feeName: json['fee_name'] as String,
      feeCategory: json['fee_category'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionMethod: json['transaction_method'] as String?,
      status: json['status'] as String,
      familyId: json['family_id'] as String,
      familyName: json['family_name'] as String?,
      evidencePath: json['evidence_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fee_transaction_id': feeTransactionId,
      'transaction_date': transactionDate,
      'fee_id': feeId,
      'fee_name': feeName,
      'fee_category': feeCategory,
      'amount': amount,
      'transaction_method': transactionMethod,
      'status': status,
      'family_id': familyId,
      'family_name': familyName,
      'evidence_path': evidencePath,
    };
  }

  String get formattedAmount {
    final formatter = amount.toStringAsFixed(0);
    return 'Rp $formatter';
  }

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isUnpaid => status.toLowerCase() == 'unpaid';
}

class FeeTransactionListResponse {
  final int total;
  final int limit;
  final int offset;
  final List<FeeTransactionModel> data;

  FeeTransactionListResponse({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory FeeTransactionListResponse.fromJson(Map<String, dynamic> json) {
    return FeeTransactionListResponse(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      data: (json['data'] as List)
          .map((item) => FeeTransactionModel.fromJson(item))
          .toList(),
    );
  }

  bool get hasMore => offset + data.length < total;
}
