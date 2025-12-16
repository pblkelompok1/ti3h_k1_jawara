class UsahaData {
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String agama;
  final String pekerjaan;
  final String alamatLengkap;
  final String namaUsaha;
  final String jenisUsaha;
  final String alamatUsaha;
  final String mulaiUsaha;
  final String tujuanSurat;

  UsahaData({
    required this.namaLengkap,
    required this.nik,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.agama,
    required this.pekerjaan,
    required this.alamatLengkap,
    required this.namaUsaha,
    required this.jenisUsaha,
    required this.alamatUsaha,
    required this.mulaiUsaha,
    this.tujuanSurat = 'keperluan administrasi',
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
      'alamat_lengkap': alamatLengkap,
      'nama_usaha': namaUsaha,
      'jenis_usaha': jenisUsaha,
      'alamat_usaha': alamatUsaha,
      'mulai_usaha': mulaiUsaha,
      'tujuan_surat': tujuanSurat,
    };
  }

  factory UsahaData.fromJson(Map<String, dynamic> json) {
    return UsahaData(
      namaLengkap: json['nama_lengkap'] as String,
      nik: json['nik'] as String,
      tempatLahir: json['tempat_lahir'] as String,
      tanggalLahir: json['tanggal_lahir'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      agama: json['agama'] as String,
      pekerjaan: json['pekerjaan'] as String,
      alamatLengkap: json['alamat_lengkap'] as String,
      namaUsaha: json['nama_usaha'] as String,
      jenisUsaha: json['jenis_usaha'] as String,
      alamatUsaha: json['alamat_usaha'] as String,
      mulaiUsaha: json['mulai_usaha'] as String,
      tujuanSurat: json['tujuan_surat'] as String? ?? 'keperluan administrasi',
    );
  }
}
