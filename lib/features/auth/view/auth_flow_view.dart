import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enum/auth_flow_status.dart';
import '../provider/auth_flow_provider.dart';
import 'package:lottie/lottie.dart';

class AuthFlowView extends ConsumerWidget {
  const AuthFlowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authFlowAsync = ref.watch(authFlowProvider);

    return authFlowAsync.when(
      data: (state) {
        switch (state) {
          case AuthFlowStatus.notLoggedIn:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/start');
            });
            return _loadingLottie();

          case AuthFlowStatus.admin:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/admin/dashboard');
            });
            return _loadingLottie();

          case AuthFlowStatus.incompleteData:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/incomplete-data-screen');
            });
            return _loadingLottie();

          case AuthFlowStatus.uninitialized:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/pending-approval-screen');
            });
            return _loadingLottie();

          case AuthFlowStatus.ready:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
            return _loadingLottie();
        }
      },
      loading: () => _loadingLottie(),
      error: (err, _) => Center(child: Text("Error: $err")),
    );
  }
}

Widget _loadingLottie() {
  return Scaffold(
    backgroundColor: Colors.white, // Konsisten dengan loading
    body: Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Lottie.asset('assets/lottie/Loading.json'),
      ),
    ),
  );
}
