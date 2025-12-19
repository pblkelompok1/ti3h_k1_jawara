import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/themes/app_colors.dart';
import '../../../core/services/family_service.dart';
import '../../../core/services/home_service.dart';
import '../../../core/services/rt_service.dart';
import '../../../core/services/resident_service.dart';
import '../../../core/provider/auth_service_provider.dart';
import '../../resident/provider/resident_providers.dart';
import '../widgets/HomeSection.dart';
import '../../resident/widgets/ResidentsSection.dart';
import '../../resident/widgets/FamiliesSection.dart';

// Import homeListProvider from HomeSection
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

class AdminResidentView extends ConsumerStatefulWidget {
  const AdminResidentView({super.key});

  @override
  ConsumerState<AdminResidentView> createState() => _AdminResidentViewState();
}

class _AdminResidentViewState extends ConsumerState<AdminResidentView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(selectedTabProvider.notifier).state = _tabController.index;
      }
    });

    // Initial data fetch for My Family
    Future.microtask(() => 
      ref.read(myFamilyProvider.notifier).fetchMyFamily()
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary(context),
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Kembali',
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary(context),
                                AppColors.primary(context).withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary(context).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kependudukan Admin',
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Kelola data warga RT',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.softBorder(context),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary(context),
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary(context),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Rumah'),
                Tab(text: 'Warga'),
                Tab(text: 'Keluarga'),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                HomeSection(),
                ResidentsSection(),
                FamiliesSection(),
              ],
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptionsBottomSheet,
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
    );
  }

  void _showAddOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              'Pilih Jenis Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tambah Rumah
            _buildOptionTile(
              icon: Icons.home_work_rounded,
              title: 'Tambah Rumah',
              subtitle: 'Daftarkan rumah baru',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _showAddHomeDialog();
              },
            ),
            const SizedBox(height: 12),
            
            // Tambah Keluarga
            _buildOptionTile(
              icon: Icons.people_alt_rounded,
              title: 'Tambah Keluarga',
              subtitle: 'Daftarkan keluarga baru',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _showAddFamilyDialog();
              },
            ),
            const SizedBox(height: 12),
            
            // Tambah Warga
            _buildOptionTile(
              icon: Icons.person_add_rounded,
              title: 'Tambah Warga',
              subtitle: 'Daftarkan warga baru',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _showAddResidentDialog();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHomeDialog() async {
    final authService = ref.read(authServiceProvider);
    final homeService = HomeService(authService);
    final familyService = FamilyService(authService);
    
    final homeNameController = TextEditingController();
    final homeAddressController = TextEditingController();
    String? selectedFamilyId;
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

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Tambah Rumah',
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
                  await homeService.createHome(
                    homeName: homeNameController.text,
                    homeAddress: homeAddressController.text,
                    familyId: selectedFamilyId!,
                  );
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rumah berhasil ditambahkan')),
                  );
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
    ).then((_) {
      // Refresh home list when dialog closes
      ref.invalidate(homeListProvider);
    });
  }

  void _showAddFamilyDialog() async {
    final authService = ref.read(authServiceProvider);
    final familyService = FamilyService(authService);
    final rtService = RTService(authService);
    
    final familyNameController = TextEditingController();
    int? selectedRtId;
    List<Map<String, dynamic>> rtList = [];
    bool isLoading = true;
    
    // Fetch RT list
    try {
      rtList = await rtService.getRTList();
      isLoading = false;
    } catch (e) {
      isLoading = false;
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Tambah Keluarga',
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
                    controller: familyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Keluarga',
                      hintText: 'Contoh: Keluarga Budi Santoso',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: selectedRtId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih RT',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      items: rtList.map((rt) {
                        return DropdownMenuItem<int>(
                          value: rt['rt_id'] as int,
                          child: Text('RT ${rt['rt_name'] ?? rt['rt_id']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedRtId = value);
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
                if (familyNameController.text.isEmpty || selectedRtId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                try {
                  await familyService.createFamily(
                    familyName: familyNameController.text,
                    rtId: selectedRtId!,
                  );
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Keluarga berhasil ditambahkan')),
                  );
                  
                  // Refresh family list
                  ref.invalidate(myFamilyProvider);
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

  void _showAddResidentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Warga Baru'),
        content: const Text(
          'Fitur tambah warga masih dalam pengembangan. Silakan gunakan form registrasi warga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
