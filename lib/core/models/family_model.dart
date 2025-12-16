class FamilyModel {
  final String familyId;
  final String familyName;
  final String? headOfFamily;

  FamilyModel({
    required this.familyId,
    required this.familyName,
    this.headOfFamily,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      familyId: json['family_id'] as String,
      familyName: json['family_name'] as String,
      headOfFamily: json['head_of_family'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family_id': familyId,
      'family_name': familyName,
      'head_of_family': headOfFamily,
    };
  }

  // Convert to Map<String, dynamic> for compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'family_id': familyId,
      'family_name': familyName,
      'head_name': headOfFamily,
      'member_count': 0, // Will be populated by backend or separately
    };
  }
}
