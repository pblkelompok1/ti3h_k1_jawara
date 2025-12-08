import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class ReportIssueView extends StatefulWidget {
  const ReportIssueView({super.key});

  @override
  State<ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<ReportIssueView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _contactController = TextEditingController();
  String _category = 'Kebersihan';
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Masalah'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderBanner(isDark: isDark),
              const SizedBox(height: 16),
              _SectionTitle('Detail Keluhan'),
              const SizedBox(height: 12),
              _InputLabel('Kategori'),
              const SizedBox(height: 8),
              _buildDropdown(isDark),
              const SizedBox(height: 16),
              _InputLabel('Judul Masalah'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hint: 'Contoh: Lampu jalan mati di RT 03',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _InputLabel('Deskripsi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descController,
                hint: 'Jelaskan lokasi, waktu, dan detail kejadian',
                isDark: isDark,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _InputLabel('Kontak (opsional)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _contactController,
                hint: 'No. WA atau email',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _AttachmentCard(isDark: isDark),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Petugas akan meninjau dan memberi update secepatnya',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          items: const [
            'Kebersihan',
            'Keamanan',
            'Fasilitas',
            'Lainnya',
          ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _category = val);
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade500),
        filled: true,
        fillColor: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      _showSnack('Judul dan deskripsi wajib diisi');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    _showSnack('Laporan berhasil dikirim');
    Navigator.pop(context);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(context),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(context),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final bool isDark;
  const _AttachmentCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPrimaryInputBoxDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.attachment, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lampiran (opsional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tambah foto/video pendukung',
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur lampiran belum diaktifkan')),
              );
            },
            child: const Text('Pilih'),
          )
        ],
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final bool isDark;
  const _HeaderBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFF42533B);
    final Color iconBg = Colors.white.withOpacity(0.18);
    return Container
(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.report_gmailerrorred_outlined,
                color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'Lapor Masalah',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
