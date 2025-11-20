import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/layout/views/main_layout.dart';
import 'package:ti3h_k1_jawara/features/dashboard/view/dashboard_view.dart';
import 'package:ti3h_k1_jawara/features/finance/view/finance_view.dart';
import 'package:ti3h_k1_jawara/features/resident/view/resident_view.dart';
import 'package:ti3h_k1_jawara/features/market/view/marketplace_view.dart';
import 'auth/view/start_screen.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    /// Main Pages
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create',
              builder: (context, state) => const CreateView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const MarketMainScreen(),
            ),
          ],
        ),
      ],
    ),

    // Routes
    GoRoute(
      path: '/start',
      builder: (context, state) => const StartScreen(),
    ),
  ],
);