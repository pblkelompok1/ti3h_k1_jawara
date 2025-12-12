class ResidentRegistrationModel {
  final String userId;
  final String email;
  final String role;
  final String status; // 'pending', 'approved', 'rejected'
  final String? name;
  final String? nik;
  final String? phone;
  final String? address;
  final String? familyRole;
  final String? ktpPath;
  final String? kkPath;

  ResidentRegistrationModel({
    required this.userId,
    required this.email,
    required this.role,
    required this.status,
    this.name,
    this.nik,
    this.phone,
    this.address,
    this.familyRole,
    this.ktpPath,
    this.kkPath,
  });

  factory ResidentRegistrationModel.fromJson(Map<String, dynamic> json) {
    return ResidentRegistrationModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      name: json['name'] as String?,
      nik: json['nik'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      familyRole: json['family_role'] as String?,
      ktpPath: json['ktp_path'] as String?,
      kkPath: json['kk_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'role': role,
      'status': status,
      'name': name,
      'nik': nik,
      'phone': phone,
      'address': address,
      'family_role': familyRole,
      'ktp_path': ktpPath,
      'kk_path': kkPath,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCitizen => role == 'citizen';

  // Get display name with fallback
  String get displayName => name ?? email.split('@').first;

  // Check if has complete data
  bool get hasCompleteData => name != null && nik != null && familyRole != null;

  // Get document URLs (will add base URL from service)
  String? getKtpUrl(String baseUrl) => ktpPath != null ? '$baseUrl/$ktpPath' : null;
  String? getKkUrl(String baseUrl) => kkPath != null ? '$baseUrl/$kkPath' : null;

  ResidentRegistrationModel copyWith({
    String? userId,
    String? email,
    String? role,
    String? status,
    String? name,
    String? nik,
    String? phone,
    String? address,
    String? familyRole,
    String? ktpPath,
    String? kkPath,
  }) {
    return ResidentRegistrationModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      familyRole: familyRole ?? this.familyRole,
      ktpPath: ktpPath ?? this.ktpPath,
      kkPath: kkPath ?? this.kkPath,
    );
  }
}

class ResidentRegistrationResponse {
  final int total;
  final int limit;
  final int offset;
  final List<ResidentRegistrationModel> data;

  ResidentRegistrationResponse({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory ResidentRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return ResidentRegistrationResponse(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      data: (json['data'] as List)
          .map((e) => ResidentRegistrationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'limit': limit,
      'offset': offset,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
