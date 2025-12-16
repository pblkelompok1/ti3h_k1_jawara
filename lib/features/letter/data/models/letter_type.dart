class LetterType {
  final String letterId;
  final String letterName;
  final String templatePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  LetterType({
    required this.letterId,
    required this.letterName,
    required this.templatePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LetterType.fromJson(Map<String, dynamic> json) {
    return LetterType(
      letterId: json['letter_id'] as String,
      letterName: json['letter_name'] as String,
      templatePath: json['template_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter_id': letterId,
      'letter_name': letterName,
      'template_path': templatePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
