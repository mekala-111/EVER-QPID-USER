import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/settings/view/desktop/desktop_support_view.dart';
import 'package:everqpidapp/Features/settings/view_model/support_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SupportScreen extends StatefulWidget {
  final String userId;
  const SupportScreen({super.key, required this.userId});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedCategory;
  final List<SupportAttachment> _attachments = [];
  final List<String> _categories = [
    'Technical Issue',
    'Account Problem',
    'Payment Issue',
    'Subscription',
    'Report User',
    'Feature Request',
    'Other',
  ];
  final ImagePicker _picker = ImagePicker();

  static const _maxFiles = 5;
  static const _maxBytes = 10 * 1024 * 1024;

  String? _emailError;
  String? _nameError;
  String? _categoryError;
  String? _subjectError;
  String? _messageError;

  @override
  void initState() {
    super.initState();
    final email = LoggedInUser.email?.trim();
    final name = LoggedInUser.name?.trim();
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
    if (name != null && name.isNotEmpty) {
      _firstNameController.text = name;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final remaining = _maxFiles - _attachments.length;
      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can upload up to 5 files.')),
        );
        return;
      }

      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;

      final accepted = <SupportAttachment>[];
      for (final file in picked.take(remaining)) {
        final bytes = await file.readAsBytes();
        if (bytes.lengthInBytes > _maxBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${file.name} exceeds 10MB and was skipped.'),
              ),
            );
          }
          continue;
        }
        accepted.add(SupportAttachment(
          name: file.name.isNotEmpty ? file.name : 'image.jpg',
          bytes: bytes,
        ));
      }

      if (accepted.isEmpty) return;
      setState(() => _attachments.addAll(accepted));
    } catch (e) {
      AppLogger.d('File pick error: $e');
    }
  }

  bool _validateForm() {
    setState(() {
      _emailError = null;
      _nameError = null;
      _categoryError = null;
      _subjectError = null;
      _messageError = null;

      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(_emailController.text.trim())) {
        _emailError = 'Please enter a valid email';
      }

      if (_firstNameController.text.trim().isEmpty) {
        _nameError = 'Name is required';
      }

      if (_selectedCategory == null || _selectedCategory == 'Select Category') {
        _categoryError = 'Please select a category';
      }

      if (_subjectController.text.trim().isEmpty) {
        _subjectError = 'Subject is required';
      }

      if (_messageController.text.trim().isEmpty) {
        _messageError = 'Message is required';
      }
    });

    return _emailError == null &&
        _nameError == null &&
        _categoryError == null &&
        _subjectError == null &&
        _messageError == null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;

    final supportVM = context.read<SupportViewModel>();
    final success = await supportVM.sendSupportRequest(
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      subject: _subjectController.text.trim(),
      category: _selectedCategory!,
      description: _messageController.text.trim(),
      attachments: _attachments.map((e) => e.bytes).toList(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Support request sent successfully'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(supportVM.errorMessage ?? 'Error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SupportViewModel, (bool, bool)>(
      (vm) => (vm.isSending, vm.isLoading),
    );
    final isSending = busy.$1;
    final isLoading = busy.$2;

    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(isSending: isSending, isLoading: isLoading),
      desktop: (_) => Stack(
        children: [
          DesktopSupportView(
            emailController: _emailController,
            nameController: _firstNameController,
            subjectController: _subjectController,
            messageController: _messageController,
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (v) => setState(() {
              _selectedCategory = v;
              _categoryError = null;
            }),
            attachments: _attachments,
            onPickFiles: _pickFiles,
            onRemoveAttachment: (i) =>
                setState(() => _attachments.removeAt(i)),
            onSubmit: _submit,
            isSending: isSending,
            emailError: _emailError,
            nameError: _nameError,
            categoryError: _categoryError,
            subjectError: _subjectError,
            messageError: _messageError,
            onMessageChanged: (_) => setState(() => _messageError = null),
            onFieldChanged: () => setState(() {
              _emailError = null;
              _nameError = null;
              _subjectError = null;
            }),
          ),
          if (isSending || isLoading)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC084FC),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Mobile (unchanged presentation) ────────────────────────────────────

  Widget _buildMobile({required bool isSending, required bool isLoading}) {
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
          'Back',
          style: getTextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support',
                  style: getTextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _firstNameController,
                  hintText: 'Full Name',
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: _categoryError != null
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: Text(
                            'Select Category',
                            style: getTextStyle(
                              fontSize: 15,
                              color: Colors.grey[400],
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                          items: _categories.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _categoryError = null;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_categoryError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          _categoryError!,
                          style: getTextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _subjectController,
                  hintText: 'Subject',
                  errorText: _subjectError,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: _messageError != null
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLength: 220,
                        maxLines: 6,
                        style: getTextStyle(fontSize: 15, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Write here...',
                          hintStyle: getTextStyle(
                            fontSize: 15,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _messageError = null;
                          });
                        },
                      ),
                    ),
                    if (_messageError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          _messageError!,
                          style: getTextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_messageController.text.length} / 220',
                    style: getTextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Attachments',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickFiles,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Add files here',
                        style: getTextStyle(
                          fontSize: 15,
                          color: PColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_attachments.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _attachments.map((file) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              file.bytes,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _attachments.remove(file));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
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
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSending ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSending || isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(color: PColors.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1)
                : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: getTextStyle(fontSize: 15, color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: getTextStyle(fontSize: 15, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              if (errorText != null) {
                setState(() {
                  if (controller == _emailController) {
                    _emailError = null;
                  } else if (controller == _firstNameController) {
                    _nameError = null;
                  } else if (controller == _subjectController) {
                    _subjectError = null;
                  }
                });
              }
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: getTextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
