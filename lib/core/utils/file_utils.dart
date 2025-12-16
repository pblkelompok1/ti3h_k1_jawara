class FileUtils {
  static const String baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev";

  /// Build URL for file from storage path
  /// Example: storage/profile/xxx.jpg -> /files/storage%2Fprofile%2Fxxx.jpg
  static String buildFileUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    
    // URL encode the path
    final encodedPath = Uri.encodeComponent(path);
    return '$baseUrl/files/$encodedPath';
  }

  /// Check if file is PDF based on extension
  static bool isPdf(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.toLowerCase().endsWith('.pdf');
  }

  /// Check if file is image
  static bool isImage(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif');
  }

  /// Get file name from path
  static String getFileName(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.split('/').last;
  }
}
