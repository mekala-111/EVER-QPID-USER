import 'dart:typed_data';

/// Client-side upload guards (trust boundary before signed-URL PUT).
/// Backend must still enforce size, MIME, and signed-URL expiry.
class UploadValidation {
  UploadValidation._();

  static const int maxImageBytes = 8 << 20; // 8 MB
  static const int maxAudioBytes = 15 << 20; // 15 MB

  /// Strip path segments and non-safe characters.
  static String sanitizeFileName(String name) {
    final base = name.replaceAll('\\', '/').split('/').last.trim();
    final cleaned = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') {
      return 'upload.bin';
    }
    return cleaned.length > 120 ? cleaned.substring(0, 120) : cleaned;
  }

  /// Detect common image MIME from magic bytes (not extension).
  static String? imageContentType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'image/gif';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }

  static void assertValidImage(List<int> bytes) {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    if (data.isEmpty) {
      throw Exception('Empty image');
    }
    if (data.length > maxImageBytes) {
      throw Exception('Image too large (max ${maxImageBytes >> 20}MB)');
    }
    if (imageContentType(data) == null) {
      throw Exception('Unsupported or invalid image type');
    }
  }

  static void assertValidAudio(List<int> bytes) {
    if (bytes.isEmpty) {
      throw Exception('Empty audio');
    }
    if (bytes.length > maxAudioBytes) {
      throw Exception('Audio too large (max ${maxAudioBytes >> 20}MB)');
    }
  }

  /// Runnable check — fails if magic-byte detection regresses.
  static void demo() {
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]);
    assert(imageContentType(jpeg) == 'image/jpeg');
    assert(sanitizeFileName('../../evil.jpg') == 'evil.jpg');
    assert(sanitizeFileName(r'a\b\c.png') == 'c.png');
  }
}
