import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_form_controls.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class EditBioScreen extends StatefulWidget {
  final String? initialBio;

  const EditBioScreen({super.key, this.initialBio});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  late TextEditingController _bioController;
  final int _maxLength = 220;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio ?? '');
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _saveAndGoBack() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.setAboutMe(_bioController.text);
    Fluttertoast.showToast(msg: 'Bio updated successfully');
    Navigator.pop(context, _bioController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(),
      desktop: (_) => _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    final len = _bioController.text.length;
    return DesktopSubpageBody(
      header: const DesktopSubpageHeader(
        title: 'This is Me',
        subtitle: 'Describe yourself in the best way',
      ),
      tip: const DesktopTipCard(
        title: 'Bio Tips',
        tips: [
          'Keep it genuine and specific',
          'Mention hobbies or values that matter to you',
          'A short, warm intro works best',
        ],
      ),
      saveBar: DesktopSaveBar(onSave: _saveAndGoBack),
      form: DesktopFormCard(
        title: 'Your Bio',
        icon: Icons.favorite_border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: _bioController,
                maxLength: _maxLength,
                maxLines: 10,
                minLines: 6,
                style: getTextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.5,
                ),
                cursorColor: WelcomeTheme.violetLight,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  hintStyle: getTextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$len / $_maxLength',
                style: getTextStyle(
                  fontSize: 13,
                  color: len > _maxLength - 20
                      ? WelcomeTheme.violetLight
                      : Colors.white.withValues(alpha: 0.45),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This is Me',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe yourself in the best way',
                    style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _bioController,
                      maxLength: _maxLength,
                      maxLines: 8,
                      style: getTextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write here...',
                        hintStyle: getTextStyle(
                          fontSize: 15,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_bioController.text.length} / $_maxLength',
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
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
                    'Update',
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
}
