import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class TagihIuranPage extends StatefulWidget {
  const TagihIuranPage({super.key});

  @override
  State<TagihIuranPage> createState() => _TagihIuranPageState();
}

class _TagihIuranPageState extends State<TagihIuranPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nominalCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String? _selectedKategori;
  String? _selectedHari;
  int? _selectedMinggu;

  bool isAuto = false;

  final List<String> _kategoriList = [
    "Iuran Rutin",
    "Mingguan",
    "Sumbangan",
    "Darurat",
  ];

  final List<String> _hariList = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  int _getWeekNumber(DateTime date) {
    int weekIndex = ((date.day - 1) / 7).floor() + 1;
    return weekIndex.clamp(1, 4);
  }

  void _autoFill() {
    final now = DateTime.now();
    final hari = _hariList[now.weekday - 1];
    final minggu = _getWeekNumber(now);

    setState(() {
      _selectedHari = hari;
      _selectedMinggu = minggu;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${_nameCtrl.text}"),
            Text("Nominal: ${_nominalCtrl.text}"),
            Text("Kategori: ${_selectedKategori ?? '-'}"),
            Text("Hari: ${_selectedHari ?? '-'}"),
            Text("Minggu ke: ${_selectedMinggu ?? '-'}"),
            Text("Deskripsi: ${_descCtrl.text.isEmpty ? '-' : _descCtrl.text}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Kembali"),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Iuran berhasil ditagih (simulasi)"),
                ),
              );
            },
            child: const Text("Tagih"),
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
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Iuran"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                decoration: InputDecoration(
                  hintText: "Masukkan nama pemasukan",
                  filled: true,
                  fillColor: AppColors.bgPrimaryInputBox(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text("Nominal"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nominalCtrl,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                decoration: InputDecoration(
                  hintText: "Masukkan nominal",
                  filled: true,
                  fillColor: AppColors.bgPrimaryInputBox(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text("Kategori"),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimaryInputBox(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.softBorder(context)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedKategori,
                    isExpanded: true,
                    hint: const Text("Pilih kategori"),
                    items: _kategoriList
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedKategori = v),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isAuto,
                    onChanged: (v) {
                      setState(() => isAuto = v ?? false);
                      if (isAuto) _autoFill();
                    },
                  ),
                  const Text("Tagih Otomatis"),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hari"),
                        const SizedBox(height: 6),
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
                              value: _selectedHari,
                              hint: const Text("Pilih hari"),
                              isExpanded: true,
                              items: _hariList
                                  .map(
                                    (h) => DropdownMenuItem(
                                      value: h,
                                      child: Text(h),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedHari = v),
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
                        const Text("Minggu ke"),
                        const SizedBox(height: 6),
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
                            child: DropdownButton<int>(
                              value: _selectedMinggu,
                              hint: const Text("Pilih minggu"),
                              isExpanded: true,
                              items: List.generate(
                                4,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text("Minggu ${i + 1}"),
                                ),
                              ),
                              onChanged: (v) =>
                                  setState(() => _selectedMinggu = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Text("Deskripsi"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Masukkan deskripsi",
                  filled: true,
                  fillColor: AppColors.bgPrimaryInputBox(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 30),
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
                    "Tagih",
                    style: TextStyle(
                      color: AppColors.textPrimaryReverse(context),
                      fontWeight: FontWeight.w700,
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
}
