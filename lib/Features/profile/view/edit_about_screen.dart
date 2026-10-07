import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_form_controls.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/helper/date_formatter_helper.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditAboutScreen extends StatefulWidget {
  const EditAboutScreen({super.key});

  @override
  State<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  final String _countryCode = '+91';
  List<String> _selectedLanguages = [];
  int? _selectedHeight;
  String? _selectedMaritalStatus;
  String? _selectedReligion;
  DateTime? _selectedDate;
  String? _selectedZodiacSign;
  String? _selectedSmokingHabit;
  String? _selectedAlcoholConsumption;
  String? _selectedWorkoutFrequency;

  String? _phoneError;

  final List<int> _heightOptions = List.generate(61, (index) => 140 + index);

  final List<String> _allLanguages = [
    'Hindi',
    'English',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Gujarati',
    'Urdu',
    'Kannada',
    'Odia',
    'Malayalam',
    'Punjabi',
    'Assamese',
    'Maithili',
    'Sanskrit',
    'Konkani',
    'Nepali',
    'Sindhi',
    'Dogri',
    'Kashmiri',
    'Manipuri',
    'Bodo',
    'Santali',
  ];

  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  final List<String> _religionOptions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Buddhist',
    'Jain',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _zodiacSignOptions = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];
  final List<String> _smokingHabitOptions = [
    'Non-smoker',
    'Social Smoker',
    'Smoker when drinking',
    'Smoker',
    'Trying to quit',
  ];
  final List<String> _alcoholConsumptionOptions = [
    'Not for me',
    'Sober',
    'Sober curious',
    'On special occasions',
    'Socially on weekends',
    'Most Nights',
  ];
  final List<String> _workoutFrequencyOptions = [
    'Never',
    'Sometimes',
    'Often',
    'Everyday',
  ];

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<ProfileViewModel>();

    _nameController = TextEditingController(text: viewModel.fullName ?? '');
    _phoneController = TextEditingController(
      text: viewModel.mobileNumber ?? '',
    );
    _dobController = TextEditingController(text: viewModel.dateOfBirth ?? '');

    _selectedLanguages = List<String>.from(viewModel.otherLanguages);

    if (viewModel.height != null) {
      _selectedHeight = viewModel.height;
    }

    if (viewModel.relationshipStatus != null &&
        viewModel.relationshipStatus!.isNotEmpty &&
        _maritalStatusOptions.contains(viewModel.relationshipStatus)) {
      _selectedMaritalStatus = viewModel.relationshipStatus;
    }

    if (viewModel.religion != null &&
        viewModel.religion!.isNotEmpty &&
        _religionOptions.contains(viewModel.religion)) {
      _selectedReligion = viewModel.religion;
    }
    if (viewModel.zodiacSign != null &&
        viewModel.zodiacSign!.isNotEmpty &&
        _zodiacSignOptions.contains(viewModel.zodiacSign)) {
      _selectedZodiacSign = viewModel.zodiacSign;
    }
    if (viewModel.smokingHabit != null &&
        viewModel.smokingHabit!.isNotEmpty &&
        _smokingHabitOptions.contains(viewModel.smokingHabit)) {
      _selectedSmokingHabit = viewModel.smokingHabit;
    }
    if (viewModel.alcoholConsumption != null &&
        viewModel.alcoholConsumption!.isNotEmpty &&
        _alcoholConsumptionOptions.contains(viewModel.alcoholConsumption)) {
      _selectedAlcoholConsumption = viewModel.alcoholConsumption;
    }
    if (viewModel.workoutFrequency != null &&
        viewModel.workoutFrequency!.isNotEmpty &&
        _workoutFrequencyOptions.contains(viewModel.workoutFrequency)) {
      _selectedWorkoutFrequency = viewModel.workoutFrequency;
    }

    if (viewModel.dateOfBirth != null && viewModel.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(viewModel.dateOfBirth!);
        _dobController.text = formatForDisplay(_selectedDate!);
      } catch (_) {
        _selectedDate = null;
        _dobController.clear();
      }
    }

    // Add phone validation listener
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();

    setState(() {
      if (phone.isEmpty) {
        _phoneError = null; // No error for empty field
      } else if (phone.length != 10) {
        _phoneError = 'Phone number must be 10 digits';
      } else if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
        _phoneError = 'Invalid Indian phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        final dark = MediaQuery.sizeOf(context).width >= 768;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: dark
                ? const ColorScheme.dark(
                    primary: WelcomeTheme.violetSoft,
                    surface: Color(0xFF160E28),
                  )
                : ColorScheme.light(primary: PColors.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _showLanguageSelector({bool dark = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? const Color(0xFF160E28) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            'Select Languages',
                            style: getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: dark ? Colors.white : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Done',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: dark
                                    ? WelcomeTheme.violetLight
                                    : PColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: dark ? Colors.white12 : Colors.black12,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _allLanguages.length,
                        itemBuilder: (context, index) {
                          final language = _allLanguages[index];
                          final isSelected =
                              _selectedLanguages.contains(language);

                          return CheckboxListTile(
                            title: Text(
                              language,
                              style: getTextStyle(
                                fontSize: 15,
                                color: dark ? Colors.white : Colors.black,
                              ),
                            ),
                            value: isSelected,
                            activeColor: dark
                                ? WelcomeTheme.violetSoft
                                : PColors.primaryColor,
                            checkColor: Colors.white,
                            onChanged: (value) {
                              setModalState(() {
                                setState(() {
                                  if (value == true) {
                                    _selectedLanguages.add(language);
                                  } else {
                                    _selectedLanguages.remove(language);
                                  }
                                });
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  bool _validateForm() {
    // Name validation
    if (_nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your name',
        backgroundColor: Colors.red,
      );
      return false;
    }

    // Phone validation - only if user has modified the phone field
    final viewModel = context.read<ProfileViewModel>();
    final originalPhone = viewModel.mobileNumber ?? '';

    if (_phoneController.text.trim() != originalPhone) {
      final phone = _phoneController.text.trim();

      if (phone.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please enter a phone number',
          backgroundColor: Colors.red,
        );
        return false;
      }

      if (phone.length != 10) {
        Fluttertoast.showToast(
          msg: 'Phone number must be 10 digits',
          backgroundColor: Colors.red,
        );
        return false;
      }

      if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
        Fluttertoast.showToast(
          msg: 'Invalid Indian phone number (must start with 6-9)',
          backgroundColor: Colors.red,
        );
        return false;
      }
    }

    return true;
  }

  void _saveAndGoBack() {
    if (!_validateForm()) {
      return;
    }

    final viewModel = context.read<ProfileViewModel>();

    // Update name
    if (_nameController.text.trim().isNotEmpty) {
      viewModel.setFullName(_nameController.text.trim());
    }

    // Update DOB
    if (_dobController.text.isNotEmpty) {
      viewModel.setDateOfBirth(_dobController.text);
    }

    // Update height
    if (_selectedHeight != null) {
      viewModel.setHeight(_selectedHeight!);
    }

    // Update marital status
    if (_selectedMaritalStatus != null) {
      viewModel.setRelationshipStatus(_selectedMaritalStatus!);
    }

    // Update religion
    if (_selectedReligion != null) {
      viewModel.setReligion(_selectedReligion!);
    }
    // Update zodiac sign
    if (_selectedZodiacSign != null) {
      viewModel.setZodiacSign(_selectedZodiacSign!);
    }
    // Update smoking habit
    if (_selectedSmokingHabit != null) {
      viewModel.setSmokingHabit(_selectedSmokingHabit!);
    }
    // Update alcohol consumption
    if (_selectedAlcoholConsumption != null) {
      viewModel.setAlcoholConsumption(_selectedAlcoholConsumption!);
    }
    // Update workout frequency
    if (_selectedWorkoutFrequency != null) {
      viewModel.setWorkoutFrequency(_selectedWorkoutFrequency!);
    }

    // Update languages
    viewModel.setLanguages(_selectedLanguages);

    // Only update phone if it changed and is valid
    final originalPhone = viewModel.mobileNumber ?? '';
    if (_phoneController.text.trim() != originalPhone &&
        _phoneController.text.trim().isNotEmpty) {
      viewModel.setPhoneNumber(_countryCode, _phoneController.text.trim());
    }

    Fluttertoast.showToast(msg: 'About info updated successfully');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(),
      desktop: (_) => _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    Widget field(String label, Widget child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [DesktopFieldLabel(label), child],
        );

    return DesktopSubpageBody(
      header: const DesktopSubpageHeader(
        title: 'About',
        subtitle: 'Complete your basic info',
      ),
      tip: const DesktopTipCard(
        title: 'Profile Tips',
        tips: [
          'Add accurate information',
          'Complete your languages',
          'Complete more fields to improve matching',
        ],
      ),
      saveBar: DesktopSaveBar(onSave: _saveAndGoBack),
      form: DesktopFormCard(
        title: 'Basic Information',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DesktopTwoCol(
              left: field(
                'Name',
                DesktopTextField(
                  controller: _nameController,
                  hint: 'Enter your name',
                ),
              ),
              right: field(
                'Mobile Number',
                Row(
                  children: [
                    Container(
                      height: DesktopFormStyle.fieldHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius:
                            BorderRadius.circular(DesktopFormStyle.radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        _countryCode,
                        style: getTextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DesktopTextField(
                        controller: _phoneController,
                        hint: 'Phone number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        errorText: _phoneError,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DesktopTwoCol(
              left: field(
                'Date of Birth',
                DesktopTextField(
                  controller: _dobController,
                  hint: 'DD-MM-YYYY',
                  readOnly: true,
                  onTap: _selectDate,
                ),
              ),
              right: field(
                'Height',
                DesktopDropdown<int>(
                  value: _selectedHeight,
                  items: _heightOptions,
                  hint: 'Select height',
                  itemLabel: (h) => '$h cm',
                  onChanged: (v) => setState(() => _selectedHeight = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DesktopFieldLabel('Languages'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final lang in _selectedLanguages)
                  InputChip(
                    label: Text(lang),
                    labelStyle:
                        getTextStyle(fontSize: 13, color: Colors.white),
                    backgroundColor:
                        WelcomeTheme.violet.withValues(alpha: 0.25),
                    side: BorderSide(
                      color: WelcomeTheme.violet.withValues(alpha: 0.45),
                    ),
                    deleteIconColor: Colors.white70,
                    onDeleted: () =>
                        setState(() => _selectedLanguages.remove(lang)),
                  ),
                ActionChip(
                  avatar: Icon(Icons.add,
                      size: 16, color: WelcomeTheme.violetLight),
                  label: Text(
                    'Add Language',
                    style: getTextStyle(
                      fontSize: 13,
                      color: WelcomeTheme.violetLight,
                    ),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  side: BorderSide(
                    color: WelcomeTheme.violet.withValues(alpha: 0.35),
                  ),
                  onPressed: () => _showLanguageSelector(dark: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DesktopTwoCol(
              left: field(
                'Marital Status',
                DesktopDropdown<String>(
                  value: _selectedMaritalStatus,
                  items: _maritalStatusOptions,
                  hint: 'Select marital status',
                  onChanged: (v) =>
                      setState(() => _selectedMaritalStatus = v),
                ),
              ),
              right: field(
                'Religion',
                DesktopDropdown<String>(
                  value: _selectedReligion,
                  items: _religionOptions,
                  hint: 'Select religion',
                  onChanged: (v) => setState(() => _selectedReligion = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DesktopTwoCol(
              left: field(
                'Zodiac Sign',
                DesktopDropdown<String>(
                  value: _selectedZodiacSign,
                  items: _zodiacSignOptions,
                  hint: 'Select zodiac sign',
                  onChanged: (v) => setState(() => _selectedZodiacSign = v),
                ),
              ),
              right: field(
                'Smoking Habit',
                DesktopDropdown<String>(
                  value: _selectedSmokingHabit,
                  items: _smokingHabitOptions,
                  hint: 'Select smoking habit',
                  onChanged: (v) => setState(() => _selectedSmokingHabit = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DesktopTwoCol(
              left: field(
                'Alcohol Consumption',
                DesktopDropdown<String>(
                  value: _selectedAlcoholConsumption,
                  items: _alcoholConsumptionOptions,
                  hint: 'Select alcohol consumption',
                  onChanged: (v) =>
                      setState(() => _selectedAlcoholConsumption = v),
                ),
              ),
              right: field(
                'Workout Frequency',
                DesktopDropdown<String>(
                  value: _selectedWorkoutFrequency,
                  items: _workoutFrequencyOptions,
                  hint: 'Select workout frequency',
                  onChanged: (v) =>
                      setState(() => _selectedWorkoutFrequency = v),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Back',
          style: getTextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your basic info',
                    style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Enter your name',
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Mobile Number'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _countryCode,
                          style: getTextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: _phoneController,
                              hintText: 'Phone number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            if (_phoneError != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _phoneError!,
                                style: getTextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Date of Birth'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _dobController,
                    hintText: 'DD-MM-YYYY',
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Languages'),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      ..._selectedLanguages.map((lang) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildLanguageTile(lang),
                        );
                      }),
                      _buildAddButton(
                        'Add Language',
                        onTap: () => _showLanguageSelector(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Height'),
                  const SizedBox(height: 8),
                  _buildHeightDropdownField(
                    value: _selectedHeight,
                    hint: 'Select height',
                    items: _heightOptions,
                    onChanged: (value) {
                      setState(() => _selectedHeight = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Martial Status'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _selectedMaritalStatus,
                    hint: 'Select marital status',
                    items: _maritalStatusOptions,
                    onChanged: (value) {
                      setState(() => _selectedMaritalStatus = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Religion'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _selectedReligion,
                    hint: 'Select religion',
                    items: _religionOptions,
                    onChanged: (value) {
                      setState(() => _selectedReligion = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Zodiac Sign'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _selectedZodiacSign,
                    hint: 'Select zodiac sign',
                    items: _zodiacSignOptions,
                    onChanged: (value) {
                      setState(() => _selectedZodiacSign = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Smoking Habit'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _selectedSmokingHabit,
                    hint: 'Select smoking habit',
                    items: _smokingHabitOptions,
                    onChanged: (value) {
                      setState(() => _selectedSmokingHabit = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Alcohol Consumption'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _selectedAlcoholConsumption,
                    hint: 'Select alcohol consumption',
                    items: _alcoholConsumptionOptions,
                    onChanged: (value) {
                      setState(() => _selectedAlcoholConsumption = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Workout Frequency'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _selectedWorkoutFrequency,
                    hint: 'Select workout frequency',
                    items: _workoutFrequencyOptions,
                    onChanged: (value) {
                      setState(() => _selectedWorkoutFrequency = value);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndGoBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: getTextStyle(
        fontSize: 13,
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        style: getTextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: getTextStyle(fontSize: 15, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildHeightDropdownField({
    required int? value,
    required String hint,
    required List<int> items,
    required Function(int?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: getTextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          style: getTextStyle(fontSize: 15, color: Colors.black),
          items: items.map((height) {
            return DropdownMenuItem<int>(
              value: height,
              child: Text('$height cm'),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: getTextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          style: getTextStyle(fontSize: 15, color: Colors.black),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              language,
              style: getTextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLanguages.remove(language);
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, color: Colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: PColors.primaryColor, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: getTextStyle(
                fontSize: 15,
                color: PColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
