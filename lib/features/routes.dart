import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_resident_view.dart';
import 'package:ti3h_k1_jawara/features/auth/view/incomplete_data_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/login_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/onboarding_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/pending_approval_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/signup_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/start_screen.dart';
import 'package:ti3h_k1_jawara/features/layout/views/main_layout.dart';
import 'package:ti3h_k1_jawara/features/dashboard/view/dashboard_view.dart';
import 'package:ti3h_k1_jawara/features/finance/view/finance_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/checkout_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/transaction_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/resident_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/report_issue_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/report_detail_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/marketplace_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/product_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/account_view.dart';
import 'package:ti3h_k1_jawara/features/profile/view/profile_view.dart';
import 'package:ti3h_k1_jawara/features/finance/view/iuran_warga_view.dart';
import 'package:ti3h_k1_jawara/features/finance/view/dana_pribadi_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/ajukan_surat_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/detail_kegiatan_view.dart';
import 'auth/view/auth_flow_view.dart';
import 'auth/view/form_input_data_screen.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_dashboard_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/registration_approval_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_laporan_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_request_surat_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_report_dashboard.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_report_detail.dart';
import 'package:ti3h_k1_jawara/features/admin/view/finance_view.dart'
    as admin_finance;
import 'market/view/camera_detection_screen.dart';
import 'finance/widgets/add_finance_page.dart';
import 'finance/widgets/tagih_iuran_page.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_banner_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_activity_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_activity_form_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_activity_detail_view.dart';
import 'package:ti3h_k1_jawara/features/letter/presentation/screens/letter_selection_screen.dart';
import 'package:ti3h_k1_jawara/features/letter/presentation/screens/letter_type_selection_screen.dart';
import 'package:ti3h_k1_jawara/features/letter/presentation/screens/domisili_form_screen.dart';
import 'package:ti3h_k1_jawara/features/letter/presentation/screens/usaha_form_screen.dart';
import 'package:ti3h_k1_jawara/features/letter/presentation/screens/admin_letter_approval_screen.dart';
import 'package:ti3h_k1_jawara/features/letter/data/models/letter_type.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/auth-flow',
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/start',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StartScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/incomplete-data-screen',
        builder: (context, state) => const IncompleteDataScreen(),
      ),
      GoRoute(
        path: '/pending-approval-screen',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/auth-flow',
        builder: (context, state) => const AuthFlowView(),
      ),
      GoRoute(
        path: '/form-input-data',
        builder: (context, state) => const FormInputDataScreen(),
      ),
      // Main Layout dan nested routes tetap seperti sebelumnya
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                builder: (_, __) => const FinanceView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/resident',
                builder: (_, __) => const ResidentView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace',
                builder: (_, __) => const MarketMainScreen(),
              ),
            ],
          ),
        ],
      ),
      // Profile / Product / Checkout / Account routes
      GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),
      GoRoute(path: '/account', builder: (_, __) => const AccountView()),
      GoRoute(
        path: '/lapor-masalah',
        builder: (_, __) => const ReportIssueView(),
      ),
      GoRoute(
        path: '/report-detail/:reportId',
        builder: (context, state) {
          final reportId = state.pathParameters['reportId'] ?? '';
          return ReportDetailView(reportId: reportId);
        },
      ),
      GoRoute(
        path: '/ajukan-surat',
        builder: (_, __) => const AjukanSuratView(),
      ),
      GoRoute(path: '/iuran-warga', builder: (_, __) => const IuranWargaView()),
      GoRoute(
        path: '/dana-pribadi',
        builder: (_, __) => const DanaPribadiView(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '1';
          return ProductView(productId: productId);
        },
      ),
      GoRoute(
        path: '/checkout/:id/:quantity',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '1';
          final quantity =
              int.tryParse(state.pathParameters['quantity'] ?? '1') ?? 1;
          return CheckoutView(productId: productId, quantity: quantity);
        },
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) {
          final transactionId = state.pathParameters['id'] ?? '1';
          return TransactionView(transactionId: transactionId);
        },
      ),

      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (_, __) => const AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/registrations',
        builder: (_, __) => const RegistrationApprovalView(),
      ),
      GoRoute(
        path: '/admin/laporan',
        builder: (_, __) => const AdminLaporanView(),
      ),
      // Placeholder routes untuk fitur admin lainnya
      GoRoute(
        path: '/admin/residents',
        builder: (_, __) => const AdminResidentView(),
      ),
      GoRoute(
        path: '/admin/finance',
        builder: (_, __) => const admin_finance.AdminFinanceView(),
      ),
      GoRoute(
        path: '/admin/banners',
        builder: (_, __) => const AdminBannerView(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (_, __) => const AdminReportDashboard(),
      ),
      GoRoute(
        path: '/admin/report-detail/:reportId',
        builder: (context, state) {
          final reportId = state.pathParameters['reportId'] ?? '';
          return AdminReportDetail(reportId: reportId);
        },
      ),
      GoRoute(
        path: '/admin/letters',
        builder: (_, __) => const AdminRequestSuratView(),
      ),
      // Letter Management Routes (New System)
      GoRoute(
        path: '/letter/selection',
        builder: (_, __) => const LetterSelectionScreen(),
      ),
      GoRoute(
        path: '/letter/type-selection',
        builder: (_, __) => const LetterTypeSelectionScreen(),
      ),
      GoRoute(
        path: '/letter/domisili-form',
        builder: (context, state) {
          final letterType = state.extra as LetterType;
          return DomisiliFormScreen(letterType: letterType);
        },
      ),
      GoRoute(
        path: '/letter/usaha-form',
        builder: (context, state) {
          final letterType = state.extra as LetterType;
          return UsahaFormScreen(letterType: letterType);
        },
      ),
      GoRoute(
        path: '/admin/letter-approval',
        builder: (_, __) => const AdminLetterApprovalScreen(),
      ),
      // Activity Management Routes
      GoRoute(
        path: '/admin/activities',
        builder: (_, __) => const AdminActivityView(),
      ),
      GoRoute(
        path: '/admin/activities/create',
        builder: (_, __) => const AdminActivityFormView(),
      ),
      GoRoute(
        path: '/admin/activities/:activityId',
        builder: (context, state) {
          final activityId = state.pathParameters['activityId'] ?? '';
          return AdminActivityDetailView(activityId: activityId);
        },
      ),
      GoRoute(
        path: '/admin/activities/:activityId/edit',
        builder: (context, state) {
          final activityId = state.pathParameters['activityId'] ?? '';
          return AdminActivityFormView(activityId: activityId);
        },
      ),
      GoRoute(
        path: '/camera-detection',
        builder: (_, __) => const CameraDetectionScreen(),
      ),
      GoRoute(
        path: '/detail-kegiatan',
        builder: (_, __) => const DetailKegiatanView(),
      ),
      GoRoute(path: '/add-finance', builder: (_, __) => const AddFinancePage()),
      GoRoute(path: '/tagih-iuran', builder: (_, __) => const TagihIuranPage()),
    ],
  );
});
