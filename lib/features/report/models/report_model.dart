enum ReportCategory {
  keamanan,
  kebersihan,
  infrastruktur,
  sosial,
  lainnya;

  String get displayName {
    switch (this) {
      case ReportCategory.keamanan:
        return 'Keamanan';
      case ReportCategory.kebersihan:
        return 'Kebersihan';
      case ReportCategory.infrastruktur:
        return 'Infrastruktur';
      case ReportCategory.sosial:
        return 'Sosial';
      case ReportCategory.lainnya:
        return 'Lainnya';
    }
  }

  static ReportCategory fromString(String value) {
    return ReportCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportCategory.lainnya,
    );
  }
}

enum ReportStatus {
  unsolved,
  inprogress,
  solved;

  String get displayName {
    switch (this) {
      case ReportStatus.unsolved:
        return 'Belum Ditangani';
      case ReportStatus.inprogress:
        return 'Sedang Ditangani';
      case ReportStatus.solved:
        return 'Selesai';
    }
  }

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.unsolved,
    );
  }
}

class ReportModel {
  final String reportId;
  final ReportCategory category;
  final String reportName;
  final String description;
  final String? contactPerson;
  final ReportStatus status;
  final List<String> evidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.reportId,
    required this.category,
    required this.reportName,
    required this.description,
    this.contactPerson,
    required this.status,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['report_id'] as String,
      category: ReportCategory.fromString(json['category'] as String),
      reportName: json['report_name'] as String,
      description: json['description'] as String,
      contactPerson: json['contact_person'] as String?,
      status: ReportStatus.fromString(json['status'] as String),
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'category': category.name,
      'report_name': reportName,
      'description': description,
      'contact_person': contactPerson,
      'status': status.name,
      'evidence': evidence,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReportModel copyWith({
    String? reportId,
    ReportCategory? category,
    String? reportName,
    String? description,
    String? contactPerson,
    ReportStatus? status,
    List<String>? evidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      category: category ?? this.category,
      reportName: reportName ?? this.reportName,
      description: description ?? this.description,
      contactPerson: contactPerson ?? this.contactPerson,
      status: status ?? this.status,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ReportListResponse {
  final int total;
  final List<ReportModel> data;

  ReportListResponse({
    required this.total,
    required this.data,
  });

  factory ReportListResponse.fromJson(Map<String, dynamic> json) {
    return ReportListResponse(
      total: json['total'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreateReportRequest {
  final ReportCategory category;
  final String reportName;
  final String description;
  final String? contactPerson;
  final List<String> evidence;

  CreateReportRequest({
    required this.category,
    required this.reportName,
    required this.description,
    this.contactPerson,
    this.evidence = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'report_name': reportName,
      'description': description,
      if (contactPerson != null) 'contact_person': contactPerson,
      'evidence': evidence,
    };
  }
}

class UpdateReportRequest {
  final ReportCategory? category;
  final String? reportName;
  final String? description;
  final String? contactPerson;
  final ReportStatus? status;
  final List<String>? evidence;

  UpdateReportRequest({
    this.category,
    this.reportName,
    this.description,
    this.contactPerson,
    this.status,
    this.evidence,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (category != null) map['category'] = category!.name;
    if (reportName != null) map['report_name'] = reportName;
    if (description != null) map['description'] = description;
    if (contactPerson != null) map['contact_person'] = contactPerson;
    if (status != null) map['status'] = status!.name;
    if (evidence != null) map['evidence'] = evidence;
    return map;
  }
}
