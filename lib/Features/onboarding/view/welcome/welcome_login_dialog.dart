import 'package:everqpidapp/Features/onboarding/view/profile_intro_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/google_auth_flow.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

enum _LoginStep { welcome, phone, otp }

/// Desktop web login modal — Figma “Welcome back” + phone OTP step.
class WelcomeLoginDialog extends StatefulWidget {
  const WelcomeLoginDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => const WelcomeLoginDialog(),
    );
  }

  @override
  State<WelcomeLoginDialog> createState() => _WelcomeLoginDialogState();
}

class _WelcomeLoginDialogState extends State<WelcomeLoginDialog> {
  _LoginStep _step = _LoginStep.welcome;

  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _completePhone = '';
  String _phoneNumber = '';
  String _countryCode = '';
  bool _valid = false;
  bool _loading = false;

  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpFocus = List.generate(6, (_) => FocusNode());
  int _resendTimer = 60;
  bool _canResend = false;

  static const _manPhoto =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&q=80';
  static const _womanPhoto =
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&q=80';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final n in _otpFocus) {
      n.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _canResend = false;
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || _step != _LoginStep.otp) return false;
      if (_resendTimer <= 1) {
        setState(() {
          _resendTimer = 0;
          _canResend = true;
        });
        return false;
      }
      setState(() => _resendTimer--);
      return true;
    });
  }

  String get _otp => _otpCtrls.map((c) => c.text).join();
  bool get _otpComplete => _otpCtrls.every((c) => c.text.isNotEmpty);

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate() || !_valid) return;

    setState(() => _loading = true);
    final authVm = context.read<AuthViewModel>();
    authVm.setPhoneDetails(
      completePhoneNumber: _completePhone,
      phoneNumber: _phoneNumber,
      countryCode: _countryCode,
    );
    final ok = await authVm.sendOtp(_completePhone);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      for (final c in _otpCtrls) {
        c.clear();
      }
      setState(() => _step = _LoginStep.otp);
      _startResendTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _otpFocus[0].requestFocus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _loading) return;
    setState(() => _loading = true);
    final authVm = context.read<AuthViewModel>();
    final ok = await authVm.sendOtp(_completePhone, isResend: true);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpComplete || _loading) return;

    setState(() => _loading = true);
    final authVm = context.read<AuthViewModel>();

    try {
      final otpOk = await authVm.verifyOtp(_otp);
      if (!mounted) return;
      if (!otpOk) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVm.errorMessage ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
        for (final c in _otpCtrls) {
          c.clear();
        }
        _otpFocus[0].requestFocus();
        return;
      }

      final userExists = await authVm.loginWithPhoneNumber(
        _countryCode,
        _phoneNumber,
      );
      if (!mounted) return;

      if (userExists) {
        final loggedIn = await authVm.loginUser(
          countryCode: _countryCode,
          mobileNumber: _phoneNumber,
        );
        if (!mounted) return;
        setState(() => _loading = false);
        if (loggedIn) {
          Navigator.of(context).pop();
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
                authVm.errorMessage ?? 'Login failed. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _loading = false);
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UnifiedOnboardingScreen(isPhone: true),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: maxH),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: WelcomeTheme.violet.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violetSoft.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                child: switch (_step) {
                  _LoginStep.welcome => _buildWelcome(),
                  _LoginStep.phone => _buildPhone(),
                  _LoginStep.otp => _buildOtp(),
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              if (_step == _LoginStep.phone || _step == _LoginStep.otp)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _step = _step == _LoginStep.otp
                                  ? _LoginStep.phone
                                  : _LoginStep.welcome;
                            }),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Everqpid',
          style: getTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ).copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        const _MiniPhotoCollage(topUrl: _womanPhoto, bottomUrl: _manPhoto),
        const SizedBox(height: 22),
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Login to continue your journey',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 13.5,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 24),
        _SolidButton(
          background: Colors.white,
          onPressed: () => GoogleAuthFlow.signIn(
            context,
            onCloseHost: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _GoogleGlyph(size: 18),
              const SizedBox(width: 10),
              Text(
                'Continue with Google',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _OrDivider(),
        const SizedBox(height: 16),
        _OutlinedGlowButton(
          onPressed: () => setState(() => _step = _LoginStep.phone),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smartphone_outlined,
                size: 18,
                color: Colors.white.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 10),
              Text(
                'Use Mobile Number',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text.rich(
          TextSpan(
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            children: [
              const TextSpan(text: "Don't have an account? "),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () => setState(() => _step = _LoginStep.phone),
                  child: Text(
                    'Sign up',
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WelcomeTheme.violetLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your data is safe with us.',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildPhone() {
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: WelcomeTheme.violetSoft.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.smartphone_outlined,
              size: 32,
              color: WelcomeTheme.violetLight,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Enter your phone number',
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll send you a 6-digit code to verify your number.",
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          IntlPhoneField(
            controller: _phoneCtrl,
            initialCountryCode: 'IN',
            style: getTextStyle(fontSize: 15, color: Colors.white),
            dropdownTextStyle: getTextStyle(fontSize: 14, color: Colors.white),
            dropdownIcon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            decoration: InputDecoration(
              hintText: 'Enter mobile number',
              hintStyle: getTextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.35),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1528),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: WelcomeTheme.violetSoft,
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.4),
              ),
            ),
            onChanged: (phone) {
              _completePhone = phone.completeNumber;
              _phoneNumber = phone.number;
              _countryCode = phone.countryCode;
              var ok = false;
              try {
                ok = phone.isValidNumber();
              } catch (_) {}
              setState(() => _valid = ok);
            },
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return 'Please enter your phone number';
              }
              var ok = false;
              try {
                ok = phone.isValidNumber();
              } catch (_) {}
              if (!ok) return 'Please enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _GradientButton(
            label: 'Send OTP',
            loading: _loading,
            enabled: _valid,
            onTap: _sendOtp,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 14,
                color: Colors.white.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 6),
              Text(
                'Your number is secure and private',
                style: getTextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              style: getTextStyle(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      PPages.termsConditionsScreen,
                    ),
                    child: Text(
                      'Terms',
                      style: getTextStyle(
                        fontSize: 11.5,
                        color: WelcomeTheme.violetLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' & '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      PPages.privacyPolicyScreen,
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: getTextStyle(
                        fontSize: 11.5,
                        color: WelcomeTheme.violetLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOtp() {
    final ss = _resendTimer.toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verify Mobile Number',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter the 6-digit code sent to your phone number.',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 13.5,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: _loading
                ? null
                : () => setState(() => _step = _LoginStep.phone),
            icon: Icon(
              Icons.edit_outlined,
              size: 14,
              color: WelcomeTheme.violetLight,
            ),
            label: Text(
              _completePhone,
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: WelcomeTheme.violetLight,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _DialogOtpBox(
                  controller: _otpCtrls[i],
                  focusNode: _otpFocus[i],
                  onChanged: (value) {
                    if (value.isNotEmpty && i < 5) {
                      _otpFocus[i + 1].requestFocus();
                    } else if (value.isNotEmpty && i == 5) {
                      _verifyOtp();
                    }
                    setState(() {});
                  },
                  onBackspace: () {
                    if (i > 0) {
                      _otpCtrls[i].clear();
                      _otpFocus[i - 1].requestFocus();
                    }
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.55),
            ),
            children: [
              const TextSpan(text: "Didn't receive code? "),
              if (_canResend)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: _resendOtp,
                    child: Text(
                      'Resend OTP',
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WelcomeTheme.violetLight,
                      ),
                    ),
                  ),
                )
              else
                TextSpan(
                  text: '00:$ss',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WelcomeTheme.violetLight,
                  ),
                ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _GradientButton(
          label: 'Verify and Login',
          loading: _loading,
          enabled: _otpComplete,
          onTap: _verifyOtp,
        ),
      ],
    );
  }
}

class _DialogOtpBox extends StatelessWidget {
  const _DialogOtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    final focused = focusNode.hasFocus;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1528),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: focused || filled
                ? WelcomeTheme.violetSoft
                : WelcomeTheme.violetSoft.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            cursorColor: WelcomeTheme.violetLight,
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                onBackspace();
              } else {
                onChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _MiniPhotoCollage extends StatelessWidget {
  const _MiniPhotoCollage({required this.topUrl, required this.bottomUrl});
  final String topUrl;
  final String bottomUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: _photo(topUrl, rotate: -0.08),
          ),
          Positioned(
            right: 8,
            bottom: 4,
            child: _photo(bottomUrl, rotate: 0.1),
          ),
          Icon(
            Icons.favorite,
            color: WelcomeTheme.violetSoft.withValues(alpha: 0.9),
            size: 22,
            shadows: [
              Shadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.8),
                blurRadius: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photo(String url, {required double rotate}) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        width: 88,
        height: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: WelcomeTheme.violetSoft.withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: WelcomeTheme.violet.withValues(alpha: 0.35),
              blurRadius: 16,
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.12),
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: getTextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _OutlinedGlowButton extends StatelessWidget {
  const _OutlinedGlowButton({required this.onPressed, required this.child});
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: WelcomeTheme.violetSoft.withValues(alpha: 0.75),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF161222),
        ),
        child: child,
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  const _SolidButton({
    required this.onPressed,
    required this.child,
    required this.background,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.enabled,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: enabled ? WelcomeTheme.ctaGradient : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.12),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: (enabled && !loading) ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                            Colors.white.withValues(alpha: enabled ? 1 : 0.45),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final stroke = size.width * 0.18;
    final rect = Rect.fromCircle(center: Offset(r, r), radius: r - stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.55, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.05, math.pi * 0.55, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 0.6, math.pi * 0.45, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, math.pi * 1.05, math.pi * 0.45, false, paint);

    canvas.drawRect(
      Rect.fromLTWH(r - stroke * 0.1, r - stroke * 0.55, r * 0.95, stroke),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
