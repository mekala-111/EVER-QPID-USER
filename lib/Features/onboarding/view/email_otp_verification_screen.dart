import 'package:everqpidapp/Features/onboarding/view/profile_intro_screen.dart';
import 'package:everqpidapp/Features/onboarding/view_model/email_auth_view_model.dart';
import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EmailOtpVerificationScreen extends StatefulWidget {
  final String email;
  const EmailOtpVerificationScreen({super.key, required this.email});

  @override
  State<EmailOtpVerificationScreen> createState() =>
      _EmailOtpVerificationScreenState();
}

class _EmailOtpVerificationScreenState
    extends State<EmailOtpVerificationScreen> {
  static const int _otpLength = 5;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(_otpLength, (_) => FocusNode());

  bool _isSubmitting = false;

  String get _otp => _controllers.map((e) => e.text).join();

  bool get _isComplete => _controllers.every((e) => e.text.isNotEmpty);

  Future<void> _verifyOtp() async {
    if (!_isComplete || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final vm = context.read<EmailAuthViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final verificationSuccess = await vm.verifyOtp(_otp);
      if (!verificationSuccess) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userExists = await vm.checkUserExists();
      if (!mounted) return;

      if (userExists == true) {
        final success = await vm.emailLogin(_otp);
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        if (success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            PPages.mainScreen,
            (route) => false,
          );
          PermissionManager.showAfterLogin();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage ?? 'Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const UnifiedOnboardingScreen(isPhone: false),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.form,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your email',
                style: getTextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the verification code sent to ${widget.email}',
                style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              /// OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    onChanged: (v) {
                      if (v.isNotEmpty && i < _otpLength - 1) {
                        _nodes[i + 1].requestFocus();
                      } else if (i == _otpLength - 1) {
                        _verifyOtp();
                      }
                      setState(() {});
                    },
                  );
                }),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isComplete && !_isSubmitting) ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isComplete ? PColors.primaryColor : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isComplete ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
