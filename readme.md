# 🏘️ Jawara - RT Management Mobile Application

Aplikasi mobile untuk manajemen RT berbasis Flutter dengan backend FastAPI. Aplikasi ini menyediakan fitur-fitur lengkap untuk pengelolaan RT termasuk marketplace, keuangan, pengajuan surat, laporan warga, dan manajemen kegiatan.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Prerequisites](#-prerequisites)
- [Instalasi & Setup](#-instalasi--setup)
- [Konfigurasi](#-konfigurasi)
- [Fitur Wajib Diimplementasikan](#-fitur-wajib-diimplementasikan)
- [Menjalankan Aplikasi](#-menjalankan-aplikasi)
- [To-Do List](#-to-do-list)
- [Dokumentasi API](#-dokumentasi-api)
- [Tech Stack](#-tech-stack)
- [Tim Pengembang](#-tim-pengembang)

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


## 🎓 Implementasi Materi Pembelajaran

Proyek ini mengimplementasikan berbagai konsep dan teknik Flutter yang dipelajari dalam kurikulum mobile development:

| Jobsheet | Materi | Penjelasan Implementasi | Status |
|----------|--------|------------------------|--------|
| #09 | Kamera | Capture foto dari kamera di marketplace (upload produk), activity management (upload kegiatan), dan report (lampiran laporan) | ✅ Completed |
| #10 | Dasar State Management | Riverpod untuk mengelola UI state. Provider patterns untuk auth, marketplace, finance, dan fitur lainnya | ✅ Completed |
| #11 | Pemrograman Asynchronous | Async/await di API calls, file operations, dan permission handling di `lib/core/services/` | ✅ Completed |
| #12 | Streams | StreamProvider untuk real-time updates di dashboard, activity list, dan marketplace transactions | ✅ Completed |
| #13 | Persistensi Data | JSON serialization dengan `freezed` & `json_serializable`, local storage dengan SharedPreferences & FlutterSecureStorage | ✅ Completed |
| #14 | Restful API | Backend FastAPI dengan endpoint CRUD. HTTP requests via `Dio` & `http` di `lib/core/services/` | ✅ Completed |

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

## ✅ To-Do List Completed

### Backend Development - Alex
- [x] Memperbarui Database
- [x] Memperbarui Seeder
- [x] Memperbaiki Bug atau Logic yang keliru (CRUD)

### Frontend Development - Alex
- [x] Request Surat screen
- [x] Laporan Screen
- [x] Managemen Banner (dashboard + marketplace)
- [x] Rework Registrasi pending (sekarang kurang bagus sih)

### UI/UX Development - Ninis
- [x] Rapikan Backend
- [x] Rapikan UI

### Additional Features Completed
- [x] Activity Management untuk Admin
- [x] Product Rating & Review System
- [x] Marketplace dengan sistem transaksi
- [x] Letter Request System (Domisili & Usaha)
- [x] Finance Management (Iuran RT/RW)
- [x] Citizen Report System
- [x] Authentication & Authorization
- [x] Profile Management dengan Family Data
---

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

## 🔗 Repository Links

- **Frontend (Flutter)**: Repository ini
- **Backend (FastAPI)**: [github.com/pblkelompok1/backend_jawara](https://github.com/pblkelompok1/backend_jawara)

---

## 📱 Supported Platform

- ✅ Android (Min SDK 21 / Android 5.0)


## � Tim Pengembang

- **Alex** - FullStack Developer
- **Ninis** - ML/AI Developer
- **Candra** - Frontend Developer
- **Ekya** - FullStack Developer

---

**Happy Coding! 🚀**
