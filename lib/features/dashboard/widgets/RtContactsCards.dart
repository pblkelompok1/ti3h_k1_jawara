import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class RtContactsCards extends StatelessWidget {
  const RtContactsCards({super.key});

  final List<Map<String, dynamic>> _contacts = const [
    {
      'name': 'Ketua RT',
      'info': 'Bapak Ahmad',
      'phone': '0812-3456-7890',
      'icon': Icons.account_circle_rounded,
      'color': Color(0xFF4285F4),
      'emergency': 'Kontak Darurat Umum',
    },
    {
      'name': 'Sekretaris',
      'info': 'Ibu Siti',
      'phone': '0812-3456-7891',
      'icon': Icons.edit_note_rounded,
      'color': Color(0xFF9C27B0),
      'emergency': 'Administrasi & Surat Menyurat',
    },
    {
      'name': 'Bendahara',
      'info': 'Bapak Budi',
      'phone': '0812-3456-7892',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFFFF9800),
      'emergency': 'Urusan Keuangan & Iuran',
    },
    {
      'name': 'Seksi Keamanan',
      'info': 'Bapak Joko',
      'phone': '0812-3456-7893',
      'icon': Icons.security_rounded,
      'color': Color(0xFFF44336),
      'emergency': 'Darurat Keamanan',
    },
    {
      'name': 'Seksi Kebersihan',
      'info': 'Ibu Dewi',
      'phone': '0812-3456-7894',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF4CAF50),
      'emergency': 'Masalah Kebersihan Lingkungan',
    },
    {
      'name': 'Seksi Sosial',
      'info': 'Bapak Rudi',
      'phone': '0812-3456-7895',
      'icon': Icons.diversity_3_rounded,
      'color': Color(0xFF00BCD4),
      'emergency': 'Kegiatan Sosial & Kemasyarakatan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hubungi Pengurus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            width: double.infinity,
            height: 1.2,
            color: AppColors.softBorder(context), // atau Colors.grey.shade300
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < _contacts.length - 1 ? 12 : 0),
                child: _buildContactCard(
                  context,
                  isDark: isDark,
                  name: _contacts[index]['name']!,
                  info: _contacts[index]['info']!,
                  phone: _contacts[index]['phone']!,
                  icon: _contacts[index]['icon']!,
                  color: _contacts[index]['color']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required bool isDark,
    required String name,
    required String info,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        _showContactDialog(
          context,
          name: name,
          info: info,
          phone: phone,
          icon: icon,
          color: color,
          emergency: _contacts.firstWhere((contact) => contact['name'] == name)['emergency'] as String,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              info,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(
    BuildContext context, {
    required String name,
    required String info,
    required String phone,
    required IconData icon,
    required Color color,
    required String emergency,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDashboardCard(context) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              
              // Jabatan
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              // Nama
              Text(
                info,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Divider
              Divider(
                color: AppColors.softBorder(context),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              
              // Emergency Type
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emergency_rounded,
                          size: 18,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kontak Untuk:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emergency,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Phone Number with Copy Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.grey[800] 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nomor $phone berhasil disalin'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: color,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          color: color,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
