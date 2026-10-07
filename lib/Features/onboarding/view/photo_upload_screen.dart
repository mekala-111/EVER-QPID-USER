import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/email_auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/photo_upload_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/signup_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';

class PhotoUploadScreen extends StatefulWidget {
  final String name;
  final DateTime dob;
  final String gender;
  final String lookingFor;

  const PhotoUploadScreen({
    super.key,
    required this.name,
    required this.dob,
    required this.gender,
    required this.lookingFor,
  });

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  /// Bytes (not [File]) so preview + S3 upload work on Flutter web.
  final List<Uint8List?> _images = List.filled(4, null);
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  bool get _hasAtLeastOneImage => _images.any((img) => img != null);

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _images[index] = bytes;
        });
      }
    } catch (e) {
      AppLogger.d('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
  }

  Future<void> _completeSignup() async {
    if (!_hasAtLeastOneImage) {
      Fluttertoast.showToast(msg: "Please upload at least one image");
      return;
    }

    final emailAuthVM = context.read<EmailAuthViewModel>();
    final signupViewModel = Provider.of<SignupViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final loc = await PermissionManager.promptLocationForSignup(context);
    if (!mounted) return;
    if (loc == null) {
      Fluttertoast.showToast(
        msg:
            'Location is required. Tap Allow, then confirm in the browser prompt.',
        backgroundColor: Colors.red,
      );
      return;
    }
    signupViewModel.setLocation(loc.lat, loc.lng, loc.locationString);
    emailAuthVM.setLocation(loc.lat, loc.lng, loc.locationString);

    setState(() => _isUploading = true);

    try {
      final photoViewModel = Provider.of<PhotoUploadViewModel>(
        context,
        listen: false,
      );

      final uploadedUrls = await photoViewModel.uploadImages(_images);

      if (uploadedUrls.isEmpty) {
        throw Exception(
          photoViewModel.error ?? 'Failed to upload images',
        );
      }

      signupViewModel.setProfilePhotos(uploadedUrls);
      signupViewModel.setProfileImageUrl(uploadedUrls.first);
      signupViewModel.setFullName(widget.name);
      signupViewModel
          .setDateOfBirth(DateFormat('yyyy-MM-dd').format(widget.dob));
      signupViewModel.setGender(widget.gender);
      signupViewModel.setLookingFor(widget.lookingFor);
      emailAuthVM.setFullName(widget.name);
      emailAuthVM.setDateOfBirth(DateFormat('yyyy-MM-dd').format(widget.dob));
      emailAuthVM.setGender(widget.gender);
      emailAuthVM.setLookingFor(widget.lookingFor);
      emailAuthVM.setProfilePhotos(uploadedUrls);
      emailAuthVM.setProfileImageUrl(uploadedUrls.first);

      final phoneCode = authViewModel.countryCode ?? '';
      final phone = authViewModel.phoneNumber ?? '';
      final isPhoneSignup = phone.isNotEmpty &&
          (emailAuthVM.email == null || emailAuthVM.email!.isEmpty);

      AppLogger.d(
        '🧾 Completing signup isPhone=$isPhoneSignup '
        'phone=$phoneCode$phone email=${emailAuthVM.email}',
      );

      if (isPhoneSignup && (phoneCode.isEmpty || phone.isEmpty)) {
        throw Exception('Phone number missing. Please restart login.');
      }

      final success = isPhoneSignup
          ? await signupViewModel.performSignup(
              countryCode: phoneCode,
              mobileNumber: phone,
            )
          : await emailAuthVM.emailSignup();

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (success) {
        Fluttertoast.showToast(msg: "Welcome to Everqpid ❤️");
        Navigator.pushNamedAndRemoveUntil(
          context,
          PPages.mainScreen,
          (route) => false,
        );
        PermissionManager.showAfterLogin();
      } else {
        Fluttertoast.showToast(
          msg: isPhoneSignup
              ? (signupViewModel.errorMessage ?? "Signup failed")
              : (emailAuthVM.errorMessage ?? "Signup failed"),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppContentFrame(
          maxWidth: ContentMaxWidth.form,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressBar(currentStep: 5, totalSteps: 5),
                    const SizedBox(height: 40),
                    Text(
                      'Show Your Best Self',
                      style: getTextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload at least one photo so Cupid can help\nyou make a great first impression.',
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: photoSlotColumns(context),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return _PhotoBox(
                            image: _images[index],
                            onTap: () => _pickImage(index),
                            onRemove: () => _removeImage(index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasAtLeastOneImage ? _completeSignup : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasAtLeastOneImage
                              ? PColors.primaryColor
                              : Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit',
                          style: getTextStyle(
                            color: _hasAtLeastOneImage
                                ? Colors.white
                                : Colors.grey[500],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (_isUploading) _LoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF9B51E0), // Everqpid theme purple
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Uploading your photos...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This may take a few seconds",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoBox({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          image: image != null
              ? DecorationImage(image: MemoryImage(image!), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? const Center(child: Icon(Icons.add, size: 40, color: Colors.grey))
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isCompleted ? PColors.primaryColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
