import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/glass_card.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/material.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // ponytail: local ack only — wire AppConfig contact API when endpoint exists
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thanks ${_name.text.trim()} — we\'ll reply at ${AppConfig.contactEmail}.',
        ),
        backgroundColor: WelcomeTheme.violetDeep,
      ),
    );
    _formKey.currentState?.reset();
    _name.clear();
    _email.clear();
    _subject.clear();
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    final supportEmail = AppConfig.contactEmail;

    return LandingSectionPad(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Contact',
            title: "We'd love to\n",
            highlight: 'hear from you.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, c) {
              final stack = c.maxWidth < 900;
              final left = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions about dating safely, your account, or partnerships — we\'re here.',
                    style: getTextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _LinkRow(
                    icon: Icons.support_agent_outlined,
                    label: 'Support',
                    value: supportEmail,
                    onTap: () =>
                        Navigator.pushNamed(context, PPages.supportScreen),
                  ),
                  const SizedBox(height: 16),
                  _LinkRow(
                    icon: Icons.shield_outlined,
                    label: 'Safety',
                    value: 'Safety tips',
                    onTap: () =>
                        Navigator.pushNamed(context, PPages.safetyTipsScreen),
                  ),
                  const SizedBox(height: 16),
                  _LinkRow(
                    icon: Icons.help_outline,
                    label: 'FAQ / Help',
                    value: 'Get help',
                    onTap: () =>
                        Navigator.pushNamed(context, PPages.supportScreen),
                  ),
                ],
              );

              final form = GlassCard(
                enableHover: false,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field(_name, 'Name', (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter your name';
                        return null;
                      }),
                      const SizedBox(height: 14),
                      _field(_email, 'Email', (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Enter your email';
                        if (!t.contains('@') || !t.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      }),
                      const SizedBox(height: 14),
                      _field(_subject, 'Subject', (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter a subject';
                        return null;
                      }),
                      const SizedBox(height: 14),
                      _field(
                        _message,
                        'Message',
                        (v) {
                          if (v == null || v.trim().length < 10) {
                            return 'Message should be at least 10 characters';
                          }
                          return null;
                        },
                        maxLines: 5,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: WelcomeTheme.violet,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Send Message',
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 28), form],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: left),
                  const SizedBox(width: 36),
                  Expanded(flex: 6, child: form),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    String? Function(String?) validator, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      style: getTextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: getTextStyle(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: WelcomeTheme.violet.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: WelcomeTheme.violet.withValues(alpha: 0.28),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WelcomeTheme.violetLight),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WelcomeTheme.violet.withValues(alpha: 0.18),
            ),
            child: Icon(icon, color: WelcomeTheme.violetLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getTextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  value,
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
