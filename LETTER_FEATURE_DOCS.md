# 📄 Letter Request Feature Documentation

## Overview
Fitur pengajuan surat memungkinkan warga untuk mengajukan permohonan surat (Domisili & Usaha) secara online, dan admin dapat menyetujui/menolak pengajuan tersebut. Saat disetujui, PDF akan otomatis di-generate oleh backend.

## Features Implemented

### 🏠 For Citizens (Users)
1. **Letter Selection Screen** - Pilih jenis surat yang ingin diajukan
2. **Domisili Form Screen** - Form pengajuan Surat Keterangan Domisili
3. **Usaha Form Screen** - Form pengajuan Surat Keterangan Usaha
4. **My Requests Screen** - Lihat daftar pengajuan surat
   - Status: Pending, Approved, Rejected
   - Download PDF untuk surat yang disetujui
   - Lihat alasan penolakan

### 👨‍💼 For Admin
1. **Admin Approval Screen** - Review dan proses pengajuan surat
   - Lihat detail pengajuan
   - Approve pengajuan (PDF auto-generated)
   - Reject pengajuan dengan alasan

## File Structure

```
lib/features/letter/
├── data/
│   ├── models/
│   │   ├── letter_type.dart           # Model tipe surat
│   │   ├── letter_transaction.dart    # Model transaksi surat
│   │   ├── domisili_data.dart         # Model data domisili
│   │   └── usaha_data.dart            # Model data usaha
│   └── services/
│       └── letter_api_service.dart    # API service untuk letter endpoints
├── presentation/
│   └── screens/
│       ├── letter_selection_screen.dart       # Screen pilih jenis surat
│       ├── domisili_form_screen.dart          # Form surat domisili
│       ├── usaha_form_screen.dart             # Form surat usaha
│       ├── my_letter_requests_screen.dart     # Daftar pengajuan user
│       └── admin_letter_approval_screen.dart  # Approval admin
└── letter.dart                         # Export file
```

## Routes Added

```dart
// User Routes
/letter/selection           -> Letter Selection Screen
/letter/domisili-form       -> Domisili Form Screen
/letter/usaha-form          -> Usaha Form Screen
/letter/my-requests         -> My Letter Requests Screen

// Admin Routes
/admin/letter-approval      -> Admin Letter Approval Screen
```

## API Integration

### Base URL
```dart
baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev/api/v1"
```

### Endpoints Used
1. `GET /letters` - Get letter types
2. `POST /letters/requests?user_id={userId}` - Create letter request
3. `GET /letters/requests?user_id={userId}` - Get user's requests
4. `GET /letters/requests?status=pending` - Get pending requests (admin)
5. `PATCH /letters/requests/{transactionId}/status` - Approve/reject request
6. `GET /{pdfPath}` - Download PDF

## Usage Examples

### For Citizens

#### 1. Navigate to Letter Selection
```dart
context.push('/letter/selection');
```

#### 2. View My Requests
```dart
context.push('/letter/my-requests');
```

#### 3. Submit Domisili Request
```dart
final domisiliData = DomisiliData(
  namaLengkap: "Ahmad Fauzi",
  nik: "1234567890123456",
  // ... other fields
);

await letterApiService.createLetterRequest(
  letterId: letterType.letterId,
  data: domisiliData.toJson(),
  userId: userId,
);
```

### For Admin

#### 1. Navigate to Approval Screen
```dart
context.push('/admin/letter-approval');
```

#### 2. Approve Request
```dart
await letterApiService.updateRequestStatus(
  transactionId: request.letterTransactionId,
  status: 'approved',
);
```

#### 3. Reject Request
```dart
await letterApiService.updateRequestStatus(
  transactionId: request.letterTransactionId,
  status: 'rejected',
  rejectionReason: 'Data tidak lengkap',
);
```

## Data Models

### Letter Type
```dart
class LetterType {
  final String letterId;
  final String letterName;
  final String templatePath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Letter Transaction
```dart
class LetterTransaction {
  final String letterTransactionId;
  final DateTime applicationDate;
  final String status; // 'pending', 'approved', 'rejected'
  final Map<String, dynamic> data;
  final String? letterResultPath;
  final String? rejectionReason;
  final String userId;
  final String letterId;
  final String? letterName;
  final String? applicantName;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Domisili Data
```dart
class DomisiliData {
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String agama;
  final String pekerjaan;
  final String statusKawin;
  final String alamatLengkap;
  final String sejakTanggal;
}
```

### Usaha Data
```dart
class UsahaData {
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String agama;
  final String pekerjaan;
  final String alamatLengkap;
  final String namaUsaha;
  final String jenisUsaha;
  final String alamatUsaha;
  final String mulaiUsaha;
  final String tujuanSurat;
}
```

## Dependencies Required

Make sure these are in `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^17.0.0
  intl: ^0.19.0
  flutter_secure_storage: ^9.2.4
  http: ^1.6.0
  path_provider: ^2.1.5
  url_launcher: ^6.3.1  # NEW - for PDF download
```

## State Management

Uses **Riverpod** for state management:

```dart
// Provider untuk letter types
final letterTypesProvider = FutureProvider<List<LetterType>>((ref) async {
  final service = LetterApiService();
  return await service.getLetterTypes();
});

// Provider untuk user requests
final myLetterRequestsProvider = FutureProvider.autoDispose<List<LetterTransaction>>((ref) async {
  // ... fetch user requests
});

// Provider untuk admin pending requests
final adminLetterRequestsProvider = FutureProvider.autoDispose<List<LetterTransaction>>((ref) async {
  // ... fetch pending requests
});
```

## UI/UX Features

### Form Validation
- NIK must be 16 digits
- All required fields validated
- Date picker for dates (formatted to Indonesian format)
- Dropdown for gender, religion, marital status

### Status Display
- **Pending** - Orange badge with clock icon
- **Approved** - Green badge with check icon + Download PDF button
- **Rejected** - Red badge with cancel icon + Rejection reason

### Loading States
- Circular progress indicator during API calls
- Loading overlay during approval/rejection
- Refresh button to reload data

### Error Handling
- API errors displayed in SnackBars
- Retry buttons on error views
- Form validation errors inline

## Testing Checklist

- [ ] User can view available letter types
- [ ] User can fill and submit Domisili form
- [ ] User can fill and submit Usaha form
- [ ] User can view their letter requests
- [ ] User can see request status (pending/approved/rejected)
- [ ] User can download approved PDF
- [ ] User can see rejection reason
- [ ] Admin can view pending requests
- [ ] Admin can approve request
- [ ] Admin can reject request with reason
- [ ] PDF auto-generated on approval
- [ ] Navigation works correctly
- [ ] Error handling works properly

## Notes & Considerations

### Date Format
- Input: Date picker (DateTime)
- Output to backend: Indonesian format "DD Month YYYY" (e.g., "15 Januari 2020")
- This matches the template requirements

### PDF Download
- Uses `url_launcher` to open PDF in external browser/viewer
- PDF URL is constructed from `letterResultPath` returned by backend

### Authentication
- Uses `flutter_secure_storage` to get user token
- Token automatically included in API headers
- User ID retrieved from stored user data

### Backend Integration
- All field names use `snake_case` to match backend expectations
- Data validated on both frontend and backend
- PDF generation handled entirely by backend

## Future Enhancements

Potential improvements:
1. Add PDF preview before download
2. Add notification when request status changes
3. Add search/filter in request list
4. Add request cancellation feature
5. Add file upload for supporting documents
6. Add signature pad for digital signatures
7. Export request history to Excel/PDF

---

**Status:** ✅ Completed and Ready for Testing
**Last Updated:** December 16, 2025
