class BannerModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String? imageUrl;
  final String tipePromo; // 'flash_sale', 'super_brand_day', 'regular', 'seasonal'
  final String lokasi; // 'dashboard', 'marketplace'
  final int urutan;
  final bool aktif;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final String? linkTujuan;
  final DateTime dibuat;
  final DateTime? diubah;

  BannerModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.imageUrl,
    required this.tipePromo,
    required this.lokasi,
    required this.urutan,
    required this.aktif,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.linkTujuan,
    required this.dibuat,
    this.diubah,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      imageUrl: json['image_url'],
      tipePromo: json['tipe_promo'],
      lokasi: json['lokasi'],
      urutan: json['urutan'],
      aktif: json['aktif'] ?? true,
      tanggalMulai: json['tanggal_mulai'] != null
          ? DateTime.parse(json['tanggal_mulai'])
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
      linkTujuan: json['link_tujuan'],
      dibuat: DateTime.parse(json['dibuat']),
      diubah: json['diubah'] != null ? DateTime.parse(json['diubah']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'image_url': imageUrl,
      'tipe_promo': tipePromo,
      'lokasi': lokasi,
      'urutan': urutan,
      'aktif': aktif,
      'tanggal_mulai': tanggalMulai?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'link_tujuan': linkTujuan,
      'dibuat': dibuat.toIso8601String(),
      'diubah': diubah?.toIso8601String(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? imageUrl,
    String? tipePromo,
    String? lokasi,
    int? urutan,
    bool? aktif,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    String? linkTujuan,
    DateTime? dibuat,
    DateTime? diubah,
  }) {
    return BannerModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      imageUrl: imageUrl ?? this.imageUrl,
      tipePromo: tipePromo ?? this.tipePromo,
      lokasi: lokasi ?? this.lokasi,
      urutan: urutan ?? this.urutan,
      aktif: aktif ?? this.aktif,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      linkTujuan: linkTujuan ?? this.linkTujuan,
      dibuat: dibuat ?? this.dibuat,
      diubah: diubah ?? this.diubah,
    );
  }
}
