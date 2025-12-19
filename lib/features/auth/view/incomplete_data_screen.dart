import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/provider/auth_service_provider.dart';

class IncompleteDataScreen extends ConsumerWidget {
  const IncompleteDataScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.logout();

        if (context.mounted) {
          context.go('/auth-flow');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal logout: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final horizontalPadding = screenWidth * 0.08; // 8% of width
    final illustrationSize = (screenWidth * 0.5).clamp(140.0, 280.0);
    final titleFontSize = (screenWidth * 0.065).clamp(20.0, 32.0);
    final descFontSize = (screenWidth * 0.04).clamp(13.0, 16.0);
    final buttonHeight = (screenHeight * 0.06).clamp(44.0, 52.0);
    final spacingLarge = (screenHeight * 0.04).clamp(24.0, 48.0);
    final spacingMedium = (screenHeight * 0.02).clamp(12.0, 20.0);
    final spacingSmall = (screenHeight * 0.015).clamp(8.0, 16.0);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: spacingMedium,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: spacingMedium),

                  // Illustration dengan animasi implisit
                  _buildIllustration(primaryColor, isDark, illustrationSize),

                  SizedBox(height: spacingLarge),

                  // Title
                  Text(
                    'Data Belum Lengkap',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),

                  SizedBox(height: spacingSmall),

                  // Description
                  Text(
                    'Lengkapi data kependudukan Anda untuk membuka semua fitur.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: descFontSize,
                      height: 1.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  SizedBox(height: spacingMedium),

                  // Info card
                  Container(
                    padding: EdgeInsets.all(spacingSmall * 1.5),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(spacingSmall * 0.8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: primaryColor,
                            size: (screenWidth * 0.055).clamp(20.0, 24.0),
                          ),
                        ),
                        SizedBox(width: spacingSmall),
                        Expanded(
                          child: Text(
                            'Proses pengisian data hanya membutuhkan waktu sekitar 5 menit',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.035).clamp(12.0, 14.0),
                              height: 1.4,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacingMedium),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/form-input-data');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: primaryColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Lengkapi Data Sekarang',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: spacingSmall * 0.6),
                          Icon(
                            Icons.arrow_forward_rounded, 
                            size: (screenWidth * 0.045).clamp(18.0, 20.0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: spacingSmall),

                  // Secondary button (Logout)
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.04).clamp(14.0, 16.0), 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacingMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(Color primary, bool isDark, double size) {
    final outerSize = size;
    final middleSize = size * 0.785; // ~220/280
    final innerSize = size * 0.571; // ~160/280
    final iconContainerSize = size * 0.357; // ~100/280
    final iconSize = size * 0.179; // ~50/280
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle with gradient
        Container(
          width: outerSize,
          height: outerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primary.withOpacity(0.05),
                primary.withOpacity(0.02),
                Colors.transparent,
              ],
              stops: const [0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Middle circle
        Container(
          width: middleSize,
          height: middleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.08),
          ),
        ),

        // Inner circle
        Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.15),
          ),
        ),

        // Icon container with shadow
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary,
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: size * 0.071, // ~20/280
                offset: Offset(0, size * 0.029), // ~8/280
              ),
            ],
          ),
          child: Icon(
            Icons.assignment_outlined,
            size: iconSize,
            color: Colors.white,
          ),
        ),

        // Decorative dots - responsive positioning
        Positioned(
          top: size * 0.107, 
          right: size * 0.143, 
          child: _buildDecorativeDot(primary, size * 0.043),
        ),
        Positioned(
          bottom: size * 0.179,
          left: size * 0.107,
          child: _buildDecorativeDot(primary, size * 0.057),
        ),
        Positioned(
          top: size * 0.286, 
          left: size * 0.071, 
          child: _buildDecorativeDot(primary, size * 0.029),
        ),
        Positioned(
          bottom: size * 0.107,
          right: size * 0.214,
          child: _buildDecorativeDot(primary, size * 0.036),
        ),
      ],
    );
  }

  Widget _buildDecorativeDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.3),
      ),
    );
  }
}
