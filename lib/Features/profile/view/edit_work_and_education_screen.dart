import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_form_controls.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class EditWorkEducationScreen extends StatefulWidget {
  const EditWorkEducationScreen({super.key});

  @override
  State<EditWorkEducationScreen> createState() =>
      _EditWorkEducationScreenState();
}

class _EditWorkEducationScreenState extends State<EditWorkEducationScreen> {
  late TextEditingController _universityController;
  late TextEditingController _companyController;

  bool _currentlyStudying = false;
  String? _selectedDegree;
  String? _selectedJobTitle;
  String? _selectedJobType;
  int? _graduationYear;

  final List<String> _degrees = [
    'B.Tech',
    'B.E',
    'M.Tech',
    'MBA',
    'BBA',
    'BCA',
    'MCA',
    'BSc',
    'MSc',
    'BA',
    'MA',
    'PhD',
    'Diploma',
    'Other',
  ];

  final List<String> _jobTitles = [
    'Software Developer',
    'Designer',
    'Manager',
    'Engineer',
    'Consultant',
    'Analyst',
    'Teacher',
    'Doctor',
    'Lawyer',
    'Accountant',
    'Marketing',
    'Sales',
    'HR',
    'Other',
  ];

  final List<String> _jobTypes = [
    'Permanent',
    'Contract',
    'Freelance',
    'Internship',
    'Self-employed',
  ];

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<ProfileViewModel>();

    _universityController = TextEditingController(
      text: viewModel.collegeName ?? '',
    );
    _companyController = TextEditingController(
      text: viewModel.companyName ?? '',
    );

    if (viewModel.education != null && viewModel.education!.isNotEmpty) {
      if (_degrees.contains(viewModel.education)) {
        _selectedDegree = viewModel.education;
      }
    }

    if (viewModel.currentProfession != null &&
        viewModel.currentProfession!.isNotEmpty) {
      if (_jobTitles.contains(viewModel.currentProfession)) {
        _selectedJobTitle = viewModel.currentProfession;
      }
    }

    if (viewModel.employmentType != null &&
        viewModel.employmentType!.isNotEmpty) {
      if (_jobTypes.contains(viewModel.employmentType)) {
        _selectedJobType = viewModel.employmentType;
      }
    }

    _currentlyStudying = viewModel.currentlyStudying;
    _graduationYear = viewModel.graduationYear;
  }

  @override
  void dispose() {
    _universityController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _saveAndGoBack() {
    final viewModel = context.read<ProfileViewModel>();

    viewModel.setEducationInfo(
      education: _selectedDegree,
      college: _universityController.text.isNotEmpty
          ? _universityController.text
          : null,
      graduationYear: _graduationYear,
      currentlyStudying: _currentlyStudying,
    );

    viewModel.setWorkInfo(
      profession: _selectedJobTitle,
      company:
          _companyController.text.isNotEmpty ? _companyController.text : null,
      role: null,
      employmentType: _selectedJobType,
    );
    Fluttertoast.showToast(msg: 'Work & Education info updated successfully');
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
        title: 'Work & Education',
        subtitle: 'Complete your work and education info',
      ),
      tip: const DesktopTipCard(
        title: 'Why add this?',
        tips: [
          'Adding your work and education helps people understand more about you.',
          'Profiles with education details get better matches.',
        ],
      ),
      saveBar: DesktopSaveBar(onSave: _saveAndGoBack),
      form: Column(
        children: [
          DesktopFormCard(
            title: 'Education',
            icon: Icons.school_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesktopTwoCol(
                  left: field(
                    'Degree',
                    DesktopDropdown<String>(
                      value: _selectedDegree,
                      items: _degrees,
                      hint: 'Select Degree',
                      onChanged: (v) => setState(() => _selectedDegree = v),
                    ),
                  ),
                  right: field(
                    'University / College',
                    DesktopTextField(
                      controller: _universityController,
                      hint: 'University / College',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () =>
                      setState(() => _currentlyStudying = !_currentlyStudying),
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _currentlyStudying
                              ? WelcomeTheme.violetSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _currentlyStudying
                                ? WelcomeTheme.violetSoft
                                : Colors.white38,
                            width: 2,
                          ),
                        ),
                        child: _currentlyStudying
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Currently studying here',
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DesktopFormCard(
            title: 'Work',
            icon: Icons.work_outline_rounded,
            child: Column(
              children: [
                DesktopTwoCol(
                  left: field(
                    'Job Title',
                    DesktopDropdown<String>(
                      value: _selectedJobTitle,
                      items: _jobTitles,
                      hint: 'Job Title',
                      onChanged: (v) => setState(() => _selectedJobTitle = v),
                    ),
                  ),
                  right: field(
                    'Company Name',
                    DesktopTextField(
                      controller: _companyController,
                      hint: 'Company Name',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                field(
                  'Job Type',
                  DesktopDropdown<String>(
                    value: _selectedJobType,
                    items: _jobTypes,
                    hint: 'Job Type',
                    onChanged: (v) => setState(() => _selectedJobType = v),
                  ),
                ),
              ],
            ),
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
                    'Work & Education',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your work and education info',
                    style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Education',
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    value: _selectedDegree,
                    items: _degrees,
                    hintText: 'Select Degree',
                    onChanged: (value) {
                      setState(() {
                        _selectedDegree = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _universityController,
                    hintText: 'University/College',
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentlyStudying = !_currentlyStudying;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _currentlyStudying
                                ? PColors.primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: _currentlyStudying
                                  ? PColors.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _currentlyStudying
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Currently Studying here',
                          style: getTextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Work',
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    value: _selectedJobTitle,
                    items: _jobTitles,
                    hintText: 'Job Title',
                    onChanged: (value) {
                      setState(() {
                        _selectedJobTitle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _companyController,
                    hintText: 'Company Name',
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    value: _selectedJobType,
                    items: _jobTypes,
                    hintText: 'Job Type',
                    onChanged: (value) {
                      setState(() {
                        _selectedJobType = value;
                      });
                    },
                  ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
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

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String hintText,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hintText,
            style: getTextStyle(fontSize: 15, color: Colors.grey[400]),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          style: getTextStyle(fontSize: 15, color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
