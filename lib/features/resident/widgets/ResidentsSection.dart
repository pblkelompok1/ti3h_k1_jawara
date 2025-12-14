import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/document_button.dart';
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
                          value: resident['occupation_name'] ?? 'Tidak diketahui',
                        ),
                        _DetailItem(
                          icon: Icons.phone_outlined,
                          label: 'No. Telepon',
                          value: resident['phone'] ?? '-',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildDocumentSection(context, resident),

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

  Widget _buildDocumentSection(BuildContext context, Map<String, dynamic> resident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dokumen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        DocumentButton(
          documentPath: resident['ktp_path']?.toString(),
          documentName: 'KTP',
          icon: Icons.credit_card,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 8),
        DocumentButton(
          documentPath: resident['kk_path']?.toString(),
          documentName: 'Kartu Keluarga',
          icon: Icons.people,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 8),
        DocumentButton(
          documentPath: resident['birth_certificate_path']?.toString(),
          documentName: 'Akta Kelahiran',
          icon: Icons.description,
          color: const Color(0xFFFF9800),
        ),
      ],
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
