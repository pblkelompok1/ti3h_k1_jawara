import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

// 1. Provider untuk toggle antara recommendation dan popular
final activityTypeProvider = StateProvider<ActivityType>(
  (ref) => ActivityType.recommendation,
);

enum ActivityType { recommendation, popular }

class RecommendedActivityList extends ConsumerWidget {
  const RecommendedActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(activityTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        // 2. Title selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kegiatan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            _buildSubTitleSelector(context, ref, selectedType),
          ],
        ),
        // Garis full width
        Container(
          width: double.infinity,
          height: 1.2,
          color: AppColors.softBorder(context), // atau Colors.grey.shade300
        ),
        // 3. Placeholder container untuk list view
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://images.unsplash.com/photo-1617127365659-c47fa864d8bc",
          title: 'Kegiatan Gotong Royong',
          date: '16 Desember 2025',
          category: 'Sosial',
          activityData: {
            'activity_id': '123e4567-e89b-12d3-a456-426614174000',
            'activity_name': 'Kegiatan Gotong Royong',
            'description':
                'Kegiatan gotong royong membersihkan lingkungan RT untuk menyambut tahun baru. Semua warga diharapkan hadir dan membawa peralatan kebersihan masing-masing.',
            'start_date': '2025-12-16 08:00:00',
            'end_date': '2025-12-16 12:00:00',
            'location': 'Balai RT 001/RW 005',
            'organizer': 'Ketua RT 001',
            'status': 'akan_datang',
            'preview_images': [
              'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc',
              'https://images.unsplash.com/photo-1559027615-cd4628902d4a',
            ],
            'category': 'Sosial',
          },
        ),
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://images.unsplash.com/photo-1617127365659-c47fa864d8bc",
          title: 'Isra Miraj',
          date: '30 Desember 2025',
          category: 'Keagamaan',
          activityData: {
            'activity_id': '223e4567-e89b-12d3-a456-426614174001',
            'activity_name': 'Peringatan Isra Miraj',
            'description':
                'Peringatan Isra Miraj Nabi Muhammad SAW dengan pengajian dan ceramah dari Ustadz Ahmad. Acara dimulai setelah sholat Maghrib.',
            'start_date': '2025-12-30 18:30:00',
            'end_date': '2025-12-30 21:00:00',
            'location': 'Masjid Al-Ikhlas RT 001',
            'organizer': 'Takmir Masjid',
            'status': 'akan_datang',
            'preview_images': [
              'https://images.unsplash.com/photo-1584286595398-a59f21d092f0',
            ],
            'category': 'Keagamaan',
          },
        ),
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://images.unsplash.com/photo-1617127365659-c47fa864d8bc",
          title: 'Maulid Nabi 2025',
          date: '30 Januari 2026',
          category: 'Keagamaan',
          activityData: {
            'activity_id': '323e4567-e89b-12d3-a456-426614174002',
            'activity_name': 'Maulid Nabi Muhammad SAW 2025',
            'description':
                'Perayaan Maulid Nabi Muhammad SAW dengan pembacaan sholawat, dzikir bersama, dan santunan anak yatim.',
            'start_date': '2026-01-30 19:00:00',
            'end_date': '2026-01-30 22:00:00',
            'location': 'Masjid Al-Ikhlas RT 001',
            'organizer': 'Panitia Maulid Nabi RT 001',
            'status': 'akan_datang',
            'preview_images': [
              'https://images.unsplash.com/photo-1591604466107-ec97de577aff',
              'https://images.unsplash.com/photo-1584286595398-a59f21d092f0',
              'https://images.unsplash.com/photo-1559027615-cd4628902d4a',
            ],
            'category': 'Keagamaan',
          },
        ),
        _buildActivityTile(
          context: context,
          imageUrl:
              "https://images.unsplash.com/photo-1617127365659-c47fa864d8bc",
          title: 'Syukuran Ramadhan',
          date: '30 Desember 2025',
          category: 'Keagamaan',
          activityData: {
            'activity_id': '423e4567-e89b-12d3-a456-426614174003',
            'activity_name': 'Syukuran Menyambut Ramadhan',
            'description':
                'Acara syukuran menyambut bulan suci Ramadhan dengan doa bersama dan pembagian takjil untuk warga.',
            'start_date': '2025-12-30 16:00:00',
            'end_date': '2025-12-30 18:00:00',
            'location': 'Balai RT 001/RW 005',
            'organizer': 'Pengurus RT 001',
            'status': 'akan_datang',
            'preview_images': [
              'https://images.unsplash.com/photo-1591604466107-ec97de577aff',
            ],
            'category': 'Keagamaan',
          },
        ),
      ],
    );
  }

  Widget _buildSubTitleSelector(
    BuildContext context,
    WidgetRef ref,
    ActivityType selectedType,
  ) {
    return Row(
      children: [
        _buildTitle(
          context,
          ref,
          "Terbaru",
          ActivityType.recommendation,
          selectedType,
        ),
        const SizedBox(width: 24),
        _buildTitle(
          context,
          ref,
          "Populer",
          ActivityType.popular,
          selectedType,
        ),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    WidgetRef ref,
    String title,
    ActivityType type,
    ActivityType selectedType,
  ) {
    final isActive = type == selectedType;

    // Hitung lebar teks
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;

    return GestureDetector(
      onTap: () {
        ref.read(activityTypeProvider.notifier).state = type;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppColors.textSecondaryDark,
            ),
            width: isActive ? textWidth : 0, // Lebar dinamis sesuai teks
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required BuildContext context,
    required String imageUrl,
    required String title,
    required String date,
    required String category,
    required Map<String, dynamic> activityData,
  }) {
    return InkWell(
      onTap: () => _showActivityDetail(context, activityData),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image persegi tumpul
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          // Column info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Judul
                AutoSizeText(
                  title,
                  maxLines: 2,
                  minFontSize: 15,
                  maxFontSize: 24,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                // Row tanggal & category
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        AutoSizeText(
                          date,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        AutoSizeText(
                          category,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Title
                        Center(
                          child: Text(
                            data['activity_name'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Category
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    data['status'],
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusText(data['status']),
                                  style: TextStyle(
                                    color: _getStatusColor(data['status']),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 24),

                              Icon(
                                Icons.category_rounded,
                                size: 16,
                                color: AppColors.primary(context),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                data['category'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Description
                        _buildDetailSection(
                          context: context,
                          icon: Icons.description_rounded,
                          title: 'Deskripsi',
                          content: data['description'] ?? '-',
                        ),
                        const SizedBox(height: 20),

                        // Date & Time
                        _buildDetailSection(
                          context: context,
                          icon: Icons.access_time_rounded,
                          title: 'Waktu Pelaksanaan',
                          content:
                              '${_formatDateTime(data['start_date'])}${data['end_date'] != null ? '\nsampai ${_formatDateTime(data['end_date'])}' : ''}',
                        ),
                        const SizedBox(height: 20),

                        // Location
                        _buildDetailSection(
                          context: context,
                          icon: Icons.location_on_rounded,
                          title: 'Lokasi',
                          content: data['location'] ?? '-',
                        ),
                        const SizedBox(height: 20),

                        // Organizer
                        _buildDetailSection(
                          context: context,
                          icon: Icons.person_rounded,
                          title: 'Penyelenggara',
                          content: data['organizer'] ?? '-',
                        ),
                        const SizedBox(height: 20),

                        // Preview Images
                        if (data['preview_images'] != null &&
                            (data['preview_images'] as List).isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foto Kegiatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      (data['preview_images'] as List).length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        data['preview_images'][index],
                                        width: 160,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary(context)),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary(context).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary(context).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary(context),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '-';
    try {
      final dt = DateTime.parse(dateTime);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Oct',
        'Nov',
        'Des',
      ];
      final days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];
      return '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month - 1]} ${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'akan_datang':
        return Colors.blue;
      case 'berlangsung':
        return Colors.green;
      case 'selesai':
        return Colors.grey;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'akan_datang':
        return 'Akan Datang';
      case 'berlangsung':
        return 'Sedang Berlangsung';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
