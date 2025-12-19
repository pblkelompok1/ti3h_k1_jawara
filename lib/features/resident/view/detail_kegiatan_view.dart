import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/models/kegiatan_model.dart';
import 'package:ti3h_k1_jawara/core/provider/config_provider.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/dashboard/provider/activity_provider.dart';

class DetailKegiatanView extends ConsumerStatefulWidget {
  const DetailKegiatanView({super.key});

  @override
  ConsumerState<DetailKegiatanView> createState() => _DetailKegiatanViewState();
}

class _DetailKegiatanViewState extends ConsumerState<DetailKegiatanView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollControllerAkanDatang = ScrollController();
  final ScrollController _scrollControllerOngoing = ScrollController();
  final ScrollController _scrollControllerSelesai = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(akanDatangActivitiesProvider.notifier).loadActivities();
      ref.read(ongoingActivitiesProvider.notifier).loadActivities();
      ref.read(selesaiActivitiesProvider.notifier).loadActivities();
    });

    // Setup scroll listeners for infinite scroll
    _scrollControllerAkanDatang.addListener(() {
      if (_scrollControllerAkanDatang.position.pixels >=
          _scrollControllerAkanDatang.position.maxScrollExtent * 0.8) {
        ref.read(akanDatangActivitiesProvider.notifier).loadActivities();
      }
    });

    _scrollControllerOngoing.addListener(() {
      if (_scrollControllerOngoing.position.pixels >=
          _scrollControllerOngoing.position.maxScrollExtent * 0.8) {
        ref.read(ongoingActivitiesProvider.notifier).loadActivities();
      }
    });

    _scrollControllerSelesai.addListener(() {
      if (_scrollControllerSelesai.position.pixels >=
          _scrollControllerSelesai.position.maxScrollExtent * 0.8) {
        ref.read(selesaiActivitiesProvider.notifier).loadActivities();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllerAkanDatang.dispose();
    _scrollControllerOngoing.dispose();
    _scrollControllerSelesai.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text(
          'Detail Kegiatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            isScrollable: false,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Akan Datang',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Ongoing',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Selesai',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityListView(
            akanDatangActivitiesProvider,
            _scrollControllerAkanDatang,
            'akan_datang',
          ),
          _buildActivityListView(
            ongoingActivitiesProvider,
            _scrollControllerOngoing,
            'ongoing',
          ),
          _buildActivityListView(
            selesaiActivitiesProvider,
            _scrollControllerSelesai,
            'selesai',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityListView(
    StateNotifierProvider<ActivityNotifier, ActivityState> provider,
    ScrollController scrollController,
    String status,
  ) {
    final state = ref.watch(provider);

    if (state.activities.isEmpty && state.isLoading) {
      return _buildLoadingSkeleton();
    }

    if (state.activities.isEmpty && state.error != null) {
      return _buildErrorState(state.error!, provider);
    }

    if (state.activities.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(provider.notifier).refresh();
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.activities.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.activities.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _KegiatanCard(
            kegiatan: state.activities[index],
            onTap: () => _showActivityDetail(state.activities[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String message;
    IconData icon;

    switch (status) {
      case 'akan_datang':
        message = 'Belum ada kegiatan yang akan datang';
        icon = Icons.event_available;
        break;
      case 'ongoing':
        message = 'Tidak ada kegiatan yang sedang berlangsung';
        icon = Icons.event_busy;
        break;
      case 'selesai':
        message = 'Belum ada kegiatan yang selesai';
        icon = Icons.event_note;
        break;
      default:
        message = 'Tidak ada kegiatan';
        icon = Icons.event;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String error,
    StateNotifierProvider<ActivityNotifier, ActivityState> provider,
  ) {
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(provider.notifier).refresh();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(KegiatanModel activity) {
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

                        // Category & Status
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
                                  color: _getStatusColor(activity.status)
                                      .withOpacity(0.2),
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
      case 'ongoing':
        return Colors.green;
      case 'selesai':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'akan_datang':
        return 'Akan Datang';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
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
}

class _KegiatanCard extends StatelessWidget {
  final KegiatanModel kegiatan;
  final VoidCallback onTap;

  const _KegiatanCard({required this.kegiatan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseUrl = "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final imageSize = (screenWidth * 0.2).clamp(70.0, 90.0);
    final titleFontSize = (screenWidth * 0.042).clamp(14.0, 16.0);
    final detailFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    
    String? imageUrl;
    if (kegiatan.bannerImg != null) {
      final normalizedPath = kegiatan.bannerImg!.startsWith('/') ? kegiatan.bannerImg! : '/${kegiatan.bannerImg}';
      final encodedPath = Uri.encodeComponent(normalizedPath);
      imageUrl = "$baseUrl/files/$encodedPath";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image or Category Icon
              imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _getCategoryIcon(kegiatan.category, imageSize);
                        },
                      ),
                    )
                  : _getCategoryIcon(kegiatan.category, imageSize),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      kegiatan.activityName,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            DateFormat('dd MMM yyyy', 'id_ID')
                                .format(kegiatan.startDate),
                            style: TextStyle(
                              fontSize: detailFontSize,
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            kegiatan.location,
                            style: TextStyle(
                              fontSize: detailFontSize,
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status Badge
                    _buildStatusBadge(kegiatan.status, isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDarkMode) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'akan_datang':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        text = 'Akan Datang';
        icon = Icons.schedule_rounded;
        break;
      case 'ongoing':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        text = 'Berlangsung';
        icon = Icons.play_circle_filled_rounded;
        break;
      case 'selesai':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        text = 'Selesai';
        icon = Icons.check_circle_rounded;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        text = status;
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String kategori, double size) {
    IconData icon;
    Color color;

    switch (kategori) {
      case 'sosial':
        icon = Icons.people_rounded;
        color = Colors.blue;
        break;
      case 'keagamaan':
        icon = Icons.mosque_rounded;
        color = Colors.green;
        break;
      case 'olahraga':
        icon = Icons.sports_soccer_rounded;
        color = Colors.orange;
        break;
      case 'pendidikan':
        icon = Icons.school_rounded;
        color = Colors.purple;
        break;
      case 'lainnya':
        icon = Icons.event_rounded;
        color = Colors.grey;
        break;
      default:
        icon = Icons.event_rounded;
        color = Colors.grey;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(icon, color: color, size: size * 0.4),
    );
  }
}
