import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/themes/app_colors.dart';
import '../../report/models/report_model.dart';
import '../../report/provider/report_provider.dart';
import '../../../core/services/report_service.dart';

class ReportCreateTab extends ConsumerStatefulWidget {
  const ReportCreateTab({super.key});

  @override
  ConsumerState<ReportCreateTab> createState() => _ReportCreateTabState();
}

class _ReportCreateTabState extends ConsumerState<ReportCreateTab> {
  final _formKey = GlobalKey<FormState>();
  final _reportNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactPersonController = TextEditingController();

  ReportCategory _selectedCategory = ReportCategory.keamanan;
  List<PlatformFile> _evidenceFiles = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reportNameController.dispose();
    _descriptionController.dispose();
    _contactPersonController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _evidenceFiles.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _evidenceFiles.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final request = CreateReportRequest(
        category: _selectedCategory,
        reportName: _reportNameController.text.trim(),
        description: _descriptionController.text.trim(),
        contactPerson: _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
      );

      final reportActions = ref.read(reportActionsProvider.notifier);
      final createdReport = await reportActions.createReport(request);

      // Upload evidence if any
      if (_evidenceFiles.isNotEmpty) {
        final service = ref.read(reportServiceProvider);
        final files = _evidenceFiles
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();

        if (files.isNotEmpty) {
          await service.uploadEvidence(createdReport.reportId, files);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _reportNameController.clear();
        _descriptionController.clear();
        _contactPersonController.clear();
        setState(() {
          _selectedCategory = ReportCategory.keamanan;
          _evidenceFiles.clear();
        });

        // Refresh reports list
        ref.invalidate(reportListProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.report_problem_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Laporkan Masalah Anda',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami akan segera menindaklanjuti laporan Anda',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category
            Text('Kategori Masalah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ReportCategory>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.orange(context)),
                  items: ReportCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category), color: AppColors.orange(context), size: 20),
                          const SizedBox(width: 12),
                          Text(category.displayName, style: TextStyle(color: AppColors.textPrimary(context))),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedCategory = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Report Name
            Text('Judul Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reportNameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Lampu jalan mati di RT 01',
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.orange(context), width: 2)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Judul laporan tidak boleh kosong';
                if (value.trim().length < 10) return 'Judul laporan minimal 10 karakter';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Description
            Text('Deskripsi Masalah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Jelaskan masalah dengan detail (lokasi, waktu, dll)',
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.orange(context), width: 2)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Deskripsi tidak boleh kosong';
                if (value.trim().length < 20) return 'Deskripsi minimal 20 karakter';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Contact Person
            Text('Kontak Person (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactPersonController,
              decoration: InputDecoration(
                hintText: 'Nama & No. HP (contoh: Budi - 081234567890)',
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.orange(context), width: 2)),
              ),
            ),

            const SizedBox(height: 20),

            // Evidence Images
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bukti Foto (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
                TextButton.icon(onPressed: _pickImages, icon: const Icon(Icons.add_photo_alternate), label: const Text('Tambah Foto')),
              ],
            ),
            const SizedBox(height: 12),

            if (_evidenceFiles.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Belum ada foto', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _evidenceFiles.length,
                  itemBuilder: (context, index) {
                    final file = _evidenceFiles[index];
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                            image: file.path != null ? DecorationImage(image: FileImage(File(file.path!)), fit: BoxFit.cover) : null,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.keamanan:
        return Icons.security;
      case ReportCategory.kebersihan:
        return Icons.cleaning_services;
      case ReportCategory.infrastruktur:
        return Icons.construction;
      case ReportCategory.sosial:
        return Icons.groups;
      case ReportCategory.lainnya:
        return Icons.more_horiz;
    }
  }
}
