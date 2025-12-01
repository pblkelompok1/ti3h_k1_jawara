import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/auth/view/start_screen.dart';
import '../../../core/enum/auth_flow_status.dart';
import '../provider/auth_flow_provider.dart';
import 'incomplete_data_screen.dart';
import 'pending_approval_screen.dart';
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
              context.go('/dashboard');
            });
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

          /// Uncomment if production
          // return const StartScreen();
          case AuthFlowStatus.incompleteData:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
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

          /// Uncomment if production
          // return const IncompleteDataScreen();
          case AuthFlowStatus.uninitialized:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
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

          /// Uncomment if production
          // return const PendingApprovalScreen();
          case AuthFlowStatus.ready:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
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
      },
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset('assets/lottie/Loading.json'),
          ),
        ),
      ),
      error: (err, _) => Center(child: Text("Error: $err")),
    );
  }
}
