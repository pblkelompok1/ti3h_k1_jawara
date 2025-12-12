import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/models/kegiatan_model.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class DetailKegiatanView extends StatefulWidget {
  const DetailKegiatanView({super.key});

  @override
  State<DetailKegiatanView> createState() => _DetailKegiatanViewState();
}

class _DetailKegiatanViewState extends State<DetailKegiatanView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace with real data from API
  final List<KegiatanModel> _allKegiatan = [
    // Akan Datang
    KegiatanModel(
      id: '1',
      namaKegiatan: 'Kerja Bakti Lingkungan RT 01',
      deskripsi:
          'Kegiatan gotong royong membersihkan lingkungan RT 01 meliputi saluran air, taman, dan jalan lingkungan. Diharapkan seluruh warga dapat berpartisipasi.',
      tanggalMulai: DateTime.now().add(const Duration(days: 5)),
      tanggalSelesai: DateTime.now().add(const Duration(days: 5, hours: 3)),
      lokasi: 'Balai RT 01, Jl. Mawar No. 123',
      penyelenggara: 'Pengurus RT 01',
      status: 'akan_datang',
      jumlahPeserta: 45,
      kategori: 'sosial',
    ),
    KegiatanModel(
      id: '2',
      namaKegiatan: 'Pengajian Rutin Bulanan',
      deskripsi:
          'Pengajian rutin bulanan bersama Ustadz Ahmad. Tema bulan ini: "Meningkatkan Ketakwaan di Bulan Ramadan".',
      tanggalMulai: DateTime.now().add(const Duration(days: 10)),
      tanggalSelesai: DateTime.now().add(const Duration(days: 10, hours: 2)),
      lokasi: 'Musholla Al-Ikhlas',
      penyelenggara: 'Takmir Musholla',
      status: 'akan_datang',
      jumlahPeserta: 60,
      kategori: 'keagamaan',
    ),
    KegiatanModel(
      id: '3',
      namaKegiatan: 'Turnamen Futsal Antar RT',
      deskripsi:
          'Kompetisi futsal antar RT se-kelurahan. Pendaftaran tim dibuka hingga H-3. Hadiah total Rp 5.000.000.',
      tanggalMulai: DateTime.now().add(const Duration(days: 15)),
      tanggalSelesai: DateTime.now().add(const Duration(days: 16)),
      lokasi: 'Lapangan Futsal GOR Kelurahan',
      penyelenggara: 'Karang Taruna',
      status: 'akan_datang',
      jumlahPeserta: 120,
      kategori: 'olahraga',
    ),

    // Ongoing
    KegiatanModel(
      id: '4',
      namaKegiatan: 'Posyandu Balita',
      deskripsi:
          'Pemeriksaan kesehatan balita, pemberian vitamin, dan imunisasi. Mohon membawa Buku KIA.',
      tanggalMulai: DateTime.now().subtract(const Duration(hours: 2)),
      tanggalSelesai: DateTime.now().add(const Duration(hours: 2)),
      lokasi: 'Posyandu Melati, Balai RT 02',
      penyelenggara: 'PKK RT 02',
      status: 'ongoing',
      jumlahPeserta: 35,
      kategori: 'sosial',
    ),
    KegiatanModel(
      id: '5',
      namaKegiatan: 'Rapat Koordinasi RT/RW',
      deskripsi:
          'Rapat koordinasi membahas program kerja bulan depan dan evaluasi kegiatan bulan ini.',
      tanggalMulai: DateTime.now().subtract(const Duration(minutes: 30)),
      tanggalSelesai: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
      lokasi: 'Aula Kelurahan',
      penyelenggara: 'Pengurus RW 05',
      status: 'ongoing',
      jumlahPeserta: 25,
      kategori: 'lainnya',
    ),

    // Selesai
    KegiatanModel(
      id: '6',
      namaKegiatan: '17 Agustus - Lomba HUT RI',
      deskripsi:
          'Serangkaian lomba memeriahkan HUT RI: balap karung, tarik tambang, makan kerupuk, dll. Doorprize menarik untuk peserta.',
      tanggalMulai: DateTime.now().subtract(const Duration(days: 117)),
      tanggalSelesai: DateTime.now().subtract(
        const Duration(days: 117, hours: -6),
      ),
      lokasi: 'Lapangan RT 01-03',
      penyelenggara: 'Panitia HUT RI',
      status: 'selesai',
      jumlahPeserta: 180,
      kategori: 'sosial',
    ),
    KegiatanModel(
      id: '7',
      namaKegiatan: 'Buka Puasa Bersama',
      deskripsi:
          'Buka puasa bersama seluruh warga RT 01-05 di bulan Ramadan. Menu: nasi kotak, kolak, dan es teh manis.',
      tanggalMulai: DateTime.now().subtract(const Duration(days: 245)),
      tanggalSelesai: DateTime.now().subtract(
        const Duration(days: 245, hours: -3),
      ),
      lokasi: 'Masjid Jami Al-Barokah',
      penyelenggara: 'DKM Masjid',
      status: 'selesai',
      jumlahPeserta: 250,
      kategori: 'keagamaan',
    ),
    KegiatanModel(
      id: '8',
      namaKegiatan: 'Pelatihan Komputer Gratis',
      deskripsi:
          'Pelatihan Microsoft Office (Word, Excel, PowerPoint) untuk warga. Sertifikat diberikan setelah selesai.',
      tanggalMulai: DateTime.now().subtract(const Duration(days: 30)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 28)),
      lokasi: 'Lab Komputer Kelurahan',
      penyelenggara: 'Dinas Kominfo',
      status: 'selesai',
      jumlahPeserta: 40,
      kategori: 'pendidikan',
    ),
    KegiatanModel(
      id: '9',
      namaKegiatan: 'Donor Darah PMI',
      deskripsi:
          'Kegiatan donor darah bekerjasama dengan PMI. Peserta mendapat snack, sertifikat, dan cek kesehatan gratis.',
      tanggalMulai: DateTime.now().subtract(const Duration(days: 14)),
      tanggalSelesai: DateTime.now().subtract(
        const Duration(days: 14, hours: -5),
      ),
      lokasi: 'Aula RW 05',
      penyelenggara: 'PMI & Pengurus RW',
      status: 'selesai',
      jumlahPeserta: 75,
      kategori: 'sosial',
    ),
    KegiatanModel(
      id: '10',
      namaKegiatan: 'Senam Sehat Pagi',
      deskripsi:
          'Senam aerobik bersama instruktur profesional. Kegiatan rutin setiap minggu untuk meningkatkan kesehatan warga.',
      tanggalMulai: DateTime.now().subtract(const Duration(days: 7)),
      tanggalSelesai: DateTime.now().subtract(
        const Duration(days: 7, hours: -2),
      ),
      lokasi: 'Lapangan RT 03',
      penyelenggara: 'PKK RW 05',
      status: 'selesai',
      jumlahPeserta: 55,
      kategori: 'olahraga',
    ),
  ];

  List<KegiatanModel> get _kegiatanAkanDatang =>
      _allKegiatan.where((k) => k.status == 'akan_datang').toList();

  List<KegiatanModel> get _kegiatanOngoing =>
      _allKegiatan.where((k) => k.status == 'ongoing').toList();

  List<KegiatanModel> get _kegiatanSelesai =>
      _allKegiatan.where((k) => k.status == 'selesai').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text(
          'Detail Kegiatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 4),
                  const Text('Akan Datang'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_outline, size: 18),
                  const SizedBox(width: 4),
                  const Text('Ongoing'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18),
                  const SizedBox(width: 4),
                  const Text('Selesai'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKegiatanList(_kegiatanAkanDatang, 'akan_datang'),
          _buildKegiatanList(_kegiatanOngoing, 'ongoing'),
          _buildKegiatanList(_kegiatanSelesai, 'selesai'),
        ],
      ),
    );
  }

  Widget _buildKegiatanList(List<KegiatanModel> kegiatanList, String status) {
    if (kegiatanList.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kegiatanList.length,
      itemBuilder: (context, index) {
        return _KegiatanCard(
          kegiatan: kegiatanList[index],
          onTap: () => _showDetailDialog(kegiatanList[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String message;
    IconData icon;

    switch (status) {
      case 'akan_datang':
        message = 'Belum ada kegiatan yang akan datang';
        icon = Icons.event_available;
        break;
      case 'ongoing':
        message = 'Tidak ada kegiatan yang sedang berlangsung';
        icon = Icons.event_busy;
        break;
      case 'selesai':
        message = 'Belum ada kegiatan yang selesai';
        icon = Icons.event_note;
        break;
      default:
        message = 'Tidak ada kegiatan';
        icon = Icons.event;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(KegiatanModel kegiatan) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            _getCategoryIcon(kegiatan.kategori),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                kegiatan.namaKegiatan,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                Icons.category,
                'Kategori',
                _getKategoriText(kegiatan.kategori),
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.calendar_today,
                'Tanggal Mulai',
                DateFormat('dd MMMM yyyy, HH:mm').format(kegiatan.tanggalMulai),
                isDarkMode,
              ),
              if (kegiatan.tanggalSelesai != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.event_available,
                  'Tanggal Selesai',
                  DateFormat(
                    'dd MMMM yyyy, HH:mm',
                  ).format(kegiatan.tanggalSelesai!),
                  isDarkMode,
                ),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.location_on,
                'Lokasi',
                kegiatan.lokasi,
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.person,
                'Penyelenggara',
                kegiatan.penyelenggara,
                isDarkMode,
              ),
              if (kegiatan.jumlahPeserta != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.people,
                  'Jumlah Peserta',
                  '${kegiatan.jumlahPeserta} orang',
                  isDarkMode,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kegiatan.deskripsi,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDarkMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryLight),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getCategoryIcon(String kategori) {
    IconData icon;
    Color color;

    switch (kategori) {
      case 'sosial':
        icon = Icons.people;
        color = Colors.blue;
        break;
      case 'keagamaan':
        icon = Icons.mosque;
        color = Colors.green;
        break;
      case 'olahraga':
        icon = Icons.sports_soccer;
        color = Colors.orange;
        break;
      case 'pendidikan':
        icon = Icons.school;
        color = Colors.purple;
        break;
      case 'lainnya':
        icon = Icons.event;
        color = Colors.grey;
        break;
      default:
        icon = Icons.event;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getKategoriText(String kategori) {
    switch (kategori) {
      case 'sosial':
        return 'Sosial';
      case 'keagamaan':
        return 'Keagamaan';
      case 'olahraga':
        return 'Olahraga';
      case 'pendidikan':
        return 'Pendidikan';
      case 'lainnya':
        return 'Lainnya';
      default:
        return kategori;
    }
  }
}

class _KegiatanCard extends StatelessWidget {
  final KegiatanModel kegiatan;
  final VoidCallback onTap;

  const _KegiatanCard({required this.kegiatan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getCategoryIcon(kegiatan.kategori),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kegiatan.namaKegiatan,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusBadge(kegiatan.status, isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(kegiatan.tanggalMulai),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kegiatan.lokasi,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              if (kegiatan.jumlahPeserta != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${kegiatan.jumlahPeserta} Peserta',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(
                kegiatan.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Oleh: ${kegiatan.penyelenggara}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDarkMode) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'akan_datang':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        text = 'Akan Datang';
        icon = Icons.schedule;
        break;
      case 'ongoing':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        text = 'Sedang Berlangsung';
        icon = Icons.play_circle_filled;
        break;
      case 'selesai':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        text = 'Selesai';
        icon = Icons.check_circle;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        text = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String kategori) {
    IconData icon;
    Color color;

    switch (kategori) {
      case 'sosial':
        icon = Icons.people;
        color = Colors.blue;
        break;
      case 'keagamaan':
        icon = Icons.mosque;
        color = Colors.green;
        break;
      case 'olahraga':
        icon = Icons.sports_soccer;
        color = Colors.orange;
        break;
      case 'pendidikan':
        icon = Icons.school;
        color = Colors.purple;
        break;
      case 'lainnya':
        icon = Icons.event;
        color = Colors.grey;
        break;
      default:
        icon = Icons.event;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
