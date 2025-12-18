# 🏘️ Jawara - RT Management Mobile Application

Aplikasi mobile untuk manajemen RT berbasis Flutter dengan backend FastAPI. Aplikasi ini menyediakan fitur-fitur lengkap untuk pengelolaan RT termasuk marketplace, keuangan, pengajuan surat, laporan warga, dan manajemen kegiatan.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Struktur Project](#-struktur-project)
- [Prerequisites](#-prerequisites)
- [Instalasi & Setup](#-instalasi--setup)
- [Konfigurasi](#-konfigurasi)
- [Menjalankan Aplikasi](#-menjalankan-aplikasi)
- [To-Do List](#-to-do-list)
- [Dokumentasi API](#-dokumentasi-api)
- [Tech Stack](#-tech-stack)

---

## ✨ Fitur Utama

### 👤 Untuk Warga (Citizens)
- **Dashboard**: Overview informasi RT, banner, dan quick access
- **Marketplace**: Jual beli produk antar warga dengan sistem rating & review
- **Keuangan**: Pembayaran iuran RT, riwayat transaksi
- **Pengajuan Surat**: Request surat domisili dan surat usaha
- **Laporan**: Buat laporan untuk RT (infrastruktur, keamanan, dll)
- **Kegiatan**: Lihat dan ikuti kegiatan RT
- **Profile**: Manajemen profil dan keluarga

### 👨‍💼 Untuk Admin
- **Dashboard Admin**: Statistik dan overview RT
- **Manajemen Warga**: Approve/reject registrasi warga baru
- **Manajemen Banner**: Kelola banner di dashboard dan marketplace
- **Manajemen Kegiatan**: CRUD kegiatan RT dengan upload foto
- **Review Surat**: Approve/reject pengajuan surat warga
- **Laporan Warga**: Review dan tindak lanjuti laporan dari warga
- **Keuangan**: Kelola iuran dan transaksi keuangan
- **Marketplace**: Monitor transaksi marketplace

---

## 📁 Struktur Project

```
ti3h_k1_jawara/
├── lib/                          # Source code utama
│   ├── main.dart                 # Entry point aplikasi
│   ├── core/                     # Core utilities & shared resources
│   │   ├── enum/                 # Enumerations
│   │   ├── models/               # Shared models
│   │   ├── provider/             # Shared providers (Riverpod)
│   │   ├── services/             # API services
│   │   ├── themes/               # Theme configuration
│   │   ├── utils/                # Helper utilities
│   │   └── widgets/              # Shared widgets
│   │
│   └── features/                 # Feature modules
│       ├── routes.dart           # App routing configuration
│       ├── admin/                # Admin features
│       │   ├── model/            # Admin-specific models
│       │   ├── provider/         # State management
│       │   ├── repository/       # Data layer
│       │   └── view/             # UI screens
│       │
│       ├── auth/                 # Authentication
│       │   ├── provider/         # Auth state management
│       │   ├── view/             # Login/Register screens
│       │   └── widget/           # Auth-related widgets
│       │
│       ├── dashboard/            # Dashboard features
│       │   ├── provider/
│       │   ├── view/
│       │   └── widgets/
│       │
│       ├── finance/              # Financial management
│       │   ├── data/
│       │   ├── provider/
│       │   ├── view/
│       │   └── widgets/
│       │
│       ├── letter/               # Letter request system
│       │   ├── data/
│       │   │   ├── models/       # Letter models
│       │   │   └── services/     # Letter API
│       │   └── presentation/
│       │       └── screens/      # Letter UI screens
│       │
│       ├── market/               # Marketplace
│       │   ├── models/           # Product, transaction models
│       │   ├── provider/         # Market state management
│       │   ├── view/             # Marketplace screens
│       │   └── widgets/          # Market-related widgets
│       │
│       ├── profile/              # User profile
│       │   ├── data/
│       │   ├── provider/
│       │   └── view/
│       │
│       ├── report/               # Citizen reports
│       │   ├── models/
│       │   ├── provider/
│       │   └── view/
│       │
│       └── resident/             # Resident management
│           ├── data/
│           ├── provider/
│           ├── view/
│           └── widgets/
│
├── assets/                       # Static assets
│   ├── img/                      # Images
│   └── lottie/                   # Lottie animations
│
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
├── windows/                      # Windows-specific files
├── linux/                        # Linux-specific files
├── macos/                        # macOS-specific files
│
├── test/                         # Unit & widget tests
│
├── pubspec.yaml                  # Dependencies & project config
├── analysis_options.yaml         # Dart linter rules
├── build.yaml                    # Build runner configuration
│
└── Documentation Files:
    ├── ACTIVITY_MANAGEMENT_DOCS.md
    ├── AJUKAN_SURAT_DOCS.md
    ├── BACKEND_FIX_TRANSACTION_STATUS.md
    ├── LETTER_FEATURE_DOCS.md
    └── PRODUCT_RATING_API_FRONTEND.md
```

---

## 📌 Prerequisites

Sebelum memulai, pastikan Anda sudah menginstall:

- **Flutter SDK** (versi 3.9.2 atau lebih tinggi)
  - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **IDE/Editor**:
  - Visual Studio Code + Flutter Extension, atau
  - Android Studio + Flutter Plugin
- **Platform Development Tools**:
  - **Android**: Android Studio, Android SDK, Java JDK
  - **iOS**: Xcode (macOS only)
  - **Windows**: Visual Studio 2022 with C++ development tools
- **Git** untuk version control
- **Backend API** yang sudah running (FastAPI)

---

## 🚀 Instalasi & Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd ti3h_k1_jawara
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Files (untuk freezed & json_serializable)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Verifikasi Flutter Installation

```bash
flutter doctor
```

Pastikan semua checklist ✓ hijau. Jika ada masalah, ikuti instruksi perbaikan yang diberikan.

---

## ⚙️ Konfigurasi

### 1. Backend API Configuration

Edit file konfigurasi API di `lib/core/provider/config_provider.dart`:

```dart
final configProvider = Provider<AppConfig>((ref) {
  return AppConfig(
    baseUrl: 'http://your-backend-api-url.com/api/v1',
    // Atau untuk development lokal:
    // baseUrl: 'http://10.0.2.2:8000/api/v1',  // Android Emulator
    // baseUrl: 'http://localhost:8000/api/v1',  // iOS Simulator/Web
  );
});
```

### 2. Android Configuration

Buka `android/app/src/main/AndroidManifest.xml` dan pastikan permissions sudah benar:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 3. iOS Configuration (jika develop untuk iOS)

Buka `ios/Runner/Info.plist` dan tambahkan permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>App memerlukan akses kamera untuk upload foto</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>App memerlukan akses galeri untuk upload foto</string>
```

---

## 🎯 Menjalankan Aplikasi

### Development Mode

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run with hot reload (default)
flutter run

# Run in debug mode (verbose logging)
flutter run --debug

# Run in release mode (optimized performance)
flutter run --release
```

### Build untuk Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (untuk Google Play)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

Output build akan tersedia di folder `build/`:
- Android: `build/app/outputs/flutter-apk/app-release.apk`
- Windows: `build/windows/runner/Release/`
- Web: `build/web/`

---

## ✅ To-Do List

### ✔️ Completed Tasks

- [x] **Memperbarui Database** - Alex
- [x] **Memperbarui Seeder** - Alex
- [x] **Memperbaiki Bug atau Logic yang keliru (CRUD)** - Alex
- [x] **Request Surat screen** - Alex
- [x] **Laporan Screen** - Alex
- [x] **Managemen Banner (dashboard + marketplace)** - Alex
- [x] **Rework Registrasi pending (sekarang kurang bagus sih)** - Alex
- [x] **Rapikan Backend** - Ninis
- [x] **Rapikan UI** - Ninis

---

## 📚 Dokumentasi API

Untuk detail lengkap API integration, lihat dokumentasi berikut:

- **[ACTIVITY_MANAGEMENT_DOCS.md](ACTIVITY_MANAGEMENT_DOCS.md)** - Manajemen kegiatan RT
- **[AJUKAN_SURAT_DOCS.md](AJUKAN_SURAT_DOCS.md)** - Sistem pengajuan surat
- **[LETTER_FEATURE_DOCS.md](LETTER_FEATURE_DOCS.md)** - Fitur surat lengkap
- **[PRODUCT_RATING_API_FRONTEND.md](PRODUCT_RATING_API_FRONTEND.md)** - Rating & review produk
- **[BACKEND_FIX_TRANSACTION_STATUS.md](BACKEND_FIX_TRANSACTION_STATUS.md)** - Fix transaction status

---

## 🛠️ Tech Stack

### Frontend (Mobile)
- **Framework**: Flutter 3.9.2
- **Language**: Dart
- **State Management**: Riverpod (flutter_riverpod)
- **Routing**: GoRouter
- **HTTP Client**: Dio & HTTP package
- **Local Storage**: 
  - SharedPreferences (preferences)
  - FlutterSecureStorage (secure tokens)
- **UI Components**:
  - Auto Size Text
  - Cached Network Image
  - Lottie Animations
  - QR Flutter
  - FL Chart (charts)
  - Photo View
  - Syncfusion PDF Viewer
- **Image & File**:
  - Image Picker
  - File Picker
  - Camera
  - Path Provider
- **Other**: 
  - Intl (internationalization)
  - Permission Handler
  - URL Launcher

### Backend
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **Authentication**: JWT
- **File Storage**: Local/Cloud storage

---

## 🔐 Authentication Flow

1. User login/register → Dapat access token
2. Token disimpan di `FlutterSecureStorage`
3. Setiap API request menggunakan token di header:
   ```
   Authorization: Bearer <token>
   ```
4. Token expired → Auto logout & redirect ke login

---

## 📱 Supported Platforms

- ✅ Android (Min SDK 21 / Android 5.0)
- ✅ iOS (Min iOS 12.0)
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

---

## 🐛 Troubleshooting

### Build Errors

```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild generated files
flutter pub run build_runner build --delete-conflicting-outputs

# Rebuild app
flutter run
```

### API Connection Issues

- Pastikan backend API sudah running
- Check URL di `config_provider.dart`
- Untuk Android Emulator, gunakan `10.0.2.2` bukan `localhost`
- Untuk iOS Simulator/Web, gunakan `localhost` atau IP komputer

### Permission Errors

- Android: Check `AndroidManifest.xml`
- iOS: Check `Info.plist`
- Runtime permissions dihandle oleh `permission_handler` package

---

## 👥 Team

- **Alex** - Backend & API Integration
- **Ninis** - Frontend & UI/UX

---

## 📄 License

[Specify your license here]

---

## 📞 Contact & Support

Untuk pertanyaan atau issue, silakan hubungi tim development atau buat issue di repository ini.

---

**Happy Coding! 🚀**
