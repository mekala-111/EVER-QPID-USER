// features/verification/view/selfie_capture_screen.dart

import 'dart:typed_data';

import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/verification/viewmodel/verification_viewmodel.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'verification_result_screen.dart';

/// Screen for capturing selfie with camera
class SelfieCaptureScreen extends StatefulWidget {
  final String profileImageUrl;
  final String gender;

  const SelfieCaptureScreen({
    super.key,
    required this.profileImageUrl,
    required this.gender,
  });

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _capturedImageBytes;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildBody(context, desktop: false),
      desktop: (_) => _buildBody(context, desktop: true),
    );
  }

  Widget _buildBody(BuildContext context, {required bool desktop}) {
    final scaffold = Scaffold(
      backgroundColor: desktop ? const Color(0xFF050014) : Colors.white,
      appBar: desktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
              ),
              title: Text(
                'Take Selfie',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
            ),
      body: Consumer<VerificationViewModel>(
        builder: (context, vm, child) {
          _isProcessing = vm.isLoading;

          return SafeArea(
            child: Column(
              children: [
                if (desktop)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed:
                            _isProcessing ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Back'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB9AFC8),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: _capturedImageBytes == null
                        ? _buildCameraPlaceholder(desktop: desktop)
                        : _buildCapturedImage(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: vm.errorMessage != null
                      ? _buildErrorMessage(vm.errorMessage!, desktop: desktop)
                      : _buildInstructions(desktop: desktop),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isProcessing
                      ? _buildLoadingButton()
                      : _capturedImageBytes == null
                          ? _buildCaptureButtons()
                          : _buildActionButtons(vm),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );

    if (!desktop) return scaffold;
    return ColoredBox(color: const Color(0xFF050014), child: scaffold);
  }

  Widget _buildCameraPlaceholder({required bool desktop}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 280,
          height: 350,
          decoration: BoxDecoration(
            color: desktop
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(200),
            border: Border.all(color: PColors.primaryColor, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 80,
                color: desktop ? const Color(0xFF817A91) : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No photo yet',
                style: getTextStyle(
                  fontSize: 16,
                  color: desktop ? const Color(0xFFB8B2C7) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedImage() {
    return Container(
      width: 280,
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        border: Border.all(color: PColors.primaryColor, width: 3),
        image: DecorationImage(
          image: MemoryImage(_capturedImageBytes!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInstructions({required bool desktop}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: desktop
            ? PColors.primaryColor.withValues(alpha: 0.12)
            : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: desktop ? PColors.primaryColor : Colors.blue[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _capturedImageBytes == null
                  ? (kIsWeb
                      ? 'Use your webcam or upload a clear front-facing photo'
                      : 'Align your face clearly within the frame')
                  : 'Review your photo before submitting',
              style: getTextStyle(
                fontSize: 14,
                color: desktop ? const Color(0xFFC3BDCC) : Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, {required bool desktop}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: desktop ? Colors.red.withValues(alpha: 0.12) : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: getTextStyle(fontSize: 14, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: PColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: PColors.primaryColor.withOpacity(0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Verifying...',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Camera on all platforms; web also gets an upload path (webcam can fail).
  Widget _buildCaptureButtons() {
    if (!kIsWeb) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => _pickPhoto(ImageSource.camera),
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          label: Text(
            'Capture Selfie',
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: PColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _pickPhoto(ImageSource.camera),
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              'Use webcam',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () => _pickPhoto(ImageSource.gallery),
            icon: Icon(Icons.upload_file_outlined, color: PColors.primaryColor),
            label: Text(
              'Upload a photo',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PColors.primaryColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: PColors.primaryColor,
              side: BorderSide(color: PColors.primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(VerificationViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _capturedImageBytes = null;
                });
                vm.clearError();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: PColors.primaryColor,
                side: BorderSide(color: PColors.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20, color: PColors.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Retake',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _verifyPhoto(vm),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: Text(
                'Verify',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (!mounted) return;
        setState(() {
          _capturedImageBytes = bytes;
        });
      }
    } catch (e) {
      // Webcam often fails on web — fall through to gallery once.
      if (kIsWeb && source == ImageSource.camera) {
        try {
          final XFile? photo = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          if (photo != null) {
            final bytes = await photo.readAsBytes();
            if (!mounted) return;
            setState(() => _capturedImageBytes = bytes);
            return;
          }
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? 'Could not open camera. Try “Upload a photo” instead.'
                  : 'Failed to capture photo: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyPhoto(VerificationViewModel vm) async {
    if (_capturedImageBytes == null) return;

    final success = await vm.uploadAndVerify(
      selfieBytes: _capturedImageBytes!,
      profileImageUrl: widget.profileImageUrl,
      gender: widget.gender,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationResultScreen(
          isVerified: success,
          errorMessage: vm.errorMessage,
        ),
      ),
    );
  }
}
