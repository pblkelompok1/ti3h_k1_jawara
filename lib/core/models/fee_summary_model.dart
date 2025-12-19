class FeeSummaryModel {
  final double totalUnpaidAmount;
  final int totalUnpaidCount;

  FeeSummaryModel({
    required this.totalUnpaidAmount,
    required this.totalUnpaidCount,
  });

  factory FeeSummaryModel.fromJson(Map<String, dynamic> json) {
    return FeeSummaryModel(
      totalUnpaidAmount: (json['total_unpaid_amount'] as num).toDouble(),
      totalUnpaidCount: json['total_unpaid_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_unpaid_amount': totalUnpaidAmount,
      'total_unpaid_count': totalUnpaidCount,
    };
  }

  // Format currency
  String get formattedAmount {
    return 'Rp ${totalUnpaidAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Format count message
  String get countMessage {
    if (totalUnpaidCount == 0) {
      return 'Tidak ada tagihan';
    } else if (totalUnpaidCount == 1) {
      return '1 tagihan belum dibayar';
    } else {
      return '$totalUnpaidCount tagihan belum dibayar';
    }
  }
}
