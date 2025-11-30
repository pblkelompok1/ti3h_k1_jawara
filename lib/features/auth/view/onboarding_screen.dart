import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart'; // Sesuaikan path import ini
import 'form_input_data_screen.dart'; // Import halaman form Anda

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data konten onboarding
  final List<Map<String, dynamic>> _contents = [
    {
      'title': 'Pendataan Penduduk\nLebih Mudah',
      'desc': 'Input data kependudukan, keluarga, dan pekerjaan dalam satu aplikasi yang terintegrasi.',
      'icon': Icons.app_registration_rounded,
    },
    {
      'title': 'Arsip Digital\nTerpusat',
      'desc': 'Simpan dokumen penting seperti KTP, KK, dan Akte Kelahiran secara digital dan aman.',
      'icon': Icons.folder_shared_rounded,
    },
    {
      'title': 'Verifikasi Data\nCepat & Akurat',
      'desc': 'Sistem pencarian cerdas untuk memvalidasi data keluarga dan pekerjaan secara real-time.',
      'icon': Icons.verified_user_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage == _contents.length - 1) {
      _navigateToHome();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToHome() {
    // Navigasi ke halaman FormInputDataScreen dan hapus history onboarding
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FormInputDataScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryLight;
    final secondaryColor = AppColors.secondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage != _contents.length - 1)
                    TextButton(
                      onPressed: _navigateToHome,
                      child: Text(
                        'Lewati',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Content: PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Area
                        _buildIllustration(
                          _contents[index]['icon'],
                          primaryColor,
                          secondaryColor,
                          isDark,
                        ),
                        const SizedBox(height: 48),
                        
                        // Title
                        Text(
                          _contents[index]['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          _contents[index]['desc'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer: Dots & Button
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => _buildDot(index, primaryColor, isDark),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: Text(
                        _currentPage == _contents.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Ilustrasi Ikon dengan Background Lingkaran
  Widget _buildIllustration(IconData icon, Color primary, Color secondary, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lingkaran Luar (Secondary Color / Pucat)
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark 
                ? secondary.withOpacity(0.1) 
                : primary.withOpacity(0.1),
          ),
        ),
        // Lingkaran Dalam (Agak lebih gelap)
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark 
                ? secondary.withOpacity(0.2) 
                : primary.withOpacity(0.2),
          ),
        ),
        // Ikon Utama
        Icon(
          icon,
          size: 80,
          color: primary,
        ),
      ],
    );
  }

  // Widget Indikator Halaman (Dots)
  Widget _buildDot(int index, Color primary, bool isDark) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive 
            ? primary 
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}