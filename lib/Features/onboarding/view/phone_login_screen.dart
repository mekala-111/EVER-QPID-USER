import 'dart:developer';

import 'package:everqpidapp/Features/onboarding/view/otp_verification_screen.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/settings/view/privacy_policy_screen.dart';
import 'package:everqpidapp/Features/settings/view/terms_conditions_screen.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _completePhoneNumber = '';
  String phoneNumber = '';
  String countryCode = '';
  bool _isButtonEnabled = false;
  bool _isValidNumber = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updateButtonState(bool isValid) {
    setState(() {
      _isValidNumber = isValid;
      _isButtonEnabled = isValid && _phoneController.text.isNotEmpty;
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate() || !_isValidNumber) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    log('complete phone number: $_completePhoneNumber');
    log('ph number and cc:$phoneNumber.,$countryCode');
    authViewModel.setPhoneDetails(
      completePhoneNumber: _completePhoneNumber,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );
    final success = await authViewModel.sendOtp(_completePhoneNumber);

    if (!mounted) return;

    Navigator.pop(context);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            completeNumber: _completePhoneNumber,
            phoneNumber: phoneNumber,
            countryCode: countryCode,
          ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: getTextStyle(
                          fontSize: 12,
                          color: PColors.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsConditionsScreen(),
                              ),
                            );
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: getTextStyle(
                          fontSize: 12,
                          color: PColors.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _sendOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled
                          ? PColors.primaryColor
                          : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get OTP',
                      style: getTextStyle(
                        color:
                            _isButtonEnabled ? Colors.white : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.form,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get Started',
                  style: getTextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "It's quick, secure, and hassle-free, no need\nto remember passwords.",
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                IntlPhoneField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Mobile number',
                    hintStyle: getTextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: PColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  initialCountryCode: 'IN',
                  style: getTextStyle(fontSize: 16, color: Colors.black),
                  dropdownTextStyle: getTextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                    phoneNumber = phone.number;
                    countryCode = phone.countryCode;
                    bool isValid = false;
                    try {
                      isValid = phone.isValidNumber();
                    } catch (_) {}
                    _updateButtonState(isValid);
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    bool isValid = false;
                    try {
                      isValid = phone.isValidNumber();
                    } catch (_) {}
                    if (!isValid) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
