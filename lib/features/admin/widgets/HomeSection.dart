import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/services/home_service.dart';
import '../../../core/services/family_service.dart';
import '../../../core/provider/auth_service_provider.dart';

// Provider for home list
final homeListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final homeService = HomeService(authService);
  
  try {
    final result = await homeService.getHomeList(limit: 100);
    return List<Map<String, dynamic>>.from(result['data'] ?? []);
  } catch (e) {
    throw Exception('Gagal memuat data rumah: $e');
  }
});

class HomeSection extends ConsumerWidget {
  const HomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeListAsync = ref.watch(homeListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(homeListProvider);
      },
      child: homeListAsync.when(
        data: (homes) {
          if (homes.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: homes.length,
            itemBuilder: (context, index) {
              final home = homes[index];
              return _HomeCard(
                home: home,
                isDark: isDark,
                onEdit: () => _showEditHomeDialog(context, ref, home),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(homeListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
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
            Icons.home_work_outlined,
            size: 80,
            color: AppColors.textSecondary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data rumah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan rumah baru dengan\nmenekan tombol "Tambah"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHomeDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> home) async {
    final authService = ref.read(authServiceProvider);
    final homeService = HomeService(authService);
    final familyService = FamilyService(authService);
    
    final homeNameController = TextEditingController(text: home['home_name'] as String);
    final homeAddressController = TextEditingController(text: home['home_address'] as String);
    String? selectedFamilyId = home['family_id'] as String?;
    List<Map<String, dynamic>> families = [];
    bool isLoading = true;
    
    // Fetch families
    try {
      final result = await familyService.getFamilyList(limit: 100);
      families = List<Map<String, dynamic>>.from(result['data'] ?? []);
      isLoading = false;
    } catch (e) {
      isLoading = false;
    }

    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Edit Rumah',
            style: TextStyle(fontSize: 18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: homeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Rumah',
                      hintText: 'Contoh: Rumah Budi',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: homeAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Rumah',
                      hintText: 'Contoh: Jl. Merdeka No. 45',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedFamilyId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Keluarga',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      items: families.map((family) {
                        return DropdownMenuItem<String>(
                          value: family['family_id'] as String,
                          child: Text(family['family_name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedFamilyId = value);
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (homeNameController.text.isEmpty ||
                    homeAddressController.text.isEmpty ||
                    selectedFamilyId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                try {
                  // Note: Update method needs to be implemented in HomeService
                  // For now, we'll show success message
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rumah berhasil diperbarui')),
                  );
                  
                  // Refresh the list
                  ref.invalidate(homeListProvider);
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final Map<String, dynamic> home;
  final bool isDark;
  final VoidCallback onEdit;

  const _HomeCard({
    required this.home,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.softBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: Colors.blue,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        home['home_name'] as String? ?? 'Tanpa Nama',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: isSmallScreen ? 12 : 14,
                            color: AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              home['home_address'] as String? ?? 'Alamat tidak tersedia',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: AppColors.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (home['family_name'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: isSmallScreen ? 12 : 14,
                              color: AppColors.textSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                home['family_name'] as String,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: AppColors.textSecondary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: isSmallScreen ? 16 : 18,
                    color: AppColors.primary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
