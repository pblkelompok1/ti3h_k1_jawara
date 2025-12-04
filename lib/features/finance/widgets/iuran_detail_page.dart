import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class IuranDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const IuranDetailPage({super.key, required this.data});

  @override
  State<IuranDetailPage> createState() => _IuranDetailPageState();
}

class _IuranDetailPageState extends State<IuranDetailPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _nominalCtrl;
  late TextEditingController _descCtrl;

  String? _selectedKategori;

  bool isEdit = false;

  final List<String> _kategoriList = [
    "Iuran Rutin",
    "Mingguan",
    "Sumbangan",
    "Darurat",
  ];

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.data["title"] ?? "");
    _nominalCtrl = TextEditingController(
      text: widget.data["amount"]?.toString() ?? "",
    );
    _descCtrl = TextEditingController(text: widget.data["desc"] ?? "");

    final kategori = widget.data["category"];
    if (kategori != null && _kategoriList.contains(kategori)) {
      _selectedKategori = kategori;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nominalCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _saveEdit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isEdit = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perubahan berhasil disimpan.")),
    );
  }

  void _delete() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Iuran berhasil dihapus.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.textPrimary(context)),
        title: Text(
          "Detail Iuran",
          style: TextStyle(color: AppColors.textPrimary(context)),
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
                enabled: isEdit,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                decoration: _inputDecoration(context, "Masukkan nama iuran"),
              ),

              const SizedBox(height: 18),
              const Text("Nominal"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nominalCtrl,
                enabled: isEdit,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                decoration: _inputDecoration(context, "Masukkan nominal"),
              ),

              const SizedBox(height: 18),
              const Text("Kategori"),
              const SizedBox(height: 6),
              _dropdown<String>(
                items: _kategoriList,
                value: _selectedKategori,
                onChanged: isEdit
                    ? (v) => setState(() => _selectedKategori = v)
                    : null,
                hint: "Pilih kategori",
              ),

              const SizedBox(height: 18),
              const Text("Deskripsi"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                enabled: isEdit,
                maxLines: 3,
                decoration: _inputDecoration(context, "Masukkan deskripsi"),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isEdit)
                    _button(
                      context,
                      text: "Edit",
                      color: Colors.green.shade300,
                      onTap: () => setState(() => isEdit = true),
                    ),

                  if (!isEdit) const SizedBox(width: 20),

                  if (!isEdit)
                    _button(
                      context,
                      text: "Hapus",
                      color: Colors.red.shade300,
                      onTap: _delete,
                    ),

                  if (isEdit)
                    _button(
                      context,
                      text: "Simpan",
                      color: Colors.green.shade400,
                      onTap: _saveEdit,
                    ),

                  if (isEdit) const SizedBox(width: 20),

                  if (isEdit)
                    _button(
                      context,
                      text: "Batal",
                      color: Colors.grey.shade400,
                      onTap: () => setState(() => isEdit = false),
                    ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.bgPrimaryInputBox(context),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _dropdown<T>({
    required List<T> items,
    required T? value,
    required Function(T?)? onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryInputBox(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context, {
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
