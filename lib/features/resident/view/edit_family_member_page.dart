import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/pdf_viewer.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../auth/provider/resident_viewmodel.dart';
import '../../../core/services/resident_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/file_utils.dart';
import '../provider/resident_providers.dart';

class EditFamilyMemberPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> member;

  const EditFamilyMemberPage({
    super.key,
    required this.member,
  });

  @override
  ConsumerState<EditFamilyMemberPage> createState() => _EditFamilyMemberPageState();
}

class _EditFamilyMemberPageState extends ConsumerState<EditFamilyMemberPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _nikController;
  late TextEditingController _placeOfBirthController;
  late TextEditingController _dateOfBirthController;
  final _occupationSearchController = TextEditingController();

  String? _selectedGender;
  String? _selectedRole;
  String? _selectedBloodType;
  String? _selectedReligion;
  String? _selectedOccupation;
  File? _profileImage;
  File? _ktpImage;
  String? _existingKkPath;
  String? _existingBirthCertPath;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _roleOptions = [
    'Kepala Keluarga',
    'Istri',
    'Anak',
    'Orang Tua',
    'Mertua',
    'Cucu',
    'Keponakan',
    'Lainnya'
  ];
  final List<String> _bloodTypeOptions = ['A', 'B', 'AB', 'O'];
  final List<String> _religionOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member['name']?.toString() ?? '');
    _phoneController = TextEditingController(text: widget.member['phone']?.toString() ?? '');
    _nikController = TextEditingController(text: widget.member['nik']?.toString() ?? '');
    _placeOfBirthController =
        TextEditingController(text: widget.member['place_of_birth']?.toString() ?? '');
    _dateOfBirthController =
        TextEditingController(text: widget.member['date_of_birth']?.toString() ?? '');

    // Set occupation ID if available
    _selectedOccupation = widget.member['occupation_id']?.toString();

    // Validate gender value
    final gender = widget.member['gender']?.toString();
    _selectedGender = (gender != null && _genderOptions.contains(gender)) ? gender : null;
    
    // Validate role value
    final role = (widget.member['role'] ?? widget.member['family_role'])?.toString();
    _selectedRole = (role != null && _roleOptions.contains(role)) ? role : null;
    
    // Validate blood type - make uppercase to match options
    final bloodType = widget.member['blood_type']?.toString().toUpperCase();
    _selectedBloodType = (bloodType != null && _bloodTypeOptions.contains(bloodType)) ? bloodType : null;
    
    // Validate religion value
    final religion = widget.member['religion']?.toString();
    _selectedReligion = (religion != null && _religionOptions.contains(religion)) ? religion : null;
    
    // Set existing document paths (read-only)
    _existingKkPath = widget.member['kk_path']?.toString();
    _existingBirthCertPath = widget.member['birth_certificate_path']?.toString();
    
    // Fetch occupations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(occupationListProvider.notifier).fetchOccupations();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nikController.dispose();
    _placeOfBirthController.dispose();
    _dateOfBirthController.dispose();
    _occupationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Anggota Keluarga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary(context).withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.primary(context),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _profileImage != null
                            ? Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                              )
                            : widget.member['profile_img_path'] != null &&
                                    widget.member['profile_img_path'].toString().isNotEmpty
                                ? Image.network(
                                    FileUtils.buildFileUrl(widget.member['profile_img_path'].toString()),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        (_selectedGender?.toLowerCase() == 'laki-laki'
                                            ? Icons.man_rounded
                                            : Icons.woman_rounded),
                                        size: 60,
                                        color: AppColors.primary(context),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  )
                                : Icon(
                                    (_selectedGender?.toLowerCase() == 'laki-laki'
                                        ? Icons.man_rounded
                                        : Icons.woman_rounded),
                                    size: 60,
                                    color: AppColors.primary(context),
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Informasi Pribadi'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nikController,
              label: 'NIK',
              icon: Icons.badge_outlined,
              isDark: isDark,
              keyboardType: TextInputType.number,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Jenis Kelamin',
              value: _selectedGender,
              items: _genderOptions,
              icon: Icons.wc_rounded,
              isDark: isDark,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _placeOfBirthController,
              label: 'Tempat Lahir',
              icon: Icons.location_on_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dateOfBirthController,
              label: 'Tanggal Lahir (YYYY-MM-DD)',
              icon: Icons.cake_outlined,
              isDark: isDark,
              keyboardType: TextInputType.datetime,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Golongan Darah',
              value: _selectedBloodType,
              items: _bloodTypeOptions,
              icon: Icons.bloodtype_outlined,
              isDark: isDark,
              onChanged: (value) => setState(() => _selectedBloodType = value),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Agama',
              value: _selectedReligion,
              items: _religionOptions,
              icon: Icons.mosque_outlined,
              isDark: isDark,
              onChanged: (value) => setState(() => _selectedReligion = value),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Informasi Keluarga'),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Peran Keluarga',
              value: _selectedRole,
              items: _roleOptions,
              icon: Icons.family_restroom_rounded,
              isDark: isDark,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Kontak & Pekerjaan'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'No. Telepon',
              icon: Icons.phone_outlined,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildOccupationSearchableDropdown(isDark),
            const SizedBox(height: 32),
            _buildSectionTitle('Dokumen'),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'KTP',
              icon: Icons.credit_card,
              file: _ktpImage,
              existingPath: widget.member['ktp_path']?.toString(),
              isDark: isDark,
              enabled: true,
              onTap: _pickKtpImage,
              showPreview: true,
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Kartu Keluarga (KK)',
              icon: Icons.family_restroom,
              file: null,
              existingPath: _existingKkPath,
              isDark: isDark,
              enabled: false, // Locked
              onTap: () {},
              showPreview: true,
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Akte Kelahiran',
              icon: Icons.description,
              file: null,
              existingPath: _existingBirthCertPath,
              isDark: isDark,
              enabled: false, // Locked
              onTap: () {},
              showPreview: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Menyimpan perubahan...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary(context)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary(context), width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary(context)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor:
            isDark ? AppColors.bgDashboardCard(context) : Colors.white,
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _profileImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickKtpImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _ktpImage = File(result.files.single.path!);
      });
    }
  }

  Widget _buildDocumentUpload({
    required String label,
    required IconData icon,
    required File? file,
    required String? existingPath,
    required bool isDark,
    required bool enabled,
    required VoidCallback onTap,
    bool showPreview = false,
  }) {
    final hasDocument = file != null || (existingPath != null && existingPath.isNotEmpty);
    
    return InkWell(
      onTap: hasDocument && showPreview
          ? () => _showDocumentOptions(label, existingPath, enabled, onTap)
          : (enabled ? onTap : null),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled 
                ? AppColors.softBorder(context)
                : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Document thumbnail or icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primary(context).withOpacity(0.1)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasDocument && existingPath != null && FileUtils.isImage(existingPath)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        FileUtils.buildFileUrl(existingPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            icon,
                            color: enabled ? AppColors.primary(context) : Colors.grey.shade600,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      hasDocument && existingPath != null && FileUtils.isPdf(existingPath)
                          ? Icons.picture_as_pdf
                          : icon,
                      color: enabled ? AppColors.primary(context) : Colors.grey.shade600,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? AppColors.textPrimary(context)
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null
                        ? file.path.split('/').last
                        : existingPath != null && existingPath.isNotEmpty
                            ? (showPreview ? 'Tap untuk lihat/edit' : 'Tap untuk lihat')
                            : enabled
                                ? 'Tap untuk upload'
                                : 'Tidak dapat diubah',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasDocument ? Icons.visibility : Icons.upload_file,
              color: hasDocument
                  ? AppColors.primary(context)
                  : enabled
                      ? AppColors.primary(context)
                      : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentOptions(String label, String? documentPath, bool canEdit, VoidCallback onEdit) {
    if (documentPath == null || documentPath.isEmpty) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: AppColors.primary(context),
                ),
                title: const Text('Lihat Dokumen'),
                onTap: () {
                  Navigator.pop(context);
                  final fileUrl = FileUtils.buildFileUrl(documentPath);
                  final fileName = documentPath.split('/').last;
                  
                  if (FileUtils.isPdf(documentPath)) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewer(
                          documentUrl: fileUrl,
                          documentName: fileName,
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => ImageViewer(
                          imageUrl: fileUrl,
                          imageName: fileName,
                        ),
                      ),
                    );
                  }
                },
              ),
              if (canEdit)
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: AppColors.primary(context),
                  ),
                  title: const Text('Ganti Dokumen'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
          builder: (modalContext) => _buildOccupationSearchModal(
            modalContext: modalContext,
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
              ? AppColors.bgDashboardCard(context)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.softBorder(context),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: occupationsAsync.when(
                data: (occupations) {
                  if (_selectedOccupation != null) {
                    final selected = occupations.firstWhere(
                      (o) => o['occupation_id'].toString() == _selectedOccupation,
                      orElse: () => {'occupation_name': 'Pilih pekerjaan'},
                    );
                    return Text(
                      selected['occupation_name'] ?? 'Pilih pekerjaan',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary(context),
                      ),
                    );
                  }
                  return Text(
                    'Pilih pekerjaan',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary(context),
                    ),
                  );
                },
                loading: () => Text(
                  'Memuat pekerjaan...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                error: (_, __) => Text(
                  'Error memuat pekerjaan',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.redAccentLight,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.search,
              size: 20,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupationSearchModal({
    required BuildContext modalContext,
    required TextEditingController controller,
    required AsyncValue<List<Map<String, dynamic>>> occupationsAsync,
    required String hintText,
    required bool isDark,
    required Function(String?) onChanged,
    required Function(String) onSearch,
  }) {
    return Container(
      height: MediaQuery.of(modalContext).size.height * 0.7,
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
                  color: AppColors.textSecondary(modalContext),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary(modalContext),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.bgDashboardCard(modalContext)
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
                      'Tidak ada pekerjaan ditemukan',
                      style: TextStyle(
                        color: AppColors.textSecondary(modalContext),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: occupations.length,
                  itemBuilder: (context, index) {
                    final occupation = occupations[index];
                    final occupationId = occupation['occupation_id'].toString();
                    final occupationName = occupation['occupation_name'] ?? '';
                    final isSelected = _selectedOccupation == occupationId;

                    return ListTile(
                      title: Text(
                        occupationName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary(modalContext)
                              : AppColors.textPrimary(modalContext),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary(modalContext),
                            )
                          : null,
                      onTap: () {
                        onChanged(occupationId);
                        Navigator.pop(modalContext);
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
                  'Error: ${error.toString()}',
                  style: TextStyle(
                    color: AppColors.redAccentLight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final residentId = widget.member['resident_id']?.toString();
    if (residentId == null || residentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID resident tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final residentService = ResidentService(authService);

      // Call service method to handle all updates
      await residentService.updateResidentComplete(
        residentId: residentId,
        profileImage: _profileImage,
        ktpImage: _ktpImage,
        name: _nameController.text,
        phone: _phoneController.text,
        placeOfBirth: _placeOfBirthController.text,
        gender: _selectedGender,
        familyRole: _selectedRole,
        religion: _selectedReligion,
        bloodType: _selectedBloodType,
        occupationId: _selectedOccupation != null 
            ? int.tryParse(_selectedOccupation!) 
            : null,
      );

      // Refresh family data
      ref.read(myFamilyProvider.notifier).fetchMyFamily();

      // Close page with success
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Hide loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
