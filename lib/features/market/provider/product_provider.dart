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
        {
          'title': 'Ukuran',
          'description': 'Tersedia ukuran 38-44',
        },
        {
          'title': 'Warna',
          'description': 'Abu-abu, Putih, Biru Muda',
        },
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
        {
          'title': 'Porsi',
          'description': '1 porsi untuk 1-2 orang',
        },
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
        {
          'title': 'Bahan',
          'description': 'Katun Premium 100%',
        },
        {
          'title': 'Ukuran',
          'description': 'S, M, L, XL, XXL',
        },
        {
          'title': 'Motif',
          'description': 'Batik Tulis Tradisional Jawa Timur',
        },
        {
          'title': 'Perawatan',
          'description': 'Cuci dengan tangan, jangan kena sinar matahari langsung',
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
final quantityProvider = StateProvider.family<int, String>((ref, productId) => 1);
