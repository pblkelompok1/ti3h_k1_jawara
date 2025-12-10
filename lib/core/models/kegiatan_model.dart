class KegiatanModel {
  final String id;
  final String namaKegiatan;
  final String deskripsi;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final String lokasi;
  final String penyelenggara;
  final String status; // 'akan_datang', 'ongoing', 'selesai'
  final String? gambar;
  final int? jumlahPeserta;
  final String kategori; // 'sosial', 'keagamaan', 'olahraga', 'pendidikan', 'lainnya'

  KegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.deskripsi,
    required this.tanggalMulai,
    this.tanggalSelesai,
    required this.lokasi,
    required this.penyelenggara,
    required this.status,
    this.gambar,
    this.jumlahPeserta,
    required this.kategori,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel(
      id: json['id'],
      namaKegiatan: json['nama_kegiatan'],
      deskripsi: json['deskripsi'],
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
      lokasi: json['lokasi'],
      penyelenggara: json['penyelenggara'],
      status: json['status'],
      gambar: json['gambar'],
      jumlahPeserta: json['jumlah_peserta'],
      kategori: json['kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kegiatan': namaKegiatan,
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'lokasi': lokasi,
      'penyelenggara': penyelenggara,
      'status': status,
      'gambar': gambar,
      'jumlah_peserta': jumlahPeserta,
      'kategori': kategori,
    };
  }
}
