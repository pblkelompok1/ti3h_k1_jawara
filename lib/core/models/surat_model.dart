class SuratModel {
  final String id;
  final String jenisSurat;
  final String tipePermohonan;
  final DateTime tanggajudiajukan;
  final String status; // 'menunggu', 'diproses', 'selesai', 'ditolak'
  final String? keterangan;
  final String? filePath;

  SuratModel({
    required this.id,
    required this.jenisSurat,
    required this.tipePermohonan,
    required this.tanggajudiajukan,
    required this.status,
    this.keterangan,
    this.filePath,
  });

  // Untuk mock data
  factory SuratModel.fromJson(Map<String, dynamic> json) {
    return SuratModel(
      id: json['id'] as String,
      jenisSurat: json['jenisSurat'] as String,
      tipePermohonan: json['tipePermohonan'] as String,
      tanggajudiajukan: DateTime.parse(json['tanggajudiajukan'] as String),
      status: json['status'] as String,
      keterangan: json['keterangan'] as String?,
      filePath: json['filePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenisSurat': jenisSurat,
      'tipePermohonan': tipePermohonan,
      'tanggajudiajukan': tanggajudiajukan.toIso8601String(),
      'status': status,
      'keterangan': keterangan,
      'filePath': filePath,
    };
  }
}
