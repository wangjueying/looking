import 'dart:convert';
import 'dart:io';

class Base64Helper {
  static String? imageToBase64(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return null;
      }

      final bytes = file.readAsBytesSync();
      final base64 = base64Encode(bytes);
      return base64;
    } catch (e) {
      return null;
    }
  }

  static String? imageToBase64WithType(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return null;
      }

      final bytes = file.readAsBytesSync();
      final base64 = base64Encode(bytes);
      final extension = path.split('.').last.toLowerCase();

      // Detect image type
      String mimeType;
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      return 'data:$mimeType;base64,$base64';
    } catch (e) {
      return null;
    }
  }
}
