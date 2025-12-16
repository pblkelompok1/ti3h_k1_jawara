import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/models/laporan_warga_model.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class AdminLaporanView extends StatefulWidget {
  const AdminLaporanView({super.key});

  @override
  State<AdminLaporanView> createState() => _AdminLaporanViewState();
}

class _AdminLaporanViewState extends State<AdminLaporanView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace dengan API call
  final List<LaporanWargaModel> _allLaporan = [
    // Waiting
    LaporanWargaModel(
      id: '001',
      namaWarga: 'Budi Santoso',
      nomorRumah: '12A',
      noWhatsapp: '085234567890',
      judulLaporan: 'Jalan berlubang di depan mushola',
      deskripsiLaporan:
          'Jalan di depan mushola sudah berlubang dan sangat berbahaya bagi kendaraan. Lubang tersebut cukup besar dan dapat menyebabkan kecelakaan.',
      kategoriLaporan: 'kerusakan_jalan',
      lokasi: 'Jl. Mawar No. 12, RT 03/RW 05',
      tanggalLaporan: DateTime.now(),
      status: 'waiting',
    ),
    LaporanWargaModel(
      id: '002',
      namaWarga: 'Siti Nurhaliza',
      nomorRumah: '25B',
      noWhatsapp: '081234567890',
      judulLaporan: 'Sampah menumpuk di sudut jalan',
      deskripsiLaporan:
          'Sampah menumpuk di sudut jalan perempatan, sudah 3 hari tidak diambil dan menimbulkan bau tidak sedap.',
      kategoriLaporan: 'kebersihan',
      lokasi: 'Perempatan Jl. Merpati - Jl. Mekar',
      tanggalLaporan: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'waiting',
    ),
    LaporanWargaModel(
      id: '003',
      namaWarga: 'Ahmad Suryanto',
      nomorRumah: '42C',
      noWhatsapp: '082234567890',
      judulLaporan: 'Pencahayaan jalan rusak di malam hari',
      deskripsiLaporan:
          'Lampu jalan di depan toko semakin redup dan malam hari sangat gelap. Ini mengganggu keamanan warga yang lewat malam.',
      kategoriLaporan: 'keamanan',
      lokasi: 'Jl. Anggrek No. 42, RT 02/RW 05',
      tanggalLaporan: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'waiting',
    ),

    // On Going
    LaporanWargaModel(
      id: '004',
      namaWarga: 'Rina Wijaya',
      nomorRumah: '18D',
      noWhatsapp: '083234567890',
      judulLaporan: 'Pipa air ledak',
      deskripsiLaporan:
          'Pipa air di halaman rumah bocor dan menyebabkan tanah tergenang. Sudah mengalami kebocoran selama 2 hari.',
      kategoriLaporan: 'fasilitas_umum',
      lokasi: 'Jl. Bunga No. 18, RT 01/RW 05',
      tanggalLaporan: DateTime.now().subtract(const Duration(days: 2)),
      status: 'on_going',
      catatanAdmin: 'Petugas PDAM sudah dipanggil untuk pemeriksaan',
      tanggalDiproses: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    ),
    LaporanWargaModel(
      id: '005',
      namaWarga: 'Hendra Gunawan',
      nomorRumah: '35E',
      noWhatsapp: '084234567890',
      judulLaporan: 'Tanda jalan hilang',
      deskripsiLaporan:
          'Tanda peringatan di tikungan jalan sudah rusak dan hilang. Sangat membahayakan pengendara yang tidak tahu jalan.',
      kategoriLaporan: 'kerusakan_jalan',
      lokasi: 'Tikungan Jl. Dahlia - Jl. Melati',
      tanggalLaporan: DateTime.now().subtract(const Duration(days: 3)),
      status: 'on_going',
      catatanAdmin: 'Sedang menunggu pengadaan tanda jalan baru dari kelurahan',
      tanggalDiproses: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
    ),

    // Complete
    LaporanWargaModel(
      id: '006',
      namaWarga: 'Dewi Lestari',
      nomorRumah: '22F',
      noWhatsapp: '085534567890',
      judulLaporan: 'Saluran air tersumbat',
      deskripsiLaporan:
          'Saluran air pembuangan di depan rumah tersumbat dan menyebabkan air tergenang saat hujan deras.',
      kategoriLaporan: 'kebersihan',
      lokasi: 'Jl. Teratai No. 22, RT 04/RW 05',
      tanggalLaporan: DateTime.now().subtract(const Duration(days: 7)),
      status: 'complete',
      catatanAdmin: 'Saluran sudah dibersihkan dan lancar kembali',
      tanggalDiproses: DateTime.now().subtract(const Duration(days: 6, hours: 10)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 5, hours: 14)),
    ),
    LaporanWargaModel(
      id: '007',
      namaWarga: 'Rinto Harahap',
      nomorRumah: '50G',
      noWhatsapp: '086234567890',
      judulLaporan: 'Pohon tumbang mengganggu jalan',
      deskripsiLaporan:
          'Pohon besar di depan sekolah tumbang akibat angin kencang dan menutup jalan. Sudah dihubungi BPBD untuk penanganan.',
      kategoriLaporan: 'fasilitas_umum',
      lokasi: 'Depan SDN 03, Jl. Pendidikan No. 50',
      tanggalLaporan: DateTime.now().subtract(const Duration(days: 10)),
      status: 'complete',
      catatanAdmin: 'Pohon sudah dipotong dan dibersihkan oleh BPBD',
      tanggalDiproses: DateTime.now().subtract(const Duration(days: 9, hours: 3)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 8, hours: 15)),
    ),
    LaporanWargaModel(
      id: '008',
      namaWarga: 'Anita Salsabila',
      nomorRumah: '33H',
      noWhatsapp: '087234567890',
      judulLaporan: 'Genangan air di perempatan',
      deskripsiLaporan:
          'Air tergenang di perempatan jalan utama karena saluran pembuangan tersumbat sampah. Menggangu mobilitas warga.',
      kategoriLaporan: 'kebersihan',
      lokasi: 'Perempatan Jl. Utama - Jl. Harapan',
      tanggalLaporan: DateTime.now().subtract(const Duration(days: 14)),
      status: 'complete',
      catatanAdmin: 'Petugas kebersihan sudah membersihkan dan mengalirkan air',
      tanggalDiproses: DateTime.now().subtract(const Duration(days: 13, hours: 6)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 12, hours: 9)),
    ),
  ];

  List<LaporanWargaModel> get _laporanWaiting =>
      _allLaporan.where((l) => l.status == 'waiting').toList();

  List<LaporanWargaModel> get _laporanOnGoing =>
      _allLaporan.where((l) => l.status == 'on_going').toList();

  List<LaporanWargaModel> get _laporanComplete =>
      _allLaporan.where((l) => l.status == 'complete').toList();

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
          'Laporan Warga',
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
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.schedule, size: 18),
                  SizedBox(width: 4),
                  Text('Menunggu'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.hourglass_bottom, size: 18),
                  SizedBox(width: 4),
                  Text('Diproses'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, size: 18),
                  SizedBox(width: 4),
                  Text('Selesai'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLaporanList(_laporanWaiting),
          _buildLaporanList(_laporanOnGoing),
          _buildLaporanList(_laporanComplete),
        ],
      ),
    );
  }

  Widget _buildLaporanList(List<LaporanWargaModel> laporanList) {
    if (laporanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada laporan',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: laporanList.length,
      itemBuilder: (context, index) {
        return _LaporanCard(
          laporan: laporanList[index],
          onTap: () => _showDetailDialog(laporanList[index]),
        );
      },
    );
  }

  void _showDetailDialog(LaporanWargaModel laporan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          laporan.judulLaporan,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('👤 Nama Warga', laporan.namaWarga, context),
              _buildDetailItem('🏠 Nomor Rumah', laporan.nomorRumah, context),
              _buildDetailItem('📱 WhatsApp', laporan.noWhatsapp, context),
              _buildDetailItem(
                '📂 Kategori',
                _getKategoriText(laporan.kategoriLaporan),
                context,
              ),
              _buildDetailItem('📍 Lokasi', laporan.lokasi, context),
              _buildDetailItem(
                '📅 Tanggal Laporan',
                DateFormat('dd MMMM yyyy, HH:mm').format(laporan.tanggalLaporan),
                context,
              ),
              const SizedBox(height: 12),
              Text(
                'Deskripsi:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                laporan.deskripsiLaporan,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
              if (laporan.catatanAdmin != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 Catatan Admin:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        laporan.catatanAdmin!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (laporan.tanggalDiproses != null) ...[
                const SizedBox(height: 12),
                _buildDetailItem(
                  '⏱ Tanggal Diproses',
                  DateFormat('dd MMMM yyyy, HH:mm')
                      .format(laporan.tanggalDiproses!),
                  context,
                ),
              ],
              if (laporan.tanggalSelesai != null) ...[
                const SizedBox(height: 12),
                _buildDetailItem(
                  '✅ Tanggal Selesai',
                  DateFormat('dd MMMM yyyy, HH:mm')
                      .format(laporan.tanggalSelesai!),
                  context,
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (laporan.status == 'waiting')
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit),
              label: const Text('Proses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          if (laporan.status == 'on_going')
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: const Text('Selesaikan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  String _getKategoriText(String kategori) {
    switch (kategori) {
      case 'kerusakan_jalan':
        return '🛣️ Kerusakan Jalan';
      case 'kebersihan':
        return '🧹 Kebersihan';
      case 'keamanan':
        return '🔒 Keamanan';
      case 'fasilitas_umum':
        return '🏛️ Fasilitas Umum';
      case 'lainnya':
        return '📌 Lainnya';
      default:
        return kategori;
    }
  }
}

class _LaporanCard extends StatelessWidget {
  final LaporanWargaModel laporan;
  final VoidCallback onTap;

  const _LaporanCard({
    required this.laporan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(laporan.status);
    final statusText = _getStatusText(laporan.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.judulLaporan,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'dari: ${laporan.namaWarga} (${laporan.nomorRumah})',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      laporan.lokasi,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(laporan.tanggalLaporan),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                laporan.deskripsiLaporan,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return Colors.orange;
      case 'on_going':
        return Colors.blue;
      case 'complete':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'on_going':
        return 'Diproses';
      case 'complete':
        return 'Selesai';
      default:
        return status;
    }
  }
}
