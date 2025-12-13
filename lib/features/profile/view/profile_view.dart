import 'dart:io';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import '../../../core/provider/auth_service_provider.dart';
import '../provider/profile_provider.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final _religionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _bloodType; // a/b/ab/o
  int? _occupationId;

  bool _editMode = false;
  bool _didInitForm = false;
  String? _lastResidentId;

  bool _isPickingImage = false;

  @override
  void dispose() {
    _religionCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ====== helpers ======
  void _fillEditableFromResident(Map<String, dynamic> r) {
    _religionCtrl.text = (r['religion'] ?? '').toString();
    _phoneCtrl.text = (r['phone'] ?? '').toString();

    final bt = r['blood_type'];
    _bloodType = bt == null ? null : bt.toString().toLowerCase();

    final occ = r['occupation_id'];
    _occupationId = (occ is int) ? occ : int.tryParse((occ ?? '').toString());
  }

  String _normalizeImgUrl(String baseUrl, String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  String _occupationName({
    required int? occupationId,
    required List<Map<String, dynamic>> occupations,
  }) {
    if (occupationId == null) return "-";
    final found = occupations.where((o) {
      final id = (o['occupation_id'] is int)
          ? o['occupation_id'] as int
          : int.tryParse((o['occupation_id'] ?? '').toString());
      return id == occupationId;
    }).toList();
    if (found.isEmpty) return "-";
    return (found.first['occupation_name'] ?? '-').toString();
  }

  String _familyRoleLabel(String raw) {
    final v = raw.toLowerCase();
    switch (v) {
      case 'head':
        return 'Kepala Keluarga';
      case 'wife':
        return 'Istri';
      case 'child':
        return 'Anak';
      case 'other':
        return 'Lainnya';
      default:
        return raw.isEmpty ? '-' : raw;
    }
  }

  String _statusLabel(String raw) {
    final v = raw.toLowerCase();
    switch (v) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return raw.isEmpty ? '-' : raw;
    }
  }

  String _domicileLabel(String raw) {
    final v = raw.toLowerCase();
    switch (v) {
      case 'resident':
      case 'active':
        return 'Active';
      case 'non_resident':
      case 'inactive':
        return 'Inactive';
      default:
        return raw.isEmpty ? '-' : raw;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final v = status.toLowerCase();
    if (v.contains('approved')) return Colors.green;
    if (v.contains('pending')) return Colors.orange;
    if (v.contains('rejected')) return Colors.red;
    return AppColors.textSecondary(context);
  }

  // ====== actions ======
  void _toggleEdit() {
    final loading = ref.read(profileControllerProvider).isLoading;
    if (loading) return;

    setState(() => _editMode = !_editMode);

    final data = ref.read(profileControllerProvider).value;
    if (_editMode && data != null) {
      _fillEditableFromResident(data.resident);
    }
  }

  Future<void> _saveProfile() async {
    final loading = ref.read(profileControllerProvider).isLoading;
    if (!_editMode || loading) return;

    try {
      await ref.read(profileControllerProvider.notifier).updateEditableFields(
            religion: _religionCtrl.text.trim().isEmpty
                ? null
                : _religionCtrl.text.trim(),
            phone:
                _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            bloodType: _bloodType,
            occupationId: _occupationId,
          );

      if (!mounted) return;
      setState(() => _editMode = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil disimpan")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal simpan: $e")),
      );
    }
  }

  Future<void> _pickAndUploadPhoto({required bool loading}) async {
    if (loading) return;
    if (_isPickingImage) return;

    _isPickingImage = true;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      await ref
          .read(profileControllerProvider.notifier)
          .uploadPhoto(File(picked.path));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil berhasil diupdate")),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image picker sedang aktif: ${e.code}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload foto: $e")),
      );
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _openDoc(
    BuildContext context,
    String title,
    String? path,
    String baseUrl,
  ) async {
    if (path == null || path.isEmpty || path == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dokumen tidak tersedia")),
      );
      return;
    }

    final url = _normalizeImgUrl(baseUrl, path);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.86,
          decoration: BoxDecoration(
            color: AppColors.bgDashboardCard(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.textPrimary(context)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Gagal memuat dokumen.\n$url",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);
    final auth = ref.watch(authServiceProvider);
    final loading = profileAsync.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () =>
              ref.read(profileControllerProvider.notifier).refreshAll(),
        ),
        data: (data) {
          final r = data.resident;
          final occupations = data.occupations;

          // init form once / resident changed
          final currentResidentId = (r['resident_id'] ?? '').toString();
          if (_lastResidentId != currentResidentId) {
            _lastResidentId = currentResidentId;
            _didInitForm = false;
          }
          if (!_didInitForm) {
            _fillEditableFromResident(r);
            _didInitForm = true;
          }

          final occName = _occupationName(
            occupationId: (r['occupation_id'] is int)
                ? r['occupation_id'] as int
                : int.tryParse((r['occupation_id'] ?? '').toString()),
            occupations: occupations,
          );

          final imgPath = (r['profile_img_path'] ?? '').toString();
          final imgUrl =
              imgPath.isEmpty ? null : _normalizeImgUrl(auth.baseUrl, imgPath);

          final familyRole = _familyRoleLabel((r['family_role'] ?? '-').toString());
          final domicile = _domicileLabel((r['domicile_status'] ?? '-').toString());
          final status = _statusLabel((r['status'] ?? '-').toString());

          final statusColor = _statusColor(context, (r['status'] ?? '').toString());
          final domicileColor = domicile.toLowerCase().contains('active')
              ? Colors.green
              : Colors.grey;

          return Stack(
            children: [
              _HeaderBackground(color: AppColors.bgDashboardAppHeader(context)),
              SafeArea(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    // Top bar
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        const Text(
                          "Profil",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),

                    // Hero profile
                    _CardShell(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: AppColors.softBorder(context),
                                backgroundImage:
                                    imgUrl != null ? NetworkImage(imgUrl) : null,
                                child: imgUrl == null
                                    ? Icon(Icons.person,
                                        color:
                                            AppColors.textSecondary(context),
                                        size: 30)
                                    : null,
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: InkWell(
                                  onTap: (loading || _isPickingImage)
                                      ? null
                                      : () => _pickAndUploadPhoto(
                                          loading: loading),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Opacity(
                                    opacity: (loading || _isPickingImage)
                                        ? 0.6
                                        : 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: AppColors.softBorder(context),
                                          width: 1,
                                        ),
                                      ),
                                      child: (loading || _isPickingImage)
                                          ? SizedBox(
                                              height: 14,
                                              width: 14,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color:
                                                    AppColors.primary(context),
                                              ),
                                            )
                                          : Icon(Icons.camera_alt_rounded,
                                              size: 16,
                                              color: AppColors.primary(context)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  (r['name'] ?? '-').toString(),
                                  maxLines: 1,
                                  minFontSize: 16,
                                  maxFontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "$familyRole | ${occName.isEmpty ? '-' : occName}",
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _StatusPill(
                                      text: domicile,
                                      color: domicileColor,
                                    ),
                                    _StatusPill(
                                      text: status,
                                      color: statusColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== Card: Informasi Pribadi =====
                    _CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CardHeaderRow(
                            icon: Icons.person_rounded,
                            title: "Informasi Pribadi",
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // save small button ONLY when editMode
                                if (_editMode) ...[
                                  _MiniSaveButton(
                                    disabled: loading,
                                    loading: loading,
                                    onTap: _saveProfile,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                IconButton(
                                  onPressed: loading ? null : _toggleEdit,
                                  icon: Icon(
                                    _editMode
                                        ? Icons.visibility_rounded
                                        : Icons.edit_rounded,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // readonly rows
                          _InfoRow(
                            icon: Icons.badge_rounded,
                            label: "NIK",
                            value: (r['nik'] ?? '-').toString(),
                          ),
                          _InfoRow(
                            icon: Icons.cake_rounded,
                            label: "TTL",
                            value:
                                "${(r['place_of_birth'] ?? '-').toString()}, ${(r['date_of_birth'] ?? '-').toString()}",
                          ),
                          _InfoRow(
                            icon: Icons.wc_rounded,
                            label: "Jenis Kelamin",
                            value: (r['gender'] ?? '-').toString(),
                          ),

                          const SizedBox(height: 10),
                          Divider(color: AppColors.softBorder(context)),
                          const SizedBox(height: 10),

                          // editable section (disabled when not editMode)
                          _EditableRow(
                            enabled: _editMode,
                            icon: Icons.bloodtype_rounded,
                            label: "Gol. Darah",
                            child: _editMode
                                ? _BloodDropdown(
                                    value: _bloodType,
                                    enabled: _editMode,
                                    onChanged: (v) => setState(() => _bloodType = v),
                                  )
                                : _ValuePill(value: ((r['blood_type'] ?? '-').toString()).toUpperCase(),
                                  ),
                          ),
                          _EditableRow(
                            enabled: _editMode,
                            icon: Icons.mosque_rounded,
                            label: "Agama",
                            child: _TextInput(
                              controller: _religionCtrl,
                              hint: "Agama",
                              enabled: _editMode,
                            ),
                          ),
                          _EditableRow(
                            enabled: _editMode,
                            icon: Icons.phone_rounded,
                            label: "No HP",
                            child: _TextInput(
                              controller: _phoneCtrl,
                              hint: "08xxxxxxxxxx",
                              keyboardType: TextInputType.phone,
                              enabled: _editMode,
                            ),
                          ),
                          _EditableRow(
                            enabled: _editMode,
                            icon: Icons.work_rounded,
                            label: "Pekerjaan",
                            child: _editMode
                                ? _OccupationDropdown(
                                    value: _occupationId,
                                    occupations: occupations,
                                    enabled: _editMode,
                                    onChanged: (v) =>
                                        setState(() => _occupationId = v),
                                  )
                                : _ValuePill(value: occName),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== Card: Dokumen Pendukung =====
                    _CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _CardHeaderRow(
                            icon: Icons.folder_copy_rounded,
                            title: "Dokumen Pendukung",
                          ),
                          const SizedBox(height: 12),

                          _DocRow(
                            title: "Lihat KTP",
                            onTap: () => _openDoc(
                              context,
                              "KTP",
                              (r['ktp_path'] ?? '').toString(),
                              auth.baseUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _DocRow(
                            title: "Lihat KK",
                            onTap: () => _openDoc(
                              context,
                              "KK",
                              (r['kk_path'] ?? '').toString(),
                              auth.baseUrl,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _DocRow(
                            title: "Lihat Akta",
                            onTap: () => _openDoc(
                              context,
                              "Akta Kelahiran",
                              (r['birth_certificate_path'] ?? '').toString(),
                              auth.baseUrl,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================== UI widgets ==================

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softBorder(context), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeaderRow extends StatelessWidget {
  const _CardHeaderRow({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.primary(context).withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary(context), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
              fontSize: 14,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.40), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }
}

class _MiniSaveButton extends StatelessWidget {
  const _MiniSaveButton({
    required this.disabled,
    required this.loading,
    required this.onTap,
  });

  final bool disabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: disabled ? 0.6 : 1,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary(context)),
          const SizedBox(width: 10),

          // LABEL (kiri)
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // VALUE (kanan, selalu sejajar)
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.enabled,
    required this.icon,
    required this.label,
    required this.child,
  });

  final bool enabled;
  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary(context)),
          const SizedBox(width: 10),

          /// LABEL
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.insert_drive_file_rounded,
            size: 18, color: AppColors.textSecondary(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryInputBox(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBorder(context), width: 1),
            ),
            child: Text(
              "Lihat",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.enabled,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.bgPrimaryInputBox(context),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary(context), width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
      ),
    );
  }
}


class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity, 
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryInputBox(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context), width: 1),
      ),
      child: Text(
        value,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BloodDropdown extends StatelessWidget {
  const _BloodDropdown({required this.value, required this.onChanged, required this.enabled});

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const items = ['a', 'b', 'ab', 'o'];

    return DropdownButtonFormField<String>(
      value: value,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.bgPrimaryInputBox(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary(context), width: 1.2),
        ),
      ),
      icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary(context)),
      hint: Text("Pilih", style: TextStyle(color: AppColors.textSecondary(context))),
      items: items
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(
                  v.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _OccupationDropdown extends StatelessWidget {
  const _OccupationDropdown({
    required this.value,
    required this.occupations,
    required this.onChanged,
    required this.enabled,
  });

  final int? value;
  final List<Map<String, dynamic>> occupations;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final items = occupations
        .map((o) {
          final id = (o['occupation_id'] is int)
              ? o['occupation_id'] as int
              : int.tryParse((o['occupation_id'] ?? '').toString());
          final name = (o['occupation_name'] ?? '-').toString();
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();

    return DropdownButtonFormField<int>(
      value: value,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.bgPrimaryInputBox(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softBorder(context), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary(context), width: 1.2),
        ),
      ),
      icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary(context)),
      hint: Text("Pilih", style: TextStyle(color: AppColors.textSecondary(context))),
      items: items,
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.k, required this.v});
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryInputBox(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              k,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 46, color: Colors.red.shade400),
            const SizedBox(height: 10),
            Text("Terjadi error:\n$message", textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Coba lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
