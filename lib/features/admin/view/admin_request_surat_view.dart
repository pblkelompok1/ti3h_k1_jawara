import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/models/surat_model.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class AdminRequestSuratView extends StatefulWidget {
  const AdminRequestSuratView({super.key});

  @override
  State<AdminRequestSuratView> createState() => _AdminRequestSuratViewState();
}

class _AdminRequestSuratViewState extends State<AdminRequestSuratView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<SuratModel> _requests = [
    SuratModel(
      id: 'RS-001',
      jenisSurat: 'Surat Domisili',
      tipePermohonan: 'Domisili Pribadi',
      tanggajudiajukan: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'menunggu',
      keterangan: 'Perlu verifikasi KK',
    ),
    SuratModel(
      id: 'RS-002',
      jenisSurat: 'Surat Pengantar',
      tipePermohonan: 'Pengantar RT ke Kelurahan',
      tanggajudiajukan: DateTime.now().subtract(const Duration(days: 1)),
      status: 'diproses',
      keterangan: 'Draft sedang dibuat',
    ),
    SuratModel(
      id: 'RS-003',
      jenisSurat: 'Surat Domisili',
      tipePermohonan: 'Domisili Usaha',
      tanggajudiajukan: DateTime.now().subtract(const Duration(days: 2)),
      status: 'selesai',
      keterangan: 'Siap diunduh oleh warga',
    ),
  ];

  List<SuratModel> get _waiting =>
      _requests.where((e) => e.status == 'menunggu').toList();
  List<SuratModel> get _ongoing =>
      _requests.where((e) => e.status == 'diproses').toList();
  List<SuratModel> get _complete =>
      _requests.where((e) => e.status == 'selesai').toList();

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
        title: const Text('Request Surat'),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.schedule), text: 'Menunggu'),
            Tab(icon: Icon(Icons.pending_actions), text: 'Diproses'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(context, _waiting),
          _buildList(context, _ongoing),
          _buildList(context, _complete),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<SuratModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline,
                size: 80, color: AppColors.textSecondary(context).withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('Belum ada request',
                style: TextStyle(color: AppColors.textSecondary(context))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _RequestCard(
          surat: items[index],
          onTap: () => _showDetailDialog(items[index]),
          onApprove: () => _updateStatus(items[index], 'diproses'),
          onComplete: () => _updateStatus(items[index], 'selesai'),
          onReject: () => _reject(items[index]),
        );
      },
    );
  }

  void _updateStatus(SuratModel s, String status) {
    setState(() {
      final i = _requests.indexWhere((e) => e.id == s.id);
      if (i != -1) {
        _requests[i] = SuratModel(
          id: s.id,
          jenisSurat: s.jenisSurat,
          tipePermohonan: s.tipePermohonan,
          tanggajudiajukan: s.tanggajudiajukan,
          status: status,
          keterangan: status == 'diproses'
              ? 'Sedang diproses admin'
              : status == 'selesai'
                  ? 'Siap diunduh warga'
                  : s.keterangan,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status diperbarui ke ${_statusText(status)}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _reject(SuratModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Permohonan'),
        content: const Text('Yakin ingin menolak permohonan surat ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              _updateStatus(s, 'ditolak');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(SuratModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          s.jenisSurat,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Tipe Permohonan', s.tipePermohonan),
            const SizedBox(height: 6),
            _row('Tanggal Diajukan', DateFormat('dd MMM yyyy, HH:mm').format(s.tanggajudiajukan)),
            const SizedBox(height: 6),
            _row('Status', _statusText(s.status)),
            if (s.keterangan != null) ...[
              const SizedBox(height: 6),
              _row('Keterangan', s.keterangan!),
            ],
          ],
        ),
        actions: [
          if (s.status == 'menunggu')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _updateStatus(s, 'diproses');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Proses'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          if (s.status == 'diproses')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _updateStatus(s, 'selesai');
              },
              icon: const Icon(Icons.check),
              label: const Text('Selesaikan'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  String _statusText(String s) {
    switch (s) {
      case 'menunggu':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return s;
    }
  }
}

class _RequestCard extends StatelessWidget {
  final SuratModel surat;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onComplete;
  final VoidCallback onReject;

  const _RequestCard({
    required this.surat,
    required this.onTap,
    required this.onApprove,
    required this.onComplete,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(surat.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface(context),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.description_outlined, color: statusColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(surat.jenisSurat,
                            style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(surat.tipePermohonan,
                            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText(surat.status),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(DateFormat('dd MMM yyyy').format(surat.tanggajudiajukan),
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.edit, size: 18, color: Colors.orange),
                      label: const Text('Proses'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check, size: 18, color: Colors.green),
                      label: const Text('Selesai'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Tolak',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'menunggu':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String s) {
    switch (s) {
      case 'menunggu':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return s;
    }
  }
}
