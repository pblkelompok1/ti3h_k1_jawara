class FeeModel {
  final String feeId;
  final String feeName;
  final double amount;
  final String chargeDate;
  final String description;
  final String feeCategory;
  final String automationMode;

  FeeModel({
    required this.feeId,
    required this.feeName,
    required this.amount,
    required this.chargeDate,
    required this.description,
    required this.feeCategory,
    required this.automationMode,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      feeId: json['fee_id'] as String,
      feeName: json['fee_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      chargeDate: json['charge_date'] as String,
      description: json['description'] as String? ?? '',
      feeCategory: json['fee_category'] as String,
      automationMode: json['automation_mode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fee_id': feeId,
      'fee_name': feeName,
      'amount': amount,
      'charge_date': chargeDate,
      'description': description,
      'fee_category': feeCategory,
      'automation_mode': automationMode,
    };
  }

  bool get isIncome => true; // Iuran always income

  String get formattedAmount {
    // Hilangkan '+' untuk iuran
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  // Format kategori dengan capitalize first letter
  String get displayCategory {
    if (feeCategory.isEmpty) return '';
    return feeCategory[0].toUpperCase() + feeCategory.substring(1);
  }

  // Determine if this is automated fee
  bool get isAutomated {
    return automationMode.toLowerCase() == 'weekly' || 
           automationMode.toLowerCase() == 'monthly';
  }

  // Get display automation mode
  String get displayAutomationMode {
    switch (automationMode.toLowerCase()) {
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      default:
        return automationMode;
    }
  }

  FeeModel copyWith({
    String? feeId,
    String? feeName,
    double? amount,
    String? chargeDate,
    String? description,
    String? feeCategory,
    String? automationMode,
  }) {
    return FeeModel(
      feeId: feeId ?? this.feeId,
      feeName: feeName ?? this.feeName,
      amount: amount ?? this.amount,
      chargeDate: chargeDate ?? this.chargeDate,
      description: description ?? this.description,
      feeCategory: feeCategory ?? this.feeCategory,
      automationMode: automationMode ?? this.automationMode,
    );
  }
}

class FeeListResponse {
  final int total;
  final int limit;
  final int offset;
  final List<FeeModel> data;

  FeeListResponse({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory FeeListResponse.fromJson(Map<String, dynamic> json) {
    return FeeListResponse(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      data: (json['data'] as List)
          .map((item) => FeeModel.fromJson(item))
          .toList(),
    );
  }

  bool get hasMore => offset + limit < total;
}
