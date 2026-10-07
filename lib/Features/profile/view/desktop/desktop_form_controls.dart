import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared dark form chrome for Profile edit subpages on desktop/tablet.
abstract final class DesktopFormStyle {
  static const fieldHeight = 54.0;
  static const radius = 13.0;
  static const maxContent = 1200.0;
  static const maxForm = 820.0;
  static const tipWidth = 300.0;
}

class DesktopSubpageHeader extends StatelessWidget {
  const DesktopSubpageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: 'Back',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DesktopFormCard extends StatelessWidget {
  const DesktopFormCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
  });

  final Widget child;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: WelcomeTheme.violet.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: WelcomeTheme.violetLight),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  title!,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}

class DesktopFieldLabel extends StatelessWidget {
  const DesktopFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: getTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class DesktopTextField extends StatefulWidget {
  const DesktopTextField({
    super.key,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
  });

  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  @override
  State<DesktopTextField> createState() => _DesktopTextFieldState();
}

class _DesktopTextFieldState extends State<DesktopTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: DesktopFormStyle.fieldHeight,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(DesktopFormStyle.radius),
              border: Border.all(
                color: error
                    ? Colors.redAccent.withValues(alpha: 0.7)
                    : _focused
                        ? WelcomeTheme.violet.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: _focused && !error
                  ? [
                      BoxShadow(
                        color: WelcomeTheme.violet.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: widget.controller,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              style: getTextStyle(fontSize: 15, color: Colors.white),
              cursorColor: WelcomeTheme.violetLight,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: getTextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: getTextStyle(fontSize: 12, color: Colors.redAccent),
          ),
        ],
      ],
    );
  }
}

class DesktopDropdown<T> extends StatefulWidget {
  const DesktopDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.itemLabel,
  });

  final T? value;
  final List<T> items;
  final String hint;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;

  @override
  State<DesktopDropdown<T>> createState() => _DesktopDropdownState<T>();
}

class _DesktopDropdownState<T> extends State<DesktopDropdown<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: DesktopFormStyle.fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(DesktopFormStyle.radius),
          border: Border.all(
            color: _hover
                ? WelcomeTheme.violet.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: widget.value,
            isExpanded: true,
            dropdownColor: const Color(0xFF160E28),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            hint: Text(
              widget.hint,
              style: getTextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            style: getTextStyle(fontSize: 15, color: Colors.white),
            items: widget.items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      widget.itemLabel?.call(item) ?? '$item',
                      style: getTextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}

class DesktopTwoCol extends StatelessWidget {
  const DesktopTwoCol({
    super.key,
    required this.left,
    required this.right,
    this.gap = 16,
    this.breakpoint = 640,
  });

  final Widget left;
  final Widget right;
  final double gap;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, SizedBox(height: gap), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: gap),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class DesktopSaveBar extends StatelessWidget {
  const DesktopSaveBar({
    super.key,
    required this.onSave,
    this.onCancel,
    this.enabled = true,
    this.saving = false,
  });

  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool enabled;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: getTextStyle(fontSize: 14, color: Colors.white60),
          ),
        ),
        const SizedBox(width: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? WelcomeTheme.ctaGradient : null,
            color: enabled ? null : Colors.white12,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled && !saving ? onSave : null,
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (saving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Text(
                          'Save Changes',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopTipCard extends StatelessWidget {
  const DesktopTipCard({
    super.key,
    required this.title,
    required this.tips,
  });

  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DesktopFormStyle.tipWidth,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          for (final tip in tips) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: WelcomeTheme.violetLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: getTextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Scrollable desktop subpage with optional tip panel on wide widths.
class DesktopSubpageBody extends StatelessWidget {
  const DesktopSubpageBody({
    super.key,
    required this.header,
    required this.form,
    required this.saveBar,
    this.tip,
  });

  final Widget header;
  final Widget form;
  final Widget saveBar;
  final Widget? tip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DesktopFormStyle.maxContent),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, c) {
                        final showTip = tip != null && c.maxWidth >= 980;
                        final form = ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: DesktopFormStyle.maxForm,
                          ),
                          child: this.form,
                        );
                        if (!showTip) return form;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: form),
                            const SizedBox(width: 20),
                            tip!,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 20),
              decoration: BoxDecoration(
                color: const Color(0xE6090415),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: DesktopFormStyle.maxForm,
                  ),
                  child: saveBar,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
