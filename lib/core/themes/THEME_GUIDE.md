# 🎨 Theme System Documentation

## 📋 Ringkasan

Sistem theming yang **EFISIEN** tanpa perlu `Consumer` di setiap widget!

### ✅ Yang Benar
- **1x Consumer** di root `MaterialApp` saja
- Widget lain pakai `Theme.of(context)` (tidak perlu Consumer)
- Performa optimal, tidak berat

### ❌ Yang Salah  
- Consumer di setiap widget yang butuh warna
- Membuat instance `AppColors()` berulang kali
- Memanggil provider di semua widget

---

## 🚀 Quick Start

### 1. Setup di `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/theme_provider.dart';
import 'core/themes/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HANYA 1x Consumer di sini!
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TI3H K1 Jawara',
      theme: AppTheme.lightTheme,      // Light theme
      darkTheme: AppTheme.darkTheme,   // Dark theme
      themeMode: themeMode,            // Dynamic mode switching
      home: const HomePage(),
    );
  }
}
```

### 2. Gunakan di Widget (Tidak Perlu Consumer!)

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Langsung pakai Theme.of(context)
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Container(
        color: primaryColor,
        child: Text(
          'Hello World',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
```

---

## 📚 Cara Penggunaan Detail

### **Metode 1: Theme.of(context) - Paling Direkomendasikan**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Ambil warna dari theme
      color: Theme.of(context).colorScheme.primary,
      child: Text(
        'Text',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
```

**Keuntungan:**
- ✅ Tidak perlu Consumer
- ✅ Otomatis update saat theme berubah
- ✅ Performa optimal
- ✅ Code lebih clean

---

### **Metode 2: Static Colors (Untuk Warna Tetap)**

```dart
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Warna statis, tidak berubah dengan theme
      color: AppColors.mediumBlue,
      child: Text(
        'Fixed Color',
        style: TextStyle(color: AppColors.lightBlue),
      ),
    );
  }
}
```

**Kapan Pakai:**
- Warna yang memang tidak boleh berubah
- Illustrasi, logo, atau branding khusus

---

### **Metode 3: Extension Method (Opsional)**

Tambahkan extension untuk syntax lebih clean:

```dart
extension ThemeExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
```

Kemudian gunakan:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.primary,  // Lebih pendek!
      child: Text(
        'Clean Syntax',
        style: context.textStyles.titleLarge,
      ),
    );
  }
}
```

---

## 🔄 Toggle Theme

Hanya button toggle yang perlu `Consumer`:

```dart
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        // Toggle theme
        ref.read(themeProvider.notifier).toggleTheme();
      },
    );
  }
}
```

---

## 🎨 Available Colors

### Dari ColorScheme (Dinamis)
```dart
Theme.of(context).colorScheme.primary       // Warna utama
Theme.of(context).colorScheme.secondary     // Warna sekunder
Theme.of(context).colorScheme.background    // Background
Theme.of(context).colorScheme.surface       // Surface (Card, etc)
Theme.of(context).colorScheme.error         // Error
Theme.of(context).colorScheme.onPrimary     // Text di primary
Theme.of(context).colorScheme.onBackground  // Text di background
```

### Dari AppColors (Statis)
```dart
AppColors.primaryBlack   // #1B262C
AppColors.darkBlue       // #0F4C75
AppColors.mediumBlue     // #3282B8
AppColors.lightBlue      // #BBE1FA
```

---

## 📊 Performa Comparison

### ❌ Cara Lama (Berat)
```dart
// Setiap widget perlu Consumer
class Widget1 extends ConsumerWidget { ... }
class Widget2 extends ConsumerWidget { ... }
class Widget3 extends ConsumerWidget { ... }
// 100 widgets = 100x Consumer! 😱
```

### ✅ Cara Baru (Ringan)
```dart
// Hanya 1x Consumer di root
class MyApp extends ConsumerWidget { ... }

// Widget lain pakai Theme.of(context)
class Widget1 extends StatelessWidget { ... }
class Widget2 extends StatelessWidget { ... }
class Widget3 extends StatelessWidget { ... }
// 100 widgets = tetap 1x Consumer saja! 🚀
```

---

## 🎯 Best Practices

1. **Consumer hanya di root `MaterialApp`**
   - Semua widget child otomatis rebuild saat theme berubah
   
2. **Gunakan `Theme.of(context)` untuk warna dinamis**
   - Tidak perlu Consumer tambahan
   - Flutter sudah handle rebuild otomatis
   
3. **Gunakan `AppColors` untuk warna statis**
   - Warna yang memang tidak boleh berubah
   
4. **Hindari membuat instance AppColors**
   - Semua method sudah static
   
5. **Gunakan ColorScheme semantik**
   - `primary`, `secondary`, `surface`, dll
   - Bukan hardcode warna di setiap widget

---

## 🔍 FAQ

### Q: Apakah berat kalau pakai `Theme.of(context)` di banyak widget?
**A:** Tidak! Flutter sudah optimize ini. `Theme.of(context)` sangat ringan dan efisien.

### Q: Kapan pakai Consumer?
**A:** Hanya di root `MaterialApp` dan widget toggle theme. Widget lain tidak perlu.

### Q: Apakah semua widget rebuild saat theme berubah?
**A:** Hanya widget yang pakai `Theme.of(context)` yang rebuild. Ini behavior normal Flutter dan sudah dioptimasi.

### Q: Bisa pakai AppColors.getPrimaryColor() langsung?
**A:** Bisa, tapi tidak disarankan karena tidak otomatis update. Lebih baik pakai `Theme.of(context).colorScheme.primary`.

---

## 📁 File Structure

```
lib/core/themes/
├── app_colors.dart          # Static color definitions
├── app_theme.dart           # Light & Dark theme data
├── theme_provider.dart      # Riverpod theme state
└── theme_usage_examples.dart # Contoh penggunaan lengkap
```

---

## 🎓 Kesimpulan

**Tidak perlu Consumer di setiap widget!** 

Sistem theme Flutter sudah sangat efisien:
- ✅ Consumer hanya 1x di root
- ✅ Widget pakai `Theme.of(context)`
- ✅ Performa optimal
- ✅ Code lebih clean

Happy Coding! 🚀
