import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';

class AddFinancePage extends ConsumerStatefulWidget {
  const AddFinancePage({super.key});

  @override
  ConsumerState<AddFinancePage> createState() => _AddFinancePageState();
}

class _AddFinancePageState extends ConsumerState<AddFinancePage> {
  final _formKey = GlobalKey<FormState>();

  bool isIncome = true;
  bool isSubmitting = false;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nominalCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  final TextEditingController _descCtrl = TextEditingController();
  String? _filePath;
  String? _fileName;

  final List<String> _categories = [
    'Iuran',
    'Kerja Bakti',
    'Donasi',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nominalCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _filePath = result.files.single.path;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal harus diisi')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori harus dipilih')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Check if user is logged in
      final authService = ref.read(authServiceProvider);
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!isLoggedIn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi anda telah berakhir. Silakan login kembali.'),
              backgroundColor: Colors.orange,
            ),
          );
          context.go('/start'); // Redirect to login
        }
        return;
      }

      final name = _nameCtrl.text.trim();
      final nominal = double.tryParse(
            _nominalCtrl.text.replaceAll(',', '').replaceAll('.', ''),
          ) ??
          0;

      final dateStr = 
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      final financeService = ref.read(financeServiceProvider);

      await financeService.createTransaction(
        name: name,
        amount: nominal,
        category: _selectedCategory!,
        transactionDate: dateStr,
        evidenceFilePath: _filePath,
        isExpense: !isIncome,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isIncome ? "Pemasukan" : "Pengeluaran"} berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop(); // Use GoRouter to pop
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softBorder(context)),
        color: AppColors.bgPrimaryInputBox(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isIncome = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.primary(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pemasukan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isIncome
                        ? AppColors.textPrimaryReverse(context)
                        : AppColors.textPrimary(context),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isIncome = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isIncome
                      ? AppColors.primary(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pengeluaran',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !isIncome
                        ? AppColors.textPrimaryReverse(context)
                        : AppColors.textPrimary(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggle(),

                _buildFieldLabel(
                  'Nama ${isIncome ? 'Pemasukan' : 'Pengeluaran'}',
                ),
                TextFormField(
                  controller: _nameCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama harus diisi' : null,
                  decoration: InputDecoration(
                    hintText:
                        'Masukkan nama ${isIncome ? 'pemasukan' : 'pengeluaran'}',
                    filled: true,
                    fillColor: AppColors.bgPrimaryInputBox(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                _buildFieldLabel('Nominal'),
                TextFormField(
                  controller: _nominalCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nominal harus diisi'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nominal',
                    filled: true,
                    fillColor: AppColors.bgPrimaryInputBox(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(
                            'Tanggal ${isIncome ? 'Pemasukan' : 'Pengeluaran'}',
                          ),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgPrimaryInputBox(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.softBorder(context),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _selectedDate == null
                                    ? 'Pilih tanggal'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Kategori'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgPrimaryInputBox(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.softBorder(context),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                hint: Text(
                                  'Pilih kategori',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                                items: _categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCategory = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildFieldLabel('Deskripsi'),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Masukkan deskripsi',
                    filled: true,
                    fillColor: AppColors.bgPrimaryInputBox(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                _buildFieldLabel('Bukti'),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimaryInputBox(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.softBorder(context)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _filePath == null ? Icons.upload_file : Icons.check_circle,
                          size: 48,
                          color: _filePath == null
                              ? AppColors.textSecondary(context)
                              : Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filePath == null
                              ? 'Tap untuk upload bukti (jpg, png, pdf)'
                              : 'File terpilih: $_fileName',
                          style: TextStyle(
                            color: _filePath == null
                                ? AppColors.textSecondary(context)
                                : AppColors.textPrimary(context),
                            fontWeight: _filePath == null
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: AppColors.primary(context).withOpacity(0.6),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textPrimaryReverse(context),
                              ),
                            ),
                          )
                        : Text(
                            'Simpan',
                            style: TextStyle(
                              color: AppColors.textPrimaryReverse(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
