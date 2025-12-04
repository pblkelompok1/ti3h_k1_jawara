import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class AddFinancePage extends StatefulWidget {
  const AddFinancePage({super.key});

  @override
  State<AddFinancePage> createState() => _AddFinancePageState();
}

class _AddFinancePageState extends State<AddFinancePage> {
  final _formKey = GlobalKey<FormState>();

  bool isIncome = true;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nominalCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  final TextEditingController _descCtrl = TextEditingController();
  String? _imageUrl;

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

  Future<void> _showImageUrlDialog() async {
    final ctrl = TextEditingController(text: _imageUrl ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Upload bukti (URL)'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Masukkan URL gambar'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final url = ctrl.text.trim();
                _imageUrl = url.isEmpty ? null : url;
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final nominal =
        double.tryParse(
          _nominalCtrl.text.replaceAll(',', '').replaceAll('.', ''),
        ) ??
        0;

    final date = _selectedDate;
    final category = _selectedCategory ?? _categories.first;
    final desc = _descCtrl.text.trim();
    final type = isIncome ? 'Pemasukan' : 'Pengeluaran';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipe: $type'),
            Text('Nama: $name'),
            Text('Nominal: Rp ${nominal.toStringAsFixed(0)}'),
            Text(
              'Tanggal: ${date != null ? "${date.day}/${date.month}/${date.year}" : "-"}',
            ),
            Text('Kategori: $category'),
            Text('Deskripsi: ${desc.isEmpty ? "-" : desc}'),
            Text('Bukti: ${_imageUrl ?? "-"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data iuran/keuangan berhasil disimpan'),
                ),
              );

              Navigator.of(context).maybePop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
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
          onPressed: () => Navigator.pop(context),
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
                  onTap: _showImageUrlDialog,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimaryInputBox(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.softBorder(context)),
                    ),
                    child: _imageUrl == null
                        ? Center(
                            child: Text(
                              'Upload bukti ${isIncome ? 'pemasukan' : 'pengeluaran'}',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  'Gagal memuat gambar',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
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
