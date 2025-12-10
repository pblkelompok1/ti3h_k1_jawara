import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/services/finance_service.dart';
import 'qr_transaksi_page.dart';
import 'package:flutter/services.dart';

class DetailTagihanPribadiPage extends StatefulWidget {
  final bool isDark;
  final int feeTransactionId;
  final String kategori;
  final String judul;
  final String amount;
  final String dueDate;
  final FinanceService financeService;

  const DetailTagihanPribadiPage({
    super.key,
    required this.isDark,
    required this.feeTransactionId,
    required this.kategori,
    required this.judul,
    required this.amount,
    required this.dueDate,
    required this.financeService,
  });

  @override
  State<DetailTagihanPribadiPage> createState() =>
      _DetailTagihanPribadiPageState();
}

class _DetailTagihanPribadiPageState extends State<DetailTagihanPribadiPage> {
  String? _selectedMethod;
  File? _bukti;
  final ImagePicker _picker = ImagePicker();
  bool isSubmitting = false;

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (file != null && mounted) {
        setState(() => _bukti = File(file.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memilih gambar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        title: Text(
          "Tagihan Pribadi",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeroCard(context),

            const SizedBox(height: 30),
            _sectionTitle(context, "Detail Pembayaran"),

            GestureDetector(
              onTap: () => _choosePaymentMethod(context),
              child: _info(
                "Metode Pembayaran",
                _selectedMethod ?? "Pilih metode",
                Icons.credit_card,
                context,
                selectable: true,
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedMethod == "Cash")
              _buildCashSection(context),

            if (_selectedMethod == "Transfer Bank")
              _buildTransferSection(context),

            if (_selectedMethod == "QRIS")
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: QRTransaksiWidget(
                  isDark: widget.isDark,
                  amount: widget.amount,
                  judul: widget.judul,
                  nama: "Nama User",
                ),
              ),

            if (_selectedMethod == "QRIS") _buildQRISUploadSection(context),

            if (_selectedMethod == null) _buildChooseMethodButton(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary(context),
            AppColors.primary(context).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            _getCategoryIcon(widget.kategori),
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 10),

          _badge(widget.kategori),
          const SizedBox(height: 10),

          Text(
            widget.judul,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 16),
          Text(
            "Total Tagihan",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String kategori) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(kategori, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _info(
    String title,
    String value,
    IconData icon,
    BuildContext context, {
    bool selectable = false,
  }) {
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$title\n$value",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
              ),
            ),
          ),
          if (selectable)
            Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
        ],
      ),
    );
  }

  Widget _buildTransferSection(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softBorder(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Bank", "BCA", context),
              _buildCopyRow(context, "No. Rekening", "1234567890"),
              _buildInfoRow("Atas Nama", "PT Digital Payment", context),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _sectionTitle(context, "Upload Bukti Pembayaran"),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.4)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBorder(context)),
            ),
            child: _bukti == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        "Klik untuk upload bukti pembayaran",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_bukti!, fit: BoxFit.cover),
                  ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_bukti == null || isSubmitting)
                ? null
                : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_bukti == null || isSubmitting)
                  ? Colors.grey
                  : AppColors.primary(context),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Kirim Bukti Pembayaran",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseMethodButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _choosePaymentMethod(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Pilih Metode Pembayaran",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _choosePaymentMethod(BuildContext context) {
    final isDark = widget.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.32,
          minChildSize: 0.22,
          maxChildSize: 0.80,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),

              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.softBorder(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  Text(
                    "Pilih Metode Pembayaran",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildPaymentOption(
                    context,
                    icon: Icons.money,
                    title: "Cash",
                    subtitle: "Bayar tunai (wajib upload bukti)",
                    onTap: () {
                      setState(() {
                        _selectedMethod = "Cash";
                        _bukti = null;
                      });

                      Future.microtask(() {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    context,
                    icon: Icons.qr_code_2,
                    title: "QRIS",
                    subtitle: "Bayar dengan scan QR code",
                    onTap: () {
                      setState(() {
                        _selectedMethod = "QRIS";
                        _bukti = null;
                      });

                      Future.microtask(() {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    context,
                    icon: Icons.account_balance,
                    title: "Transfer Bank",
                    subtitle: "Transfer manual ke rekening",
                    onTap: () {
                      setState(() {
                        _selectedMethod = "Transfer Bank";
                        _bukti = null;
                      });
                      Future.microtask(() {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      });
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.softBorder(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: AppColors.primary(context)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String kategori) {
    if (kategori.isEmpty) return Icons.receipt_long;

    switch (kategori.toLowerCase()) {
      case 'listrik':
        return Icons.flash_on;
      case 'air':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      case 'telepon':
        return Icons.phone;
      default:
        return Icons.receipt_long;
    }
  }

  Widget _buildQRISUploadSection(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _sectionTitle(context, "Upload Bukti Pembayaran QRIS (Wajib)"),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.4)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBorder(context)),
            ),
            child: _bukti == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        "Upload bukti pembayaran QRIS",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_bukti!, fit: BoxFit.cover),
                  ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_bukti == null || isSubmitting)
                ? null
                : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_bukti == null || isSubmitting)
                  ? Colors.grey
                  : AppColors.primary(context),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Kirim Bukti Pembayaran QRIS",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // Submit payment to backend
  Future<void> _submitPayment() async {
    if (_bukti == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bukti pembayaran wajib diupload!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      String transactionMethod;
      if (_selectedMethod == "Cash") {
        transactionMethod = "cash";
      } else if (_selectedMethod == "Transfer Bank") {
        transactionMethod = "transfer";
      } else if (_selectedMethod == "QRIS") {
        transactionMethod = "qris";
      } else {
        throw Exception("Metode pembayaran tidak valid");
      }

      await widget.financeService.updateFeeTransaction(
        feeTransactionId: widget.feeTransactionId,
        transactionMethod: transactionMethod,
        evidenceFilePath: _bukti!.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bukti pembayaran berhasil dikirim! Menunggu konfirmasi admin."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back and refresh
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim bukti pembayaran: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // Build Cash section with evidence upload
  Widget _buildCashSection(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softBorder(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary(context), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pastikan Anda telah membayar secara tunai kepada pengurus",
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _sectionTitle(context, "Upload Bukti Pembayaran (Wajib)"),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.4)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBorder(context)),
            ),
            child: _bukti == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        "Klik untuk upload bukti pembayaran cash",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_bukti!, fit: BoxFit.cover),
                  ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_bukti == null || isSubmitting)
                ? null
                : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_bukti == null || isSubmitting)
                  ? Colors.grey
                  : AppColors.primary(context),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Kirim Bukti Pembayaran",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label kecil ("No. Rekening")
          Text(
            "$label:",
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nomor rekening (warna oranye seperti di gambar)
              Text(
                value.replaceAllMapped(
                  RegExp(r".{4}"),
                  (m) => "${m.group(0)} ",
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange, // warna sama seperti gambar
                ),
              ),

              // Tombol SALIN
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nomor rekening disalin"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Text(
                  "SALIN",
                  style: TextStyle(
                    color: AppColors.primary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
