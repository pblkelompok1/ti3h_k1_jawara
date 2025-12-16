import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/letter/data/models/letter_transaction.dart';
import 'package:ti3h_k1_jawara/features/letter/data/services/letter_api_service.dart';

final myLetterRequestsProvider = FutureProvider.autoDispose<List<LetterTransaction>>((ref) async {
  const storage = FlutterSecureStorage();
  final userDataStr = await storage.read(key: "user_data");
  
  if (userDataStr == null) throw Exception('User not logged in');
  
  final userData = jsonDecode(userDataStr);
  final userId = userData['id'] as String;
  
  final service = LetterApiService();
  final result = await service.getLetterRequests(userId: userId, limit: 100);
  
  return result['data'] as List<LetterTransaction>;
});

class MyLetterRequestsScreen extends ConsumerWidget {
  const MyLetterRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(myLetterRequestsProvider);

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
        title: const Text('Pengajuan Surat Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(myLetterRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) => _buildContent(context, requests, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorView(context, error, isDark, ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/letter/selection'),
        backgroundColor: AppColors.primary(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajukan Surat', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<LetterTransaction> requests, bool isDark) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 16),
            Text('Belum ada pengajuan surat',
              style: TextStyle(fontSize: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/letter/selection'),
              icon: const Icon(Icons.add),
              label: const Text('Ajukan Surat'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => _buildRequestCard(context, requests[index], isDark),
    );
  }

  Widget _buildRequestCard(BuildContext context, LetterTransaction request, bool isDark) {
    Color statusColor = _getStatusColor(request.status);
    IconData statusIcon = _getStatusIcon(request.status);

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
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(statusIcon, color: statusColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.letterName ?? 'Surat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      const SizedBox(height: 4),
                      Text(request.applicantName ?? '-',
                        style: TextStyle(fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
                _buildStatusBadge(request.statusText, statusColor),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Tanggal Pengajuan',
              _formatDate(request.applicationDate), isDark),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.update, 'Terakhir Update',
              _formatDate(request.updatedAt), isDark),
            
            if (request.isRejected && request.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Alasan Penolakan:', 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text(request.rejectionReason!, 
                            style: const TextStyle(fontSize: 12, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (request.isApproved && request.hasPdf) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(context, request),
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(error.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(myLetterRequestsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadPdf(BuildContext context, LetterTransaction request) async {
    try {
      final service = LetterApiService();
      final pdfUrl = service.getPdfUrl(request.letterResultPath!);
      
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka PDF'), 
              backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), 
            backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
