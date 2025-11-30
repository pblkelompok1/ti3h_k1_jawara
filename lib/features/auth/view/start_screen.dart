import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _patternAnimationController;
  late Animation<double> _patternAnimation;

  @override
  void initState() {
    super.initState();

    // Pattern animation controller
    _patternAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _patternAnimation = CurvedAnimation(
      parent: _patternAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _patternAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background dengan warna hijau terang (atas)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size.width,
              height: size.height,
              color: isDark ? AppColors.primaryDark : const Color(0xFF9DC08B),
            ),
          ),

          // Pattern/Corak dekoratif di area hijau - TETAP ANIMASI
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: size.height * 0.5,
              child: AnimatedBuilder(
                animation: _patternAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: PatternPainter(
                      isDark: isDark,
                      animationValue: _patternAnimation.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Icon & Judul
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(height: 160,),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset('assets/img/jawara.png'),
                ),
                const SizedBox(height: 15),
                const Text(
                  'JAWARA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Aplikasi Kependudukan,\nKeuangan, dan Marketplace RT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Wave curve - Putih (bawah)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: size.height * 0.5,
                color: isDark ? AppColors.surfaceDark : Colors.white,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  const Spacer(flex: 2),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.primaryLight,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.primaryLight,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Footer Text
                  Text(
                    'Kelola RT Anda dengan Mudah',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk membuat wave/ombak asimetris
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Mulai dari kiri atas dengan posisi lebih tinggi
    path.lineTo(0, size.height * 0.15);

    // Curve yang lebih smooth
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.1,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.15,
      size.width,
      size.height * 0.08,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Painter untuk membuat pattern/corak dekoratif
class PatternPainter extends CustomPainter {
  final bool isDark;
  final double animationValue;

  PatternPainter({required this.isDark, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Gunakan animationValue yang sudah smooth dari CurvedAnimation
    final t = animationValue;

    // Scale yang lebih terlihat: 0.8 -> 1.2
    final scale = 0.8 + (0.4 * t);

    // Opacity yang lebih dinamis: 0.05 -> 0.25
    final baseOpacity = 0.05 + (0.2 * t);

    final paint = Paint()
      ..color = Colors.white.withOpacity(baseOpacity)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(baseOpacity + 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Lingkaran besar di kanan atas - gerakan horizontal dan vertikal lebih besar
    final offset1 = Offset(
      size.width * 0.85 + (30 * t),
      size.height * 0.1 + (20 * t),
    );
    canvas.drawCircle(offset1, 60 + (40 * scale), paint);

    // Lingkaran sedang di kiri atas - gerakan berlawanan arah
    final offset2 = Offset(
      size.width * 0.15 - (25 * t),
      size.height * 0.15 + (30 * t),
    );
    canvas.drawCircle(offset2, 40 + (20 * t), strokePaint);

    // Lingkaran kecil di tengah kanan - floating effect lebih terlihat
    final offset3 = Offset(
      size.width * 0.9 + (15 * t),
      size.height * 0.35 - (40 * t),
    );
    canvas.drawCircle(offset3, 25 + (15 * t), paint);

    // Lingkaran stroke di kiri tengah - pulse lebih besar
    final offset4 = Offset(size.width * 0.1, size.height * 0.4 + (25 * t));
    canvas.drawCircle(offset4, 30 + (30 * t), strokePaint);

    // Tambahan lingkaran kecil tersebar - gerakan lebih besar
    final smallCircles = [
      Offset(size.width * 0.3 + (35 * t), size.height * 0.05 + (15 * t)),
      Offset(size.width * 0.7 - (30 * t), size.height * 0.25 + (25 * t)),
      Offset(size.width * 0.25 + (20 * t), size.height * 0.35 - (35 * t)),
    ];

    for (var center in smallCircles) {
      canvas.drawCircle(center, 12 + (10 * t), paint);
    }

    // Garis-garis dekoratif - animasi wave lebih terlihat
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(baseOpacity + 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 + (1 * t);

    // Garis lengkung 1 - bergelombang lebih besar
    final path1 = Path();
    final curve1Y = size.height * 0.1 + (30 * t);
    path1.moveTo(size.width * 0.6, curve1Y);
    path1.quadraticBezierTo(
      size.width * 0.65,
      curve1Y + (size.height * 0.05) + (20 * t),
      size.width * 0.7,
      curve1Y,
    );
    canvas.drawPath(path1, linePaint);

    // Garis lengkung 2 - bergelombang berlawanan
    final path2 = Path();
    final curve2Y = size.height * 0.25 - (25 * t);
    path2.moveTo(size.width * 0.05, curve2Y);
    path2.quadraticBezierTo(
      size.width * 0.1,
      curve2Y + (size.height * 0.05) - (15 * t),
      size.width * 0.15,
      curve2Y,
    );
    canvas.drawPath(path2, linePaint);

    // Lingkaran transparan yang muncul dan menghilang - lebih dramatis
    for (int i = 0; i < 3; i++) {
      final offset = (i * 0.33);
      final fadeValue = ((t + offset) % 1.0);
      final fadePaint = Paint()
        ..color = Colors.white.withOpacity(0.25 * (1 - fadeValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 - (fadeValue);

      canvas.drawCircle(
        Offset(size.width * (0.4 + i * 0.2), size.height * (0.2 + i * 0.1)),
        15 + (60 * fadeValue),
        fadePaint,
      );
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
