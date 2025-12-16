class TransactionMethod {
  final int transactionMethodId;
  final String methodName;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionMethod({
    required this.transactionMethodId,
    required this.methodName,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionMethod.fromJson(Map<String, dynamic> json) {
    return TransactionMethod(
      transactionMethodId: json['transaction_method_id'] as int,
      methodName: json['method_name'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_method_id': transactionMethodId,
      'method_name': methodName,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
