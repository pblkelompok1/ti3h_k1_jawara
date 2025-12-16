import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/letter/data/models/letter_transaction.dart';
import 'package:ti3h_k1_jawara/features/letter/data/services/letter_api_service.dart';

final adminLetterRequestsProvider = FutureProvider.autoDispose<List<LetterTransaction>>((ref) async {
  final service = LetterApiService();
  final result = await service.getLetterRequests(status: 'pending', limit: 100);
  return result['data'] as List<LetterTransaction>;
});

class AdminLetterApprovalScreen extends ConsumerWidget {
  const AdminLetterApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(adminLetterRequestsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
        title: const Text('Persetujuan Surat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminLetterRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) => _buildContent(context, requests, isDark, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorView(context, error, isDark, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<LetterTransaction> requests, bool isDark, WidgetRef ref) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text('Tidak ada pengajuan pending', style: TextStyle(fontSize: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            const SizedBox(height: 8),
            Text('Semua pengajuan sudah diproses', style: TextStyle(fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => _buildRequestCard(context, requests[index], isDark, ref),
    );
  }

  Widget _buildRequestCard(BuildContext context, LetterTransaction request, bool isDark, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.description, color: Colors.blue, size: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.letterName ?? 'Surat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      const SizedBox(height: 4),
                      Text('Pemohon: ${request.applicantName ?? '-'}',
                        style: TextStyle(fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.3))),
                  child: const Text('Pending', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            const SizedBox(height: 12),
            
            // Data pemohon
            _buildDataSection('Data Pemohon', request.data, isDark),
            
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Diajukan', _formatDate(request.applicationDate), isDark),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, request, ref),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context, request, ref),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Setujui', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(String title, Map<String, dynamic> data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue)),
          const SizedBox(height: 8),
          ...data.entries.take(5).map((entry) {
            final key = _formatKey(entry.key);
            final value = entry.value.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text('$key:', style: TextStyle(fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ),
                  Expanded(
                    child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  ),
                ],
              ),
            );
          }),
          if (data.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('... dan ${data.length - 5} data lainnya', 
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, Object error, bool isDark, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Gagal memuat data', style: TextStyle(fontSize: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(adminLetterRequestsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showApproveDialog(BuildContext context, LetterTransaction request, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Pengajuan'),
        content: Text('Apakah Anda yakin ingin menyetujui pengajuan surat dari ${request.applicantName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Setujui', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _processApproval(context, request, ref);
    }
  }

  Future<void> _showRejectDialog(BuildContext context, LetterTransaction request, WidgetRef ref) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengajuan dari: ${request.applicantName}'),
            const SizedBox(height: 16),
            const Text('Alasan penolakan:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan penolakan harus diisi')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _processRejection(context, request, reasonController.text.trim(), ref);
    }
  }

  Future<void> _processApproval(BuildContext context, LetterTransaction request, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = LetterApiService();
      await service.updateRequestStatus(
        transactionId: request.letterTransactionId,
        status: 'approved',
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajuan berhasil disetujui!'), 
            backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        ref.refresh(adminLetterRequestsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyetujui: $e'),
            backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _processRejection(BuildContext context, LetterTransaction request, String reason, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = LetterApiService();
      await service.updateRequestStatus(
        transactionId: request.letterTransactionId,
        status: 'rejected',
        rejectionReason: reason,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajuan berhasil ditolak'), 
            backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
        );
        ref.refresh(adminLetterRequestsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menolak: $e'),
            backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
