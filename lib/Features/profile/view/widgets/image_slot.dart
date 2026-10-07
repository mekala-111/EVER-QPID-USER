import 'dart:typed_data';

/// One of the fixed edit-profile photo slots (local bytes and/or network URL).
class ImageSlot {
  final Uint8List? localBytes;
  final String? networkUrl;
  final bool isModified;

  ImageSlot({
    this.localBytes,
    this.networkUrl,
    this.isModified = false,
  });

  bool get hasImage => localBytes != null || networkUrl != null;
  bool get isLocalImage => localBytes != null;
}
