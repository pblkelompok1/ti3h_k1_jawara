import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/provider/resident_service_provider.dart';
import '../provider/resident_providers.dart';
import '../../auth/widget/file_input_widget.dart';

class AddFamilyMemberPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> familyInfo;

  const AddFamilyMemberPage({
    super.key,
    required this.familyInfo,
  });

  @override
  ConsumerState<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends ConsumerState<AddFamilyMemberPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _nikController;
  late TextEditingController _placeOfBirthController;
  late TextEditingController _dateOfBirthController;
  final _occupationSearchController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedRole;
  String? _selectedBloodType;
  String? _selectedReligion;
  String? _selectedOccupation;
  String? _selectedOccupationName;
  
  // Files
  File? _ktpFile;
  File? _kkFile;
  File? _birthCertFile;
  
  bool _isLoading = false;
  bool _isFetchingOccupations = false;
  List<Map<String, dynamic>> _occupations = [];

  // Options
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _roleOptions = [
    'Kepala Keluarga',
    'Istri',
    'Suami',
    'Anak',
    'Orang Tua',
    'Mertua',
    'Cucu',
    'Keponakan',
    'Lainnya'
  ];
  final List<String> _bloodTypeOptions = ['A', 'B', 'AB', 'O', '-'];
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
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _nikController = TextEditingController();
    _placeOfBirthController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    
    // Fetch occupations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOccupations();
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

  Future<void> _fetchOccupations([String? search]) async {
    setState(() => _isFetchingOccupations = true);
    try {
      final residentService = ref.read(residentServiceProvider);
      final occupations = await residentService.getOccupationList(name: search);
      if (mounted) {
        setState(() {
          _occupations = occupations;
          _isFetchingOccupations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingOccupations = false);
      }
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          final file = File(result.files.single.path!);
          switch (type) {
            case 'ktp':
              _ktpFile = file;
              break;
            case 'kk':
              _kkFile = file;
              break;
            case 'birth_cert':
              _birthCertFile = file;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showOccupationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.backgroundDark 
                      : AppColors.backgroundLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.softBorder(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Title & Search
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Pekerjaan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _occupationSearchController,
                            decoration: InputDecoration(
                              hintText: 'Cari pekerjaan...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              _fetchOccupations(value.isEmpty ? null : value);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Occupation List
                    Expanded(
                      child: _isFetchingOccupations
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _occupations.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final occupation = _occupations[index];
                                final isSelected = _selectedOccupation == occupation['occupation_id']?.toString();
                                
                                return ListTile(
                                  title: Text(
                                    occupation['occupation_name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                          ? AppColors.primary(context) 
                                          : AppColors.textPrimary(context),
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle, color: AppColors.primary(context))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedOccupation = occupation['occupation_id']?.toString();
                                      _selectedOccupationName = occupation['occupation_name']?.toString();
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate files
    if (_ktpFile == null || _kkFile == null || _birthCertFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua dokumen (KTP, KK, Akta Lahir)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedOccupation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih pekerjaan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final residentService = ref.read(residentServiceProvider);
      final familyId = widget.familyInfo['family_id']?.toString() ?? '';

      await residentService.createResidentSubmission(
        name: _nameController.text.trim(),
        nik: _nikController.text.trim(),
        placeOfBirth: _placeOfBirthController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        gender: _selectedGender!,
        familyRole: _selectedRole!,
        familyId: familyId,
        occupationId: _selectedOccupation!,
        ktpFile: _ktpFile!,
        kkFile: _kkFile!,
        birthCertificateFile: _birthCertFile!,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        religion: _selectedReligion,
        bloodType: _selectedBloodType,
        domicileStatus: 'active',
        status: 'pending',
      );

      if (mounted) {
        // Refresh family data
        ref.read(myFamilyProvider.notifier).fetchMyFamily();
        
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran anggota keluarga berhasil! Menunggu persetujuan admin.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftarkan: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        title: const Text(
          'Tambah Anggota Keluarga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Family Info (Read-only)
                _buildFamilyInfoCard(isDark),
                
                const SizedBox(height: 24),
                
                // Personal Information Section
                _buildSectionTitle('Informasi Pribadi'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nikController,
                  label: 'NIK',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIK tidak boleh kosong';
                    }
                    if (value.length != 16) {
                      return 'NIK harus 16 digit';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _phoneController,
                  label: 'No. Telepon (Opsional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 16),
                
                _buildDropdownField(
                  label: 'Jenis Kelamin',
                  icon: Icons.wc_outlined,
                  value: _selectedGender,
                  items: _genderOptions,
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _placeOfBirthController,
                  label: 'Tempat Lahir',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tempat lahir tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildDateField(),
                
                const SizedBox(height: 24),
                
                // Family & Religion Section
                _buildSectionTitle('Keluarga & Agama'),
                const SizedBox(height: 16),
                
                _buildDropdownField(
                  label: 'Peran dalam Keluarga',
                  icon: Icons.family_restroom_outlined,
                  value: _selectedRole,
                  items: _roleOptions,
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator: (value) => value == null ? 'Pilih peran keluarga' : null,
                ),
                
                const SizedBox(height: 16),
                
                _buildDropdownField(
                  label: 'Agama',
                  icon: Icons.mosque_outlined,
                  value: _selectedReligion,
                  items: _religionOptions,
                  onChanged: (value) => setState(() => _selectedReligion = value),
                ),
                
                const SizedBox(height: 16),
                
                _buildDropdownField(
                  label: 'Golongan Darah',
                  icon: Icons.water_drop_outlined,
                  value: _selectedBloodType,
                  items: _bloodTypeOptions,
                  onChanged: (value) => setState(() => _selectedBloodType = value),
                ),
                
                const SizedBox(height: 24),
                
                // Occupation Section
                _buildSectionTitle('Pekerjaan'),
                const SizedBox(height: 16),
                
                _buildOccupationSelector(isDark),
                
                const SizedBox(height: 24),
                
                // Documents Section
                _buildSectionTitle('Dokumen'),
                const SizedBox(height: 16),
                
                _buildFileUpload(
                  title: 'KTP',
                  file: _ktpFile,
                  onPick: () => _pickFile('ktp'),
                  required: true,
                  isDark: isDark,
                ),
                
                const SizedBox(height: 12),
                
                _buildFileUpload(
                  title: 'Kartu Keluarga',
                  file: _kkFile,
                  onPick: () => _pickFile('kk'),
                  required: true,
                  isDark: isDark,
                ),
                
                const SizedBox(height: 12),
                
                _buildFileUpload(
                  title: 'Akta Lahir',
                  file: _birthCertFile,
                  onPick: () => _pickFile('birth_cert'),
                  required: true,
                  isDark: isDark,
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Daftar Anggota Keluarga',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.family_restroom,
                color: AppColors.primary(context),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Keluarga',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Keluarga', widget.familyInfo['family_name'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow('Kepala Keluarga', widget.familyInfo['head_name'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow('Jumlah Anggota', '${widget.familyInfo['member_count'] ?? 0} orang'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateOfBirthController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Tanggal Lahir',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.edit_calendar),
          onPressed: _selectDate,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
      ),
      onTap: _selectDate,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Tanggal lahir tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildOccupationSelector(bool isDark) {
    return InkWell(
      onTap: _showOccupationSelector,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedOccupation == null 
                ? Colors.grey.shade400 
                : AppColors.primary(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.work_outline,
              color: _selectedOccupation == null 
                  ? Colors.grey 
                  : AppColors.primary(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedOccupationName ?? 'Pilih Pekerjaan *',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedOccupation == null
                      ? Colors.grey
                      : AppColors.textPrimary(context),
                  fontWeight: _selectedOccupation == null 
                      ? FontWeight.normal 
                      : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUpload({
    required String title,
    required File? file,
    required VoidCallback onPick,
    bool required = false,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        FileInputWidget(
          file: file,
          hintText: 'Pilih file $title',
          isDark: isDark,
          onTap: onPick,
        ),
      ],
    );
  }
}
