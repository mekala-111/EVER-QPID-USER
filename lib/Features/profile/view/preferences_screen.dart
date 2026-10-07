import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/mainscreen/view/widgets/desktop_sidebar.dart';
import 'package:everqpidapp/Features/profile/model/preferences_model.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_preferences_view.dart';
import 'package:everqpidapp/Features/profile/view_model/preferences_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  RangeValues _ageRange = const RangeValues(18, 38);
  double _distance = 50;
  List<String> _selectedLanguages = [];
  String? _selectedReligion;
  String? _selectedRelationshipStatus;
  String? _selectedEducation;
  String? _selectedProfession;
  RangeValues _heightRange = const RangeValues(150, 180);
  String? _selectedLocation;
  List<String> _selectedLookingFor = [];
  String? _selectedInterestedIn;
  bool _allowOutOfDistance = true;
  bool _allowOutOfAgeRange = true;
  bool _tabletSidebarCollapsed = true;

  final List<String> _languageOptions = [
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

  final List<String> _relationshipStatusOptions = [
    'Single',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  final List<String> _educationOptions = [
    'High School',
    'Diploma',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'B.Tech',
    'MBA',
    'MBBS',
  ];

  final List<String> _professionOptions = [
    'Software Developer',
    'Designer',
    'Engineer',
    'Doctor',
    'Teacher',
    'Business Owner',
    'Manager',
    'Student',
    'Other',
  ];

  final List<String> _lookingForOptions = [
    'Looking for a partner',
    'Friendship',
    'Marriage',
    'Long-term Relationship',
    'Long-term, open to short',
    'Short-term, open to long',
    'Short-term, fun',
    'New friends',
    'Casual dating',
    'Still figuring it out',
  ];

  final List<String> _interestedInOptions = ['Women', 'Men', 'Everyone'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PreferencesViewModel>();
      vm.fetchPreferences().then((_) {
        if (vm.hasPreferences) {
          _loadPreferences(vm.preferences!);
        }
      });
    });
  }

  void _loadPreferences(UserPreferences prefs) {
    setState(() {
      _ageRange = RangeValues(
        prefs.minAge != null && prefs.minAge! > 0
            ? prefs.minAge!.toDouble()
            : 18,
        prefs.maxAge != null && prefs.maxAge! > 0
            ? prefs.maxAge!.toDouble()
            : 38,
      );

      _distance = prefs.distance != null && prefs.distance! > 0
          ? (prefs.distance! / 1000).toDouble()
          : 50;

      _selectedLanguages = prefs.otherLanguages ?? [];

      _selectedReligion =
          _religionOptions.contains(prefs.religion) ? prefs.religion : null;

      _selectedRelationshipStatus =
          _relationshipStatusOptions.contains(prefs.maritalStatus)
              ? prefs.maritalStatus
              : null;

      _selectedEducation =
          _educationOptions.contains(prefs.education) ? prefs.education : null;

      _selectedProfession = _professionOptions.contains(prefs.profession)
          ? prefs.profession
          : null;

      _selectedInterestedIn = _interestedInOptions.contains(prefs.interestedIn)
          ? prefs.interestedIn
          : null;

      _heightRange = RangeValues(
        prefs.minHeight != null && prefs.minHeight! > 0
            ? prefs.minHeight!.toDouble()
            : 150,
        prefs.maxHeight != null && prefs.maxHeight! > 0
            ? prefs.maxHeight!.toDouble()
            : 180,
      );

      _selectedLookingFor = prefs.looking ?? [];

      _selectedLocation = prefs.locationString;

      _allowOutOfDistance = prefs.allowOutOfDistance ?? true;
      _allowOutOfAgeRange = prefs.allowOutOfAgeRange ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final vm = context.read<PreferencesViewModel>();

    final prefs = UserPreferences(
      id: vm.preferences?.id ?? '',
      userId: vm.preferences?.userId ?? '',
      locationString: _selectedLocation,
      lat: vm.preferences?.lat,
      lng: vm.preferences?.lng,
      distance: (_distance * 1000).toInt(),
      minAge: _ageRange.start.toInt(),
      maxAge: _ageRange.end.toInt(),
      minHeight: _heightRange.start.toInt(),
      maxHeight: _heightRange.end.toInt(),
      looking: _selectedLookingFor.isEmpty ? null : _selectedLookingFor,
      otherLanguages: _selectedLanguages.isEmpty ? null : _selectedLanguages,
      religion: _selectedReligion,
      maritalStatus: _selectedRelationshipStatus,
      profession: _selectedProfession,
      education: _selectedEducation,
      interestedIn: _selectedInterestedIn,
      allowOutOfDistance: _allowOutOfDistance,
      allowOutOfAgeRange: _allowOutOfAgeRange,
    );

    final success = await vm.savePreferences(prefs);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.refresh, color: Colors.red[400], size: 28),
            const SizedBox(width: 8),
            Text(
              'Reset Preferences',
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset all preferences to default? This action cannot be undone.',
          style: getTextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: getTextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetPreferences();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Reset',
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPreferences() async {
    final vm = context.read<PreferencesViewModel>();

    final success = await vm.resetPreferences();

    if (success && mounted) {
      if (vm.hasPreferences) {
        _loadPreferences(vm.preferences!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences reset successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (vm.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _leaveToTab(int index) {
    Navigator.of(context).pop();
    MainScreenBridge.navigateToTab(index);
  }

  Widget _desktopForm() {
    return DesktopPreferencesView(
      ageRange: _ageRange,
      onAgeRangeChanged: (v) => setState(() => _ageRange = v),
      distance: _distance,
      onDistanceChanged: (v) => setState(() => _distance = v),
      heightRange: _heightRange,
      onHeightRangeChanged: (v) => setState(() => _heightRange = v),
      languageOptions: _languageOptions,
      selectedLanguages: _selectedLanguages,
      onLanguagesChanged: (v) => setState(() => _selectedLanguages = v),
      religionOptions: _religionOptions,
      selectedReligion: _selectedReligion,
      onReligionChanged: (v) => setState(() => _selectedReligion = v),
      relationshipStatusOptions: _relationshipStatusOptions,
      selectedRelationshipStatus: _selectedRelationshipStatus,
      onRelationshipStatusChanged: (v) =>
          setState(() => _selectedRelationshipStatus = v),
      educationOptions: _educationOptions,
      selectedEducation: _selectedEducation,
      onEducationChanged: (v) => setState(() => _selectedEducation = v),
      professionOptions: _professionOptions,
      selectedProfession: _selectedProfession,
      onProfessionChanged: (v) => setState(() => _selectedProfession = v),
      lookingForOptions: _lookingForOptions,
      selectedLookingFor: _selectedLookingFor,
      onLookingForChanged: (v) => setState(() => _selectedLookingFor = v),
      interestedInOptions: _interestedInOptions,
      selectedInterestedIn: _selectedInterestedIn,
      onInterestedInChanged: (v) => setState(() => _selectedInterestedIn = v),
      allowOutOfDistance: _allowOutOfDistance,
      onAllowOutOfDistanceChanged: (v) =>
          setState(() => _allowOutOfDistance = v),
      allowOutOfAgeRange: _allowOutOfAgeRange,
      onAllowOutOfAgeRangeChanged: (v) =>
          setState(() => _allowOutOfAgeRange = v),
      onSave: _savePreferences,
      onReset: () => _showResetDialog(context),
      onCancel: () => Navigator.pop(context),
    );
  }

  Widget _shell({required bool collapsed, VoidCallback? onToggleCollapse}) {
    return Scaffold(
      backgroundColor: const Color(0xFF090416),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Images.bg,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            cacheWidth: 1600,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF090416)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesktopSidebar(
                selectedIndex: 4,
                onSelect: _leaveToTab,
                collapsed: collapsed,
                onToggleCollapse: onToggleCollapse,
              ),
              Expanded(
                child: Column(
                  children: [
                    const DesktopContentTopBar(),
                    Expanded(child: _desktopForm()),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        title: Text(
          "Preferences",
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Selector<PreferencesViewModel, (bool, bool)>(
            selector: (_, vm) => (vm.isResetting, vm.isSaving),
            builder: (context, state, _) {
              final isResetting = state.$1;
              final isSaving = state.$2;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: isResetting ? Colors.grey : Colors.red[400],
                    ),
                    onPressed: isResetting || isSaving
                        ? null
                        : () => _showResetDialog(context),
                    tooltip: 'Reset Preferences',
                  ),
                  TextButton(
                    onPressed:
                        isSaving || isResetting ? null : _savePreferences,
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Save',
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PColors.primaryColor,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.form,
        child: Consumer<PreferencesViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vm.successMessage != null)
                    _buildSuccessMessage(vm.successMessage!),
                  if (vm.errorMessage != null)
                    _buildErrorMessage(vm.errorMessage!),
                  _buildSectionTitle('Age Range'),
                  _buildAgeRangeSlider(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Distance'),
                  _buildDistanceSlider(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Languages'),
                  _buildMultiSelectChips(
                    options: _languageOptions,
                    selected: _selectedLanguages,
                    onChanged: (value) =>
                        setState(() => _selectedLanguages = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Religion'),
                  _buildDropdown(
                    value: _selectedReligion,
                    items: _religionOptions,
                    hint: 'Select Religion',
                    onChanged: (value) =>
                        setState(() => _selectedReligion = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Marital Status'),
                  _buildDropdown(
                    value: _selectedRelationshipStatus,
                    items: _relationshipStatusOptions,
                    hint: 'Select Status',
                    onChanged: (value) =>
                        setState(() => _selectedRelationshipStatus = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Education'),
                  _buildDropdown(
                    value: _selectedEducation,
                    items: _educationOptions,
                    hint: 'Select Education',
                    onChanged: (value) =>
                        setState(() => _selectedEducation = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Profession'),
                  _buildDropdown(
                    value: _selectedProfession,
                    items: _professionOptions,
                    hint: 'Select Profession',
                    onChanged: (value) =>
                        setState(() => _selectedProfession = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Height Range'),
                  _buildHeightRangeSlider(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Looking For'),
                  _buildMultiSelectChips(
                    options: _lookingForOptions,
                    selected: _selectedLookingFor,
                    onChanged: (value) =>
                        setState(() => _selectedLookingFor = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Interested In'),
                  _buildSingleSelectChips(
                    options: _interestedInOptions,
                    selected: _selectedInterestedIn,
                    onChanged: (value) =>
                        setState(() => _selectedInterestedIn = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Advanced Options'),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    'Show profiles outside distance range',
                    _allowOutOfDistance,
                    (value) => setState(() => _allowOutOfDistance = value),
                  ),
                  _buildSwitchTile(
                    'Show profiles outside age range',
                    _allowOutOfAgeRange,
                    (value) => setState(() => _allowOutOfAgeRange = value),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = breakpointOf(constraints.maxWidth);
        if (bp == AppBreakpoint.mobile) return _buildMobile();
        if (bp == AppBreakpoint.desktop) {
          return _shell(collapsed: false);
        }
        return _shell(
          collapsed: _tabletSidebarCollapsed,
          onToggleCollapse: () {
            setState(
              () => _tabletSidebarCollapsed = !_tabletSidebarCollapsed,
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: getTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} years',
          style: getTextStyle(
            fontSize: 14,
            color: PColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        RangeSlider(
          values: _ageRange,
          min: 18,
          max: 80,
          divisions: 62,
          activeColor: PColors.primaryColor,
          onChanged: (values) => setState(() => _ageRange = values),
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_distance.toInt()} km',
          style: getTextStyle(
            fontSize: 14,
            color: PColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: _distance,
          min: 1,
          max: 500,
          divisions: 499,
          activeColor: PColors.primaryColor,
          onChanged: (value) => setState(() => _distance = value),
        ),
      ],
    );
  }

  Widget _buildHeightRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_heightRange.start.toInt()} cm - ${_heightRange.end.toInt()} cm',
          style: getTextStyle(
            fontSize: 14,
            color: PColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        RangeSlider(
          values: _heightRange,
          min: 140,
          max: 220,
          divisions: 80,
          activeColor: PColors.primaryColor,
          onChanged: (values) => setState(() => _heightRange = values),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: validValue,
        hint: Text(hint, style: getTextStyle(color: Colors.grey[600])),
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: getTextStyle(fontSize: 15)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (value) {
            final newSelected = List<String>.from(selected);
            if (value) {
              newSelected.add(option);
            } else {
              newSelected.remove(option);
            }
            onChanged(newSelected);
          },
          selectedColor: PColors.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: PColors.primaryColor,
          labelStyle: getTextStyle(
            fontSize: 14,
            color: isSelected ? PColors.primaryColor : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectChips({
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (value) => onChanged(value ? option : null),
          selectedColor: PColors.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: PColors.primaryColor,
          labelStyle: getTextStyle(
            fontSize: 14,
            color: isSelected ? PColors.primaryColor : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: getTextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: PColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: getTextStyle(fontSize: 14, color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: getTextStyle(fontSize: 14, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}
