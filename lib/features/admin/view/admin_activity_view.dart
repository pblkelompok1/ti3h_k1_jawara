import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/admin/model/activity_model.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/activity_provider.dart';

class AdminActivityView extends ConsumerStatefulWidget {
  const AdminActivityView({super.key});

  @override
  ConsumerState<AdminActivityView> createState() => _AdminActivityViewState();
}

class _AdminActivityViewState extends ConsumerState<AdminActivityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Filter by tab - sesuai dengan response dari backend
      final statuses = ['', 'Akan Datang', 'Ongoing', 'Selesai'];
      final status = statuses[_tabController.index];
      
      // DEBUG: Print tab change
      print('📑 [AdminActivityView] Tab changed to index: ${_tabController.index}');
      print('   - Status value: "$status"');
      print('   - Selected status: "${status.isEmpty ? null : status}"');
      
      setState(() {
        _selectedStatus = status.isEmpty ? null : status;
      });
      ref.read(activityListProvider.notifier).filterByStatus(_selectedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activitiesAsync = ref.watch(activityListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary(context),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Kelola Kegiatan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary(context),
                        AppColors.primary(context).withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary(context),
                    unselectedLabelColor: AppColors.textSecondary(context),
                    indicatorColor: AppColors.primary(context),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Akan Datang'),
                      Tab(text: 'Berlangsung'),
                      Tab(text: 'Selesai'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Search Bar
            Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari kegiatan...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary(context),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(activityListProvider.notifier)
                                      .filterByName(null);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.backgroundDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        // Debounce search
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchController.text == value) {
                            ref
                                .read(activityListProvider.notifier)
                                .filterByName(value.isEmpty ? null : value);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary(context),
                          AppColors.primary(context).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/admin/activities/create'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Activities List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(activityListProvider.notifier).refresh();
                },
                child: activitiesAsync.when(
                  data: (response) {
                    if (response.data.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: response.data.length,
                      itemBuilder: (context, index) {
                        final activity = response.data[index];
                        return _buildActivityCard(context, activity);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(activityListProvider.notifier).refresh();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: AppColors.textSecondary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada kegiatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah kegiatan baru',
            style: TextStyle(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color statusColor;
    IconData statusIcon;
    
    // Backend mengirim status dalam format Title Case dengan spasi
    switch (activity.status) {
      case 'Akan Datang':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'Ongoing':
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle_rounded;
        break;
      case 'Selesai':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 4 : 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push(
          '/admin/activities/${activity.activityId}',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.activityName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.displayStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (activity.description != null &&
                  activity.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  activity.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Info Details
              _buildInfoRow(
                context,
                Icons.calendar_today_rounded,
                _formatDateRange(activity),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.location_on_rounded,
                activity.location,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.person_rounded,
                activity.organizer,
              ),

              if (activity.category != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push(
                      '/admin/activities/${activity.activityId}/edit',
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, activity),
                    icon: const Icon(Icons.delete_rounded, size: 18),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateRange(ActivityModel activity) {
    final startFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final start = startFormat.format(activity.startDate);

    if (activity.endDate == null) {
      return start;
    }

    final end = startFormat.format(activity.endDate!);
    return '$start - $end';
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    ActivityModel activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kegiatan "${activity.activityName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(deleteActivityProvider)
            .call(activity.activityId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kegiatan berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus kegiatan: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
