// features/verification/view/verification_result_screen.dart

import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen displaying verification result
class VerificationResultScreen extends StatelessWidget {
  final bool isVerified;
  final String? errorMessage;

  const VerificationResultScreen({
    super.key,
    required this.isVerified,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildScaffold(context, desktop: false),
      desktop: (_) => _buildScaffold(context, desktop: true),
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool desktop}) {
    return Scaffold(
      backgroundColor: desktop ? const Color(0xFF050014) : Colors.white,
      appBar: desktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const SizedBox.shrink(),
              automaticallyImplyLeading: false,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isVerified
                      ? (desktop
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.green[50])
                      : (desktop
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.red[50]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isVerified
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 80,
                  color: isVerified ? Colors.green[600] : Colors.red[600],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isVerified ? 'Verification Successful!' : 'Verification Failed',
                style: getTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: desktop ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isVerified
                    ? 'Your profile has been verified successfully. You now have a verified badge on your profile.'
                    : errorMessage ??
                        'Unable to verify your profile. Please try again.',
                style: getTextStyle(
                  fontSize: 16,
                  color: desktop ? const Color(0xFFB8B2C7) : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (isVerified) _buildVerifiedBenefits(desktop: desktop),
              const Spacer(),
              isVerified
                  ? _buildSuccessButton(context)
                  : _buildFailureButtons(context, desktop: desktop),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBenefits({required bool desktop}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            desktop ? Colors.green.withValues(alpha: 0.12) : Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: desktop
              ? Colors.green.withValues(alpha: 0.35)
              : Colors.green[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Verified Benefits',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBenefitItem('Increased profile visibility'),
          _buildBenefitItem('More trust from other users'),
          _buildBenefitItem('Higher match potential'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: Colors.green[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: getTextStyle(fontSize: 14, color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          await context.read<GetProfileViewModel>().fetchProfile();
          if (!context.mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: PColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFailureButtons(BuildContext context, {required bool desktop}) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              final profile = context.read<GetProfileViewModel>().profile;
              if (profile != null &&
                  profile.profileImageUrl != null &&
                  profile.gender != null) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Try Again',
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
          child: OutlinedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  desktop ? const Color(0xFFC8C2D3) : Colors.grey[700],
              side: BorderSide(
                color: desktop
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey[300]!,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: desktop ? const Color(0xFFC8C2D3) : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
