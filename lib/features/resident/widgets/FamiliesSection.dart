import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import '../view/family_detail_page.dart';
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
    // Fetch families from API
    Future.microtask(() {
      ref.read(familyListProvider.notifier).fetchFamilies();
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
          final head = (f['head_of_family'] ?? '').toString().toLowerCase();
          final address = (f['address'] ?? '').toString().toLowerCase();
          final rtName = (f['rt_name'] ?? '').toString().toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || head.contains(q) || address.contains(q) || rtName.contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyListAsync = ref.watch(familyListProvider);

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
          child: familyListAsync.when(
            data: (families) {
              // Update state for filtering
              if (_allFamilies.isEmpty || _allFamilies.length != families.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _allFamilies = families;
                    _filteredFamilies = families;
                  });
                });
              }
              
              final displayFamilies = _filteredFamilies.isEmpty ? families : _filteredFamilies;
              
              if (displayFamilies.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.home_work_rounded,
                  title: 'Tidak Ada Keluarga',
                  subtitle: 'Belum ada data keluarga yang tersedia',
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: displayFamilies.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final family = displayFamilies[index];
                  return FamilyListCard(
                    family: family,
                    onTap: () => _navigateToFamilyDetail(context, family),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
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
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(familyListProvider.notifier).fetchFamilies();
                      },
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
        ),
      ],
    );
  }

  void _navigateToFamilyDetail(BuildContext context, Map<String, dynamic> family) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FamilyDetailPage(familyData: family),
      ),
    );
  }
}

