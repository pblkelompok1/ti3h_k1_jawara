import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/models/resident_registration_model.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/registration_provider.dart';
import 'package:ti3h_k1_jawara/features/admin/widget/status_chip.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RegistrationApprovalView extends ConsumerStatefulWidget {
  const RegistrationApprovalView({super.key});

  @override
  ConsumerState<RegistrationApprovalView> createState() => _RegistrationApprovalViewState();
}

class _RegistrationApprovalViewState extends ConsumerState<RegistrationApprovalView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when 90% scrolled
      ref.read(otherRegistrationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingRegistrationsProvider);
    final otherAsync = ref.watch(otherRegistrationsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: AutoSizeText(
          'Persetujuan Registrasi',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          minFontSize: 16,
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary(context)),
            onPressed: () {
              ref.invalidate(pendingRegistrationsProvider);
              ref.read(otherRegistrationsProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingRegistrationsProvider);
          await ref.read(otherRegistrationsProvider.notifier).refresh();
        },
        child: pendingAsync.when(
          data: (pendingList) {
            return otherAsync.when(
              data: (otherList) {
                if (pendingList.isEmpty && otherList.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingList.length + otherList.length + 1, // +1 for loading indicator
                  itemBuilder: (context, index) {
                    // Pending users first
                    if (index < pendingList.length) {
                      return _buildRegistrationCard(
                        context,
                        pendingList[index],
                        isPending: true,
                      );
                    }
                    
                    // Other users
                    final otherIndex = index - pendingList.length;
                    if (otherIndex < otherList.length) {
                      return _buildRegistrationCard(
                        context,
                        otherList[otherIndex],
                        isPending: false,
                      );
                    }

                    // Loading indicator at bottom
                    if (ref.read(otherRegistrationsProvider.notifier).hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    return const SizedBox(height: 16);
                  },
                );
              },
              loading: () => _buildLoadingWithPending(pendingList),
              error: (error, stack) => _buildErrorWithPending(pendingList, error),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Tidak ada registrasi',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWithPending(List<ResidentRegistrationModel> pendingList) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: pendingList.length + 1,
      itemBuilder: (context, index) {
        if (index < pendingList.length) {
          return _buildRegistrationCard(context, pendingList[index], isPending: true);
        }
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildErrorWithPending(List<ResidentRegistrationModel> pendingList, Object error) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: pendingList.length + 1,
      itemBuilder: (context, index) {
        if (index < pendingList.length) {
          return _buildRegistrationCard(context, pendingList[index], isPending: true);
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Gagal memuat data lainnya',
                  style: TextStyle(color: AppColors.redAccent(context)),
                ),
                TextButton(
                  onPressed: () => ref.read(otherRegistrationsProvider.notifier).refresh(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
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
              ref.invalidate(pendingRegistrationsProvider);
              ref.read(otherRegistrationsProvider.notifier).refresh();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(
    BuildContext context,
    ResidentRegistrationModel registration, {
    required bool isPending,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPending
            ? AppColors.primary(context).withOpacity(0.05)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending
              ? AppColors.primary(context).withOpacity(0.3)
              : AppColors.surface(context),
          width: isPending ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetail(context, registration),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            registration.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                          const SizedBox(height: 4),
                          AutoSizeText(
                            registration.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: registration.status,
                      type: registration.isApproved
                          ? StatusType.success
                          : registration.isRejected
                              ? StatusType.rejected
                              : StatusType.pending,
                    ),
                  ],
                ),
                if (registration.nik != null || registration.familyRole != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (registration.nik != null)
                        _buildInfoChip(context, Icons.badge, 'NIK: ${registration.nik}'),
                      if (registration.familyRole != null)
                        _buildInfoChip(context, Icons.people, registration.familyRole!),
                      if (registration.phone != null)
                        _buildInfoChip(context, Icons.phone, registration.phone!),
                    ],
                  ),
                ],
                if (registration.address != null) ...[
                  const SizedBox(height: 8),
                  AutoSizeText(
                    registration.address!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleReject(context, registration.userId),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Tolak'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.redAccent(context),
                            side: BorderSide(color: AppColors.redAccent(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleApprove(context, registration.userId),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Setujui'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary(context),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary(context)),
          const SizedBox(width: 4),
          AutoSizeText(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary(context),
            ),
            maxLines: 1,
            minFontSize: 10,
          ),
        ],
      ),
    );
  }

  void _handleApprove(BuildContext context, String userId) {
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
              
              try {
                await ref.read(registrationActionsProvider.notifier).approveRegistration(userId);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registrasi berhasil disetujui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyetujui: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _handleReject(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Registrasi'),
        content: const Text('Anda yakin ingin menolak registrasi ini?'),
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
              Navigator.pop(dialogContext);

              try {
                await ref.read(registrationActionsProvider.notifier).declineRegistration(userId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registrasi berhasil ditolak'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menolak: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, ResidentRegistrationModel registration) {
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
              AutoSizeText(
                'Detail Registrasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 1,
                minFontSize: 18,
              ),
              const SizedBox(height: 24),
              if (registration.name != null)
                _buildDetailRow(context, 'Nama', registration.name!),
              _buildDetailRow(context, 'Email', registration.email),
              if (registration.nik != null)
                _buildDetailRow(context, 'NIK', registration.nik!),
              if (registration.phone != null)
                _buildDetailRow(context, 'Telepon', registration.phone!),
              if (registration.address != null)
                _buildDetailRow(context, 'Alamat', registration.address!),
              if (registration.familyRole != null)
                _buildDetailRow(context, 'Role Keluarga', registration.familyRole!),
              const SizedBox(height: 8),
              Row(
                children: [
                  AutoSizeText(
                    'Status',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: 12),
                  StatusChip(
                    label: registration.status,
                    type: registration.isApproved
                        ? StatusType.success
                        : registration.isRejected
                            ? StatusType.rejected
                            : StatusType.pending,
                  ),
                ],
              ),
              if (registration.ktpPath != null || registration.kkPath != null) ...[
                const SizedBox(height: 24),
                AutoSizeText(
                  'Dokumen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                if (registration.ktpPath != null)
                  _buildDocumentRow(
                    context,
                    'KTP',
                    registration.ktpPath!,
                    Icons.credit_card,
                  ),
                if (registration.kkPath != null)
                  _buildDocumentRow(
                    context,
                    'Kartu Keluarga',
                    registration.kkPath!,
                    Icons.family_restroom,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentRow(
    BuildContext context,
    String label,
    String path,
    IconData icon,
  ) {
    final isImage = path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png');
    final isPdf = path.toLowerCase().endsWith('.pdf');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.primary(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // TODO: Implement document viewer when endpoint ready
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Endpoint dokumen belum tersedia'),
                duration: Duration(seconds: 2),
              ),
            );
            // _showDocumentViewer(context, path, isImage);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        isImage ? 'Gambar' : isPdf ? 'PDF' : 'Dokumen',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.remove_red_eye,
                  size: 20,
                  color: AppColors.primary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TODO: Uncomment when document endpoint ready
  // void _showDocumentViewer(BuildContext context, String path, bool isImage) {
  //   final adminService = ref.read(adminServiceProvider);
  //   final documentUrl = adminService.getDocumentUrl(path);
  //   
  //   if (documentUrl == null) return;
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.black,
  //     builder: (context) => SafeArea(
  //       child: Column(
  //         children: [
  //           AppBar(
  //             backgroundColor: Colors.black,
  //             leading: IconButton(
  //               icon: const Icon(Icons.close, color: Colors.white),
  //               onPressed: () => Navigator.pop(context),
  //             ),
  //             title: Text(
  //               isImage ? 'Preview Gambar' : 'Preview Dokumen',
  //               style: const TextStyle(color: Colors.white),
  //             ),
  //           ),
  //           Expanded(
  //             child: isImage
  //                 ? InteractiveViewer(
  //                     child: Image.network(
  //                       documentUrl,
  //                       fit: BoxFit.contain,
  //                       loadingBuilder: (context, child, progress) {
  //                         if (progress == null) return child;
  //                         return const Center(child: CircularProgressIndicator());
  //                       },
  //                       errorBuilder: (context, error, trace) {
  //                         return Center(
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               const Icon(Icons.error, color: Colors.red, size: 48),
  //                               const SizedBox(height: 16),
  //                               Text(
  //                                 'Gagal memuat gambar',
  //                                 style: const TextStyle(color: Colors.white),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   )
  //                 : Center(
  //                     child: Text(
  //                       'PDF Viewer belum diimplementasi',
  //                       style: const TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: AutoSizeText(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
              maxLines: 1,
              minFontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AutoSizeText(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              minFontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
