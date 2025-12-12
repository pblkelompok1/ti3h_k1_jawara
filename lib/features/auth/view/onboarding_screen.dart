import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';

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
      'title': 'Kelola\nKependudukan',
      'desc': 'Semua data warga dalam satu sistem. Cepat, rapi, tanpa ribet.',
      'lottie': 'assets/lottie/citizen.json',
    },
    {
      'title': 'Keuangan RT\nTransparan',
      'desc': 'Catat iuran dan transaksi secara otomatis. Jelas, aman, dan mudah dipantau.',
      'lottie': 'assets/lottie/finance.json',
    },
    {
      'title': 'Marketplace\nWarga',
      'desc': 'Belanja dan jual produk antar warga. Praktis dan mendukung ekonomi lokal.',
      'lottie': 'assets/lottie/marketplace.json',
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
    // Navigasi ke auth-flow menggunakan GoRouter
    context.go('/start');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryLight;

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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration Area
                          _buildLottieIllustration(
                            _contents[index]['lottie'],
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

  // Widget untuk Ilustrasi Lottie Animation
  Widget _buildLottieIllustration(String lottiePath) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Lottie.asset(
        lottiePath,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
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