import 'dart:typed_data';

import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

/// Desktop Support form presentation — state/controllers live in [SupportScreen].
class DesktopSupportView extends StatelessWidget {
  const DesktopSupportView({
    super.key,
    required this.emailController,
    required this.nameController,
    required this.subjectController,
    required this.messageController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.attachments,
    required this.onPickFiles,
    required this.onRemoveAttachment,
    required this.onSubmit,
    required this.isSending,
    required this.emailError,
    required this.nameError,
    required this.categoryError,
    required this.subjectError,
    required this.messageError,
    required this.onMessageChanged,
    required this.onFieldChanged,
  });

  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final List<SupportAttachment> attachments;
  final VoidCallback onPickFiles;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onSubmit;
  final bool isSending;
  final String? emailError;
  final String? nameError;
  final String? categoryError;
  final String? subjectError;
  final String? messageError;
  final ValueChanged<String> onMessageChanged;
  final VoidCallback onFieldChanged;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB9AFC8),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 8),
              _Header(),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: const Color(0xFF120A1F).withValues(alpha: 0.72),
                  border: Border.all(
                    color: WelcomeTheme.violet.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: WelcomeTheme.violet.withValues(alpha: 0.12),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: 'Email Address',
                              icon: Icons.mail_outline,
                              child: _DarkTextField(
                                controller: emailController,
                                hint: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                errorText: emailError,
                                onChanged: (_) => onFieldChanged(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _LabeledField(
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              child: _DarkTextField(
                                controller: nameController,
                                hint: 'Your name',
                                errorText: nameError,
                                onChanged: (_) => onFieldChanged(),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _LabeledField(
                        label: 'Email Address',
                        icon: Icons.mail_outline,
                        child: _DarkTextField(
                          controller: emailController,
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          errorText: emailError,
                          onChanged: (_) => onFieldChanged(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        child: _DarkTextField(
                          controller: nameController,
                          hint: 'Your name',
                          errorText: nameError,
                          onChanged: (_) => onFieldChanged(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: 'Select Category',
                              icon: Icons.sell_outlined,
                              child: _DarkDropdown(
                                value: selectedCategory,
                                items: categories,
                                errorText: categoryError,
                                onChanged: onCategoryChanged,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _LabeledField(
                              label: 'Subject',
                              icon: Icons.description_outlined,
                              child: _DarkTextField(
                                controller: subjectController,
                                hint: 'Brief summary',
                                errorText: subjectError,
                                onChanged: (_) => onFieldChanged(),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _LabeledField(
                        label: 'Select Category',
                        icon: Icons.sell_outlined,
                        child: _DarkDropdown(
                          value: selectedCategory,
                          items: categories,
                          errorText: categoryError,
                          onChanged: onCategoryChanged,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Subject',
                        icon: Icons.description_outlined,
                        child: _DarkTextField(
                          controller: subjectController,
                          hint: 'Brief summary',
                          errorText: subjectError,
                          onChanged: (_) => onFieldChanged(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Message',
                      icon: Icons.edit_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DarkTextField(
                            controller: messageController,
                            hint: 'Write your message here...',
                            maxLines: 6,
                            maxLength: 220,
                            minHeight: 160,
                            errorText: messageError,
                            onChanged: onMessageChanged,
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${messageController.text.length} / 220',
                              style: getTextStyle(
                                fontSize: 12,
                                color: const Color(0xFF8E879E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Attachments',
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload screenshots or files that can help us understand the issue.',
                      style: getTextStyle(
                        fontSize: 12,
                        color: const Color(0xFFB9B2C8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _UploadZone(onTap: onPickFiles),
                    const SizedBox(height: 8),
                    Text(
                      'ⓘ You can upload up to 5 files. Max size 10MB each.',
                      style: getTextStyle(
                        fontSize: 11,
                        color: const Color(0xFF8E879E),
                      ),
                    ),
                    if (attachments.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (var i = 0; i < attachments.length; i++)
                            _FileChip(
                              attachment: attachments[i],
                              onRemove: () => onRemoveAttachment(i),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _SubmitButton(
                        loading: isSending,
                        onPressed: isSending ? null : onSubmit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportAttachment {
  const SupportAttachment({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
  int get sizeBytes => bytes.lengthInBytes;
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Support',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.favorite_rounded,
                    size: 22,
                    color: WelcomeTheme.violetLight.withValues(alpha: 0.9),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'How can we help you?',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: WelcomeTheme.violetLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tell us what happened and our support team will get back to you.',
                style: getTextStyle(
                  fontSize: 14,
                  color: const Color(0xFFB9B2C8),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [WelcomeTheme.violetDeep, WelcomeTheme.violetSoft],
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.4),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(
            Icons.headset_mic_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFB9B2C8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.minHeight,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? errorText;
  final int maxLines;
  final int? maxLength;
  final double? minHeight;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints:
              minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            style: getTextStyle(fontSize: 14, color: Colors.white),
            cursorColor: WelcomeTheme.violetLight,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: getTextStyle(
                fontSize: 14,
                color: const Color(0xFF7A728C),
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 14 : 16,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: getTextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}

class _DarkDropdown extends StatelessWidget {
  const _DarkDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1228),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFFB9B2C8)),
              hint: Text(
                'Select Category',
                style: getTextStyle(
                  fontSize: 14,
                  color: const Color(0xFF7A728C),
                ),
              ),
              style: getTextStyle(fontSize: 14, color: Colors.white),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: getTextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: WelcomeTheme.violet.withValues(alpha: 0.55),
            radius: 14,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 36,
                  color: WelcomeTheme.violetLight,
                ),
                const SizedBox(height: 10),
                Text(
                  'Drag & drop files here or click to browse',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(r);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

class _FileChip extends StatelessWidget {
  const _FileChip({required this.attachment, required this.onRemove});
  final SupportAttachment attachment;
  final VoidCallback onRemove;

  String get _sizeLabel {
    final kb = attachment.sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 18, color: WelcomeTheme.violetLight),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(fontSize: 12, color: Colors.white),
                ),
                Text(
                  _sizeLabel,
                  style: getTextStyle(
                    fontSize: 10,
                    color: const Color(0xFF8E879E),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16, color: Color(0xFFB9B2C8)),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed, required this.loading});
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                colors: [WelcomeTheme.violetDeep, WelcomeTheme.violetSoft],
              ),
        color: onPressed == null ? Colors.white12 : null,
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: WelcomeTheme.violet.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 210,
            height: 54,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit Request',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
