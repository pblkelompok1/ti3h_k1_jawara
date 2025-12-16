import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../report/models/report_model.dart';
import '../../report/provider/report_provider.dart';
import '../../../core/services/report_service.dart';

class AdminReportDetail extends ConsumerWidget {
  final String reportId;

  const AdminReportDetail({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildCategoryChip(report.category),
                  const Spacer(),
                  _buildStatusChip(report.status),
                ],
              ),

              const SizedBox(height: 24),

              Text(report.reportName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              
              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
                    const SizedBox(height: 12),
                    Text(report.description, style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context), height: 1.5)),
                  ],
                ),
              ),

              if (report.contactPerson != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.contact_phone, color: AppColors.orange(context), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kontak Person', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(report.contactPerson!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (report.evidence.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Bukti Foto (${report.evidence.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.evidence.length,
                    itemBuilder: (context, index) {
                      final imageUrl = ref.read(reportServiceProvider).getEvidenceUrl(report.evidence[index]);
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[300]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Timestamps
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('Dibuat:', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        const Spacer(),
                        Text(_formatDateTime(report.createdAt), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.update, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('Diperbarui:', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        const Spacer(),
                        Text(_formatDateTime(report.updatedAt), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Update Buttons
              Text('Ubah Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              const SizedBox(height: 12),

              Row(
                children: [
                  if (report.status != ReportStatus.inprogress)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(context, ref, reportId, ReportStatus.inprogress),
                        icon: const Icon(Icons.pending),
                        label: const Text('Sedang Ditangani'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  if (report.status != ReportStatus.inprogress && report.status != ReportStatus.solved) const SizedBox(width: 12),
                  if (report.status != ReportStatus.solved)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(context, ref, reportId, ReportStatus.solved),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Tandai Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),

              if (report.status == ReportStatus.solved) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(context, ref, reportId, ReportStatus.unsolved),
                    icon: const Icon(Icons.undo),
                    label: const Text('Buka Kembali'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Gagal memuat detail laporan'),
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.invalidate(reportDetailProvider(reportId)), child: const Text('Coba Lagi')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ReportCategory category) {
    final color = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(category), size: 20, color: color),
          const SizedBox(width: 8),
          Text(category.displayName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(status.displayName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _getCategoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.keamanan:
        return Colors.red;
      case ReportCategory.kebersihan:
        return Colors.green;
      case ReportCategory.infrastruktur:
        return Colors.blue;
      case ReportCategory.sosial:
        return Colors.purple;
      case ReportCategory.lainnya:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.keamanan:
        return Icons.security;
      case ReportCategory.kebersihan:
        return Icons.cleaning_services;
      case ReportCategory.infrastruktur:
        return Icons.construction;
      case ReportCategory.sosial:
        return Icons.groups;
      case ReportCategory.lainnya:
        return Icons.more_horiz;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.unsolved:
        return Colors.red;
      case ReportStatus.inprogress:
        return Colors.orange;
      case ReportStatus.solved:
        return Colors.green;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String reportId, ReportStatus newStatus) async {
    try {
      await ref.read(reportActionsProvider.notifier).updateStatus(reportId, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diubah menjadi: ${newStatus.displayName}'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(reportActionsProvider.notifier).deleteReport(reportId);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil dihapus'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
