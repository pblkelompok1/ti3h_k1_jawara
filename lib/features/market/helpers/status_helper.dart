import 'package:flutter/material.dart';

class StatusHelper {
  /// Convert backend status format (e.g., "BELUM_DIBAYAR") to UI-friendly format (e.g., "Belum Dibayar")
  static String formatStatus(String backendStatus) {
    // Replace underscores with spaces and capitalize first letter of each word
    return backendStatus
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // Get vibrant color for each status
  static Color getStatusColor(String status) {
    // Normalize status to handle both formats
    final normalizedStatus = formatStatus(status);

    switch (normalizedStatus) {
      case 'Belum Dibayar':
        return const Color(0xFFFF6B35); // Vibrant orange-red
      case 'Proses':
        return const Color(0xFF4ECDC4); // Vibrant turquoise
      case 'Siap Diambil':
        return const Color(0xFFF39C12); // Vibrant orange/gold
      case 'Sedang Dikirim':
        return const Color(0xFF9B59B6); // Vibrant purple
      case 'Selesai':
        return const Color(0xFF2ECC71); // Vibrant green
      case 'Ditolak':
        return const Color(0xFFE74C3C); // Vibrant red
      default:
        return Colors.grey.shade600;
    }
  }

  // Get display label for status
  static String getStatusLabel(String status) {
    // Normalize status first
    final normalizedStatus = formatStatus(status);

    switch (normalizedStatus) {
      case 'Belum Dibayar':
        return 'Menunggu Pembayaran';
      case 'Proses':
        return 'Sedang Diproses';
      case 'Siap Diambil':
        return 'Siap Diambil';
      case 'Sedang Dikirim':
        return 'Dalam Pengiriman';
      case 'Selesai':
        return 'Selesai';
      case 'Ditolak':
        return 'Dibatalkan';
      default:
        return normalizedStatus;
    }
  }

  // Get icon for status
  static IconData getStatusIcon(String status) {
    // Normalize status first
    final normalizedStatus = formatStatus(status);

    switch (normalizedStatus) {
      case 'Belum Dibayar':
        return Icons.pending_actions;
      case 'Proses':
        return Icons.inventory_2;
      case 'Siap Diambil':
        return Icons.store;
      case 'Sedang Dikirim':
        return Icons.local_shipping;
      case 'Selesai':
        return Icons.check_circle;
      case 'Ditolak':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Get gradient colors for status badge
  static List<Color> getStatusGradient(String status) {
    // Normalize status first
    final normalizedStatus = formatStatus(status);

    switch (normalizedStatus) {
      case 'Belum Dibayar':
        return [const Color(0xFFFF6B35), const Color(0xFFFF8C42)];
      case 'Proses':
        return [const Color(0xFF4ECDC4), const Color(0xFF44A08D)];
      case 'Siap Diambil':
        return [const Color(0xFFF39C12), const Color(0xFFE67E22)];
      case 'Sedang Dikirim':
        return [const Color(0xFF9B59B6), const Color(0xFF8E44AD)];
      case 'Selesai':
        return [const Color(0xFF2ECC71), const Color(0xFF27AE60)];
      case 'Ditolak':
        return [const Color(0xFFE74C3C), const Color(0xFFC0392B)];
      default:
        return [Colors.grey.shade600, Colors.grey.shade700];
    }
  }
}
