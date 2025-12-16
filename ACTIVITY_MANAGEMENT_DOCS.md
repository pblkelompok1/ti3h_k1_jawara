# Activity Management - Admin Feature

Fitur manajemen kegiatan RT untuk admin yang terintegrasi dengan API backend.

## ⚠️ Important: Status Format

Berdasarkan API documentation (`ACTIVITY_API_FRONTEND.md`), status kegiatan menggunakan format khusus:

**Response dari Backend** (yang diterima frontend):
- `"Akan Datang"` - Kegiatan yang akan datang
- `"Ongoing"` - Kegiatan sedang berlangsung  
- `"Selesai"` - Kegiatan selesai

**Request ke Backend** (yang dikirim frontend):
- `"akan_datang"` - untuk create/update
- `"ongoing"` - untuk create/update
- `"selesai"` - untuk create/update

> 💡 **Note**: Aplikasi otomatis melakukan konversi format menggunakan method `_getApiStatus()` di form view saat submit data.

## 📋 Fitur Utama

### ✅ Untuk Admin:
- **List Kegiatan**: Melihat daftar semua kegiatan dengan filter dan pencarian
- **Create Kegiatan**: Membuat kegiatan baru dengan detail lengkap
- **Edit Kegiatan**: Mengubah informasi kegiatan yang sudah ada
- **Delete Kegiatan**: Menghapus kegiatan
- **Upload Gambar**: Upload multiple images (max 10) untuk setiap kegiatan
- **Detail Kegiatan**: Melihat detail lengkap kegiatan dengan foto-foto
- **Filter & Search**: Filter by status (Akan Datang, Ongoing, Selesai) dan search by name
- **Tab Navigation**: 4 tabs - Semua, Akan Datang, Berlangsung (Ongoing), Selesai
- **Pagination**: Load more untuk menampilkan lebih banyak data

## 📁 Struktur File

```
lib/features/admin/
├── model/
│   └── activity_model.dart          # Model untuk Activity
├── repository/
│   └── activity_repository.dart     # API calls ke backend
├── provider/
│   └── activity_provider.dart       # State management (Riverpod)
└── view/
    ├── admin_activity_view.dart           # List semua kegiatan
    ├── admin_activity_form_view.dart      # Form create/edit
    └── admin_activity_detail_view.dart    # Detail kegiatan
```

## 🎨 UI/UX Features

### List View
- **Modern Card Design**: Card dengan shadow, rounded corners, status badge
- **Tab Navigation**: 4 tabs (Semua, Akan Datang, Berlangsung, Selesai)
- **Search Bar**: Real-time search dengan debouncing
- **Pull to Refresh**: Swipe down untuk refresh data
- **Empty State**: Tampilan kosong yang informatif
- **Status Badge**: Visual indicator dengan icon dan warna untuk setiap status
- **Quick Actions**: Edit dan Delete button di setiap card
- **FAB**: Floating Action Button untuk create kegiatan baru

### Form View (Create/Edit)
- **Clean Form Layout**: Input fields yang rapi dan mudah digunakan
- **Date & Time Picker**: Date dan time picker yang user-friendly
- **Image Picker**: Multiple image selection dengan preview
- **Status Dropdown**: Dropdown untuk memilih status kegiatan
- **Validation**: Form validation untuk required fields
- **Loading State**: Loading indicator saat submit
- **Auto-load Data**: Load data otomatis saat edit mode

### Detail View
- **Hero Image**: Banner image di header dengan gradient overlay
- **Info Cards**: Card-based layout untuk informasi kegiatan
- **Image Gallery**: Grid layout untuk preview images
- **Action Buttons**: Edit dan Delete di app bar
- **Status Badge**: Visual status indicator
- **Category Tag**: Tag untuk kategori kegiatan

## 🔌 API Integration

Menggunakan endpoint dari API backend:

### Endpoints yang digunakan:
- `GET /activity` - Get all activities dengan filter
- `GET /activity/{activity_id}` - Get detail kegiatan
- `POST /activity` - Create kegiatan baru
- `PUT /activity/{activity_id}` - Update kegiatan
- `DELETE /activity/{activity_id}` - Delete kegiatan
- `POST /activity/{activity_id}/upload-images` - Upload images

### Model Data:
```dart
class ActivityModel {
  final String activityId;
  final String activityName;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String organizer;
  final String? status; // "Upcoming", "Ongoing", "Completed", "Cancelled"
  final String? bannerImg;
  final List<String> previewImages;
  final String? category;
}
```

## 🎯 State Management

Menggunakan **Riverpod** untuk state management:

### Providers:
- `activityRepositoryProvider` - Repository instance
- `activityListProvider` - State untuk list kegiatan dengan pagination
- `activityDetailProvider` - Detail kegiatan by ID
- `upcomingActivitiesProvider` - Kegiatan akan datang
- `ongoingActivitiesProvider` - Kegiatan berlangsung
- `completedActivitiesProvider` - Kegiatan selesai
- `createActivityProvider` - Function untuk create
- `updateActivityProvider` - Function untuk update
- `deleteActivityProvider` - Function untuk delete
- `uploadActivityImagesProvider` - Function untuk upload images
- `activitySearchProvider` - Search functionality

## 🚀 Cara Menggunakan

### 1. Navigasi ke Activity Management
Dari admin dashboard, klik card "Kegiatan" atau navigate ke `/admin/activities`

### 2. Melihat List Kegiatan
- Scroll untuk melihat semua kegiatan
- Gunakan tab untuk filter by status
- Gunakan search bar untuk mencari kegiatan
- Pull down untuk refresh

### 3. Membuat Kegiatan Baru
- Klik tombol + di pojok kanan atas
- Isi semua field required (nama, tanggal mulai, lokasi, penyelenggara)
- Pilih tanggal dan waktu
- Pilih status kegiatan
- Upload gambar (opsional, max 10)
- Klik "Buat Kegiatan"

### 4. Edit Kegiatan
- Klik tombol "Edit" di card atau detail view
- Ubah field yang diperlukan
- Upload gambar tambahan jika perlu
- Klik "Simpan Perubahan"

### 5. Hapus Kegiatan
- Klik tombol "Hapus" di card atau detail view
- Konfirmasi penghapusan
- Kegiatan akan dihapus dari database

### 6. Lihat Detail
- Klik card kegiatan
- Lihat semua informasi lengkap
- Lihat galeri foto kegiatan

## 🎨 Themes & Colors

- Support **Light & Dark Mode**
- Menggunakan `AppColors` dari theme system
- Status colors:
  - Upcoming: Blue
  - Ongoing: Orange
  - Completed: Green
  - Cancelled: Red

## 📱 Responsive Design

- Adaptive layout untuk berbagai ukuran layar
- Touch-friendly button sizes
- Smooth animations dan transitions
- Pull-to-refresh gesture

## ⚠️ Error Handling

- Try-catch pada semua API calls
- Error message yang informatif
- Retry mechanism dengan button
- Loading states yang clear
- Form validation messages

## 🔐 Authorization

- Semua endpoint memerlukan **Bearer token** authentication
- Token otomatis di-attach oleh `AuthService.sendWithAuth()`
- Auto-refresh token jika expired

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^17.0.0
  intl: ^0.19.0  # For date formatting
  image_picker: ^1.1.2  # For image selection
  cached_network_image: ^3.4.1  # For image loading
  http: ^1.6.0  # For API calls
```

## 🚧 Future Enhancements

Fitur yang bisa ditambahkan di masa depan:
- [ ] Participant management (daftar peserta)
- [ ] Calendar view untuk kegiatan
- [ ] Notification untuk kegiatan upcoming
- [ ] Export kegiatan ke PDF
- [ ] Share kegiatan ke social media
- [ ] Comments/Discussion untuk setiap kegiatan
- [ ] Attendance tracking
- [ ] Budget management untuk kegiatan

## 📝 Notes

- Maximum 10 images per activity
- Allowed image types: JPEG, JPG, PNG, WEBP
- Date format: ISO 8601 (YYYY-MM-DDTHH:mm:ssZ)
- Indonesian locale untuk date formatting
- Automatic image optimization (handled by backend)

## 🐛 Known Issues

None at the moment. Report issues di GitHub repository.

## 📞 Contact

Untuk pertanyaan atau bantuan, hubungi tim development.

---

**Last Updated:** December 16, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
