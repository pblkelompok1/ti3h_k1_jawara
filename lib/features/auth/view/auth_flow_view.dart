import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/auth/view/start_screen.dart';
import '../../../core/enum/auth_flow_status.dart';
import '../provider/auth_flow_provider.dart';
import 'incomplete_data_screen.dart';
import 'pending_approval_screen.dart';


class AuthFlowView extends ConsumerWidget {
  const AuthFlowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authFlowAsync = ref.watch(authFlowProvider);

    return authFlowAsync.when(
      data: (state) {
        switch (state) {
          case AuthFlowStatus.notLoggedIn:
            return const StartScreen();
          case AuthFlowStatus.incompleteData:
            return const IncompleteDataScreen();
          case AuthFlowStatus.ready:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
            return const SizedBox.shrink();
          case AuthFlowStatus.uninitialized:
            return const PendingApprovalScreen();
        }
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Center(child: Text("Error: $err")),
    );
  }
}
