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

## 🎯 Fitur Wajib Diimplementasikan

### 1️⃣ Marketplace & Product Rating

| Fitur | Component | State Management | Package | Status |
|-------|-----------|------------------|---------|--------|
| Upload Foto Produk | `image_picker_widget.dart` | `ProductImageProvider` | `image_picker` | ✅ Implemented |
| Ambil Foto dari Kamera | `camera_capture_screen.dart` | `CameraProvider` | `camera` | ✅ Implemented |
| Perlihatkan Gallery | `product_gallery_view.dart` | `GalleryProvider` | `photo_view` | ✅ Implemented |
| Rating Produk (1-5 Star) | `product_rating_widget.dart` | `ProductRatingProvider` | `fl_chart` | ✅ Implemented |
| Review Produk | `product_review_screen.dart` | `ReviewProvider` | `dio` | ✅ Implemented |
| Marketplace List | `marketplace_list_view.dart` | `MarketplaceProvider` | `flutter_riverpod` | ✅ Implemented |
| Transaksi Produk | `transaction_detail_view.dart` | `TransactionProvider` | `http` | ✅ Implemented |

**Location:** `lib/features/market/`
**Key Files:**
- `lib/features/market/models/product_model.dart`
- `lib/features/market/provider/product_provider.dart`
- `lib/features/market/view/marketplace_list_view.dart`

---

### 2️⃣ Activity Management (Admin)

| Fitur | Component | State Management | File Location | Status |
|-------|-----------|------------------|---------------|--------|
| List Kegiatan | `admin_activity_view.dart` | `ActivityProvider` | `lib/features/admin/view/` | ✅ Implemented |
| Create Kegiatan | `admin_activity_form_view.dart` | `ActivityFormProvider` | `lib/features/admin/view/` | ✅ Implemented |
| Edit Kegiatan | `admin_activity_form_view.dart` | `ActivityFormProvider` | `lib/features/admin/view/` | ✅ Implemented |
| Delete Kegiatan | `admin_activity_view.dart` | `ActivityProvider` | `lib/features/admin/view/` | ✅ Implemented |
| Upload Foto Kegiatan (Multi) | `activity_image_picker.dart` | `ActivityImageProvider` | `lib/features/admin/widget/` | ✅ Implemented |
| Detail Kegiatan | `admin_activity_detail_view.dart` | `ActivityDetailProvider` | `lib/features/admin/view/` | ✅ Implemented |
| Filter by Status | `activity_filter_widget.dart` | `ActivityFilterProvider` | `lib/features/admin/widget/` | ✅ Implemented |
| Search Kegiatan | `activity_search_widget.dart` | `ActivitySearchProvider` | `lib/features/admin/widget/` | ✅ Implemented |

**Location:** `lib/features/admin/`
**Key Files:**
- `lib/features/admin/model/activity_model.dart`
- `lib/features/admin/provider/activity_provider.dart`
- `lib/features/admin/repository/activity_repository.dart`

---

### 3️⃣ Letter Request System

| Fitur | Component | State Management | User Type | Status |
|-------|-----------|------------------|-----------|--------|
| Pilih Jenis Surat | `letter_selection_screen.dart` | `LetterTypeProvider` | Warga | ✅ Implemented |
| Form Surat Domisili | `domisili_form_screen.dart` | `DomisiliFormProvider` | Warga | ✅ Implemented |
| Form Surat Usaha | `usaha_form_screen.dart` | `UsahaFormProvider` | Warga | ✅ Implemented |
| Lihat Status Pengajuan | `my_letter_requests_screen.dart` | `LetterRequestsProvider` | Warga | ✅ Implemented |
| Download/View PDF | `letter_pdf_viewer.dart` | `LetterPdfProvider` | Warga | ✅ Implemented |
| Approval Pengajuan | `admin_letter_approval_screen.dart` | `LetterApprovalProvider` | Admin | ✅ Implemented |
| Reject dengan Alasan | `letter_rejection_dialog.dart` | `LetterRejectionProvider` | Admin | ✅ Implemented |

**Location:** `lib/features/letter/`
**Key Files:**
- `lib/features/letter/data/models/letter_transaction.dart`
- `lib/features/letter/data/services/letter_api_service.dart`
- `lib/features/letter/presentation/screens/`

---

### 4️⃣ Finance Management

| Fitur | Component | State Management | Status |
|-------|-----------|------------------|--------|
| Lihat Iuran RT | `finance_list_view.dart` | `FinanceProvider` | ✅ Implemented |
| Bayar Iuran | `payment_screen.dart` | `PaymentProvider` | ✅ Implemented |
| Riwayat Pembayaran | `payment_history_view.dart` | `PaymentHistoryProvider` | ✅ Implemented |
| QR Code Pembayaran | `payment_qr_screen.dart` | `QrProvider` | ✅ Implemented |
| Struk Pembayaran | `payment_receipt_view.dart` | `ReceiptProvider` | ✅ Implemented |

**Location:** `lib/features/finance/`
**Key Files:**
- `lib/features/finance/data/models/fee_model.dart`
- `lib/features/finance/provider/finance_provider.dart`

---

### 5️⃣ Report & Dashboard

| Fitur | Component | State Management | User Type | Status |
|-------|-----------|------------------|-----------|--------|
| Buat Laporan | `report_form_screen.dart` | `ReportFormProvider` | Warga | ✅ Implemented |
| Lihat Laporan Saya | `my_reports_view.dart` | `MyReportsProvider` | Warga | ✅ Implemented |
| Dashboard Warga | `dashboard_citizen_view.dart` | `DashboardProvider` | Warga | ✅ Implemented |
| Dashboard Admin | `admin_dashboard_view.dart` | `AdminDashboardProvider` | Admin | ✅ Implemented |
| Statistik & Chart | `dashboard_chart_widget.dart` | `ChartProvider` | Admin | ✅ Implemented |
| Lihat Laporan Warga | `admin_laporan_view.dart` | `LaporanAdminProvider` | Admin | ✅ Implemented |

**Location:** `lib/features/dashboard/`, `lib/features/report/`
**Key Files:**
- `lib/features/report/models/report_model.dart`
- `lib/features/dashboard/provider/dashboard_provider.dart`

---

### 6️⃣ Authentication & Profile

| Fitur | Component | State Management | Status |
|-------|-----------|------------------|--------|
| Login | `login_screen.dart` | `AuthProvider` | ✅ Implemented |
| Register | `register_screen.dart` | `RegisterProvider` | ✅ Implemented |
| Profile Management | `profile_view.dart` | `ProfileProvider` | ✅ Implemented |
| Family Data | `family_management_view.dart` | `FamilyProvider` | ✅ Implemented |
| Logout | `profile_view.dart` | `AuthProvider` | ✅ Implemented |
| Token Management | `auth_service.dart` | FlutterSecureStorage | ✅ Implemented |

**Location:** `lib/features/auth/`, `lib/features/profile/`
**Key Files:**
- `lib/core/services/auth_service.dart`
- `lib/core/models/user_model.dart`

---

### 7️⃣ Additional Features

| Fitur | State Management | Location | Status |
|-------|------------------|----------|--------|
| Permission Handler | `permission_provider.dart` | `lib/core/provider/` | ✅ Implemented |
| File Download/Storage | `download_service.dart` | `lib/core/services/` | ✅ Implemented |
| PDF Viewer | `pdf_viewer_widget.dart` | `lib/core/widgets/` | ✅ Implemented |
| Banner Management | `BannerProvider` | `lib/features/admin/` | ✅ Implemented |
| Resident Registration Approval | `RegistrationProvider` | `lib/features/admin/` | ✅ Implemented |

---

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

## 📱 Supported Platform

- ✅ Android (Min SDK 21 / Android 5.0)

---

## 🎓 Implementasi Materi Pembelajaran

Proyek ini mengimplementasikan berbagai konsep dan teknik Flutter yang dipelajari dalam kurikulum mobile development:

| No | Materi | Implementasi | Status |
|----|---------|--------------|--------|
| #09 | **Kamera** | Menggunakan plugin `camera` untuk capture foto dari kamera perangkat. Diimplementasikan di marketplace (upload produk), activity management (upload kegiatan), dan report (lampiran laporan) | ✅ Implemented |
| #10 | **Dasar State Management** | Menggunakan `Riverpod` sebagai state management untuk mengelola UI state di seluruh aplikasi. Provider patterns digunakan untuk auth, marketplace, finance, dan fitur lainnya | ✅ Implemented |
| #11 | **Pemrograman Asynchronous** | Implementasi async/await di API calls, file operations, dan permission handling. Menggunakan `Future` dan `async` di service layer (`lib/core/services/`) | ✅ Implemented |
| #12 | **Streams** | Implementasi stream dengan Riverpod `StreamProvider` untuk real-time updates di dashboard, activity list, dan marketplace transactions | ✅ Implemented |
| #13 | **Persistensi Data** | JSON serialization dengan `freezed` dan `json_serializable`. Local storage dengan `SharedPreferences` dan `FlutterSecureStorage` untuk token/session management | ✅ Implemented |
| #14 | **Restful API** | Backend API di FastAPI dengan endpoint CRUD untuk semua fitur. HTTP requests menggunakan `Dio` dan `http` package. API integration di `lib/core/services/` | ✅ Implemented |
| #15 | **Progress Project - Bagian 1** | Phase 1 development dengan fitur authentication, dashboard, dan marketplace basic functionality. Selesai dengan struktur project yang clean | ✅ Completed |
| #16 | **Progress Project - Bagian 2 + #17 UAS** | Phase 2 development dengan semua advanced features (activity management, letter system, finance, reports). Final project yang comprehensive dan siap production | ✅ Completed |

---

## 🔗 Repository Links

- **Frontend (Flutter)**: Repository ini
- **Backend (FastAPI)**: [github.com/pblkelompok1/backend_jawara](https://github.com/pblkelompok1/backend_jawara)

---

## � Tim Pengembang

- **Alex** - FullStack Developer
- **Ninis** - ML/AI Developer
- **Candra** - Frontend Developer
- **Ekya** - FullStack Developer

---

**Happy Coding! 🚀**
