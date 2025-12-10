# Fitur Ajukan Surat - Dokumentasi

## Deskripsi Umum
Halaman "Ajukan Surat" memungkinkan warga untuk mengajukan permohonan surat (Surat Domisili dan Surat Pengantar) dan melacak status permohonan mereka.

## Fitur Utama

### 1. **FAB (Floating Action Button) - Ajukan Surat Baru**
- Tombol hijau floating action button di bawah kanan
- Ketika diklik membuka dialog untuk memilih jenis surat
- Pilihan surat: Surat Domisili, Surat Pengantar
- Konfirmasi permohonan akan ditampilkan dalam bentuk snackbar

### 2. **List Surat dengan Status**
Setiap list tile menampilkan:
- **Icon**: Ikon deskripsi berdasarkan status
- **Jenis Surat**: Nama surat yang diajukan
- **Tipe Permohonan**: Detail permohonan
- **Status Badge**: Menampilkan status dengan warna berbeda
  - 🟢 **Selesai** (Hijau) - Surat sudah bisa diunduh
  - 🟠 **Diproses** (Orange) - Sedang dalam proses approval
  - 🔵 **Menunggu** (Biru) - Menunggu verifikasi data
  - 🔴 **Ditolak** (Merah) - Permohonan ditolak

### 3. **Informasi Tile**
Setiap surat menampilkan:
- Tanggal pengajuan (format: dd MMM yyyy)
- Keterangan status dari admin
- Tombol "Download Surat" (hanya muncul saat status "Selesai")

### 4. **Download Fitur**
- Tombol download biru yang muncul hanya untuk surat berstatus "Selesai"
- Menampilkan snackbar untuk feedback download
- Simulasi proses download selama 2 detik

## Status & Warna

| Status | Warna | Icon | Keterangan |
|--------|-------|------|-----------|
| Selesai | Hijau | ✓ Circle | Surat sudah bisa diunduh |
| Diproses | Orange | ⏱ | Sedang diproses admin |
| Menunggu | Biru | ⏳ | Menunggu verifikasi |
| Ditolak | Merah | ✗ | Permohonan ditolak |

## Struktur Model

```dart
class SuratModel {
  final String id;
  final String jenisSurat;        // "Surat Domisili" atau "Surat Pengantar"
  final String tipePermohonan;    // Detail tipe permohonan
  final DateTime tanggajudiajukan;
  final String status;            // "menunggu", "diproses", "selesai", "ditolak"
  final String? keterangan;       // Pesan dari admin
}
```

## Data Mock
- **3 Surat Contoh:**
  1. Surat Domisili (Selesai) - diajukan 5 hari lalu
  2. Surat Pengantar (Diproses) - diajukan 2 hari lalu
  3. Surat Domisili (Menunggu) - diajukan hari ini

## Navigation
- **Route**: `/ajukan-surat`
- **Navigasi dari**: Quick Actions Widget (Dashboard) - tombol "Ajukan Surat"
- **Go Router Integration**: Sudah terintegrasi dengan go_router

## Packages yang Ditambahkan
Siap untuk upgrade:
- `dio: ^5.6.0` - Untuk HTTP requests & download file
- `path_provider: ^2.1.5` - Untuk akses direktori file
- `permission_handler: ^11.4.4` - Untuk permission management
- `pdf: ^3.10.8` - Untuk generate dan manipulasi PDF

## Catatan Implementasi
- Download service saat ini menggunakan simulasi
- Ketika packages ter-install, implementasi lengkap dengan:
  - Real file download dengan Dio
  - Storage permission handling
  - PDF generation
  - Save ke downloads folder

## UI/UX Features
✅ Responsive design (mobile-friendly)
✅ Dark mode support
✅ Color-coded status system
✅ Smooth transitions & animations
✅ Shadow & border radius untuk depth
✅ Consistent theme dengan app
