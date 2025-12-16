import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/admin/model/activity_model.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/activity_provider.dart';

class AdminActivityFormView extends ConsumerStatefulWidget {
  final String? activityId; // null = create, not null = edit

  const AdminActivityFormView({
    super.key,
    this.activityId,
  });

  @override
  ConsumerState<AdminActivityFormView> createState() =>
      _AdminActivityFormViewState();
}

class _AdminActivityFormViewState
    extends ConsumerState<AdminActivityFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String _selectedStatus = 'Akan Datang';
  
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Status options - sesuai dengan response backend
  final List<String> _statusOptions = [
    'Akan Datang',
    'Ongoing',
    'Selesai',
  ];

  // Map display status ke API format (untuk request)
  String _getApiStatus(String displayStatus) {
    switch (displayStatus) {
      case 'Akan Datang':
        return 'akan_datang';
      case 'Ongoing':
        return 'ongoing';
      case 'Selesai':
        return 'selesai';
      default:
        return displayStatus.toLowerCase().replaceAll(' ', '_');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.activityId != null) {
      _loadActivityData();
    } else {
      _isLoadingData = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadActivityData() async {
    try {
      final activity = await ref.read(
        activityDetailProvider(widget.activityId!).future,
      );

      setState(() {
        _nameController.text = activity.activityName;
        _descriptionController.text = activity.description ?? '';
        _locationController.text = activity.location;
        _organizerController.text = activity.organizer;
        _categoryController.text = activity.category ?? '';
        _selectedStatus = activity.status ?? 'Akan Datang';
        _startDate = activity.startDate;
        _startTime = TimeOfDay.fromDateTime(activity.startDate);
        if (activity.endDate != null) {
          _endDate = activity.endDate;
          _endTime = TimeOfDay.fromDateTime(activity.endDate!);
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.activityId != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Kegiatan' : 'Buat Kegiatan Baru',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary(context),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildSectionTitle('Nama Kegiatan *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        'Masukkan nama kegiatan',
                        Icons.event_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama kegiatan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description Field
                    _buildSectionTitle('Deskripsi'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration(
                        'Masukkan deskripsi kegiatan',
                        Icons.description_rounded,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Start Date & Time
                    _buildSectionTitle('Tanggal & Waktu Mulai *'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildDateField(
                            context,
                            'Pilih tanggal',
                            _startDate,
                            (date) => setState(() => _startDate = date),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeField(
                            context,
                            'Waktu',
                            _startTime,
                            (time) => setState(() => _startTime = time),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // End Date & Time
                    _buildSectionTitle('Tanggal & Waktu Selesai'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildDateField(
                            context,
                            'Pilih tanggal',
                            _endDate,
                            (date) => setState(() => _endDate = date),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeField(
                            context,
                            'Waktu',
                            _endTime,
                            (time) => setState(() => _endTime = time),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Location Field
                    _buildSectionTitle('Lokasi *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration(
                        'Masukkan lokasi kegiatan',
                        Icons.location_on_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Organizer Field
                    _buildSectionTitle('Penyelenggara *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _organizerController,
                      decoration: _inputDecoration(
                        'Masukkan nama penyelenggara',
                        Icons.person_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Penyelenggara wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Status Dropdown
                    _buildSectionTitle('Status'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: _inputDecoration(
                        'Pilih status',
                        Icons.flag_rounded,
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category Field
                    _buildSectionTitle('Kategori'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _categoryController,
                      decoration: _inputDecoration(
                        'Masukkan kategori',
                        Icons.category_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Images Section
                    _buildSectionTitle('Foto Kegiatan'),
                    const SizedBox(height: 8),
                    _buildImagePicker(),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'Simpan Perubahan' : 'Buat Kegiatan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary(context)),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textSecondary(context).withOpacity(0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textSecondary(context).withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary(context),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String hint,
    DateTime? date,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration(hint, Icons.calendar_today_rounded),
        child: Text(
          date != null
              ? DateFormat('dd MMM yyyy', 'id_ID').format(date)
              : hint,
          style: TextStyle(
            color: date != null
                ? AppColors.textPrimary(context)
                : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    String hint,
    TimeOfDay? time,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration(hint, Icons.access_time_rounded),
        child: Text(
          time != null ? time.format(context) : hint,
          style: TextStyle(
            color: time != null
                ? AppColors.textPrimary(context)
                : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_selectedImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            padding: const EdgeInsets.all(4),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        if (_selectedImages.length < 10)
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary(context).withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 48,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah Foto (Maks. 10)',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      final remaining = 10 - _selectedImages.length;
      final filesToAdd = pickedFiles.take(remaining).map((xFile) {
        return File(xFile.path);
      }).toList();

      setState(() {
        _selectedImages.addAll(filesToAdd);
      });

      if (pickedFiles.length > remaining) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal 10 foto. Beberapa foto tidak ditambahkan.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal dan waktu mulai wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      DateTime? endDateTime;
      if (_endDate != null && _endTime != null) {
        endDateTime = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      if (widget.activityId == null) {
        // Create new activity
        final request = ActivityRequest(
          activityName: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          startDate: startDateTime,
          endDate: endDateTime,
          location: _locationController.text.trim(),
          organizer: _organizerController.text.trim(),
          status: _getApiStatus(_selectedStatus), // Convert ke format API
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
        );

        final activity = await ref.read(createActivityProvider).call(request);

        // Upload images if any
        if (_selectedImages.isNotEmpty) {
          await ref
              .read(uploadActivityImagesProvider)
              .call(activity.activityId, _selectedImages);
        }

        if (mounted) {
          // Refresh list activity
          ref.invalidate(activityListProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kegiatan berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        // Update existing activity
        final updates = <String, dynamic>{
          'activity_name': _nameController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'start_date': startDateTime.toIso8601String(),
          'end_date': endDateTime?.toIso8601String(),
          'location': _locationController.text.trim(),
          'organizer': _organizerController.text.trim(),
          'status': _getApiStatus(_selectedStatus), // Convert ke format API
          'category': _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
        };

        await ref
            .read(updateActivityProvider)
            .call(widget.activityId!, updates);

        // Upload new images if any
        if (_selectedImages.isNotEmpty) {
          await ref
              .read(uploadActivityImagesProvider)
              .call(widget.activityId!, _selectedImages);
        }

        if (mounted) {
          // Refresh list activity
          ref.invalidate(activityListProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kegiatan berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
