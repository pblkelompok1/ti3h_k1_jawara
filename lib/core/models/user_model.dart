class UserModel {
  final String id;
  final String email;
  final String role; // 'admin' atau 'user'
  final String? name;
  final String? residentId;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.residentId,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      name: json['name'] as String?,
      residentId: json['resident_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'resident_id': residentId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? name,
    String? residentId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      residentId: residentId ?? this.residentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
