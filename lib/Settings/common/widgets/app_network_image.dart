import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared network image with disk/memory cache, placeholders, and decode sizing.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth = 800,
    this.memCacheHeight,
    this.borderRadius,
    this.errorIconSize = 48,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final BorderRadius? borderRadius;
  final double errorIconSize;

  static ImageProvider provider(String url, {int? memCacheWidth}) {
    return CachedNetworkImageProvider(
      url,
      maxWidth: memCacheWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _errorBox();
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (_, __) => ColoredBox(
        color: Colors.grey.shade300,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _errorBox(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _errorBox() {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Center(
        child:
            Icon(Icons.broken_image, size: errorIconSize, color: Colors.grey),
      ),
    );
  }
}
