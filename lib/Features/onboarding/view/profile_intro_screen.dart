// import 'package:everqpidapp/Features/onboarding/view/common_widget.dart';
// import 'package:everqpidapp/Features/onboarding/view/name_dob_screen.dart';
// import 'package:everqpidapp/Settings/constants/text_styles.dart';
// import 'package:everqpidapp/Settings/utils/p_colors.dart';
// import 'package:flutter/material.dart';

// class ProfileIntroScreen extends StatelessWidget {
//   const ProfileIntroScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Progress bar
//               const ProgressBar(currentStep: 1, totalSteps: 5),

//               const SizedBox(height: 40),

//               // Title
//               Text(
//                 'Let\'s start with an\nintro',
//                 style: getTextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black,
//                   height: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Description
//               Text(
//                 'Share your name and date of birth to\npersonalize your experience.',
//                 style: getTextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   height: 1.5,
//                 ),
//               ),

//               const Spacer(),

//               // Continue Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const NameDobScreen(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: PColors.primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     'Continue',
//                     style: getTextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:developer';
import 'dart:typed_data';

import 'package:everqpidapp/Features/onboarding/view/desktop/web_onboarding_shell.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/email_auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/photo_upload_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/signup_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UnifiedOnboardingScreen extends StatefulWidget {
  final bool isPhone;
  const UnifiedOnboardingScreen({super.key, required this.isPhone});

  @override
  State<UnifiedOnboardingScreen> createState() =>
      _UnifiedOnboardingScreenState();
}

class _UnifiedOnboardingScreenState extends State<UnifiedOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Mobile progress track still uses 5 (existing behaviour).
  final int _totalPages = 5;

  /// Actual content steps in the PageView / web card.
  static const int _contentSteps = 4;

  // Form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedLookingFor;
  final List<Uint8List?> _images = List.filled(4, null);
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _goingForward = true;
  bool _showSuccess = false;
  String? _inlineError;

  double get _progress => (_currentPage + 1) / _totalPages;

  bool get _canContinue {
    switch (_currentPage) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _dobController.text.isNotEmpty;
      case 1:
        return _selectedGender != null;
      case 2:
        return _selectedLookingFor != null;
      case 3:
        return _images.any((img) => img != null);
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  void _nextPage() {
    if (_isUploading) return;
    if (_currentPage < _contentSteps - 1) {
      _goingForward = true;
      _inlineError = null;
      if (context.isMobile) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _currentPage++);
      }
    } else {
      _completeSignup();
    }
  }

  void _prevPage() {
    if (_isUploading || _currentPage <= 0) return;
    _goingForward = false;
    _inlineError = null;
    if (context.isMobile) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _currentPage--);
    }
  }

  Future<void> _selectDate() async {
    final isWeb = !context.isMobile;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        if (!isWeb) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: PColors.primaryColor),
            ),
            child: child!,
          );
        }
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFA855F7),
              onPrimary: Colors.white,
              surface: Color(0xFF160A27),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF160A27),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void _goToMain() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      PPages.mainScreen,
      (route) => false,
    );
    PermissionManager.showAfterLogin();
  }

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
    if (!_images.any((img) => img != null)) {
      Fluttertoast.showToast(msg: "Please upload at least one image");
      return;
    }
    if (_isUploading) return;

    final isMobile = context.isMobile;
    final photoViewModel = Provider.of<PhotoUploadViewModel>(
      context,
      listen: false,
    );
    final emailAuthVM = context.read<EmailAuthViewModel>();
    final signupViewModel = Provider.of<SignupViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Same location dialog as existing-user login (gesture-gated for web).
    final loc = await PermissionManager.promptLocationForSignup(context);
    if (!mounted) return;
    if (loc == null) {
      const msg =
          'Location is required to create your profile. Tap Allow, then confirm in the browser prompt.';
      if (isMobile) {
        Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red);
      } else {
        setState(() => _inlineError = msg);
      }
      return;
    }
    signupViewModel.setLocation(loc.lat, loc.lng, loc.locationString);
    emailAuthVM.setLocation(loc.lat, loc.lng, loc.locationString);

    setState(() {
      _isUploading = true;
      _inlineError = null;
    });

    try {
      final uploadedUrls = await photoViewModel.uploadImages(_images);

      if (uploadedUrls.isEmpty) {
        throw Exception("Failed to upload images");
      }

      final dob = _selectedDate;
      if (dob == null) {
        throw Exception('Date of birth is required');
      }
      final dobIso = DateFormat('yyyy-MM-dd').format(dob);

      signupViewModel.setProfilePhotos(uploadedUrls);
      signupViewModel.setProfileImageUrl(uploadedUrls.first);
      signupViewModel.setFullName(_nameController.text);
      signupViewModel.setDateOfBirth(dobIso);
      signupViewModel.setGender(_selectedGender!);
      signupViewModel.setLookingFor(_selectedLookingFor!);
      emailAuthVM.setFullName(_nameController.text);
      emailAuthVM.setDateOfBirth(dobIso);
      emailAuthVM.setGender(_selectedGender!);
      emailAuthVM.setLookingFor(_selectedLookingFor!);
      emailAuthVM.setProfilePhotos(uploadedUrls);
      emailAuthVM.setProfileImageUrl(uploadedUrls.first);

      final phoneCode = authViewModel.countryCode ?? '';
      final phone = authViewModel.phoneNumber ?? '';
      log('checking the isphone value: ${widget.isPhone}');
      final success = widget.isPhone
          ? await signupViewModel.performSignup(
              countryCode: phoneCode,
              mobileNumber: phone,
            )
          : await emailAuthVM.emailSignup();

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (success) {
        if (isMobile) {
          Fluttertoast.showToast(msg: "Welcome to Everqpid ❤️");
          _goToMain();
        } else {
          setState(() => _showSuccess = true);
        }
      } else {
        final msg = signupViewModel.errorMessage ??
            emailAuthVM.errorMessage ??
            "We couldn't save your information. Please try again.";
        if (isMobile) {
          Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red);
        } else {
          setState(() => _inlineError = msg);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        if (!isMobile) {
          _inlineError = "We couldn't save your information. Please try again.";
        }
      });
      if (isMobile) {
        Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) {
      return _buildWeb();
    }
    return _buildMobile();
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            AppContentFrame(
              maxWidth: ContentMaxWidth.form,
              child: Column(
                children: [
                  // Continuous Linear Progress Indicator
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          PColors.primaryColor,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),

                  // PageView for screens
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        _buildNameDobPage(),
                        _buildGenderPage(),
                        _buildLookingForPage(),
                        _buildPhotoUploadPage(),
                      ],
                    ),
                  ),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _nextPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canContinue
                              ? PColors.primaryColor
                              : Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _contentSteps - 1
                              ? 'Submit'
                              : 'Continue',
                          style: getTextStyle(
                            color:
                                _canContinue ? Colors.white : Colors.grey[500],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeb() {
    if (_showSuccess) {
      return WebOnboardingShell(
        currentStep: _contentSteps,
        totalSteps: _contentSteps,
        footer: WebOnboardingContinueButton(
          enabled: true,
          loading: false,
          label: 'Start Discovering',
          onPressed: _goToMain,
        ),
        child: _buildWebSuccess(),
      );
    }

    return WebOnboardingShell(
      currentStep: _currentPage + 1,
      totalSteps: _contentSteps,
      onBack: _currentPage > 0 ? _prevPage : null,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_inlineError != null) ...[
            Text(
              _inlineError!,
              style: getTextStyle(fontSize: 13, color: const Color(0xFFF87171)),
            ),
            const SizedBox(height: 12),
          ],
          WebOnboardingContinueButton(
            enabled: _canContinue && !_isUploading,
            loading: _isUploading,
            label: _currentPage == _contentSteps - 1 ? 'Submit' : 'Continue →',
            onPressed: _nextPage,
          ),
          const SizedBox(height: 14),
          const WebOnboardingPrivacyNote(),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) {
          final offset = Tween<Offset>(
            begin: Offset(_goingForward ? 0.06 : -0.06, 0),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentPage),
          child: _webStepContent(),
        ),
      ),
    );
  }

  Widget _webStepContent() {
    switch (_currentPage) {
      case 0:
        return _buildWebNameDob();
      case 1:
        return _buildWebGender();
      case 2:
        return _buildWebLookingFor();
      case 3:
        return _buildWebPhotos();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWebSuccess() {
    return Column(
      children: [
        Icon(
          Icons.favorite_rounded,
          size: 48,
          color: WelcomeTheme.violetSoft,
        ),
        const SizedBox(height: 20),
        Text(
          "You're all set!",
          style: getTextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your EverQpid journey starts here.',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFFAAA3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildWebNameDob() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Tell Cupid Who You Are',
                style: getTextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.favorite_rounded,
                size: 22, color: WelcomeTheme.violetSoft),
          ],
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Text(
            'Share your name and date of birth to personalize your experience.',
            style: getTextStyle(
              fontSize: 15,
              height: 1.5,
              color: const Color(0xFFAAA3B8),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Full name',
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE8E4EE),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: getTextStyle(fontSize: 15, color: Colors.white),
          cursorColor: WelcomeTheme.violetSoft,
          decoration: webOnboardingFieldDecoration(
            hint: 'Enter your full name',
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Date of birth',
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE8E4EE),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dobController,
          readOnly: true,
          onTap: _selectDate,
          style: getTextStyle(fontSize: 15, color: Colors.white),
          decoration: webOnboardingFieldDecoration(
            hint: 'DD / MM / YYYY',
            suffixIcon: IconButton(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today_rounded,
                  size: 20, color: Color(0xFFA855F7)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your gender',
          style: getTextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose your gender to help Cupid personalize your match suggestions.',
          style: getTextStyle(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFFAAA3B8),
          ),
        ),
        const SizedBox(height: 28),
        _GenderOption(
          label: 'Women',
          isSelected: _selectedGender == 'Women',
          dark: true,
          onTap: () => setState(() => _selectedGender = 'Women'),
        ),
        const SizedBox(height: 12),
        _GenderOption(
          label: 'Man',
          isSelected: _selectedGender == 'Man',
          dark: true,
          onTap: () => setState(() => _selectedGender = 'Man'),
        ),
        const SizedBox(height: 12),
        _GenderOption(
          label: 'Other',
          isSelected: _selectedGender == 'Other',
          dark: true,
          onTap: () => setState(() => _selectedGender = 'Other'),
        ),
      ],
    );
  }

  Widget _buildWebLookingFor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Are You Looking For?',
          style: getTextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Be honest with Cupid. It helps him aim straight at your perfect match.',
          style: getTextStyle(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFFAAA3B8),
          ),
        ),
        const SizedBox(height: 28),
        _LookingForOption(
          title: 'Date',
          description:
              "I'm interested in dating, be it casual or something meaningful.",
          isSelected: _selectedLookingFor == 'Date',
          dark: true,
          onTap: () => setState(() => _selectedLookingFor = 'Date'),
        ),
        const SizedBox(height: 12),
        _LookingForOption(
          title: 'BFF',
          description: "I'm looking for genuine friendships and new BFFs.",
          isSelected: _selectedLookingFor == 'BFF',
          dark: true,
          onTap: () => setState(() => _selectedLookingFor = 'BFF'),
        ),
      ],
    );
  }

  Widget _buildWebPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Show Your Best Self',
          style: getTextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Upload at least one photo so Cupid can help you make a great first impression.',
          style: getTextStyle(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFFAAA3B8),
          ),
        ),
        const SizedBox(height: 28),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return _PhotoBox(
              image: _images[index],
              dark: true,
              onTap: () => _pickImage(index),
              onRemove: () => _removeImage(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNameDobPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Tell Cupid Who You\nAre',
            style: getTextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share your name and date of birth to\npersonalize your experience.',
            style: getTextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            style: getTextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              hintText: 'full name',
              hintStyle: getTextStyle(fontSize: 16, color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dobController,
            readOnly: true,
            onTap: _selectDate,
            style: getTextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
              hintText: 'date of birth',
              hintStyle: getTextStyle(fontSize: 16, color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Select your gender',
            style: getTextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose your gender to help Cupid\npersonalize your match suggestions.',
            style: getTextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _GenderOption(
            label: 'Women',
            isSelected: _selectedGender == 'Women',
            onTap: () => setState(() => _selectedGender = 'Women'),
          ),
          const SizedBox(height: 16),
          _GenderOption(
            label: 'Man',
            isSelected: _selectedGender == 'Man',
            onTap: () => setState(() => _selectedGender = 'Man'),
          ),
          const SizedBox(height: 16),
          _GenderOption(
            label: 'Other',
            isSelected: _selectedGender == 'Other',
            onTap: () => setState(() => _selectedGender = 'Other'),
          ),
        ],
      ),
    );
  }

  Widget _buildLookingForPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What Are You\nLooking For?',
            style: getTextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Be honest with Cupid. It helps him aim\nstraight at your perfect match.',
            style: getTextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _LookingForOption(
            title: 'Date',
            description:
                'I\'m interested in dating, be it casual or\nsomething meaningful.',
            isSelected: _selectedLookingFor == 'Date',
            onTap: () => setState(() => _selectedLookingFor = 'Date'),
          ),
          const SizedBox(height: 16),
          _LookingForOption(
            title: 'BFF',
            description: 'I\'m looking for genuine friendships and new\nBFFs.',
            isSelected: _selectedLookingFor == 'BFF',
            onTap: () => setState(() => _selectedLookingFor = 'BFF'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              child: CircularProgressIndicator(
                color: PColors.primaryColor,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
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
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool dark;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? (isSelected
            ? const Color(0xFFA855F7).withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05))
        : const Color(0xFFF5F5F5);
    final border = dark
        ? (isSelected
            ? const Color(0xFFA855F7)
            : Colors.white.withValues(alpha: 0.10))
        : (isSelected ? PColors.primaryColor : Colors.transparent);
    final textColor = dark ? Colors.white : Colors.black;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: dark ? 1.2 : 2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: getTextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark ? const Color(0xFFA855F7) : PColors.primaryColor,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LookingForOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final bool dark;

  const _LookingForOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? (isSelected
            ? const Color(0xFFA855F7).withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05))
        : const Color(0xFFF5F5F5);
    final border = dark
        ? (isSelected
            ? const Color(0xFFA855F7)
            : Colors.white.withValues(alpha: 0.10))
        : (isSelected ? PColors.primaryColor : Colors.transparent);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: dark ? 1.2 : 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 18,
                      color: dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: getTextStyle(
                      fontSize: 12,
                      color: dark ? const Color(0xFFAAA3B8) : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark ? const Color(0xFFA855F7) : PColors.primaryColor,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
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
  final bool dark;

  const _PhotoBox({
    required this.image,
    required this.onTap,
    required this.onRemove,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: dark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: dark
              ? Border.all(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.28),
                )
              : null,
          image: image != null
              ? DecorationImage(image: MemoryImage(image!), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: dark ? const Color(0xFFA855F7) : Colors.grey,
                ),
              )
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
                          color: Colors.black.withValues(alpha: 0.6),
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
