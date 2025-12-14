import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import '../widgets/FamilyMemberCard.dart';

class FamilyDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> familyData;

  const FamilyDetailPage({
    super.key,
    required this.familyData,
  });

  @override
  ConsumerState<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends ConsumerState<FamilyDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch residents for this family
    final familyId = widget.familyData['family_id']?.toString();
    if (familyId != null && familyId.isNotEmpty) {
      Future.microtask(() {
        ref.read(residentListProvider.notifier).fetchResidents(
          familyId: familyId,
        );
      });
    }
  }

  Future<void> _handleRefresh() async {
    final familyId = widget.familyData['family_id']?.toString();
    if (familyId != null && familyId.isNotEmpty) {
      await ref.read(residentListProvider.notifier).fetchResidents(
        familyId: familyId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final residentsAsync = ref.watch(residentListProvider);

    // Calculate member count from residents data
    int memberCount = 0;
    residentsAsync.whenData((residents) {
      memberCount = residents.length;
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        title: Text(
          widget.familyData['family_name'] ?? 'Detail Keluarga',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary(context),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Family Info Card
            _buildFamilyInfoCard(isDark, memberCount),
            
            const SizedBox(height: 24),
            
            // Members Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Anggota Keluarga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$memberCount orang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Residents List
            residentsAsync.when(
              data: (residents) {
                if (residents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textSecondary(context).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada anggota keluarga',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: residents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final resident = residents[index];
                    return FamilyMemberCard(
                      member: resident,
                      isHead: false,
                      onEdit: null,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _handleRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyInfoCard(bool isDark, int memberCount) {
    final familyName = widget.familyData['family_name'] ?? '-';
    final familyId = widget.familyData['family_id']?.toString() ?? '-';
    final headOfFamily = widget.familyData['head_of_family']?.toString();
    final address = widget.familyData['address']?.toString();
    final rtName = widget.familyData['rt_name']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(context),
            AppColors.primary(context).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(context).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keluarga',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AutoSizeText(
                      familyName,
                      maxLines: 2,
                      minFontSize: 16,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Info Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('ID Keluarga', familyId.length > 20 
                    ? '${familyId.substring(0, 20)}...' 
                    : familyId),
                const Divider(color: Colors.white24, height: 24),
                _buildInfoRow('Kepala Keluarga', 
                    headOfFamily?.isEmpty ?? true 
                        ? 'Belum ada kepala keluarga' 
                        : headOfFamily!),
                const Divider(color: Colors.white24, height: 24),
                _buildInfoRow('RT', rtName),
                const Divider(color: Colors.white24, height: 24),
                _buildInfoRow('Alamat', 
                    address?.isEmpty ?? true 
                        ? 'Alamat belum diisi' 
                        : address!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AutoSizeText(
            value,
            maxLines: 3,
            minFontSize: 12,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
