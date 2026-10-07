import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String senderName;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // title: Text(senderName, style: const TextStyle(color: Colors.white)),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: Colors.white),
        //     onPressed: () {
        //       // Could add download, share, etc.
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: AppNetworkImage(
            url: imageUrl,
            fit: BoxFit.contain,
            memCacheWidth: 1200,
          ),
        ),
      ),
    );
  }
}
