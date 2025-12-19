import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/config_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ti3h_k1_jawara/core/models/kegiatan_model.dart';
import 'package:ti3h_k1_jawara/features/dashboard/provider/activity_provider.dart';
import 'package:intl/intl.dart';

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
    
    // Watch the appropriate provider based on selected type
    final activitiesAsync = selectedType == ActivityType.recommendation
        ? ref.watch(recommendedActivitiesProvider)
        : ref.watch(popularActivitiesProvider);

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
          color: AppColors.softBorder(context),
        ),
        // 3. Activities list
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return _buildEmptyState(context);
            }
            return Column(
              spacing: 0,
              children: activities.map((activity) {
                return _buildActivityTile(
                  context: context,
                  activity: activity,
                );
              }).toList(),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error.toString()),
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
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

  Widget _buildLoadingState() {
    return Column(
      spacing: 15,
      children: List.generate(3, (index) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kegiatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat kegiatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required BuildContext context,
    required KegiatanModel activity,
  }) {
    final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
    
    // Use first preview image if available, otherwise use banner image
    String? imageUrl;
    if (activity.previewImages.isNotEmpty) {
      final imagePath = activity.previewImages[0];
      final normalizedPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
      final encodedPath = Uri.encodeComponent(normalizedPath);
      imageUrl = "$baseUrl/files/$encodedPath";
    } else if (activity.bannerImg != null) {
      final normalizedPath = activity.bannerImg!.startsWith('/') ? activity.bannerImg! : '/${activity.bannerImg}';
      final encodedPath = Uri.encodeComponent(normalizedPath);
      imageUrl = "$baseUrl/files/$encodedPath";
    }

    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final formattedDate = dateFormat.format(activity.startDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _showActivityDetail(context, activity),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image persegi tumpul
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.event_rounded,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.event_rounded,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
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
                    activity.activityName,
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
                            formattedDate,
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
                            _getKategoriText(activity.category),
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
      ),
    );
  }

  String _getKategoriText(String kategori) {
    switch (kategori) {
      case 'sosial':
        return 'Sosial';
      case 'keagamaan':
        return 'Keagamaan';
      case 'olahraga':
        return 'Olahraga';
      case 'pendidikan':
        return 'Pendidikan';
      case 'lainnya':
        return 'Lainnya';
      default:
        return kategori;
    }
  }

  void _showActivityDetail(BuildContext context, KegiatanModel activity) {
    final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
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
                            activity.activityName,
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
                                    activity.status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusText(activity.status),
                                  style: TextStyle(
                                    color: _getStatusColor(activity.status),
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
                                _getKategoriText(activity.category),
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
                          content: activity.description,
                        ),
                        const SizedBox(height: 20),

                        // Date & Time
                        _buildDetailSection(
                          context: context,
                          icon: Icons.access_time_rounded,
                          title: 'Waktu Pelaksanaan',
                          content:
                              '${_formatDateTime(activity.startDate)}${activity.endDate != null ? '\nsampai ${_formatDateTime(activity.endDate!)}' : ''}',
                        ),
                        const SizedBox(height: 20),

                        // Location
                        _buildDetailSection(
                          context: context,
                          icon: Icons.location_on_rounded,
                          title: 'Lokasi',
                          content: activity.location,
                        ),
                        const SizedBox(height: 20),

                        // Organizer
                        _buildDetailSection(
                          context: context,
                          icon: Icons.person_rounded,
                          title: 'Penyelenggara',
                          content: activity.organizer,
                        ),
                        const SizedBox(height: 20),

                        // Preview Images
                        if (activity.previewImages.isNotEmpty)
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
                                  itemCount: activity.previewImages.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final imagePath = activity.previewImages[index];
                                    final normalizedPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
                                    final encodedPath = Uri.encodeComponent(normalizedPath);
                                    final imageUrl = "$baseUrl/files/$encodedPath";
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        width: 160,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 160,
                                            height: 120,
                                            color: Colors.grey.shade300,
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey.shade600,
                                            ),
                                          );
                                        },
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

  String _formatDateTime(DateTime dateTime) {
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
    return '${days[dateTime.weekday % 7]}, ${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
