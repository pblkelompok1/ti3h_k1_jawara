# Account Feature - Marketplace

Fitur Account untuk marketplace dengan CRUD produk, manajemen transaksi, dan pesanan.

## 📁 Struktur File

```
lib/features/market/
├── provider/
│   └── account_provider.dart          # State management untuk account
├── view/
│   └── account_view.dart              # Halaman utama account dengan 4 tabs
└── widgets/account/
    ├── MyProductsTab.dart             # Tab produk user dengan CRUD
    ├── ActiveTransactionsTab.dart     # Tab transaksi aktif
    ├── TransactionHistoryTab.dart     # Tab riwayat transaksi
    └── MyOrdersTab.dart               # Tab pesanan user sebagai pembeli
```

## 🎯 Fitur

### 1. **My Products Tab (CRUD Produk)**
- ✅ Tambah produk baru (dialog form)
- ✅ Edit produk (dialog form)
- ✅ Hapus produk (konfirmasi)
- ✅ Toggle status aktif/nonaktif
- ✅ Tampilkan informasi produk: nama, kategori, harga, stok, terjual
- ✅ Empty state ketika belum ada produk
- ✅ Kategori: Makanan, Minuman, Pakaian, Elektronik, Lainnya

### 2. **Active Transactions Tab**
- ✅ List transaksi yang sedang berlangsung
- ✅ Status badge: Menunggu, Diproses, Siap
- ✅ Kelola transaksi (dialog untuk update status)
- ✅ Detail: ID, produk, pembeli, jumlah, total, metode pembayaran, waktu
- ✅ Empty state ketika tidak ada transaksi aktif

### 3. **Transaction History Tab**
- ✅ List riwayat transaksi selesai/dibatalkan
- ✅ Status badge: Selesai (hijau), Dibatalkan (merah)
- ✅ Detail: ID, produk, pembeli, jumlah, total, metode pembayaran, tanggal
- ✅ Empty state ketika belum ada riwayat

### 4. **My Orders Tab** (User sebagai pembeli)
- ✅ List pesanan yang dibuat user
- ✅ Status: Menunggu, Diproses, Selesai
- ✅ Aksi berdasarkan status:
  - **Menunggu**: Bayar / Batalkan
  - **Diproses**: Lacak pesanan (tracking dialog)
- ✅ Detail: ID, produk, penjual, jumlah, total, metode pembayaran, tanggal
- ✅ Dialog tracking dengan 4 step: Pesanan Diterima, Dikemas, Dalam Pengiriman, Tiba
- ✅ Empty state ketika belum ada pesanan

## 🎨 Desain

### Color Scheme
- Primary: `AppColors.primary(context)`
- Background Card: `AppColors.bgDashboardCard(context)`
- Border: `AppColors.softBorder(context)`
- Text Primary: `AppColors.textPrimary(context)`
- Text Secondary: `AppColors.textSecondary(context)`

### Status Colors
- **Pending/Menunggu**: Orange
- **Processing/Diproses**: Blue
- **Ready/Siap**: Green
- **Completed/Selesai**: Green
- **Cancelled/Dibatalkan**: Red

### UI Components
- Border Radius: 16px (cards), 12px (buttons/elements), 8px (badges)
- Padding: 24px (horizontal screen), 16px (card content)
- Icon Size: 18-24px
- Font Sizes: 12-18px

## 📊 Data Structure

### User Product
```dart
{
  'id': String,
  'name': String,
  'price': int,
  'stock': int,
  'category': String,
  'description': String,
  'image': String,
  'status': 'active' | 'inactive',
  'sold': int,
}
```

### Transaction
```dart
{
  'id': String,
  'product_name': String,
  'buyer_name': String,
  'price': int,
  'quantity': int,
  'total': int,
  'status': 'pending' | 'processing' | 'ready' | 'completed' | 'cancelled',
  'date': String,
  'payment_method': String,
}
```

### Order
```dart
{
  'id': String,
  'product_name': String,
  'seller_name': String,
  'price': int,
  'quantity': int,
  'total': int,
  'status': 'pending' | 'processing' | 'completed',
  'date': String,
  'payment_method': String,
}
```

## 🚀 Navigasi

### Akses Halaman Account
1. Dari Marketplace: Klik icon **person** di top bar
2. Routing: `/account`

### Implementasi di marketplace_view.dart
```dart
// Top bar dengan icon button account
IconButton(
  onPressed: () => context.push('/account'),
  icon: const Icon(Icons.person_outline_rounded),
)
```

## 🔧 State Management

### Providers yang tersedia:
- `userProductsProvider` - StateNotifier untuk CRUD produk
- `activeTransactionsProvider` - StateProvider untuk transaksi aktif
- `transactionHistoryProvider` - StateProvider untuk riwayat
- `myOrdersProvider` - StateProvider untuk pesanan user
- `accountSelectedTabProvider` - StateProvider untuk tab aktif

### Contoh penggunaan:
```dart
// Read
final products = ref.watch(userProductsProvider);

// Add
ref.read(userProductsProvider.notifier).addProduct(productData);

// Update
ref.read(userProductsProvider.notifier).updateProduct(id, productData);

// Delete
ref.read(userProductsProvider.notifier).deleteProduct(id);

// Toggle Status
ref.read(userProductsProvider.notifier).toggleProductStatus(id);
```

## 📝 Dummy Data

### Produk (3 items)
1. Nasi Goreng Special - Rp 25.000
2. Kue Brownies Coklat - Rp 35.000
3. Kemeja Batik Pria - Rp 150.000 (nonaktif)

### Transaksi Aktif (3 items)
1. Sepatu Olahraga - Pending
2. Tahu Telor - Processing
3. Nasi Goreng Special - Ready

### Riwayat (4 items)
1. Brownies Coklat - Completed
2. Kemeja Batik - Completed
3. Sepatu Casual - Completed
4. Nasi Goreng Special - Cancelled

### Pesanan (2 items)
1. Tahu Telor Warjo - Pending
2. Baju Koko - Processing

## ✨ Fitur Interaktif

### Dialogs & Modals
- ✅ Add/Edit Product Dialog - Form lengkap dengan validasi
- ✅ Delete Confirmation - Alert dialog
- ✅ Transaction Management - Radio button untuk update status
- ✅ Payment Dialog - Konfirmasi pembayaran
- ✅ Cancel Order - Konfirmasi pembatalan
- ✅ Tracking Dialog - 4 step tracking pesanan

### SnackBar Notifications
- ✅ Produk berhasil ditambahkan/diperbarui/dihapus
- ✅ Status transaksi diperbarui
- ✅ Pembayaran dikonfirmasi
- ✅ Pesanan dibatalkan

## 🎯 Best Practices

1. **Separation of Concerns**: Setiap tab adalah widget terpisah
2. **Reusable Components**: Card widgets untuk konsistensi
3. **Dummy Data**: Sudah disediakan untuk testing
4. **Error Handling**: Validasi form dan konfirmasi aksi
5. **Responsive UI**: Adapt dengan dark/light mode
6. **Modern Design**: Mengikuti design system yang ada

## 🔜 Future Enhancements

- [ ] Image upload untuk produk
- [ ] Filter & search produk
- [ ] Export data transaksi
- [ ] Notifikasi real-time
- [ ] Integrasi payment gateway
- [ ] Rating & review produk
- [ ] Chat dengan pembeli/penjual

---

**Dibuat**: 1 Desember 2025  
**Status**: ✅ Complete & Production Ready
