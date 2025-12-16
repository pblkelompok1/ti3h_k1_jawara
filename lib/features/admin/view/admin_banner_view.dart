import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ti3h_k1_jawara/core/models/banner_model.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class AdminBannerView extends StatefulWidget {
  const AdminBannerView({super.key});

  @override
  State<AdminBannerView> createState() => _AdminBannerViewState();
}

class _AdminBannerViewState extends State<AdminBannerView> {
  late List<BannerModel> _bannerList;
  String _filterLokasi = 'semua';
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _bannerList = [
      BannerModel(
        id: '001',
        judul: 'Flash Sale 12.12',
        deskripsi: 'Diskon hingga 80% untuk semua kategori',
        imageUrl: 'https://via.placeholder.com/600x300?text=Flash+Sale+12.12',
        tipePromo: 'flash_sale',
        lokasi: 'dashboard',
        urutan: 1,
        aktif: true,
        tanggalMulai: DateTime.now(),
        tanggalSelesai: DateTime.now().add(const Duration(days: 2)),
        linkTujuan: '/marketplace',
        dibuat: DateTime.now().subtract(const Duration(days: 5)),
      ),
      BannerModel(
        id: '002',
        judul: 'Super Brand Day Xiaomi',
        deskripsi: 'Dapatkan cashback hingga Rp 500rb',
        imageUrl: 'https://via.placeholder.com/600x300?text=Super+Brand+Day',
        tipePromo: 'super_brand_day',
        lokasi: 'marketplace',
        urutan: 2,
        aktif: true,
        tanggalMulai: DateTime.now(),
        tanggalSelesai: DateTime.now().add(const Duration(days: 1)),
        linkTujuan: '/marketplace',
        dibuat: DateTime.now().subtract(const Duration(days: 3)),
      ),
      BannerModel(
        id: '003',
        judul: 'Promo Gratis Ongkos Kirim',
        deskripsi: 'Gratis ongkir untuk pembelian minimum Rp 50rb',
        imageUrl: 'https://via.placeholder.com/600x300?text=Gratis+Ongkir',
        tipePromo: 'regular',
        lokasi: 'dashboard',
        urutan: 3,
        aktif: false,
        tanggalMulai: DateTime.now().subtract(const Duration(days: 7)),
        tanggalSelesai: DateTime.now().subtract(const Duration(days: 2)),
        linkTujuan: '/marketplace',
        dibuat: DateTime.now().subtract(const Duration(days: 10)),
      ),
      BannerModel(
        id: '004',
        judul: 'Hemat Belanja Kebutuhan Rumah',
        deskripsi: 'Belanja kebutuhan rumah jadi lebih hemat',
        imageUrl: 'https://via.placeholder.com/600x300?text=Kebutuhan+Rumah',
        tipePromo: 'seasonal',
        lokasi: 'marketplace',
        urutan: 4,
        aktif: true,
        tanggalMulai: DateTime.now().subtract(const Duration(days: 1)),
        tanggalSelesai: DateTime.now().add(const Duration(days: 5)),
        linkTujuan: '/marketplace',
        dibuat: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<BannerModel> get _filteredBanner {
    return _bannerList.where((banner) {
      bool lokasiMatch =
          _filterLokasi == 'semua' || banner.lokasi == _filterLokasi;
      bool statusMatch = _filterStatus == 'semua' ||
          (_filterStatus == 'aktif' && banner.aktif) ||
          (_filterStatus == 'nonaktif' && !banner.aktif);
      return lokasiMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text(
          'Kelola Banner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerDialog(context),
        label: const Text('Tambah Banner'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: AppColors.surface(context),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Semua',
                        value: 'semua',
                        isLocation: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Dashboard',
                        value: 'dashboard',
                        isLocation: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Marketplace',
                        value: 'marketplace',
                        isLocation: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Semua',
                        value: 'semua',
                        isLocation: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Aktif',
                        value: 'aktif',
                        isLocation: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Nonaktif',
                        value: 'nonaktif',
                        isLocation: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Banner List
          Expanded(
            child: _filteredBanner.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: AppColors.textSecondary(context)
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada banner',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredBanner.length,
                    itemBuilder: (context, index) {
                      return _BannerCard(
                        key: ValueKey(_filteredBanner[index].id),
                        banner: _filteredBanner[index],
                        onEdit: () => _showBannerDialog(context,
                            banner: _filteredBanner[index]),
                        onDelete: () =>
                            _deleteBanner(_filteredBanner[index].id),
                        onToggle: () =>
                            _toggleBannerStatus(_filteredBanner[index]),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final banner = _filteredBanner.removeAt(oldIndex);
                        _filteredBanner.insert(newIndex, banner);
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isLocation,
  }) {
    final isSelected = isLocation
        ? _filterLokasi == value
        : _filterStatus == value;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          if (isLocation) {
            _filterLokasi = value;
          } else {
            _filterStatus = value;
          }
        });
      },
      backgroundColor: AppColors.surface(context),
      selectedColor: AppColors.primary(context),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : AppColors.textSecondary(context),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  void _showBannerDialog(BuildContext context, {BannerModel? banner}) {
    final isEdit = banner != null;
    final judulController = TextEditingController(text: banner?.judul ?? '');
    final deskripsiController =
        TextEditingController(text: banner?.deskripsi ?? '');
    final linkController =
        TextEditingController(text: banner?.linkTujuan ?? '');
    String selectedTipe = banner?.tipePromo ?? 'regular';
    String selectedLokasi = banner?.lokasi ?? 'dashboard';
    bool isAktif = banner?.aktif ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Banner' : 'Tambah Banner Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Judul',
                  controller: judulController,
                  context: context,
                ),
                const SizedBox(height: 12),
                _buildTextFormField(
                  label: 'Deskripsi',
                  controller: deskripsiController,
                  context: context,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildTextFormField(
                  label: 'Link Tujuan (opsional)',
                  controller: linkController,
                  context: context,
                  hint: '/marketplace',
                ),
                const SizedBox(height: 12),
                Text(
                  'Tipe Promo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: selectedTipe,
                  isExpanded: true,
                  items: ['flash_sale', 'super_brand_day', 'regular', 'seasonal']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              _getTipeText(e),
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedTipe = value ?? 'regular'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: selectedLokasi,
                  isExpanded: true,
                  items: ['dashboard', 'marketplace']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedLokasi = value ?? 'dashboard'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isAktif,
                      onChanged: (value) =>
                          setState(() => isAktif = value ?? true),
                    ),
                    Text(
                      'Banner Aktif',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEdit) {
                            _editBanner(
                              banner!.copyWith(
                                judul: judulController.text,
                                deskripsi: deskripsiController.text,
                                tipePromo: selectedTipe,
                                lokasi: selectedLokasi,
                                aktif: isAktif,
                                linkTujuan: linkController.text,
                                diubah: DateTime.now(),
                              ),
                            );
                          } else {
                            _addBanner(
                              judul: judulController.text,
                              deskripsi: deskripsiController.text,
                              tipePromo: selectedTipe,
                              lokasi: selectedLokasi,
                              linkTujuan: linkController.text,
                            );
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(isEdit ? 'Simpan' : 'Tambah'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label',
            hintStyle: TextStyle(
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  String _getTipeText(String tipe) {
    switch (tipe) {
      case 'flash_sale':
        return '⚡ Flash Sale';
      case 'super_brand_day':
        return '🎉 Super Brand Day';
      case 'regular':
        return '📢 Regular';
      case 'seasonal':
        return '🎄 Seasonal';
      default:
        return tipe;
    }
  }

  void _addBanner({
    required String judul,
    required String deskripsi,
    required String tipePromo,
    required String lokasi,
    required String linkTujuan,
  }) {
    setState(() {
      _bannerList.add(
        BannerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          judul: judul,
          deskripsi: deskripsi,
          tipePromo: tipePromo,
          lokasi: lokasi,
          urutan: _bannerList.length + 1,
          aktif: true,
          linkTujuan: linkTujuan.isNotEmpty ? linkTujuan : null,
          dibuat: DateTime.now(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Banner berhasil ditambahkan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editBanner(BannerModel updatedBanner) {
    setState(() {
      final index = _bannerList.indexWhere((b) => b.id == updatedBanner.id);
      if (index != -1) {
        _bannerList[index] = updatedBanner;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Banner berhasil diperbarui'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteBanner(String bannerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Banner'),
        content: const Text('Apakah Anda yakin ingin menghapus banner ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _bannerList.removeWhere((b) => b.id == bannerId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Banner berhasil dihapus'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _toggleBannerStatus(BannerModel banner) {
    _editBanner(banner.copyWith(aktif: !banner.aktif));
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _BannerCard({
    required Key key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle, color: AppColors.textSecondary(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.judul,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner.deskripsi,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: banner.aktif ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    banner.aktif ? 'AKTIF' : 'NONAKTIF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text(_getTipeText(banner.tipePromo)),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 10),
                ),
                const SizedBox(width: 6),
                Chip(
                  label: Text(banner.lokasi.toUpperCase()),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.orange.shade100,
                  labelStyle: TextStyle(color: Colors.orange.shade700, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    banner.aktif ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue,
                    size: 20,
                  ),
                  tooltip: banner.aktif ? 'Nonaktifkan' : 'Aktifkan',
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTipeText(String tipe) {
    switch (tipe) {
      case 'flash_sale':
        return '⚡ Flash Sale';
      case 'super_brand_day':
        return '🎉 Super Brand Day';
      case 'regular':
        return '📢 Regular';
      case 'seasonal':
        return '🎄 Seasonal';
      default:
        return tipe;
    }
  }
}
