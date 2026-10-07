import 'dart:typed_data';

import 'package:everqpidapp/Settings/helper/upload_validation.dart';
import 'package:flutter/material.dart';
import '../repository/photo_upload_repository.dart';

class PhotoUploadViewModel extends ChangeNotifier {
  final PhotoUploadRepository _repo = PhotoUploadRepository();

  bool isUploading = false;
  String? error;

  /// Upload image bytes (works on mobile + web; avoids `dart:io` [File] on web).
  Future<List<String>> uploadImages(List<Uint8List?> images) async {
    isUploading = true;
    error = null;
    notifyListeners();

    final uploadedUrls = <String>[];

    try {
      for (final image in images) {
        if (image == null || image.isEmpty) continue;

        UploadValidation.assertValidImage(image);
        final mime = UploadValidation.imageContentType(image)!;
        final ext = mime == 'image/png'
            ? 'png'
            : mime == 'image/webp'
                ? 'webp'
                : mime == 'image/gif'
                    ? 'gif'
                    : 'jpg';
        final fileName = UploadValidation.sanitizeFileName(
          'profile_${DateTime.now().millisecondsSinceEpoch}.$ext',
        );

        final signedUrl = await _repo.getSignedUrl(fileName);
        await _repo.uploadToS3(signedUrl, image, contentType: mime);
        uploadedUrls.add(_repo.convertSignedUrlToPublicUrl(signedUrl));
      }
    } catch (e) {
      error = e.toString();
    }

    isUploading = false;
    notifyListeners();

    return uploadedUrls;
  }
}
