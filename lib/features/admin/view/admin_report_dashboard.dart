import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../report/models/report_model.dart';
import '../../report/provider/report_provider.dart';

class AdminReportDashboard extends ConsumerStatefulWidget {
  const AdminReportDashboard({super.key});

  @override
  ConsumerState<AdminReportDashboard> createState() => _AdminReportDashboardState();
}

class _AdminReportDashboardState extends ConsumerState<AdminReportDashboard> {
  String? _selectedCategory;
  String? _selectedStatus;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(adminReportStatsProvider);
    
    final filterNotifier = ref.watch(reportFilterProvider.notifier);
    final filterParams = ref.watch(reportFilterProvider);
    final reportsAsync = ref.watch(reportListProvider(filterParams));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manajemen Laporan'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminReportStatsProvider);
          ref.invalidate(reportListProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Total', value: stats.total.toString(), color: Colors.blue, icon: Icons.summarize)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Belum Ditangani', value: stats.unsolved.toString(), color: Colors.red, icon: Icons.report_problem)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Sedang Ditangani', value: stats.inProgress.toString(), color: Colors.orange, icon: Icons.pending)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Selesai', value: stats.solved.toString(), color: Colors.green, icon: Icons.check_circle)),
                      ],
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),

              const SizedBox(height: 24),

              // Filters
              Text('Filter & Pencarian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              const SizedBox(height: 12),

              // Category Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('Semua Kategori'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                      ...ReportCategory.values.map((c) => DropdownMenuItem(value: c.name, child: Text(c.displayName))),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      filterNotifier.setCategory(value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Status Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    hint: const Text('Semua Status'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Status')),
                      ...ReportStatus.values.map((s) => DropdownMenuItem(value: s.name, child: Text(s.displayName))),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                      filterNotifier.setStatus(value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari laporan...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            filterNotifier.setSearch(null);
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  filterNotifier.setSearch(value.isEmpty ? null : value);
                },
              ),

              const SizedBox(height: 24),

              // Reports List
              Text('Daftar Laporan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              const SizedBox(height: 12),

              reportsAsync.when(
                data: (response) {
                  if (response.data.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Tidak ada laporan', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: response.data.map((report) => _AdminReportCard(report: report, isDark: isDark)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $e'),
                      ElevatedButton(onPressed: () => ref.invalidate(reportListProvider), child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }
}

class _AdminReportCard extends ConsumerWidget {
  final ReportModel report;
  final bool isDark;

  const _AdminReportCard({required this.report, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/admin/report-detail/${report.reportId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCategoryChip(report.category),
                  const Spacer(),
                  _buildStatusChip(report.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(report.reportName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
              const SizedBox(height: 8),
              Text(report.description, style: TextStyle(fontSize: 14, color: Colors.grey[600]), maxLines: 2),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(_formatDate(report.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const Spacer(),
                  // Quick Actions
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.blue,
                    onPressed: () => context.push('/admin/report-detail/${report.reportId}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: () => _confirmDelete(context, ref, report.reportId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ReportCategory category) {
    final color = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(category.displayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil dihapus'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}
