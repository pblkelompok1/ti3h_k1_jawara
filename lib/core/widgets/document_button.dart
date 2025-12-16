import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/config_provider.dart';
import '../themes/app_colors.dart';
import '../utils/file_utils.dart';
import 'pdf_viewer.dart';
import 'image_viewer.dart';

class DocumentButton extends ConsumerWidget {
  final String? documentPath;
  final String documentName;
  final IconData icon;
  final Color? color;

  const DocumentButton({
    super.key,
    required this.documentPath,
    required this.documentName,
    required this.icon,
    this.color,
  });

  bool _isValidDocument(String? path) {
    return path != null && path.isNotEmpty;
  }

  String _buildFileUrl(String baseUrl, String path) {
    // Ensure path starts with /
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    // Build URL with proper encoding using Uri.parse
    final uri = Uri.parse('$baseUrl/files');
    final fullUrl = uri.replace(path: '${uri.path}${Uri.encodeComponent(normalizedPath)}');
    return fullUrl.toString();
  }

  void _showDocumentNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange.shade400,
            ),
            const SizedBox(width: 12),
            const Text('Dokumen Tidak Ditemukan'),
          ],
        ),
        content: Text(
          'Dokumen $documentName belum tersedia atau belum diunggah.',
          style: TextStyle(
            color: AppColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(baseUrlProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isValid = _isValidDocument(documentPath);
    final buttonColor = color ?? AppColors.primary(context);

    return InkWell(
      onTap: () {
        if (isValid) {
          final url = _buildFileUrl(baseUrl, documentPath!);
          final isPdf = FileUtils.isPdf(url);
          
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => isPdf
                  ? PdfViewer(
                      documentUrl: url,
                      documentName: documentName,
                    )
                  : ImageViewer(
                      imageUrl: url,
                      imageName: documentName,
                    ),
            ),
          );
        } else {
          _showDocumentNotFoundDialog(context);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isValid
              ? buttonColor.withOpacity(isDark ? 0.15 : 0.1)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isValid
                ? buttonColor.withOpacity(0.3)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isValid
                  ? buttonColor
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                documentName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isValid
                      ? AppColors.textPrimary(context)
                      : AppColors.textSecondary(context),
                ),
              ),
            ),
            Icon(
              isValid ? Icons.chevron_right : Icons.block,
              color: isValid
                  ? buttonColor.withOpacity(0.5)
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
