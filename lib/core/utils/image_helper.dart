import 'dart:io';

class ImageHelper {
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static bool isImageFile(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  static Future<int> getImageSize(String path) async {
    try {
      final file = File(path);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
