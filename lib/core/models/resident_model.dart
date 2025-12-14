class ResidentModel {
  final String residentId;
  final String nik;
  final String name;
  final String? phone;
  final String placeOfBirth;
  final String dateOfBirth;
  final String gender;
  final bool isDeceased;
  final String familyRole;
  final String? religion;
  final String domicileStatus;
  final String status;
  final String bloodType;
  final String profileImgPath;
  final String ktpPath;
  final String kkPath;
  final String birthCertificatePath;
  final int occupationId;
  final String? occupationName;
  final String familyId;

  ResidentModel({
    required this.residentId,
    required this.nik,
    required this.name,
    this.phone,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.gender,
    required this.isDeceased,
    required this.familyRole,
    this.religion,
    required this.domicileStatus,
    required this.status,
    required this.bloodType,
    required this.profileImgPath,
    required this.ktpPath,
    required this.kkPath,
    required this.birthCertificatePath,
    required this.occupationId,
    this.occupationName,
    required this.familyId,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      residentId: json['resident_id'] as String,
      nik: json['nik'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      placeOfBirth: json['place_of_birth'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      gender: json['gender'] as String,
      isDeceased: json['is_deceased'] as bool? ?? false,
      familyRole: json['family_role'] as String,
      religion: json['religion'] as String?,
      domicileStatus: json['domicile_status'] as String? ?? 'active',
      status: json['status'] as String? ?? 'pending',
      bloodType: json['blood_type'] as String? ?? '',
      profileImgPath: json['profile_img_path'] as String? ?? '',
      ktpPath: json['ktp_path'] as String? ?? '',
      kkPath: json['kk_path'] as String? ?? '',
      birthCertificatePath: json['birth_certificate_path'] as String? ?? '',
      occupationId: json['occupation_id'] as int? ?? 0,
      occupationName: json['occupation_name'] as String?,
      familyId: json['family_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resident_id': residentId,
      'nik': nik,
      'name': name,
      'phone': phone,
      'place_of_birth': placeOfBirth,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'is_deceased': isDeceased,
      'family_role': familyRole,
      'religion': religion,
      'domicile_status': domicileStatus,
      'status': status,
      'blood_type': bloodType,
      'profile_img_path': profileImgPath,
      'ktp_path': ktpPath,
      'kk_path': kkPath,
      'birth_certificate_path': birthCertificatePath,
      'occupation_id': occupationId,
      'occupation_name': occupationName,
      'family_id': familyId,
    };
  }

  // Convert to Map<String, dynamic> for compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'id': residentId,
      'resident_id': residentId,
      'name': name,
      'nik': nik,
      'phone': phone ?? '-',
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'place_of_birth': placeOfBirth,
      'role': familyRole,
      'family_role': familyRole,
      'occupation': occupationName ?? 'Tidak diketahui',
      'occupation_name': occupationName,
      'occupation_id': occupationId,
      'blood_type': bloodType,
      'religion': religion,
      'family_id': familyId,
      'profile_img_path': profileImgPath,
      'ktp_path': ktpPath,
      'kk_path': kkPath,
      'birth_certificate_path': birthCertificatePath,
      'is_deceased': isDeceased,
      'domicile_status': domicileStatus,
      'status': status,
    };
  }

  String getProfileImageUrl(String baseUrl) {
    return '$baseUrl/$profileImgPath';
  }

  String getKtpUrl(String baseUrl) {
    return '$baseUrl/$ktpPath';
  }

  String getKkUrl(String baseUrl) {
    return '$baseUrl/$kkPath';
  }

  String getBirthCertificateUrl(String baseUrl) {
    return '$baseUrl/$birthCertificatePath';
  }
}
