import 'package:flutter_riverpod/flutter_riverpod.dart';

// Product Model
class Product {
  final String id;
  final String name;
  final int price;
  final List<String> kategori;
  final int stock;
  final int viewCount;
  final String description;
  final List<Map<String, String>> moreDetail;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String seller;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.kategori,
    required this.stock,
    required this.viewCount,
    required this.description,
    required this.moreDetail,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.seller,
  });
}

// Dummy Products Database
class ProductRepository {
  static final List<Product> _products = [
    Product(
      id: '1',
      name: 'Sepatu Tidak Skena',
      price: 100000,
      kategori: ['Pakaian', 'Sepatu', 'Sport'],
      stock: 15,
      viewCount: 245,
      description:
          'asdasdasdasd Ad asd asd asd asd as dasd as das dsa  ad asd asd asdasdasdasd Ad asd asd asd asd as dasd as das dsa  ad asd asd asdasdasdasd Ad asd asd asd asd as dasd',
      moreDetail: [
        {
          'title': 'Bahan',
          'description': 'Canvas Premium dengan sol karet anti slip',
        },
        {'title': 'Ukuran', 'description': 'Tersedia ukuran 38-44'},
        {'title': 'Warna', 'description': 'Abu-abu, Putih, Biru Muda'},
        {
          'title': 'Perawatan',
          'description': 'Bersihkan dengan sikat lembut dan air',
        },
      ],
      images: [
        'https://images.unsplash.com/photo-1549298916-b41d501d3772',
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2',
        'https://images.unsplash.com/photo-1543508282-6319a3e2621f',
      ],
      rating: 4.5,
      reviewCount: 145,
      seller: 'Pak Budhi Bangsul',
    ),
    Product(
      id: '2',
      name: 'Tahu Telor Warjo',
      price: 20000,
      kategori: ['Makanan', 'Tradisional'],
      stock: 50,
      viewCount: 532,
      description:
          'Tahu telor khas dengan bumbu kacang spesial. Dibuat fresh setiap hari dengan bahan pilihan berkualitas. Cocok untuk makan siang atau makan malam bersama keluarga.',
      moreDetail: [
        {
          'title': 'Komposisi',
          'description': 'Tahu putih, telur ayam, kol, tauge, bumbu kacang',
        },
        {'title': 'Porsi', 'description': '1 porsi untuk 1-2 orang'},
        {
          'title': 'Penyajian',
          'description': 'Disajikan hangat dengan kerupuk',
        },
        {
          'title': 'Expired',
          'description': 'Konsumsi dalam 6 jam setelah pembuatan',
        },
      ],
      images: [
        'https://images.unsplash.com/photo-1551218808-94e220e084d2',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
      ],
      rating: 4.8,
      reviewCount: 89,
      seller: 'Warung Pak Warjo',
    ),
    Product(
      id: '3',
      name: 'Batik Tulis Premium',
      price: 450000,
      kategori: ['Pakaian', 'Batik', 'Formal'],
      stock: 8,
      viewCount: 156,
      description:
          'Batik tulis asli buatan pengrajin lokal dengan motif khas Jawa Timur. Cocok untuk acara formal dan semi formal. Bahan katun premium yang nyaman dan adem.',
      moreDetail: [
        {'title': 'Bahan', 'description': 'Katun Premium 100%'},
        {'title': 'Ukuran', 'description': 'S, M, L, XL, XXL'},
        {'title': 'Motif', 'description': 'Batik Tulis Tradisional Jawa Timur'},
        {
          'title': 'Perawatan',
          'description':
              'Cuci dengan tangan, jangan kena sinar matahari langsung',
        },
        {
          'title': 'Origin',
          'description': 'Handmade by local artisan - Surabaya',
        },
      ],
      images: [
        'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc',
        'https://images.unsplash.com/photo-1622470953794-aa9c70b0fb9d',
      ],
      rating: 4.9,
      reviewCount: 67,
      seller: 'Batik Nusantara Collection',
    ),
    Product(
      id: '4',
      name: 'Minyak Goreng Sawit Premium 1L',
      price: 18000,
      kategori: ['Bahan Masak', 'Sembako'],
      stock: 120,
      viewCount: 432,
      description:
          'Minyak goreng sawit premium dengan kualitas tinggi. Cocok untuk menggoreng, menumis, dan berbagai kebutuhan dapur lainnya.',
      moreDetail: [
        {'title': 'Jenis Minyak', 'description': 'Minyak sawit olahan premium'},
        {'title': 'Berat Bersih', 'description': '1 Liter'},
        {'title': 'Expired', 'description': '18 bulan sejak produksi'},
      ],
      images: ['https://images.unsplash.com/photo-1601050690597-df4b8b1fa09c'],
      rating: 4.7,
      reviewCount: 112,
      seller: 'UD. Bahan Masak Sejahtera',
    ),
    Product(
      id: '5',
      name: 'Tepung Terigu Segitiga Biru 1kg',
      price: 13000,
      kategori: ['Bahan Masak', 'Baking'],
      stock: 80,
      viewCount: 301,
      description:
          'Tepung terigu serbaguna yang cocok untuk membuat kue, roti, gorengan, dan berbagai masakan lainnya.',
      moreDetail: [
        {'title': 'Tekstur', 'description': 'Halus dan putih bersih'},
        {'title': 'Cocok Untuk', 'description': 'Kue, roti, gorengan, pancake'},
      ],
      images: ['https://images.unsplash.com/photo-1582650673208-985d31a43ec7'],
      rating: 4.6,
      reviewCount: 78,
      seller: 'Toko Sembako Makmur',
    ),

    Product(
      id: '6',
      name: 'Headphone Wireless BassBoost',
      price: 150000,
      kategori: ['Elektronik', 'Audio'],
      stock: 35,
      viewCount: 690,
      description:
          'Headphone wireless dengan kualitas suara mendalam dan bass kuat. Nyaman digunakan untuk aktivitas harian.',
      moreDetail: [
        {'title': 'Koneksi', 'description': 'Bluetooth 5.0'},
        {
          'title': 'Daya Tahan Baterai',
          'description': 'Hingga 10 jam pemakaian',
        },
        {'title': 'Jarak Koneksi', 'description': '10 meter'},
      ],
      images: ['https://images.unsplash.com/photo-1518444026104-7f91c1f2fe5b'],
      rating: 4.4,
      reviewCount: 210,
      seller: 'Elektronik Jaya Abadi',
    ),
    Product(
      id: '7',
      name: 'Blender Serbaguna 3-in-1',
      price: 220000,
      kategori: ['Elektronik', 'Peralatan Dapur'],
      stock: 22,
      viewCount: 421,
      description:
          'Blender serbaguna dengan tiga mode: jus, penghalus bumbu, dan penghancur es. Kuat dan hemat daya.',
      moreDetail: [
        {'title': 'Daya', 'description': '300 Watt'},
        {'title': 'Material', 'description': 'Kaca & stainless steel'},
        {'title': 'Fitur', 'description': 'Anti slip base, 3 mode kecepatan'},
      ],
      images: ['https://images.unsplash.com/photo-1616628182505-d70119e4c876'],
      rating: 4.8,
      reviewCount: 154,
      seller: 'Dapur Elektronik Official',
    ),
    Product(
      id: '8',
      name: 'Lampu LED Hemat Energi 12W',
      price: 18000,
      kategori: ['Elektronik', 'Pencahayaan'],
      stock: 200,
      viewCount: 812,
      description:
          'Lampu LED terang dengan konsumsi daya rendah. Tahan lama hingga 2 tahun pemakaian normal.',
      moreDetail: [
        {'title': 'Watt', 'description': '12W'},
        {'title': 'Color Temperature', 'description': 'Warm White 3000K'},
        {'title': 'Durability', 'description': '20.000 jam penggunaan'},
      ],
      images: ['https://images.unsplash.com/photo-1582719478291-c6f9f4dff92e'],
      rating: 4.3,
      reviewCount: 87,
      seller: 'Lampu Maju Jaya',
    ),
    Product(
      id: '9',
      name: 'Jasa Cuci Sepatu Premium',
      price: 25000,
      kategori: ['Jasa', 'Perawatan Sepatu'],
      stock: 9999,
      viewCount: 382,
      description:
          'Layanan cuci sepatu premium untuk semua jenis bahan: canvas, leather, suede. Menggunakan chemical aman dan wangi.',
      moreDetail: [
        {
          'title': 'Jenis Layanan',
          'description': 'Deep Clean, Fast Clean, Whitening Midsole',
        },
        {'title': 'Durasi Pengerjaan', 'description': '1–2 hari kerja'},
        {
          'title': 'Catatan',
          'description':
              'Sepatu dijamin bersih dan wangi kembali seperti baru.',
        },
      ],
      images: ['https://images.unsplash.com/photo-1528701800489-20be3c6b3a31'],
      rating: 4.9,
      reviewCount: 129,
      seller: 'SneakerCare Specialist',
    ),
    Product(
      id: '10',
      name: 'Jasa Perbaikan & Cuci AC',
      price: 75000,
      kategori: ['Jasa', 'Servis Rumah'],
      stock: 10,
      viewCount: 412,
      description:
          'Layanan cuci AC, tambah freon, dan perbaikan unit AC di rumah Anda. Ditangani oleh teknisi profesional.',
      moreDetail: [
        {
          'title': 'Layanan Utama',
          'description': 'Cuci AC, tambah freon, perbaikan ringan dan berat',
        },
        {'title': 'Waktu Pengerjaan', 'description': '30–60 menit per unit'},
        {
          'title': 'Garansi',
          'description': 'Garansi 7 hari untuk layanan perbaikan',
        },
      ],
      images: ['https://images.unsplash.com/photo-1616628182505-d70119e4c876'],
      rating: 4.8,
      reviewCount: 201,
      seller: 'Teknisi AC Pak Budi',
    ),
    Product(
      id: '12',
      name: 'Jasa Teknisi Listrik',
      price: 70000,
      kategori: ['Jasa', 'Servis Rumah'],
      stock: 15,
      viewCount: 502,
      description:
          'Menangani masalah listrik seperti konslet, pemasangan saklar, lampu, ataupun perbaikan instalasi sederhana.',
      moreDetail: [
        {
          'title': 'Layanan Meliputi',
          'description':
              'Perbaikan MCB, stop kontak, fitting lampu, instalasi dasar',
        },
        {'title': 'Durasi', 'description': '30–90 menit tergantung kerusakan'},
        {
          'title': 'Garansi',
          'description': 'Garansi 3 hari setelah pengerjaan',
        },
      ],
      images: ['https://images.unsplash.com/photo-1609010697446-11f9e0fabbde'],
      rating: 4.6,
      reviewCount: 132,
      seller: 'Teknisi Listrik Pak Joko',
    ),
    Product(
      id: '13',
      name: 'Nasi Goreng Spesial',
      price: 25000,
      kategori: ['Makanan', 'Nasi'],
      stock: 40,
      viewCount: 620,
      description:
          'Nasi goreng spesial dengan telur, ayam suwir, dan kerupuk. Cocok untuk makan siang atau malam.',
      moreDetail: [
        {'title': 'Porsi', 'description': '1 porsi kenyang'},
        {'title': 'Level Pedas', 'description': 'Bisa request'},
      ],
      images: [
        'https://images.unsplash.com/photo-1604908177522-4322e7f5fd9a?w=800',
      ],
      rating: 4.7,
      reviewCount: 134,
      seller: 'Nasi Goreng Pak Kumis',
    ),

    Product(
      id: '14',
      name: 'Ayam Geprek Sambal Bawang',
      price: 22000,
      kategori: ['Makanan', 'Ayam'],
      stock: 55,
      viewCount: 845,
      description:
          'Ayam geprek crispy dengan sambal bawang pedas dan nasi hangat.',
      moreDetail: [
        {'title': 'Level Pedas', 'description': '1–5'},
        {'title': 'Bonus', 'description': 'Gratis lalapan'},
      ],
      images: [
        'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=800',
      ],
      rating: 4.8,
      reviewCount: 201,
      seller: 'Geprek Jawara',
    ),

    Product(
      id: '15',
      name: 'Bakso Urat Jumbo',
      price: 20000,
      kategori: ['Makanan', 'Bakso'],
      stock: 60,
      viewCount: 710,
      description: 'Bakso urat jumbo dengan kuah kaldu gurih dan mie kuning.',
      moreDetail: [
        {'title': 'Isi', 'description': 'Bakso urat, mie, tahu'},
        {'title': 'Tambahan', 'description': 'Sambal & kecap'},
      ],
      images: [
        'https://images.unsplash.com/photo-1601050690173-4a9c2e6a3c7c?w=800',
      ],
      rating: 4.6,
      reviewCount: 156,
      seller: 'Bakso Pak Slamet',
    ),

    Product(
      id: '16',
      name: 'Sate Ayam Madura',
      price: 30000,
      kategori: ['Makanan', 'Sate'],
      stock: 35,
      viewCount: 905,
      description:
          'Sate ayam khas Madura dengan bumbu kacang kental dan lontong.',
      moreDetail: [
        {'title': 'Isi', 'description': '10 tusuk + lontong'},
        {'title': 'Bumbu', 'description': 'Kacang & kecap'},
      ],
      images: [
        'https://images.unsplash.com/photo-1625944524124-4f4f8a0a8a5c?w=800',
      ],
      rating: 4.9,
      reviewCount: 289,
      seller: 'Sate Madura Cak Man',
    ),
  ];

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getAllProducts() {
    return _products;
  }
}

// Product Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Provider to get a specific product by ID
final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});

// Provider for quantity state
final quantityProvider = StateProvider.family<int, String>(
  (ref, productId) => 1,
);
