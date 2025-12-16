import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/letter/data/models/letter_type.dart';
import 'package:ti3h_k1_jawara/features/letter/data/models/domisili_data.dart';
import 'package:ti3h_k1_jawara/features/letter/data/services/letter_api_service.dart';

class DomisiliFormScreen extends ConsumerStatefulWidget {
  final LetterType letterType;

  const DomisiliFormScreen({super.key, required this.letterType});

  @override
  ConsumerState<DomisiliFormScreen> createState() => _DomisiliFormScreenState();
}

class _DomisiliFormScreenState extends ConsumerState<DomisiliFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final _apiService = LetterApiService();

  // Form controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _alamatController = TextEditingController();

  // Dropdown values
  String _jenisKelamin = 'Laki-laki';
  String _agama = 'Islam';
  String _statusKawin = 'Belum Kawin';

  DateTime? _tanggalLahir;
  DateTime? _sejakTanggal;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalLahir == null) {
      _showSnackBar('Silakan pilih tanggal lahir', isError: true);
      return;
    }

    if (_sejakTanggal == null) {
      _showSnackBar('Silakan pilih sejak tanggal berdomisili', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get user ID from storage
      final userDataStr = await _storage.read(key: "user_data");
      if (userDataStr == null) {
        throw Exception('User not logged in');
      }
      final userData = jsonDecode(userDataStr);
      final userId = userData['id'] as String;

      // Format tanggal ke format Indonesia
      final tanggalLahirFormatted = _formatDateIndonesia(_tanggalLahir!);
      final sejakTanggalFormatted = _formatDateIndonesia(_sejakTanggal!);

      // Create domisili data
      final domisiliData = DomisiliData(
        namaLengkap: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: tanggalLahirFormatted,
        jenisKelamin: _jenisKelamin,
        agama: _agama,
        pekerjaan: _pekerjaanController.text.trim(),
        statusKawin: _statusKawin,
        alamatLengkap: _alamatController.text.trim(),
        sejakTanggal: sejakTanggalFormatted,
      );

      // Submit request
      await _apiService.createLetterRequest(
        letterId: widget.letterType.letterId,
        data: domisiliData.toJson(),
        userId: userId,
      );

      if (mounted) {
        _showSnackBar('Pengajuan surat berhasil dikirim!');
        context.go('/letter/selection');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal mengajukan surat: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDateIndonesia(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        title: const Text('Form Surat Domisili'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildSectionHeader('Data Pribadi', Icons.person, isDark),
                      const SizedBox(height: 20),

                      // Nama Lengkap
                      _buildLabel('Nama Lengkap', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _namaController,
                        hintText: 'Masukkan nama lengkap',
                        isDark: isDark,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // NIK
                      _buildLabel('NIK', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nikController,
                        hintText: 'Masukkan NIK (16 digit)',
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.credit_card,
                        maxLength: 16,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'NIK harus diisi';
                          }
                          if (value.length != 16) {
                            return 'NIK harus 16 digit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Tempat & Tanggal Lahir
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Tempat Lahir', isDark, required: true),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _tempatLahirController,
                                  hintText: 'Kota',
                                  isDark: isDark,
                                  prefixIcon: Icons.location_on_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Tanggal Lahir', isDark, required: true),
                                const SizedBox(height: 8),
                                _buildDateField(
                                  context,
                                  isDark,
                                  value: _tanggalLahir,
                                  onTap: () => _selectDate(context, isDark, isForBirthDate: true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Jenis Kelamin
                      _buildLabel('Jenis Kelamin', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _jenisKelamin,
                        items: ['Laki-laki', 'Perempuan'],
                        onChanged: (value) => setState(() => _jenisKelamin = value!),
                        isDark: isDark,
                        icon: Icons.wc,
                      ),
                      const SizedBox(height: 20),

                      // Agama
                      _buildLabel('Agama', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _agama,
                        items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
                        onChanged: (value) => setState(() => _agama = value!),
                        isDark: isDark,
                        icon: Icons.mosque_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Pekerjaan
                      _buildLabel('Pekerjaan', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _pekerjaanController,
                        hintText: 'Masukkan pekerjaan',
                        isDark: isDark,
                        prefixIcon: Icons.work_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Pekerjaan harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Status Perkawinan
                      _buildLabel('Status Perkawinan', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _statusKawin,
                        items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
                        onChanged: (value) => setState(() => _statusKawin = value!),
                        isDark: isDark,
                        icon: Icons.favorite_outline,
                      ),
                      const SizedBox(height: 32),

                      // Alamat Section
                      _buildSectionHeader('Informasi Domisili', Icons.home, isDark),
                      const SizedBox(height: 20),

                      // Alamat Lengkap
                      _buildLabel('Alamat Lengkap', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _alamatController,
                        hintText: 'Masukkan alamat lengkap',
                        isDark: isDark,
                        prefixIcon: Icons.location_city,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Sejak Tanggal
                      _buildLabel('Berdomisili Sejak', isDark, required: true),
                      const SizedBox(height: 8),
                      _buildDateField(
                        context,
                        isDark,
                        value: _sejakTanggal,
                        onTap: () => _selectDate(context, isDark, isForBirthDate: false),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Ajukan Surat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary(context),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, bool isDark, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary(context),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        counterText: '',
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 14,
                ),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, bool isDark, {DateTime? value, required VoidCallback onTap}) {
    final dateText = value != null ? DateFormat('dd MMMM yyyy', 'id_ID').format(value) : 'Pilih tanggal';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: value != null
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDark, {required bool isForBirthDate}) async {
    final initialDate = isForBirthDate
        ? (_tanggalLahir ?? DateTime(2000, 1, 1))
        : (_sejakTanggal ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary(context),
              onPrimary: Colors.white,
              surface: isDark ? AppColors.cardDark : Colors.white,
              onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isForBirthDate) {
          _tanggalLahir = picked;
        } else {
          _sejakTanggal = picked;
        }
      });
    }
  }
}
