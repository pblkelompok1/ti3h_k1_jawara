import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import 'EmptyStateWidget.dart';
import 'FamilyListCard.dart';
import 'SearchBarWidget.dart';

class FamiliesSection extends ConsumerStatefulWidget {
  const FamiliesSection({super.key});

  @override
  ConsumerState<FamiliesSection> createState() => _FamiliesSectionState();
}

class _FamiliesSectionState extends ConsumerState<FamiliesSection> {
  List<Map<String, dynamic>> _allFamilies = [];
  List<Map<String, dynamic>> _filteredFamilies = [];
  
  @override
  void initState() {
    super.initState();
    // Load initial dummy data
    Future.microtask(() {
      _allFamilies = ref.read(dummyFamiliesProvider);
      _filteredFamilies = _allFamilies;
      setState(() {});
    });
  }

  void _filterFamilies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFamilies = _allFamilies;
      });
    } else {
      setState(() {
        _filteredFamilies = _allFamilies.where((f) {
          final name = (f['family_name'] ?? '').toString().toLowerCase();
          final head = (f['head_name'] ?? '').toString().toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || head.contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final families = _filteredFamilies;

    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Search Bar
        SearchBarWidget(
          hintText: 'Cari keluarga...',
          onSearch: _filterFamilies,
        ),
        
        const SizedBox(height: 16),
        
        // Families List
        Expanded(
          child: families.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.home_work_rounded,
                  title: 'Tidak Ditemukan',
                  subtitle: 'Tidak ada keluarga yang sesuai dengan pencarian',
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: families.length,
                  itemBuilder: (context, index) {
                    final family = families[index];
                    return FamilyListCard(
                      family: family,
                      onTap: () => _showFamilyDetail(context, ref, family),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showFamilyDetail(BuildContext context, WidgetRef ref, Map<String, dynamic> family) {
    final familyId = family['family_id'] ?? '';
    // Fetch detail before showing
    ref.read(familyDetailProvider.notifier).fetchFamilyDetail(familyId);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FamilyDetailSheet(family: family),
    );
  }
}

class FamilyDetailSheet extends ConsumerWidget {
  final Map<String, dynamic> family;

  const FamilyDetailSheet({super.key, required this.family});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final familyId = family['family_id'] ?? family['id'] ?? '';
    final familyName = family['family_name'] ?? family['name'] ?? '-';
    
    // Watch family detail
    final familyDetailAsync = ref.watch(familyDetailProvider);

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
                        'Detail Keluarga',
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
                child: familyDetailAsync.when(
                  data: (detail) {
                    final members = List<Map<String, dynamic>>.from(detail['members'] ?? []);
                    final memberCount = detail['member_count'] ?? members.length;
                    final activeCount = members.where((m) => m['status'] == 'approved').length;
                    final address = detail['address'] ?? '-';
                    
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Family Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary(context).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary(context).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_rounded,
                                size: 48,
                                color: AppColors.primary(context),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                familyName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID: $familyId',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                              if (address != '-') ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.textSecondary(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        address,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.people_rounded,
                                label: 'Anggota',
                                value: '$memberCount',
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.check_circle_rounded,
                                label: 'Aktif',
                                value: '$activeCount',
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Members Section
                        Text(
                          'Daftar Anggota',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Display actual members
                        if (members.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'Belum ada anggota',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          )
                        else
                          ...members.map((member) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildMemberTile(
                              context,
                              name: member['name'] ?? '-',
                              role: member['role'] ?? '-',
                              occupation: member['occupation'] ?? '-',
                            ),
                          )),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Gagal memuat detail',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context, {
    required String name,
    required String role,
    required String occupation,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.softBorder(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primary(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$role • $occupation',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
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
