import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import 'EmptyStateWidget.dart';
import 'FamilyMemberCard.dart';
import 'FamilySummaryCard.dart';

class MyFamilySection extends ConsumerWidget {
  const MyFamilySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myFamilyAsync = ref.watch(myFamilyProvider);

    return myFamilyAsync.when(
      data: (family) {
        if (family.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.family_restroom_rounded,
            title: 'Belum Ada Data Keluarga',
            subtitle: 'Anda belum terdaftar dalam sistem keluarga',
          );
        }

        final members = List<Map<String, dynamic>>.from(family['members'] ?? []);
        final isHead = family['is_head'] == true;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family Summary Card
              FamilySummaryCard(
                familyName: family['family_name'] ?? 'Keluarga Saya',
                headName: family['head_name'] ?? '-',
                memberCount: family['member_count'] ?? members.length,
                isHead: isHead,
              ),
              
              const SizedBox(height: 24),
              
              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${members.length} Orang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Members List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: members.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return FamilyMemberCard(
                    member: member,
                    isHead: isHead,
                    onEdit: isHead
                        ? () => _showEditMemberDialog(context, ref, member)
                        : null,
                  );
                },
              ),
            ],
          ),
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
              onPressed: () => ref.read(myFamilyProvider.notifier).fetchMyFamily(),
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
    );
  }

  void _showEditMemberDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> member) {
    final nameController = TextEditingController(text: member['name']);
    final phoneController = TextEditingController(text: member['phone']);
    final occupationController = TextEditingController(text: member['occupation']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Anggota Keluarga'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: occupationController,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(myFamilyProvider.notifier).updateMember(
                member['id'],
                {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'occupation': occupationController.text,
                },
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil diperbarui')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
