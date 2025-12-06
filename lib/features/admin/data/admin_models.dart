// Admin Data Models

/// Model untuk registrasi user yang menunggu approval
class PendingRegistration {
  final String id;
  final String email;
  final String name;
  final String nik;
  final String phone;
  final String address;
  final String familyRole;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  final Map<String, String>? documents; // KTP, KK, Akta urls
  final Map<String, dynamic>? residentData;

  PendingRegistration({
    required this.id,
    required this.email,
    required this.name,
    required this.nik,
    required this.phone,
    required this.address,
    required this.familyRole,
    required this.status,
    required this.submittedAt,
    this.documents,
    this.residentData,
  });

  factory PendingRegistration.fromJson(Map<String, dynamic> json) {
    return PendingRegistration(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      familyRole: json['family_role'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      documents: json['documents'] != null
          ? Map<String, String>.from(json['documents'] as Map)
          : null,
      residentData: json['resident_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'nik': nik,
      'phone': phone,
      'address': address,
      'family_role': familyRole,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'documents': documents,
      'resident_data': residentData,
    };
  }
}

/// Model untuk laporan keuangan
class FinanceReport {
  final String id;
  final String type; // 'income' atau 'expense'
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String? residentId;
  final String? residentName;
  final String? receiptUrl;

  FinanceReport({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.residentId,
    this.residentName,
    this.receiptUrl,
  });

  factory FinanceReport.fromJson(Map<String, dynamic> json) {
    return FinanceReport(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'income',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      residentId: json['resident_id'] as String?,
      residentName: json['resident_name'] as String?,
      receiptUrl: json['receipt_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'resident_id': residentId,
      'resident_name': residentName,
      'receipt_url': receiptUrl,
    };
  }
}

/// Model untuk summary keuangan
class FinanceSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final DateTime? lastUpdated;

  FinanceSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    this.lastUpdated,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }
}

/// Model untuk banner (dashboard & marketplace)
class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? iconName; // Untuk dashboard banner
  final String type; // 'dashboard' atau 'marketplace'
  final int priority; // untuk sorting
  final bool isActive;
  final String? linkUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.iconName,
    required this.type,
    required this.priority,
    required this.isActive,
    this.linkUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      iconName: json['icon_name'] as String?,
      type: json['type'] as String? ?? 'dashboard',
      priority: json['priority'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      linkUrl: json['link_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'icon_name': iconName,
      'type': type,
      'priority': priority,
      'is_active': isActive,
      'link_url': linkUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? iconName,
    String? type,
    int? priority,
    bool? isActive,
    String? linkUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      linkUrl: linkUrl ?? this.linkUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model untuk laporan masalah
class ProblemReport {
  final String id;
  final String title;
  final String description;
  final String category; // 'infrastruktur', 'keamanan', 'kebersihan', dll
  final String status; // 'new', 'in_progress', 'resolved', 'closed'
  final String reporterName;
  final String reporterId;
  final String? reporterPhone;
  final String? location;
  final List<String>? imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignedTo; // admin yang handle
  final String? notes; // catatan admin
  final List<ReportComment>? comments;

  ProblemReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.reporterName,
    required this.reporterId,
    this.reporterPhone,
    this.location,
    this.imageUrls,
    required this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.notes,
    this.comments,
  });

  factory ProblemReport.fromJson(Map<String, dynamic> json) {
    return ProblemReport(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'new',
      reporterName: json['reporter_name'] as String? ?? '',
      reporterId: json['reporter_id']?.toString() ?? '',
      reporterPhone: json['reporter_phone'] as String?,
      location: json['location'] as String?,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      assignedTo: json['assigned_to'] as String?,
      notes: json['notes'] as String?,
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((e) => ReportComment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'reporter_name': reporterName,
      'reporter_id': reporterId,
      'reporter_phone': reporterPhone,
      'location': location,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'notes': notes,
      'comments': comments?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model untuk komentar di laporan
class ReportComment {
  final String id;
  final String message;
  final String authorName;
  final String authorId;
  final bool isAdmin;
  final DateTime createdAt;

  ReportComment({
    required this.id,
    required this.message,
    required this.authorName,
    required this.authorId,
    required this.isAdmin,
    required this.createdAt,
  });

  factory ReportComment.fromJson(Map<String, dynamic> json) {
    return ReportComment(
      id: json['id']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorId: json['author_id']?.toString() ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'author_name': authorName,
      'author_id': authorId,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model untuk pengajuan surat
class LetterRequest {
  final String id;
  final String letterType; // 'ktp', 'kk', 'surat_keterangan', 'surat_domisili', dll
  final String requesterName;
  final String requesterId;
  final String? requesterPhone;
  final String purpose; // tujuan pengajuan
  final String status; // 'pending', 'approved', 'rejected', 'ready', 'completed'
  final DateTime requestDate;
  final DateTime? approvedDate;
  final DateTime? completedDate;
  final String? approvedBy; // admin yang approve
  final String? notes; // catatan admin
  final String? rejectionReason;
  final Map<String, dynamic>? additionalData; // data tambahan sesuai jenis surat
  final String? documentUrl; // URL surat yang sudah jadi

  LetterRequest({
    required this.id,
    required this.letterType,
    required this.requesterName,
    required this.requesterId,
    this.requesterPhone,
    required this.purpose,
    required this.status,
    required this.requestDate,
    this.approvedDate,
    this.completedDate,
    this.approvedBy,
    this.notes,
    this.rejectionReason,
    this.additionalData,
    this.documentUrl,
  });

  factory LetterRequest.fromJson(Map<String, dynamic> json) {
    return LetterRequest(
      id: json['id']?.toString() ?? '',
      letterType: json['letter_type'] as String? ?? '',
      requesterName: json['requester_name'] as String? ?? '',
      requesterId: json['requester_id']?.toString() ?? '',
      requesterPhone: json['requester_phone'] as String?,
      purpose: json['purpose'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      requestDate: json['request_date'] != null
          ? DateTime.parse(json['request_date'] as String)
          : DateTime.now(),
      approvedDate: json['approved_date'] != null
          ? DateTime.parse(json['approved_date'] as String)
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      approvedBy: json['approved_by'] as String?,
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      documentUrl: json['document_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'letter_type': letterType,
      'requester_name': requesterName,
      'requester_id': requesterId,
      'requester_phone': requesterPhone,
      'purpose': purpose,
      'status': status,
      'request_date': requestDate.toIso8601String(),
      'approved_date': approvedDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'approved_by': approvedBy,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'additional_data': additionalData,
      'document_url': documentUrl,
    };
  }
}

/// Model untuk statistik dashboard admin
class AdminStatistics {
  final int totalResidents;
  final int pendingRegistrations;
  final int activeUsers;
  final int newReportsToday;
  final int pendingLetters;
  final double monthlyIncome;
  final double monthlyExpense;
  final int totalFamilies;

  AdminStatistics({
    required this.totalResidents,
    required this.pendingRegistrations,
    required this.activeUsers,
    required this.newReportsToday,
    required this.pendingLetters,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.totalFamilies,
  });

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    return AdminStatistics(
      totalResidents: json['total_residents'] as int? ?? 0,
      pendingRegistrations: json['pending_registrations'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      newReportsToday: json['new_reports_today'] as int? ?? 0,
      pendingLetters: json['pending_letters'] as int? ?? 0,
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 0.0,
      monthlyExpense: (json['monthly_expense'] as num?)?.toDouble() ?? 0.0,
      totalFamilies: json['total_families'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_residents': totalResidents,
      'pending_registrations': pendingRegistrations,
      'active_users': activeUsers,
      'new_reports_today': newReportsToday,
      'pending_letters': pendingLetters,
      'monthly_income': monthlyIncome,
      'monthly_expense': monthlyExpense,
      'total_families': totalFamilies,
    };
  }
}
