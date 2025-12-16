import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../report/models/report_model.dart';
import '../../report/provider/report_provider.dart';

class ReportListTab extends ConsumerWidget {
  const ReportListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterParams = ReportFilterParams(limit: 100);
    final reportsAsync = ref.watch(reportListProvider(filterParams));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportListProvider);
      },
      child: reportsAsync.when(
        data: (response) {
          if (response.data.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final report = response.data[index];
              return _ReportCard(report: report, isDark: isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Gagal memuat laporan'),
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(reportListProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada laporan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Laporan yang Anda buat akan muncul di sini', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final bool isDark;

  const _ReportCard({required this.report, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/report-detail/${report.reportId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _getCategoryColor(report.category).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getCategoryIcon(report.category), size: 16, color: _getCategoryColor(report.category)),
                        const SizedBox(width: 6),
                        Text(report.category.displayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getCategoryColor(report.category))),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(report.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(report.reportName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(report.description, style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (report.evidence.isNotEmpty) ...[
                    Icon(Icons.photo_library, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${report.evidence.length} foto', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(_formatDate(report.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    switch (status) {
      case ReportStatus.unsolved:
        color = Colors.red;
        break;
      case ReportStatus.inprogress:
        color = Colors.orange;
        break;
      case ReportStatus.solved:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status.displayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes} menit lalu';
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
