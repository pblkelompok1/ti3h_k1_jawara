class DomisiliData {
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String agama;
  final String pekerjaan;
  final String statusKawin;
  final String alamatLengkap;
  final String sejakTanggal;

  DomisiliData({
    required this.namaLengkap,
    required this.nik,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.agama,
    required this.pekerjaan,
    required this.statusKawin,
    required this.alamatLengkap,
    required this.sejakTanggal,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'agama': agama,
      'pekerjaan': pekerjaan,
      'status_kawin': statusKawin,
      'alamat_lengkap': alamatLengkap,
      'sejak_tanggal': sejakTanggal,
    };
  }

  factory DomisiliData.fromJson(Map<String, dynamic> json) {
    return DomisiliData(
      namaLengkap: json['nama_lengkap'] as String,
      nik: json['nik'] as String,
      tempatLahir: json['tempat_lahir'] as String,
      tanggalLahir: json['tanggal_lahir'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      agama: json['agama'] as String,
      pekerjaan: json['pekerjaan'] as String,
      statusKawin: json['status_kawin'] as String,
      alamatLengkap: json['alamat_lengkap'] as String,
      sejakTanggal: json['sejak_tanggal'] as String,
    );
  }
}
