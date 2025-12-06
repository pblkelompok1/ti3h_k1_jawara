import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/mock_admin_providers.dart';
import 'package:ti3h_k1_jawara/features/admin/widget/approval_card.dart';
import 'package:ti3h_k1_jawara/features/admin/widget/status_chip.dart';
import 'package:intl/intl.dart';

class RegistrationApprovalView extends ConsumerWidget {
  const RegistrationApprovalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationsAsync = ref.watch(pendingRegistrationsProviderMock);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Persetujuan Registrasi',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
      ),
      body: registrationsAsync.when(
        data: (registrations) {
          if (registrations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada registrasi pending',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingRegistrationsProviderMock);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: registrations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final registration = registrations[index];
                return ApprovalCard(
                  title: registration.name,
                  subtitle: registration.email,
                  additionalInfo: [
                    Text(
                      'NIK: ${registration.nik}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      'Role: ${registration.familyRole}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      'Diajukan: ${_formatDate(registration.submittedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                  onApprove: () => _handleApprove(context, ref, registration.id),
                  onReject: () => _handleReject(context, ref, registration.id),
                  onTap: () => _showDetail(context, registration),
                );
              },
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
                Icons.error_outline,
                size: 64,
                color: AppColors.redAccent(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(pendingRegistrationsProviderMock);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      // Fallback jika locale belum diinisialisasi
      return DateFormat('dd/MM/yyyy, HH:mm').format(date);
    }
  }

  void _handleApprove(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Setujui Registrasi'),
        content: const Text('Anda yakin ingin menyetujui registrasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              final notifier = ref.read(pendingRegistrationsProviderMock.notifier);
              await notifier.approveRegistration(userId);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registrasi berhasil disetujui'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _handleReject(BuildContext context, WidgetRef ref, String userId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Registrasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan penolakan:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final notifier = ref.read(pendingRegistrationsProviderMock.notifier);
              await notifier.rejectRegistration(userId, reasonController.text.trim());

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registrasi ditolak'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, registration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Detail Registrasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(context, 'Nama', registration.name),
              _buildDetailRow(context, 'Email', registration.email),
              _buildDetailRow(context, 'NIK', registration.nik),
              _buildDetailRow(context, 'Telepon', registration.phone),
              _buildDetailRow(context, 'Alamat', registration.address),
              _buildDetailRow(context, 'Role Keluarga', registration.familyRole),
              _buildDetailRow(
                context,
                'Tanggal Pengajuan',
                _formatDate(registration.submittedAt),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusChip(
                    label: registration.status,
                    type: registration.status == 'approved'
                        ? StatusType.success
                        : registration.status == 'rejected'
                            ? StatusType.rejected
                            : StatusType.pending,
                  ),
                ],
              ),
              if (registration.documents != null &&
                  registration.documents!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Dokumen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                ...registration.documents!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          size: 20,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Open document URL
                          },
                          child: const Text('Lihat'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
