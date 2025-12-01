import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import 'EmptyStateWidget.dart';
import 'ResidentListCard.dart';
import 'SearchBarWidget.dart';

class ResidentsSection extends ConsumerStatefulWidget {
  const ResidentsSection({super.key});

  @override
  ConsumerState<ResidentsSection> createState() => _ResidentsSectionState();
}

class _ResidentsSectionState extends ConsumerState<ResidentsSection> {
  @override
  void initState() {
    super.initState();
    // Initial fetch
    Future.microtask(() => 
      ref.read(residentListProvider.notifier).fetchResidents()
    );
  }

  @override
  Widget build(BuildContext context) {
    final residentsAsync = ref.watch(residentListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Search Bar
        SearchBarWidget(
          hintText: 'Cari warga berdasarkan nama...',
          onSearch: (query) {
            ref.read(residentListProvider.notifier).searchResidents(query);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Filter Chips
        _buildFilterChips(context),
        
        const SizedBox(height: 16),
        
        // Residents List
        Expanded(
          child: residentsAsync.when(
            data: (residents) {
              if (residents.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.person_search_rounded,
                  title: searchQuery.isEmpty 
                      ? 'Belum Ada Data Warga'
                      : 'Tidak Ditemukan',
                  subtitle: searchQuery.isEmpty
                      ? 'Belum ada warga terdaftar dalam sistem'
                      : 'Tidak ada warga yang sesuai dengan pencarian',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: residents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final resident = residents[index];
                  return ResidentListCard(
                    resident: resident,
                    onTap: () => _showResidentDetail(context, ref, resident),
                  );
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
                    Icons.error_outline_rounded,
                    size: 60,
                    color: AppColors.redAccentLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal Memuat Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(residentListProvider.notifier).fetchResidents(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final selectedFilter = ref.watch(filterStatusProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'Semua',
            isSelected: selectedFilter.isEmpty,
            onTap: () {
              ref.read(filterStatusProvider.notifier).state = '';
              ref.read(residentListProvider.notifier).fetchResidents();
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Disetujui',
            isSelected: selectedFilter == 'approved',
            color: const Color(0xFF4CAF50),
            onTap: () {
              ref.read(filterStatusProvider.notifier).state = 'approved';
              ref.read(residentListProvider.notifier).filterByStatus('approved');
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Pending',
            isSelected: selectedFilter == 'pending',
            color: const Color(0xFFFF9800),
            onTap: () {
              ref.read(filterStatusProvider.notifier).state = 'pending';
              ref.read(residentListProvider.notifier).filterByStatus('pending');
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Ditolak',
            isSelected: selectedFilter == 'rejected',
            color: AppColors.redAccentLight,
            onTap: () {
              ref.read(filterStatusProvider.notifier).state = 'rejected';
              ref.read(residentListProvider.notifier).filterByStatus('rejected');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? chipColor 
              : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor.withOpacity(isSelected ? 1 : 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : chipColor,
          ),
        ),
      ),
    );
  }

  void _showResidentDetail(BuildContext context, WidgetRef ref, Map<String, dynamic> resident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResidentDetailSheet(resident: resident),
    );
  }
}

class ResidentDetailSheet extends ConsumerWidget {
  final Map<String, dynamic> resident;

  const ResidentDetailSheet({super.key, required this.resident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.softBorder(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Warga',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildDetailSection(
                      context,
                      title: 'Informasi Pribadi',
                      items: [
                        _DetailItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Nama',
                          value: resident['name'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.badge_outlined,
                          label: 'NIK',
                          value: resident['nik'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.wc_rounded,
                          label: 'Jenis Kelamin',
                          value: resident['gender'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.cake_outlined,
                          label: 'Tanggal Lahir',
                          value: resident['date_of_birth'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.location_on_outlined,
                          label: 'Tempat Lahir',
                          value: resident['place_of_birth'] ?? '-',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildDetailSection(
                      context,
                      title: 'Informasi Keluarga',
                      items: [
                        _DetailItem(
                          icon: Icons.home_outlined,
                          label: 'Nama Keluarga',
                          value: resident['family_name'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.work_outline_rounded,
                          label: 'Pekerjaan',
                          value: resident['occupation'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.phone_outlined,
                          label: 'No. Telepon',
                          value: resident['phone'] ?? '-',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildStatusCard(context, resident['status'] ?? 'pending'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required List<_DetailItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildDetailItem(context, item)),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, _DetailItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 20,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Disetujui';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
        statusColor = const Color(0xFFFF9800);
        statusText = 'Menunggu Persetujuan';
        statusIcon = Icons.pending_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.redAccentLight;
        statusText = 'Ditolak';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.textSecondary(context);
        statusText = status;
        statusIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
