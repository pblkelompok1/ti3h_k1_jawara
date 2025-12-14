import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/config_provider.dart';
import '../themes/app_colors.dart';
import 'image_viewer.dart';

class ResidentAvatar extends ConsumerWidget {
  final String? profilePath;
  final double size;
  final bool enableTap;

  const ResidentAvatar({
    super.key,
    required this.profilePath,
    this.size = 40,
    this.enableTap = true,
  });

  bool _isDefaultOrNull(String? path) {
    return path == null || path.isEmpty;
  }

  String _buildFileUrl(String baseUrl, String path) {
    // Ensure path starts with /
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    // Build URL with proper encoding using Uri.parse
    final uri = Uri.parse('$baseUrl/files');
    final fullUrl = uri.replace(path: '${uri.path}${Uri.encodeComponent(normalizedPath)}');
    return fullUrl.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(baseUrlProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDefault = _isDefaultOrNull(profilePath);

    return GestureDetector(
      onTap: enableTap && !isDefault
          ? () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => ImageViewer(
                    imageUrl: _buildFileUrl(baseUrl, profilePath!),
                    imageName: 'Foto Profil',
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDefault
              ? (isDark ? AppColors.surfaceDark : Colors.grey.shade200)
              : Colors.transparent,
        ),
        child: ClipOval(
          child: isDefault
              ? Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                )
              : Image.network(
                  _buildFileUrl(baseUrl, profilePath!),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                      child: Center(
                        child: SizedBox(
                          width: size * 0.4,
                          height: size * 0.4,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary(context).withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: size * 0.6,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
