# 🏘️ Jawara - Aplikasi Manajemen RT/RW

Aplikasi mobile berbasis Flutter untuk memudahkan pengelolaan administrasi dan komunikasi di lingkungan RT/RW. Dibangun dengan arsitektur modern menggunakan Riverpod untuk state management dan Go Router untuk navigasi.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Struktur Folder](#-struktur-folder)
- [Teknologi yang Digunakan](#-teknologi-yang-digunakan)
- [Cara Instalasi](#-cara-instalasi)
- [Konfigurasi](#-konfigurasi)
- [To-Do List Completed](#-to-do-list-completed)
- [Tim Pengembang](#-tim-pengembang)

---

## ✨ Fitur Utama

### 👤 Untuk Warga (Citizen)
- **Dashboard Warga**: Informasi kegiatan, iuran, dan pengumuman
- **Marketplace**: Jual beli produk antar warga dengan sistem rating dan review
- **Manajemen Iuran**: Lihat dan bayar iuran RT/RW
- **Pengajuan Surat**: Ajukan surat domisili dan surat usaha secara online
- **Laporan Warga**: Laporkan keluhan atau masalah di lingkungan RT
- **Profile**: Kelola data pribadi dan keluarga

### 👨‍💼 Untuk Admin RT/RW
- **Dashboard Admin**: Overview statistik warga, iuran, dan kegiatan
- **Manajemen Warga**: CRUD data warga dan verifikasi pendaftaran
- **Manajemen Kegiatan**: Buat dan kelola kegiatan RT/RW dengan foto
- **Manajemen Banner**: Kelola banner untuk dashboard dan marketplace
- **Persetujuan Surat**: Review dan setujui/tolak pengajuan surat warga
- **Laporan & Statistik**: Monitoring keuangan dan aktivitas RT
- **Manajemen Iuran**: Atur jenis dan besaran iuran

---

## 📁 Struktur Folder

### Root Directory
```
ti3h_k1_jawara/
├── android/              # Konfigurasi platform Android
├── ios/                  # Konfigurasi platform iOS
├── linux/                # Konfigurasi platform Linux
├── macos/                # Konfigurasi platform macOS
├── windows/              # Konfigurasi platform Windows
├── web/                  # Konfigurasi platform Web
├── assets/               # Asset statis (gambar, lottie, dll)
├── lib/                  # Source code utama aplikasi
├── test/                 # File testing
├── build/                # Build artifacts (generated)
├── .dart_tool/           # Dart tools cache (generated)
└── Documentation files   # File dokumentasi fitur
```

### `/lib` - Source Code Utama

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core functionality & shared resources
│   ├── enum/                    # Enumerations
│   ├── models/                  # Shared data models
│   ├── provider/                # Global providers
│   ├── services/                # API services & business logic
│   ├── themes/                  # App theming (colors, theme provider)
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Reusable widgets
│
└── features/                    # Feature modules (by domain)
    ├── routes.dart              # App routing configuration
    │
    ├── admin/                   # Admin feature module
    │   ├── data/                # Data layer (services, models)
    │   ├── model/               # Domain models
    │   ├── provider/            # State management providers
    │   ├── repository/          # Data repositories
    │   ├── view/                # UI screens
    │   └── widgets/             # Feature-specific widgets
    │
    ├── auth/                    # Authentication module
    │   ├── provider/            # Auth state providers
    │   ├── view/                # Login, register screens
    │   └── widget/              # Auth widgets
    │
    ├── dashboard/               # Dashboard module (citizen & admin)
    │   ├── data/                # Dashboard data
    │   ├── provider/            # Dashboard providers
    │   ├── view/                # Dashboard screens
    │   └── widgets/             # Dashboard widgets
    │
    ├── finance/                 # Finance & payment module
    │   ├── data/                # Finance data & models
    │   ├── provider/            # Finance providers
    │   ├── view/                # Payment screens
    │   └── widgets/             # Finance widgets
    │
    ├── layout/                  # App layout & navigation
    │   ├── provider/            # Layout state providers
    │   ├── views/               # Layout components
    │   └── widgets/             # Layout widgets
    │
    ├── letter/                  # Letter request module
    │   ├── data/                # Letter models & services
    │   └── presentation/        # Letter UI screens
    │
    ├── market/                  # Marketplace module
    │   ├── models/              # Product, transaction models
    │   ├── provider/            # Marketplace providers
    │   ├── view/                # Product, cart, transaction screens
    │   ├── widgets/             # Marketplace widgets
    │   └── helpers/             # Helper utilities
    │
    ├── profile/                 # User profile module
    │   ├── data/                # Profile data
    │   ├── provider/            # Profile providers
    │   └── view/                # Profile screens
    │
    ├── report/                  # Citizen report module
    │   ├── models/              # Report models
    │   └── provider/            # Report providers
    │
    └── resident/                # Resident management module
        ├── data/                # Resident data
        ├── provider/            # Resident providers
        ├── view/                # Resident screens
        └── widgets/             # Resident widgets
```

### `/assets` - Static Assets

```
assets/
├── img/                  # Image assets (PNG, JPG)
│   └── jawara.png        # App logo
└── lottie/               # Lottie animation files
    ├── citizen.json      # Citizen animation
    ├── finance.json      # Finance animation
    ├── list_loading.json # List loading animation
    ├── Loading.json      # Loading animation
    └── marketplace.json  # Marketplace animation
```

### Documentation Files

File dokumentasi fitur-fitur spesifik:

- `ACTIVITY_MANAGEMENT_DOCS.md` - Dokumentasi manajemen kegiatan RT
- `AJUKAN_SURAT_DOCS.md` - Dokumentasi fitur pengajuan surat
- `LETTER_FEATURE_DOCS.md` - Dokumentasi lengkap fitur surat
- `PRODUCT_RATING_API_FRONTEND.md` - Dokumentasi API rating produk
- `BACKEND_FIX_TRANSACTION_STATUS.md` - Dokumentasi fix status transaksi

---

## 🛠️ Teknologi yang Digunakan

### Framework & Language
- **Flutter** `^3.9.2` - UI framework
- **Dart** `^3.9.2` - Programming language

### State Management & Architecture
- **flutter_riverpod** `^2.6.1` - State management
- **riverpod_generator** `^2.6.4` - Code generation untuk Riverpod
- **go_router** `^17.0.0` - Routing & navigation

### UI Components & Utilities
- **intl** `^0.19.0` - Internationalization & date formatting
- **auto_size_text** `^3.0.0` - Responsive text
- **qr_flutter** `^4.1.0` - QR code generation
- **lottie** `^3.3.2` - Lottie animations
- **fl_chart** `^1.1.1` - Charts & graphs
- **photo_view** `^0.15.0` - Image viewer
- **cached_network_image** `^3.4.1` - Image caching

### Network & Storage
- **http** `^1.6.0` - HTTP client
- **dio** `^5.6.0` - Advanced HTTP client
- **shared_preferences** `^2.5.3` - Local storage
- **flutter_secure_storage** `^9.2.4` - Secure storage
- **path_provider** `^2.1.5` - Path utilities

### Media & Files
- **image_picker** `^1.1.2` - Image picker
- **camera** `^0.11.3` - Camera access
- **file_picker** `^10.3.7` - File picker
- **syncfusion_flutter_pdfviewer** `^31.2.18` - PDF viewer

### Other
- **permission_handler** `^12.0.1` - Permission handling
- **url_launcher** `^6.3.1` - URL launcher

### Development Tools
- **build_runner** `^2.4.15` - Code generation
- **flutter_lints** `^5.0.0` - Linting rules
- **custom_lint** `^0.7.2` - Custom linting
- **riverpod_lint** `^2.6.4` - Riverpod linting

---

## 🚀 Cara Instalasi

### Prerequisites

Pastikan Anda sudah menginstall:
- **Flutter SDK** (versi 3.9.2 atau lebih tinggi)
- **Dart SDK** (versi 3.9.2 atau lebih tinggi)
- **Android Studio** / **VS Code** dengan Flutter extension
- **Git**

Untuk mengecek instalasi Flutter:
```bash
flutter --version
flutter doctor
```

### Langkah Instalasi

#### 1. Clone Repository
```bash
git clone <repository-url>
cd ti3h_k1_jawara
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Generate Code (Riverpod, Freezed, dll)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Atau untuk watch mode (auto-generate saat ada perubahan):
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

#### 4. Setup Platform

##### Android
```bash
cd android
./gradlew clean
cd ..
```

##### iOS (Mac only)
```bash
cd ios
pod install
cd ..
```

#### 5. Run Application

Untuk development:
```bash
flutter run
```

Untuk build release:
```bash
# Android APK
flutter build apk --release

# Android App Bundle (untuk Google Play)
flutter build appbundle --release

# iOS (Mac only)
flutter build ios --release
```

---

## ⚙️ Konfigurasi

### 1. API Configuration

Edit file `lib/core/provider/config_provider.dart` untuk mengatur base URL API:

```dart
final configProvider = Provider<AppConfig>((ref) {
  return AppConfig(
    baseUrl: 'http://your-api-domain.com/api/v1',
  );
});
```

### 2. Secure Storage

Aplikasi menggunakan `flutter_secure_storage` untuk menyimpan token dan data sensitif. Konfigurasi sudah otomatis.

### 3. Permissions

Permissions yang dibutuhkan (sudah dikonfigurasi di `AndroidManifest.xml`):
- Camera
- Storage (Read/Write)
- Internet
- Network State

---

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

## 👥 Tim Pengembang

- **Alex** - FullStack Developer
- **Ninis** - ML/AI Developer
- **Candra** - Frontend Developer
- **Ekya** - FullStack Developer

---

## 📝 Catatan Penting

### Status Format
Aplikasi menggunakan format status yang berbeda untuk request dan response dari API:

**Response dari Backend**:
- `"Akan Datang"`, `"Ongoing"`, `"Selesai"`

**Request ke Backend**:
- `"akan_datang"`, `"ongoing"`, `"selesai"`

Konversi otomatis dilakukan oleh aplikasi.

### Transaction Status
Status transaksi marketplace:
- **Belum Dibayar** - Transaksi belum dibayar
- **Proses** - Pesanan sedang diproses
- **Dikirim** - Pesanan sedang dikirim
- **Selesai** - Transaksi selesai
- **Dibatalkan** - Transaksi dibatalkan
- **Ditolak** - Transaksi ditolak

---

## 🔗 Link Dokumentasi Fitur

Untuk dokumentasi detail per fitur, lihat file-file berikut:
- [Activity Management](./ACTIVITY_MANAGEMENT_DOCS.md)
- [Letter Request Feature](./LETTER_FEATURE_DOCS.md)
- [Product Rating API](./PRODUCT_RATING_API_FRONTEND.md)
- [Ajukan Surat](./AJUKAN_SURAT_DOCS.md)

---

## 📞 Support

Jika ada pertanyaan atau menemukan bug, silakan hubungi tim pengembang atau buat issue di repository.

---

**© 2024 Jawara App - Manajemen RT/RW Digital**