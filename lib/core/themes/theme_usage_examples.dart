import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/theme_provider.dart';
import 'package:ti3h_k1_jawara/core/themes/app_theme.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

/// CARA 1: MENGGUNAKAN THEME (PALING DIREKOMENDASIKAN) ✅
/// - Tidak perlu Consumer di setiap widget
/// - Performa optimal
/// - Otomatis update ketika theme berubah
class ExampleUsingTheme extends StatelessWidget {
  const ExampleUsingTheme({super.key});

  @override
  Widget build(BuildContext context) {
    // Langsung akses warna dari Theme, TIDAK PERLU CONSUMER!
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.background;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contoh Menggunakan Theme'),
        // AppBar otomatis pakai theme yang sudah di-set
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Gunakan warna dari theme
            Container(
              color: primaryColor,
              padding: const EdgeInsets.all(16),
              child: Text(
                'Ini menggunakan primary color dari theme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            
            // Button otomatis ikut theme
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button dengan Theme'),
            ),
            
            // Card otomatis ikut theme
            Card(
              child: ListTile(
                title: const Text('Card Item'),
                subtitle: const Text('Otomatis ikut theme'),
                leading: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CARA 2: AKSES DIRECT AppColors (UNTUK WARNA STATIS) ✅
/// - Untuk warna yang tidak berubah berdasarkan theme
/// - Tidak perlu Consumer
class ExampleDirectColors extends StatelessWidget {
  const ExampleDirectColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Langsung pakai static colors
      color: AppColors.mediumBlue,
      child: Text(
        'Warna statis tidak peduli theme',
        style: TextStyle(color: AppColors.lightBlue),
      ),
    );
  }
}

/// CARA 3: CONSUMER HANYA DI ROOT APP (EFISIEN) ✅
/// - Consumer hanya 1x di root
/// - Semua child widget tidak perlu Consumer lagi
/// - Handle async loading state dengan .when()
class MyAppWithTheme extends ConsumerWidget {
  const MyAppWithTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch AsyncValue dari themeProvider
    final themeAsync = ref.watch(themeProvider);

    // ✅ Handle loading, error, dan success state
    return themeAsync.when(
      // Loading: tampilkan splash/loading
      loading: () => MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      
      // Error: fallback ke light theme
      error: (error, stack) => MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: Center(
            child: Text('Error loading theme: $error'),
          ),
        ),
      ),
      
      // Success: gunakan saved theme
      data: (themeMode) => MaterialApp(
        title: 'TI3H K1 Jawara',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode, // ✅ Theme dari storage
        home: const HomePage(),
      ),
    );
  }
}

/// Widget biasa TIDAK PERLU Consumer
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Langsung pakai Theme.of(context), tidak perlu Consumer!
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [
          // Toggle theme button
          ThemeToggleButton(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 100,
              color: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Text(
                  'Primary Color',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sample Button'),
            ),
            const SizedBox(height: 20),
            // Tampilkan status theme
            const ThemeStatusWidget(),
          ],
        ),
      ),
    );
  }
}

/// ✅ HANYA button toggle yang perlu Consumer (1 widget saja)
/// Handle AsyncValue dengan .when()
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);

    return themeAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const Icon(Icons.error),
      data: (themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            // ✅ Toggle theme dengan async method
            ref.read(themeProvider.notifier).toggleTheme();
          },
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        );
      },
    );
  }
}

/// ✅ Widget untuk tampilkan status theme
class ThemeStatusWidget extends ConsumerWidget {
  const ThemeStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);

    return themeAsync.when(
      loading: () => const Text('Loading theme...'),
      error: (error, _) => Text('Error: $error'),
      data: (themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Theme: ${isDark ? "Dark" : "Light"}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CARA 4: EXTENSION METHOD (OPSIONAL, UNTUK SYNTAX LEBIH CLEAN) ✅
extension ThemeExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Contoh pakai extension
class ExampleWithExtension extends StatelessWidget {
  const ExampleWithExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.primary, // Lebih clean!
      child: Text(
        'Menggunakan extension',
        style: context.textStyles.titleLarge,
      ),
    );
  }
}

/// ❌ CARA YANG SALAH (HINDARI INI)
/// Jangan pakai Consumer di setiap widget untuk akses theme!
class WrongWayExample extends ConsumerWidget {
  const WrongWayExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ BURUK: Consumer di setiap widget padahal bisa pakai Theme.of(context)
    final themeAsync = ref.watch(themeProvider);
    
    return themeAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error'),
      data: (themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return Container(
          color: AppColors.getPrimaryColor(isDark),
          child: const Text('Cara ini tidak efisien!'),
        );
      },
    );
  }
}

/// ✅ CARA YANG BENAR (GUNAKAN INI)
/// Gunakan Theme.of(context) untuk akses warna
class CorrectWayExample extends StatelessWidget {
  const CorrectWayExample({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ BENAR: Langsung pakai Theme, tidak perlu Consumer!
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Text(
        'Cara ini efisien!',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
