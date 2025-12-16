import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../provider/resident_providers.dart';
import '../view/edit_family_member_page.dart';
import '../view/add_family_member_page.dart';
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
                        ? () => _navigateToEditMember(context, ref, member)
                        : null,
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Add Member Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToAddMember(context, ref, family),
                    icon: const Icon(Icons.add_rounded, size: 24),
                    label: const Text(
                      'Tambah Anggota Keluarga',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
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

  void _navigateToEditMember(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> member,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFamilyMemberPage(member: member),
      ),
    );

    // Show success message if update was successful
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAddMember(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> family,
  ) async {
    // Navigate to add family member page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFamilyMemberPage(
          familyInfo: {
            'family_id': family['family_id'],
            'family_name': family['family_name'],
            'head_name': family['head_name'],
            'member_count': family['member_count'],
          },
        ),
      ),
    );

    // Show success message if registration was successful
    if (result == true && context.mounted) {
      // Data will be automatically refreshed via provider
    }
  }
}
