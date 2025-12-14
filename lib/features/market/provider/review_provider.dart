import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductReview {
  final String id;
  final String productId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class ReviewRepository {
  static final List<ProductReview> _reviews = [
    ProductReview(
      id: 'r1',
      productId: '1',
      userName: 'Andi Wijaya',
      rating: 5,
      comment: 'Sepatunya nyaman dipakai seharian, bahan mantap 👍',
      date: DateTime(2024, 10, 12),
    ),
    ProductReview(
      id: 'r2',
      productId: '1',
      userName: 'Budi Santoso',
      rating: 4,
      comment: 'Desain oke, cuma pengiriman agak lama.',
      date: DateTime(2024, 10, 10),
    ),
    ProductReview(
      id: 'r3',
      productId: '1',
      userName: 'Rina Putri',
      rating: 5,
      comment: 'Worth it banget untuk harga segini!',
      date: DateTime(2024, 10, 9),
    ),

    ProductReview(
      id: 'r4',
      productId: '2',
      userName: 'Siti Aminah',
      rating: 5,
      comment: 'Tahu telornya enak, bumbu kacangnya juara 🤤',
      date: DateTime(2024, 10, 8),
    ),
    ProductReview(
      id: 'r5',
      productId: '2',
      userName: 'Dewi Lestari',
      rating: 4,
      comment: 'Porsinya pas, rasanya khas.',
      date: DateTime(2024, 10, 7),
    ),

    ProductReview(
      id: 'r6',
      productId: '3',
      userName: 'Agus Pratama',
      rating: 5,
      comment: 'Batiknya asli dan kualitas premium.',
      date: DateTime(2024, 10, 6),
    ),
    ProductReview(
      id: 'r7',
      productId: '3',
      userName: 'Fitri Handayani',
      rating: 4,
      comment: 'Motif bagus, cocok buat acara formal.',
      date: DateTime(2024, 10, 5),
    ),

    ProductReview(
      id: 'r8',
      productId: '4',
      userName: 'Rahmat',
      rating: 5,
      comment: 'Minyaknya jernih dan tidak bau.',
      date: DateTime(2024, 10, 4),
    ),
    ProductReview(
      id: 'r9',
      productId: '4',
      userName: 'Yuni',
      rating: 4,
      comment: 'Harga murah dan kualitas bagus.',
      date: DateTime(2024, 10, 3),
    ),

    ProductReview(
      id: 'r10',
      productId: '5',
      userName: 'Rizky',
      rating: 5,
      comment: 'Tepungnya halus, cocok buat kue.',
      date: DateTime(2024, 10, 2),
    ),
    ProductReview(
      id: 'r11',
      productId: '5',
      userName: 'Nina',
      rating: 4,
      comment: 'Sudah langganan, tidak pernah kecewa.',
      date: DateTime(2024, 10, 1),
    ),

    ProductReview(
      id: 'r12',
      productId: '6',
      userName: 'Hendra',
      rating: 5,
      comment: 'Bassnya mantap, baterai awet.',
      date: DateTime(2024, 9, 30),
    ),
    ProductReview(
      id: 'r13',
      productId: '6',
      userName: 'Kevin',
      rating: 4,
      comment: 'Suara jernih, nyaman dipakai lama.',
      date: DateTime(2024, 9, 29),
    ),

    ProductReview(
      id: 'r14',
      productId: '7',
      userName: 'Maya',
      rating: 5,
      comment: 'Blender kuat, bisa hancurin es batu.',
      date: DateTime(2024, 9, 28),
    ),
    ProductReview(
      id: 'r15',
      productId: '7',
      userName: 'Anton',
      rating: 4,
      comment: 'Motor halus, tidak berisik.',
      date: DateTime(2024, 9, 27),
    ),

    ProductReview(
      id: 'r16',
      productId: '8',
      userName: 'Wahyu',
      rating: 5,
      comment: 'Lampunya terang dan hemat listrik.',
      date: DateTime(2024, 9, 26),
    ),
    ProductReview(
      id: 'r17',
      productId: '8',
      userName: 'Tina',
      rating: 4,
      comment: 'Cahaya nyaman di mata.',
      date: DateTime(2024, 9, 25),
    ),

    ProductReview(
      id: 'r18',
      productId: '9',
      userName: 'Bagus',
      rating: 5,
      comment: 'Sepatu jadi bersih kayak baru!',
      date: DateTime(2024, 9, 24),
    ),
    ProductReview(
      id: 'r19',
      productId: '9',
      userName: 'Doni',
      rating: 4,
      comment: 'Pelayanan ramah dan cepat.',
      date: DateTime(2024, 9, 23),
    ),
  ];

  List<ProductReview> getReviewsByProduct(String productId) {
    return _reviews.where((r) => r.productId == productId).toList();
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final productReviewsProvider = Provider.family<List<ProductReview>, String>((
  ref,
  productId,
) {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsByProduct(productId);
});
