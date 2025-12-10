import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:intl/intl.dart';

class SuratModel {
  final String id;
  final String jenisSurat;
  final String tipePermohonan;
  final DateTime tanggajudiajukan;
  final String status; // 'menunggu', 'diproses', 'selesai', 'ditolak'
  final String? keterangan;

  SuratModel({
    required this.id,
    required this.jenisSurat,
    required this.tipePermohonan,
    required this.tanggajudiajukan,
    required this.status,
    this.keterangan,
  });
}

class AjukanSuratView extends StatefulWidget {
  const AjukanSuratView({super.key});

  @override
  State<AjukanSuratView> createState() => _AjukanSuratViewState();
}

class _AjukanSuratViewState extends State<AjukanSuratView> {
  final List<SuratModel> suratList = [
    SuratModel(
      id: '001',
      jenisSurat: 'Surat Domisili',
      tipePermohonan: 'Permohonan Domisili Usaha',
      tanggajudiajukan: DateTime.now().subtract(const Duration(days: 5)),
      status: 'selesai',
      keterangan: 'Persetujuan diberikan',
    ),
    SuratModel(
      id: '002',
      jenisSurat: 'Surat Pengantar',
      tipePermohonan: 'Permohonan Surat Pengantar',
      tanggajudiajukan: DateTime.now().subtract(const Duration(days: 2)),
      status: 'diproses',
      keterangan: 'Sedang diproses oleh admin',
    ),
    SuratModel(
      id: '003',
      jenisSurat: 'Surat Domisili',
      tipePermohonan: 'Permohonan Domisili Pribadi',
      tanggajudiajukan: DateTime.now(),
      status: 'menunggu',
      keterangan: 'Menunggu verifikasi data',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Surat'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suratList.length,
          itemBuilder: (context, index) {
            return _SuratTile(
              surat: suratList[index],
              isDark: isDark,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAjukanSuratDialog(context, isDark),
        label: const Text('Ajukan Surat'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAjukanSuratDialog(BuildContext context, bool isDark) {
    String? selectedSurat = 'Surat Domisili';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajukan Surat Baru'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedSurat,
                items: ['Surat Domisili', 'Surat Pengantar']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedSurat = value),
                isExpanded: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$selectedSurat berhasil diajukan'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Ajukan'),
          ),
        ],
      ),
    );
  }
}

class _SuratTile extends StatelessWidget {
  final SuratModel surat;
  final bool isDark;

  const _SuratTile({required this.surat, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(surat.status);
    final statusIcon = _getStatusIcon(surat.status);
    final statusText = _getStatusText(surat.status);
    final isSelesai = surat.status == 'selesai';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan type surat dan status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description_outlined, color: statusColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surat.jenisSurat,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surat.tipePermohonan,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Divider(color: statusColor.withOpacity(0.2), height: 1),
          const SizedBox(height: 12),
          // Info section
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary(context)),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMM yyyy').format(surat.tanggajudiajukan),
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
              ),
            ],
          ),
          if (surat.keterangan != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    surat.keterangan!,
                    style: TextStyle(
                      fontSize: 13,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (isSelesai) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadSurat(context),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Surat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'diproses':
        return Colors.orange;
      case 'menunggu':
        return Colors.blue;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'selesai':
        return Icons.check_circle_outlined;
      case 'diproses':
        return Icons.schedule_outlined;
      case 'menunggu':
        return Icons.pending_outlined;
      case 'ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Diproses';
      case 'menunggu':
        return 'Menunggu';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Tidak Diketahui';
    }
  }

  void _downloadSurat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📥 Mengunduh ${surat.jenisSurat}...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate download completion
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${surat.jenisSurat} berhasil diunduh'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
