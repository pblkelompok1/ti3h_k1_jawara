import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/theme_provider.dart';
import 'package:ti3h_k1_jawara/core/themes/app_theme.dart';
import 'package:ti3h_k1_jawara/core/themes/theme_usage_examples.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);

    return themeAsync.when(
      // ✅ Loading: tampilkan default theme
      loading: () => MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const CircularProgressIndicator(),
      ),

      // ✅ Error: fallback ke light theme
      error: (_, __) => MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const HomePage(),
      ),

      // ✅ Success: gunakan saved theme
      data: (themeMode) => MaterialApp(
        title: 'TI3H K1 Jawara',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        // Theme dari storage
        home: const HomePage(),
      ),
    );
  }
}

void main() {
  runApp(ProviderScope(child: MyApp()));
}
