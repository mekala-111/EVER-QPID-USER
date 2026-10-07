// features/verification/view/verify_intro_screen.dart

import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/verification_viewmodel.dart';
import 'selfie_capture_screen.dart';

/// Intro screen explaining the verification process
class VerifyIntroScreen extends StatelessWidget {
  final String profileImageUrl;
  final String gender;

  const VerifyIntroScreen({
    super.key,
    required this.profileImageUrl,
    required this.gender,
  });

  void _openSelfie(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => VerificationViewModel(),
          child: SelfieCaptureScreen(
            profileImageUrl: profileImageUrl,
            gender: gender,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(context),
      desktop: (_) => _buildDesktop(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Your Profile',
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _IntroContent(
              profileImageUrl: profileImageUrl,
              desktop: false,
              onTakePhoto: () => _openSelfie(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF050014),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB9AFC8),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xFF0A041C).withValues(alpha: 0.78),
                    border: Border.all(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                    ),
                  ),
                  child: _IntroContent(
                    profileImageUrl: profileImageUrl,
                    desktop: true,
                    onTakePhoto: () => _openSelfie(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroContent extends StatelessWidget {
  const _IntroContent({
    required this.profileImageUrl,
    required this.desktop,
    required this.onTakePhoto,
  });

  final String profileImageUrl;
  final bool desktop;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    final titleColor = desktop ? Colors.white : Colors.black;
    final bodyColor = desktop ? const Color(0xFFB8B2C7) : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!desktop) const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: PColors.primaryColor,
                  width: 4,
                ),
              ),
            ),
            Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AppNetworkImage.provider(
                    profileImageUrl,
                    memCacheWidth: 400,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          'Get Verified',
          style: getTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Verify your profile with a quick selfie. This helps ensure authenticity and builds trust in the community.',
          style: getTextStyle(
            fontSize: 16,
            color: bodyColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _VerificationStep(
          icon: Icons.camera_alt,
          title: 'Take a Selfie',
          description: desktop
              ? 'Use your webcam or upload a clear photo'
              : 'Use your front camera to capture a clear photo',
          desktop: desktop,
        ),
        const SizedBox(height: 20),
        _VerificationStep(
          icon: Icons.face_retouching_natural,
          title: 'Face Recognition',
          description: "We'll compare it with your profile photo",
          desktop: desktop,
        ),
        const SizedBox(height: 20),
        _VerificationStep(
          icon: Icons.verified,
          title: 'Get Verified',
          description: 'Receive your verification badge instantly',
          desktop: desktop,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onTakePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Take Photo',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool desktop;

  const _VerificationStep({
    required this.icon,
    required this.title,
    required this.description,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: PColors.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: desktop ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: getTextStyle(
                  fontSize: 14,
                  color: desktop ? const Color(0xFFB8B2C7) : Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
