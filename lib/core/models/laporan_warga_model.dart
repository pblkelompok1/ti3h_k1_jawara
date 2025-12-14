class LaporanWargaModel {
  final String id;
  final String namaWarga;
  final String nomorRumah;
  final String noWhatsapp;
  final String judulLaporan;
  final String deskripsiLaporan;
  final String kategoriLaporan; // 'kerusakan_jalan', 'kebersihan', 'keamanan', 'fasilitas_umum', 'lainnya'
  final String lokasi;
  final DateTime tanggalLaporan;
  final String status; // 'waiting', 'on_going', 'complete'
  final String? catatanAdmin;
  final String? fotoBukti;
  final DateTime? tanggalDiproses;
  final DateTime? tanggalSelesai;

  LaporanWargaModel({
    required this.id,
    required this.namaWarga,
    required this.nomorRumah,
    required this.noWhatsapp,
    required this.judulLaporan,
    required this.deskripsiLaporan,
    required this.kategoriLaporan,
    required this.lokasi,
    required this.tanggalLaporan,
    required this.status,
    this.catatanAdmin,
    this.fotoBukti,
    this.tanggalDiproses,
    this.tanggalSelesai,
  });

  factory LaporanWargaModel.fromJson(Map<String, dynamic> json) {
    return LaporanWargaModel(
      id: json['id'],
      namaWarga: json['nama_warga'],
      nomorRumah: json['nomor_rumah'],
      noWhatsapp: json['no_whatsapp'],
      judulLaporan: json['judul_laporan'],
      deskripsiLaporan: json['deskripsi_laporan'],
      kategoriLaporan: json['kategori_laporan'],
      lokasi: json['lokasi'],
      tanggalLaporan: DateTime.parse(json['tanggal_laporan']),
      status: json['status'],
      catatanAdmin: json['catatan_admin'],
      fotoBukti: json['foto_bukti'],
      tanggalDiproses: json['tanggal_diproses'] != null
          ? DateTime.parse(json['tanggal_diproses'])
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_warga': namaWarga,
      'nomor_rumah': nomorRumah,
      'no_whatsapp': noWhatsapp,
      'judul_laporan': judulLaporan,
      'deskripsi_laporan': deskripsiLaporan,
      'kategori_laporan': kategoriLaporan,
      'lokasi': lokasi,
      'tanggal_laporan': tanggalLaporan.toIso8601String(),
      'status': status,
      'catatan_admin': catatanAdmin,
      'foto_bukti': fotoBukti,
      'tanggal_diproses': tanggalDiproses?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
    };
  }
}
