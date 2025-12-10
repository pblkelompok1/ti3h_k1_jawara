import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/services/finance_service.dart';
import 'package:ti3h_k1_jawara/core/provider/auth_service_provider.dart';
import 'family_transaction_detail_page.dart';

class DetailTagihanPage extends ConsumerStatefulWidget {
  final String? feeId; // Make required later when all callers pass it
  final String kategori;
  final String judul;
  final String amount;
  final String? chargeDate;
  final String? dueDate;
  final String? description;

  const DetailTagihanPage({
    super.key,
    this.feeId,
    required this.kategori,
    required this.judul,
    required this.amount,
    this.chargeDate,
    this.dueDate,
    this.description,
  });

  @override
  ConsumerState<DetailTagihanPage> createState() => _DetailTagihanPageState();
}

class _DetailTagihanPageState extends ConsumerState<DetailTagihanPage> {
  String selectedStatus = "Semua";
  List<Map<String, dynamic>> warga = [];
  int sudahBayar = 0;
  int belumBayar = 0;
  int pending = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Defer heavy operations to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.feeId != null) {
        _fetchFeeWithFamilies();
      } else {
        // Fallback to dummy data if no feeId provided
        _generateDummyData();
        setState(() => isLoading = false);
      }
    });
  }

  Future<void> _fetchFeeWithFamilies() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final authService = ref.read(authServiceProvider);
      final financeService = FinanceService(authService: authService);
      
      final response = await financeService.getFeeWithFamilies(
        feeId: widget.feeId!,
        offset: 0,
        limit: 100,
      );

      // Map families to warga format
      final families = (response['families'] as List?) ?? [];
      warga = families.map<Map<String, dynamic>>((family) {
        final transaction = family['transaction'] as Map<String, dynamic>?;
        final status = transaction?['status'] as String? ?? 'unpaid';
        
        // Map backend status to Indonesian
        String statusIndo;
        switch (status.toLowerCase()) {
          case 'paid':
            statusIndo = 'Lunas';
            break;
          case 'pending':
            statusIndo = 'Tertunda';
            break;
          case 'unpaid':
          default:
            statusIndo = 'Belum Lunas';
            break;
        }

        // Convert amount to double (backend might send int or double)
        final rawAmount = transaction?['amount'];
        final amountDouble = rawAmount != null 
            ? (rawAmount is int ? rawAmount.toDouble() : rawAmount as double?)
            : null;

        return {
          'family_id': family['family_id'],
          'nama': family['family_name'] ?? 'Unknown',
          'alamat': family['address'] ?? '-',
          'status': statusIndo,
          'fee_transaction_id': transaction?['fee_transaction_id'],
          'transaction_date': transaction?['transaction_date'],
          'amount': amountDouble,
          'transaction_method': transaction?['transaction_method'],
          'evidence_path': transaction?['evidence_path'],
        };
      }).toList();

      // Calculate statistics
      sudahBayar = warga.where((w) => w['status'] == 'Lunas').length;
      pending = warga.where((w) => w['status'] == 'Tertunda').length;
      belumBayar = warga.where((w) => w['status'] == 'Belum Lunas').length;

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _generateDummyData() {
    final random = Random();
    final totalWarga = 4 + random.nextInt(5); // 4-8 keluarga
    final statuses = ['Lunas', 'Tertunda', 'Belum Lunas'];
    final bloks = ['A', 'B', 'C', 'D'];
    final names = [
      'Budi Santoso', 'Siti Aminah', 'Ahmad Fauzi', 'Dewi Lestari',
      'Eko Prasetyo', 'Fitri Handayani', 'Gatot Subroto', 'Hani Kusuma',
      'Indra Wijaya', 'Joko Susilo', 'Kartika Sari', 'Lina Marlina',
    ];

    warga = List.generate(totalWarga, (i) {
      final blok = bloks[random.nextInt(bloks.length)];
      final noRumah = 1 + random.nextInt(99);
      return {
        'nama': names[i % names.length],
        'alamat': 'Blok $blok - No.$noRumah',
        'status': statuses[random.nextInt(statuses.length)],
      };
    });

    // Calculate statistics
    sudahBayar = warga.where((w) => w['status'] == 'Lunas').length;
    pending = warga.where((w) => w['status'] == 'Tertunda').length;
    belumBayar = warga.where((w) => w['status'] == 'Belum Lunas').length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        title: Text(
          "Detail Iuran",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.feeId != null) {
                            _fetchFeeWithFamilies();
                          } else {
                            _generateDummyData();
                            setState(() => isLoading = false);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(context, isDark),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final filtered = warga.where((w) {
      if (selectedStatus == "Semua") return true;
      return w["status"] == selectedStatus;
    }).toList();

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ----- HEADER -----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(widget.judul,
                          style: TextStyle(
                            color: AppColors.textPrimaryReverse(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(widget.kategori,
                          style: TextStyle(
                            color: AppColors.textPrimaryReverse(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Divider(color: AppColors.softBorder(context), thickness: 1),
                  const SizedBox(height: 18),

                  _infoRow("Jumlah Iuran", widget.amount, Icons.payments_outlined, context),
                  const SizedBox(height: 16),
                  
                  if (widget.chargeDate != null) ...[
                    _infoRow("Tanggal Tagih", widget.chargeDate!, Icons.calendar_today_outlined, context),
                    const SizedBox(height: 16),
                  ],
                  
                  if (widget.dueDate != null) ...[
                    _infoRow("Jatuh Tempo", widget.dueDate!, Icons.event_outlined, context),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 8),
                  Divider(color: AppColors.softBorder(context), thickness: 1),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      _statCard("Lunas", sudahBayar.toString(), Colors.green, context),
                      const SizedBox(width: 8),
                      _statCard("Tertunda", pending.toString(), Colors.orange, context),
                      const SizedBox(width: 8),
                      _statCard("Belum Lunas", belumBayar.toString(), Colors.red, context),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // FILTER STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status Pembayaran",
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.softBorder(context)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: "Semua", child: Text("Semua")),
                        DropdownMenuItem(value: "Lunas", child: Text("Lunas")),
                        DropdownMenuItem(value: "Tertunda", child: Text("Tertunda")),
                        DropdownMenuItem(value: "Belum Lunas", child: Text("Belum Lunas")),
                      ],
                      onChanged: (v) => setState(() => selectedStatus = v!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // LIST WARGA
            ...filtered.map((w) => _wargaItem(context, w)),

          ],
        ),
    );
  }

  Widget _infoRow(String title, String val, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String count, Color color, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _wargaItem(BuildContext context, Map<String, dynamic> w) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color = w["status"] == "Lunas"
        ? Colors.green
        : w["status"] == "Tertunda"
            ? Colors.orange
            : Colors.red;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FamilyTransactionDetailPage(
              familyData: w,
              feeTitle: widget.judul,
              feeAmount: widget.amount,
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary(context).withOpacity(.15),
              child: Icon(Icons.person, color: AppColors.primary(context)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w["nama"],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(w["alamat"],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      )),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                w["status"],
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
