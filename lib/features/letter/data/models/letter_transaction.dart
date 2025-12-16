class LetterTransaction {
  final String letterTransactionId;
  final DateTime applicationDate;
  final String status; // 'pending', 'approved', 'rejected'
  final Map<String, dynamic> data;
  final String? letterResultPath;
  final String? rejectionReason;
  final String userId;
  final String letterId;
  final String? letterName;
  final String? applicantName;
  final DateTime createdAt;
  final DateTime updatedAt;

  LetterTransaction({
    required this.letterTransactionId,
    required this.applicationDate,
    required this.status,
    required this.data,
    this.letterResultPath,
    this.rejectionReason,
    required this.userId,
    required this.letterId,
    this.letterName,
    this.applicantName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LetterTransaction.fromJson(Map<String, dynamic> json) {
    return LetterTransaction(
      letterTransactionId: json['letter_transaction_id'] as String,
      applicationDate: DateTime.parse(json['application_date'] as String),
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
      letterResultPath: json['letter_result_path'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      userId: json['user_id'] as String,
      letterId: json['letter_id'] as String,
      letterName: json['letter_name'] as String?,
      applicantName: json['applicant_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter_transaction_id': letterTransactionId,
      'application_date': applicationDate.toIso8601String(),
      'status': status,
      'data': data,
      'letter_result_path': letterResultPath,
      'rejection_reason': rejectionReason,
      'user_id': userId,
      'letter_id': letterId,
      'letter_name': letterName,
      'applicant_name': applicantName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasPdf => letterResultPath != null;

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
