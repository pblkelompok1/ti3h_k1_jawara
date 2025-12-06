import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/provider/auth_service_provider.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  StreamSubscription<bool?>? _approvalSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToApprovalStatus();
  }

  void _startListeningToApprovalStatus() {
    final authService = ref.read(authServiceProvider);
    _approvalSubscription = authService.checkUserApprovalStream().listen((isApproved) {
      if (isApproved == true && mounted) {
        // User sudah diapprove, redirect ke auth flow
        context.go('/auth-flow');
      }
    });
  }

  @override
  void dispose() {
    _approvalSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Illustration dengan animasi implisit
              _buildIllustration(primaryColor, isDark),
              
              const SizedBox(height: 48),
              
              // Title
              Text(
                'Menunggu Persetujuan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Akun Anda sedang dalam proses verifikasi oleh admin. Anda akan mendapatkan notifikasi setelah akun Anda disetujui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Proses verifikasi biasanya memakan waktu 1-2 hari kerja',
                        style: TextStyle(
                          fontSize: 14,
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
              
              const Spacer(),
              
              // Refresh Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Refresh auth flow status
                    context.go('/auth-flow');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Periksa Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Secondary button (Logout)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement logout
                    // context.go('/auth-flow');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/dashboard');
                    });
                  },
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Keluar',
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

  Widget _buildIllustration(Color primary, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle with gradient
        Container(
          width: 280,
          height: 280,
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
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.08),
          ),
        ),
        
        // Inner circle
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.15),
          ),
        ),
        
        // Icon container with shadow
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary,
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.hourglass_empty_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        
        // Decorative dots with animation suggestion
        Positioned(
          top: 30,
          right: 40,
          child: _buildDecorativeDot(primary, 12),
        ),
        Positioned(
          bottom: 50,
          left: 30,
          child: _buildDecorativeDot(primary, 16),
        ),
        Positioned(
          top: 80,
          left: 20,
          child: _buildDecorativeDot(primary, 8),
        ),
        Positioned(
          bottom: 30,
          right: 60,
          child: _buildDecorativeDot(primary, 10),
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
