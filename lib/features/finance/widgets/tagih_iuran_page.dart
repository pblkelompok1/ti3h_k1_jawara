import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/provider/finance_service_provider.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';

class TagihIuranPage extends ConsumerStatefulWidget {
  const TagihIuranPage({super.key});

  @override
  ConsumerState<TagihIuranPage> createState() => _TagihIuranPageState();
}

class _TagihIuranPageState extends ConsumerState<TagihIuranPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nominalCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  
  DateTime? _selectedDueDate;
  String? _selectedKategori;
  bool isSubmitting = false;

  final List<String> _kategoriList = [
    "Iuran Rutin Bulanan",
    "Iuran Kebersihan",
    "Iuran Keamanan",
    "Iuran Kas Warga",
    "Iuran Kegiatan",
    "Iuran Sosial",
    "Dana Darurat",
    "Iuran Pembangunan",
    "Iuran Perbaikan Fasilitas",
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nominalCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Pilih Tenggat Waktu',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori harus dipilih')),
      );
      return;
    }

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tenggat waktu harus dipilih')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary(context)),
            const SizedBox(width: 12),
            const Text(
              "Konfirmasi Tagihan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow("Nama Iuran", _nameCtrl.text),
            _buildConfirmRow("Nominal", "Rp ${_nominalCtrl.text}"),
            _buildConfirmRow("Kategori", _selectedKategori!),
            _buildConfirmRow(
              "Tenggat Waktu",
              "${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}",
            ),
            if (_descCtrl.text.isNotEmpty)
              _buildConfirmRow("Deskripsi", _descCtrl.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
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
                    context.go('/start');
                  }
                  return;
                }

                final nominal = double.tryParse(
                      _nominalCtrl.text.replaceAll(',', '').replaceAll('.', ''),
                    ) ?? 0;

                final now = DateTime.now();
                final chargeDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                final dueDate = '${_selectedDueDate!.year}-${_selectedDueDate!.month.toString().padLeft(2, '0')}-${_selectedDueDate!.day.toString().padLeft(2, '0')}';

                final financeService = ref.read(financeServiceProvider);

                final result = await financeService.createFee(
                  feeName: _nameCtrl.text.trim(),
                  amount: nominal,
                  chargeDate: chargeDate,
                  dueDate: dueDate,
                  description: _descCtrl.text.trim().isEmpty ? '-' : _descCtrl.text.trim(),
                  feeCategory: _selectedKategori!,
                );

                if (mounted) {
                  final transactionsCreated = result['transactions_created'] ?? 0;
                  
                  context.pop(); // Back to previous screen

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Iuran berhasil ditagih ke $transactionsCreated keluarga",
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuat tagihan: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => isSubmitting = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Tagih",
              style: TextStyle(color: AppColors.textPrimaryReverse(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (isRequired)
            Text(
              " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Tagih Iuran",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary(context).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary(context),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tagihan akan dikirim ke semua warga yang terdaftar",
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildFieldLabel("Nama Iuran"),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Nama iuran wajib diisi" : null,
                decoration: InputDecoration(
                  hintText: "Contoh: Iuran Kebersihan Januari",
                  filled: true,
                  fillColor: AppColors.bgPrimaryInputBox(context),
                  prefixIcon: Icon(
                    Icons.receipt_long,
                    color: AppColors.textSecondary(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.softBorder(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                      width: 2,
                    ),
                  ),
                ),
              ),

              _buildFieldLabel("Nominal per KK"),
              TextFormField(
                controller: _nominalCtrl,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Nominal wajib diisi" : null,
                decoration: InputDecoration(
                  hintText: "Masukkan jumlah nominal",
                  filled: true,
                  fillColor: AppColors.bgPrimaryInputBox(context),
                  prefixIcon: Icon(
                    Icons.payments,
                    color: AppColors.textSecondary(context),
                  ),
                  prefixText: "Rp ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.softBorder(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                      width: 2,
                    ),
                  ),
                ),
              ),

              _buildFieldLabel("Kategori"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimaryInputBox(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.softBorder(context)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedKategori,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary(context),
                    ),
                    hint: Text(
                      "Pilih kategori iuran",
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                    items: _kategoriList
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(k),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedKategori = v),
                  ),
                ),
              ),

              _buildFieldLabel("Tenggat Waktu Pembayaran"),
              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimaryInputBox(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.softBorder(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDueDate == null
                              ? "Pilih tanggal jatuh tempo"
                              : "${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}",
                          style: TextStyle(
                            color: _selectedDueDate == null
                                ? AppColors.textSecondary(context)
                                : AppColors.textPrimary(context),
                            fontWeight: _selectedDueDate == null
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textSecondary(context),
                      ),
                    ],
                  ),
                ),
              ),

              _buildFieldLabel("Deskripsi", isRequired: false),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tambahkan keterangan tambahan (opsional)",
                  filled: true,
                  fillColor: AppColors.bgPrimaryInputBox(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.softBorder(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    disabledBackgroundColor:
                        AppColors.primary(context).withOpacity(0.6),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color: AppColors.textPrimaryReverse(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Tagih Iuran",
                              style: TextStyle(
                                color: AppColors.textPrimaryReverse(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
