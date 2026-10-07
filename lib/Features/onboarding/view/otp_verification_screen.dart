import 'package:everqpidapp/Features/onboarding/view/profile_intro_screen.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String completeNumber;
  final String phoneNumber;
  final String countryCode;

  const OtpVerificationScreen({
    super.key,
    required this.completeNumber,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendTimer = 60;
  bool _canResend = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  bool get _isOtpComplete =>
      _otpControllers.every((controller) => controller.text.isNotEmpty);

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final otpOk = await authViewModel.verifyOtp(_otp);
      if (!otpOk) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        return;
      }

      final userExists = await authViewModel.loginWithPhoneNumber(
        widget.countryCode,
        widget.phoneNumber,
      );

      if (!mounted) return;

      if (userExists) {
        final loggedIn = await authViewModel.loginUser(
          countryCode: widget.countryCode,
          mobileNumber: widget.phoneNumber,
        );

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        if (loggedIn) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            PPages.mainScreen,
            (route) => false,
          );
          PermissionManager.showAfterLogin();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authViewModel.errorMessage ??
                    'Login failed. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UnifiedOnboardingScreen(isPhone: true),
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

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    _startTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success =
        await authViewModel.sendOtp(widget.completeNumber, isResend: true);

    if (!mounted) return;

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: AppContentFrame(
          maxWidth: ContentMaxWidth.form,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isOtpComplete && !_isSubmitting) ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isOtpComplete ? PColors.primaryColor : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: getTextStyle(
                    color: _isOtpComplete ? Colors.white : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.form,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your number',
                style: getTextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit verification code sent to\n${widget.completeNumber}',
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return _OtpBox(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isNotEmpty && index == 5) {
                        _verifyOtp();
                      }
                      setState(() {});
                    },
                    onBackspace: () {
                      if (index > 0) {
                        _otpControllers[index].clear();
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: RichText(
                    text: TextSpan(
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      children: [
                        const TextSpan(text: "Didn't receive the code? "),
                        TextSpan(
                          text: _canResend
                              ? 'Resend'
                              : '00:${_resendTimer.toString().padLeft(2, '0')}',
                          style: getTextStyle(
                            fontSize: 14,
                            color: _canResend
                                ? PColors.primaryColor
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            decoration: _canResend
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ],
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
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: controller.text.isEmpty
              ? Colors.grey[300]!
              : PColors.primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            onBackspace();
          } else {
            onChanged(value);
          }
        },
      ),
    );
  }
}
