import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../widget/file_input_widget.dart';
import '../widget/section_header_widget.dart';
import '../provider/resident_viewmodel.dart';
import '../provider/auth_flow_provider.dart';

class FormInputDataScreen extends ConsumerStatefulWidget {
  const FormInputDataScreen({super.key});

  @override
  ConsumerState<FormInputDataScreen> createState() => _FormInputDataScreenState();
}

class _FormInputDataScreenState extends ConsumerState<FormInputDataScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _occupationSearchController = TextEditingController();
  final _familySearchController = TextEditingController();
  
  // Dropdown values
  String? _selectedGender;
  String? _selectedFamilyRole;
  String? _selectedFamily;
  String? _selectedOccupation;
  
  DateTime? _dateOfBirth;
  bool _isSubmitting = false;
  
  // Files
  File? _ktpFile;
  File? _kkFile;
  File? _birthCertificateFile;

  @override
  void initState() {
    super.initState();
    // Fetch families and occupations on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyListProvider.notifier).fetchFamilies();
      ref.read(occupationListProvider.notifier).fetchOccupations();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _placeOfBirthController.dispose();
    _occupationSearchController.dispose();
    _familySearchController.dispose();
    super.dispose();
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
          onPressed: () => context.go('/auth-flow'),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        title: const Text('Input Data Penduduk'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ...existing code for all form fields and widgets...
                // Data Pribadi
                SectionHeaderWidget(title: 'Data Pribadi', icon: Icons.person, isDark: isDark),
                const SizedBox(height: 16),
                _buildLabel('Nama Lengkap', isDark, required: true),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Masukkan nama lengkap',
                  isDark: isDark,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildLabel('NIK', isDark, required: true),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nikController,
                  hintText: 'Masukkan NIK (16 digit)',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card,
                  maxLength: 16,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tempat Lahir', isDark, required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _placeOfBirthController,
                            hintText: 'Kota',
                            isDark: isDark,
                            prefixIcon: Icons.location_on_outlined,
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
                          _buildDateField(isDark),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('Jenis Kelamin', isDark, required: true),
                const SizedBox(height: 8),
                _buildGenderSelector(isDark),
                const SizedBox(height: 32),
                // Section: Informasi Keluarga
                SectionHeaderWidget(title: 'Informasi Keluarga', icon: Icons.family_restroom, isDark: isDark),
                const SizedBox(height: 16),
                _buildLabel('Keluarga', isDark, required: true),
                const SizedBox(height: 8),
                _buildFamilySearchableDropdown(isDark),
                const SizedBox(height: 20),
                _buildLabel('Peran dalam Keluarga', isDark, required: true),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedFamilyRole,
                  items: ['Kepala Keluarga', 'Istri', 'Anak', 'Lainnya'],
                  hintText: 'Pilih peran dalam keluarga',
                  isDark: isDark,
                  onChanged: (value) => setState(() => _selectedFamilyRole = value),
                ),
                const SizedBox(height: 32),
                // Section: Pekerjaan
                SectionHeaderWidget(title: 'Pekerjaan', icon: Icons.work_outline, isDark: isDark),
                const SizedBox(height: 16),
                _buildLabel('Pekerjaan', isDark, required: true),
                const SizedBox(height: 8),
                _buildOccupationSearchableDropdown(isDark),
                const SizedBox(height: 32),
                // Section: Dokumen
                SectionHeaderWidget(title: 'Dokumen Pendukung', icon: Icons.upload_file, isDark: isDark),
                const SizedBox(height: 16),
                _buildLabel('KTP', isDark, required: true),
                const SizedBox(height: 8),
                FileInputWidget(
                  file: _ktpFile,
                  hintText: 'Upload KTP',
                  isDark: isDark,
                  onTap: () => _pickFile('ktp'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Kartu Keluarga (KK)', isDark, required: true),
                const SizedBox(height: 8),
                FileInputWidget(
                  file: _kkFile,
                  hintText: 'Upload Kartu Keluarga',
                  isDark: isDark,
                  onTap: () => _pickFile('kk'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Akte Kelahiran', isDark, required: true),
                const SizedBox(height: 8),
                FileInputWidget(
                  file: _birthCertificateFile,
                  hintText: 'Upload Akte Kelahiran',
                  isDark: isDark,
                  onTap: () => _pickFile('birth_certificate'),
                ),
                const SizedBox(height: 32),
                // Submit Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () {
                        if (_formKey.currentState!.validate()) {
                          _submitForm();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan Data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLabel(String text, bool isDark, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimaryLight,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark 
              ? AppColors.textSecondaryDark 
              : Colors.grey.shade400,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isDark 
                    ? AppColors.textSecondaryDark 
                    : Colors.grey.shade400,
                size: 20,
              )
            : null,
        filled: true,
        fillColor: isDark 
            ? AppColors.bgPrimaryInputBoxDark 
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildGenderSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderOption(
            'Laki-laki',
            Icons.male,
            _selectedGender == 'Laki-laki',
            isDark,
            () => setState(() => _selectedGender = 'Laki-laki'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderOption(
            'Perempuan',
            Icons.female,
            _selectedGender == 'Perempuan',
            isDark,
            () => setState(() => _selectedGender = 'Perempuan'),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    String label,
    IconData icon,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.1)
              : (isDark 
                  ? AppColors.bgPrimaryInputBoxDark 
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryLight
                  : (isDark 
                      ? AppColors.textSecondaryDark 
                      : Colors.grey.shade400),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryLight
                    : (isDark 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hintText,
    required bool isDark,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.bgPrimaryInputBoxDark 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark 
                ? AppColors.textSecondaryDark 
                : Colors.grey.shade400,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark 
              ? AppColors.textSecondaryDark 
              : Colors.grey.shade400,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: isDark 
            ? AppColors.bgPrimaryInputBoxDark 
            : Colors.white,
      ),
    );
  }

  Widget _buildFamilySearchableDropdown(bool isDark) {
    final familiesAsync = ref.watch(familyListProvider);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildFamilySearchModal(
            controller: _familySearchController,
            familiesAsync: familiesAsync,
            hintText: 'Cari keluarga...',
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedFamily = value);
            },
            onSearch: (query) {
              ref.read(familyListProvider.notifier).searchFamilies(query);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.bgPrimaryInputBoxDark 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: familiesAsync.when(
                data: (families) {
                  final selectedFamily = _selectedFamily != null
                      ? families.firstWhere(
                          (item) => item['family_id'].toString() == _selectedFamily,
                          orElse: () => {},
                        )
                      : null;
                  
                  return Text(
                    selectedFamily != null && selectedFamily.isNotEmpty
                        ? selectedFamily['family_name']?.toString() ?? 'Cari keluarga...'
                        : 'Cari keluarga...',
                    style: TextStyle(
                      color: selectedFamily != null && selectedFamily.isNotEmpty
                          ? (isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight)
                          : (isDark 
                              ? AppColors.textSecondaryDark 
                              : Colors.grey.shade400),
                      fontSize: 16,
                    ),
                  );
                },
                loading: () => Text(
                  'Memuat...',
                  style: TextStyle(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
                error: (_, __) => Text(
                  'Cari keluarga...',
                  style: TextStyle(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.search,
              size: 20,
              color: isDark 
                  ? AppColors.textSecondaryDark 
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySearchModal({
    required TextEditingController controller,
    required AsyncValue<List<Map<String, dynamic>>> familiesAsync,
    required String hintText,
    required bool isDark,
    required Function(String?) onChanged,
    required Function(String) onSearch,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: isDark 
                    ? AppColors.bgPrimaryInputBoxDark 
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: familiesAsync.when(
              data: (families) {
                if (families.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data keluarga',
                      style: TextStyle(
                        color: isDark 
                            ? AppColors.textSecondaryDark 
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: families.length,
                  itemBuilder: (context, index) {
                    final item = families[index];
                    
                    return ListTile(
                      title: Text(
                        item['family_name']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          color: isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: item['address'] != null
                          ? Text(
                              item['address'].toString(),
                              style: TextStyle(
                                color: isDark 
                                    ? AppColors.textSecondaryDark 
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: () {
                        onChanged(item['family_id'].toString());
                        controller.clear();
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupationSearchableDropdown(bool isDark) {
    final occupationsAsync = ref.watch(occupationListProvider);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildOccupationSearchModal(
            controller: _occupationSearchController,
            occupationsAsync: occupationsAsync,
            hintText: 'Cari pekerjaan...',
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedOccupation = value);
            },
            onSearch: (query) {
              ref.read(occupationListProvider.notifier).searchOccupations(query);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.bgPrimaryInputBoxDark 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: occupationsAsync.when(
                data: (occupations) {
                  final selectedOccupation = _selectedOccupation != null
                      ? occupations.firstWhere(
                          (item) => item['occupation_id'].toString() == _selectedOccupation,
                          orElse: () => {},
                        )
                      : null;
                  
                  return Text(
                    selectedOccupation != null && selectedOccupation.isNotEmpty
                        ? selectedOccupation['occupation_name']?.toString() ?? 'Cari pekerjaan...'
                        : 'Cari pekerjaan...',
                    style: TextStyle(
                      color: selectedOccupation != null && selectedOccupation.isNotEmpty
                          ? (isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight)
                          : (isDark 
                              ? AppColors.textSecondaryDark 
                              : Colors.grey.shade400),
                      fontSize: 16,
                    ),
                  );
                },
                loading: () => Text(
                  'Memuat...',
                  style: TextStyle(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
                error: (_, __) => Text(
                  'Cari pekerjaan...',
                  style: TextStyle(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.search,
              size: 20,
              color: isDark 
                  ? AppColors.textSecondaryDark 
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupationSearchModal({
    required TextEditingController controller,
    required AsyncValue<List<Map<String, dynamic>>> occupationsAsync,
    required String hintText,
    required bool isDark,
    required Function(String?) onChanged,
    required Function(String) onSearch,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: isDark 
                    ? AppColors.bgPrimaryInputBoxDark 
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: occupationsAsync.when(
              data: (occupations) {
                if (occupations.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data pekerjaan',
                      style: TextStyle(
                        color: isDark 
                            ? AppColors.textSecondaryDark 
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: occupations.length,
                  itemBuilder: (context, index) {
                    final item = occupations[index];
                    
                    return ListTile(
                      title: Text(
                        item['occupation_name']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          color: isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      onTap: () {
                        onChanged(item['occupation_id'].toString());
                        controller.clear();
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _dateOfBirth = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.bgPrimaryInputBoxDark 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AutoSizeText(
              _dateOfBirth != null
                  ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                  : 'DD/MM/YYYY',
              style: TextStyle(
                color: _dateOfBirth != null
                    ? (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)
                    : (isDark
                    ? AppColors.textSecondaryDark
                    : Colors.grey.shade400),
                fontSize: 12,
              ),
              maxLines: 1,
              minFontSize: 10, // ukuran minimum teks saat mengecil
              overflow: TextOverflow.ellipsis, // menambahkan ... jika tetap overflow
            ),
            Icon(
              Icons.calendar_today,
              size: 18,
              color: isDark 
                  ? AppColors.textSecondaryDark 
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        switch (type) {
          case 'ktp':
            _ktpFile = File(result.files.single.path!);
            break;
          case 'kk':
            _kkFile = File(result.files.single.path!);
            break;
          case 'birth_certificate':
            _birthCertificateFile = File(result.files.single.path!);
            break;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _placeOfBirthController.text.isEmpty ||
        _dateOfBirth == null ||
        _selectedGender == null ||
        _selectedFamily == null ||
        _selectedFamilyRole == null ||
        _selectedOccupation == null ||
        _ktpFile == null ||
        _kkFile == null ||
        _birthCertificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Harap lengkapi semua field yang wajib diisi'),
            ],
          ),
          backgroundColor: AppColors.redAccentLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final notifier = ref.read(residentSubmissionProvider.notifier);
    await notifier.submitResident(
      name: _nameController.text,
      nik: _nikController.text,
      placeOfBirth: _placeOfBirthController.text,
      dateOfBirth: '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
      gender: _selectedGender!,
      familyRole: _selectedFamilyRole!,
      familyId: _selectedFamily!,
      occupationId: _selectedOccupation!,
      ktpFile: _ktpFile!,
      kkFile: _kkFile!,
      birthCertificateFile: _birthCertificateFile!,
    );

    final state = ref.read(residentSubmissionProvider);
    if (state is AsyncData) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Data berhasil disimpan'),
              ],
            ),
            backgroundColor: AppColors.primaryLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Refresh AuthFlowStatus to trigger redirect to dashboard
        final _ = ref.refresh(authFlowProvider);
        context.go('/auth-flow');
      }
    } else if (state is AsyncError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Gagal menyimpan data: ${state.error}'),
                ),
              ],
            ),
            backgroundColor: AppColors.redAccentLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}