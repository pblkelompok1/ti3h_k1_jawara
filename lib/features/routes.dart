import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/auth/view/incomplete_data_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/login_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/pending_approval_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/signup_screen.dart';
import 'package:ti3h_k1_jawara/features/auth/view/start_screen.dart';
import 'package:ti3h_k1_jawara/features/layout/views/main_layout.dart';
import 'package:ti3h_k1_jawara/features/dashboard/view/dashboard_view.dart';
import 'package:ti3h_k1_jawara/features/finance/view/finance_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/checkout_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/transaction_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/resident_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/marketplace_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/product_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/account_view.dart';
import 'package:ti3h_k1_jawara/features/profile/view/profile_view.dart';
import 'auth/view/auth_flow_view.dart';
import 'auth/view/form_input_data_screen.dart';
import 'package:ti3h_k1_jawara/features/admin/view/admin_dashboard_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/registration_approval_view.dart';
import 'package:ti3h_k1_jawara/features/admin/view/finance_view.dart' as admin_finance;
import 'market/view/camera_detection_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/auth-flow',
    routes: [
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
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
              GoRoute(path: '/dashboard', builder: (_, __) => const DashboardView()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/finance', builder: (_, __) => const FinanceView()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/resident', builder: (_, __) => const ResidentView()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/marketplace', builder: (_, __) => const MarketMainScreen()),
            ],
          ),
        ],
      ),
      // Profile / Product / Checkout / Account routes
      GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),
      GoRoute(path: '/account', builder: (_, __) => const AccountView()),
      GoRoute(path: '/product/:id', builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '1';
        return ProductView(productId: productId);
      }),
      GoRoute(path: '/checkout/:id/:quantity', builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '1';
        final quantity = int.tryParse(state.pathParameters['quantity'] ?? '1') ?? 1;
        return CheckoutView(productId: productId, quantity: quantity);
      }),
      GoRoute(path: '/transaction/:id', builder: (context, state) {
        final transactionId = state.pathParameters['id'] ?? '1';
        return TransactionView(transactionId: transactionId);
      }),

      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (_, __) => const AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/registrations',
        builder: (_, __) => const RegistrationApprovalView(),
      ),
      // Placeholder routes untuk fitur admin lainnya
      GoRoute(
        path: '/admin/residents',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Residents View - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/admin/finance',
        builder: (_, __) => const admin_finance.AdminFinanceView(),
      ),
      GoRoute(
        path: '/admin/banners',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Banners View - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Problem Reports View - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/admin/letters',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Letter Requests View - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/camera-detection',
        builder: (_, __) => const CameraDetectionScreen(),
      ),
    ],
  );
});
