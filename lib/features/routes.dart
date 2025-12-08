import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/layout/views/main_layout.dart';
import 'package:ti3h_k1_jawara/features/dashboard/view/dashboard_view.dart';
import 'package:ti3h_k1_jawara/features/finance/view/finance_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/checkout_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/transaction_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/resident_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/report_issue_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/marketplace_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/product_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/account_view.dart';
import 'package:ti3h_k1_jawara/features/profile/view/profile_view.dart';
import 'auth/view/auth_flow_view.dart';
import 'auth/view/form_input_data_screen.dart';
import 'market/view/camera_detection_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    // initialLocation: '/dashboard',
    initialLocation: '/auth-flow',
    routes: [
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
      GoRoute(path: '/lapor-masalah', builder: (_, __) => const ReportIssueView()),
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
      GoRoute(
        path: '/camera-detection',
        builder: (_, __) => const CameraDetectionScreen(),
      ),
    ],
  );
});
