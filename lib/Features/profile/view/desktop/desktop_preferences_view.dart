import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view_model/preferences_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Preferences presentation — same state as mobile, dark shell UI.
class DesktopPreferencesView extends StatelessWidget {
  const DesktopPreferencesView({
    super.key,
    required this.ageRange,
    required this.onAgeRangeChanged,
    required this.distance,
    required this.onDistanceChanged,
    required this.heightRange,
    required this.onHeightRangeChanged,
    required this.languageOptions,
    required this.selectedLanguages,
    required this.onLanguagesChanged,
    required this.religionOptions,
    required this.selectedReligion,
    required this.onReligionChanged,
    required this.relationshipStatusOptions,
    required this.selectedRelationshipStatus,
    required this.onRelationshipStatusChanged,
    required this.educationOptions,
    required this.selectedEducation,
    required this.onEducationChanged,
    required this.professionOptions,
    required this.selectedProfession,
    required this.onProfessionChanged,
    required this.lookingForOptions,
    required this.selectedLookingFor,
    required this.onLookingForChanged,
    required this.interestedInOptions,
    required this.selectedInterestedIn,
    required this.onInterestedInChanged,
    required this.allowOutOfDistance,
    required this.onAllowOutOfDistanceChanged,
    required this.allowOutOfAgeRange,
    required this.onAllowOutOfAgeRangeChanged,
    required this.onSave,
    required this.onReset,
    required this.onCancel,
  });

  final RangeValues ageRange;
  final ValueChanged<RangeValues> onAgeRangeChanged;
  final double distance;
  final ValueChanged<double> onDistanceChanged;
  final RangeValues heightRange;
  final ValueChanged<RangeValues> onHeightRangeChanged;

  final List<String> languageOptions;
  final List<String> selectedLanguages;
  final ValueChanged<List<String>> onLanguagesChanged;

  final List<String> religionOptions;
  final String? selectedReligion;
  final ValueChanged<String?> onReligionChanged;

  final List<String> relationshipStatusOptions;
  final String? selectedRelationshipStatus;
  final ValueChanged<String?> onRelationshipStatusChanged;

  final List<String> educationOptions;
  final String? selectedEducation;
  final ValueChanged<String?> onEducationChanged;

  final List<String> professionOptions;
  final String? selectedProfession;
  final ValueChanged<String?> onProfessionChanged;

  final List<String> lookingForOptions;
  final List<String> selectedLookingFor;
  final ValueChanged<List<String>> onLookingForChanged;

  final List<String> interestedInOptions;
  final String? selectedInterestedIn;
  final ValueChanged<String?> onInterestedInChanged;

  final bool allowOutOfDistance;
  final ValueChanged<bool> onAllowOutOfDistanceChanged;
  final bool allowOutOfAgeRange;
  final ValueChanged<bool> onAllowOutOfAgeRangeChanged;

  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PreferencesViewModel>();
    final wide = MediaQuery.sizeOf(context).width >= 1100;

    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: WelcomeTheme.violetLight),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(36, 8, 36, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(onReset: onReset, busy: vm.isResetting || vm.isSaving),
                    if (vm.successMessage != null) ...[
                      const SizedBox(height: 16),
                      _Banner(message: vm.successMessage!, ok: true),
                    ],
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _Banner(message: vm.errorMessage!, ok: false),
                    ],
                    const SizedBox(height: 24),
                    if (wide)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _GlassCard(
                                title: 'Match Basics',
                                subtitle:
                                    'Set your preferred age and search distance.',
                                child: Column(
                                  children: [
                                    _RangeBlock(
                                      label: 'Age Range',
                                      valueText:
                                          '${ageRange.start.toInt()} – ${ageRange.end.toInt()} years',
                                      child: SliderTheme(
                                        data: _sliderTheme(context),
                                        child: RangeSlider(
                                          values: ageRange,
                                          min: 18,
                                          max: 80,
                                          divisions: 62,
                                          onChanged: onAgeRangeChanged,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _RangeBlock(
                                      label: 'Maximum Distance',
                                      valueText: '${distance.toInt()} km',
                                      child: SliderTheme(
                                        data: _sliderTheme(context),
                                        child: Slider(
                                          value: distance,
                                          min: 1,
                                          max: 500,
                                          divisions: 499,
                                          onChanged: onDistanceChanged,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _RangeBlock(
                                      label: 'Height Range',
                                      valueText:
                                          '${heightRange.start.toInt()} – ${heightRange.end.toInt()} cm',
                                      child: SliderTheme(
                                        data: _sliderTheme(context),
                                        child: RangeSlider(
                                          values: heightRange,
                                          min: 140,
                                          max: 220,
                                          divisions: 80,
                                          onChanged: onHeightRangeChanged,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _GlassCard(
                                title: 'Languages',
                                subtitle:
                                    "Select the languages you'd prefer your matches to speak.",
                                child: _ChipWrap(
                                  options: languageOptions,
                                  selected: selectedLanguages,
                                  multi: true,
                                  onMulti: onLanguagesChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _GlassCard(
                        title: 'Match Basics',
                        subtitle:
                            'Set your preferred age and search distance.',
                        child: Column(
                          children: [
                            _RangeBlock(
                              label: 'Age Range',
                              valueText:
                                  '${ageRange.start.toInt()} – ${ageRange.end.toInt()} years',
                              child: SliderTheme(
                                data: _sliderTheme(context),
                                child: RangeSlider(
                                  values: ageRange,
                                  min: 18,
                                  max: 80,
                                  divisions: 62,
                                  onChanged: onAgeRangeChanged,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _RangeBlock(
                              label: 'Maximum Distance',
                              valueText: '${distance.toInt()} km',
                              child: SliderTheme(
                                data: _sliderTheme(context),
                                child: Slider(
                                  value: distance,
                                  min: 1,
                                  max: 500,
                                  divisions: 499,
                                  onChanged: onDistanceChanged,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _RangeBlock(
                              label: 'Height Range',
                              valueText:
                                  '${heightRange.start.toInt()} – ${heightRange.end.toInt()} cm',
                              child: SliderTheme(
                                data: _sliderTheme(context),
                                child: RangeSlider(
                                  values: heightRange,
                                  min: 140,
                                  max: 220,
                                  divisions: 80,
                                  onChanged: onHeightRangeChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _GlassCard(
                        title: 'Languages',
                        subtitle:
                            "Select the languages you'd prefer your matches to speak.",
                        child: _ChipWrap(
                          options: languageOptions,
                          selected: selectedLanguages,
                          multi: true,
                          onMulti: onLanguagesChanged,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _GlassCard(
                      title: 'Personal Preferences',
                      subtitle: 'Tell us more about your preferences.',
                      child: _TwoCol(
                        wide: wide,
                        children: [
                          _DarkDropdown(
                            label: 'Religion',
                            value: selectedReligion,
                            items: religionOptions,
                            hint: 'Select Religion',
                            onChanged: onReligionChanged,
                          ),
                          _DarkDropdown(
                            label: 'Marital Status',
                            value: selectedRelationshipStatus,
                            items: relationshipStatusOptions,
                            hint: 'Select Status',
                            onChanged: onRelationshipStatusChanged,
                          ),
                          _DarkDropdown(
                            label: 'Education',
                            value: selectedEducation,
                            items: educationOptions,
                            hint: 'Select Education',
                            onChanged: onEducationChanged,
                          ),
                          _DarkDropdown(
                            label: 'Profession',
                            value: selectedProfession,
                            items: professionOptions,
                            hint: 'Select Profession',
                            onChanged: onProfessionChanged,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _GlassCard(
                      title: 'Looking For',
                      subtitle: 'What kind of connection are you seeking?',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ChipWrap(
                            options: lookingForOptions,
                            selected: selectedLookingFor,
                            multi: true,
                            onMulti: onLookingForChanged,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Interested In',
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _ChipWrap(
                            options: interestedInOptions,
                            selected: selectedInterestedIn == null
                                ? const []
                                : [selectedInterestedIn!],
                            multi: false,
                            onSingle: onInterestedInChanged,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _GlassCard(
                      title: 'Advanced Options',
                      subtitle: 'Optional discovery flexibility.',
                      child: Column(
                        children: [
                          _DarkSwitch(
                            title: 'Show profiles outside distance range',
                            value: allowOutOfDistance,
                            onChanged: onAllowOutOfDistanceChanged,
                          ),
                          const SizedBox(height: 10),
                          _DarkSwitch(
                            title: 'Show profiles outside age range',
                            value: allowOutOfAgeRange,
                            onChanged: onAllowOutOfAgeRangeChanged,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _FooterBar(
              onCancel: onCancel,
              onSave: onSave,
              isSaving: vm.isSaving,
              disabled: vm.isSaving || vm.isResetting,
            ),
          ],
        ),
      ),
    );
  }

  static SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: WelcomeTheme.violetSoft,
      inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
      thumbColor: WelcomeTheme.violetLight,
      overlayColor: WelcomeTheme.violet.withValues(alpha: 0.2),
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
      trackHeight: 4,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onReset, required this.busy});
  final VoidCallback onReset;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: 'Back',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Preferences',
                    style: getTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: WelcomeTheme.violetLight.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Fine-tune who you'd like to meet.",
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: busy ? null : onReset,
          icon: Icon(
            Icons.refresh_rounded,
            size: 18,
            color: busy ? Colors.white24 : WelcomeTheme.violetLight,
          ),
          label: Text(
            'Reset Preferences',
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: busy ? Colors.white24 : WelcomeTheme.violetLight,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.onCancel,
    required this.onSave,
    required this.isSaving,
    required this.disabled,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 14, 36, 20),
      decoration: BoxDecoration(
        color: const Color(0xE6090415),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: disabled ? null : onCancel,
            child: Text(
              'Cancel',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white60,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SaveButton(onPressed: disabled ? null : onSave, loading: isSaving),
        ],
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.onPressed, required this.loading});
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: WelcomeTheme.ctaGradient,
          boxShadow: _hover && widget.onPressed != null
              ? [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.45),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.loading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else ...[
                      const Icon(Icons.save_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Save Preferences',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

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
          Text(
            title,
            style: getTextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _RangeBlock extends StatelessWidget {
  const _RangeBlock({
    required this.label,
    required this.valueText,
    required this.child,
  });

  final String label;
  final String valueText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            Text(
              valueText,
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WelcomeTheme.violetLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.options,
    required this.selected,
    required this.multi,
    this.onMulti,
    this.onSingle,
  });

  final List<String> options;
  final List<String> selected;
  final bool multi;
  final ValueChanged<List<String>>? onMulti;
  final ValueChanged<String?>? onSingle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _PrefChip(
            label: option,
            selected: selected.contains(option),
            onTap: () {
              if (multi) {
                final next = List<String>.from(selected);
                if (next.contains(option)) {
                  next.remove(option);
                } else {
                  next.add(option);
                }
                onMulti?.call(next);
              } else {
                onSingle?.call(selected.contains(option) ? null : option);
              }
            },
          ),
      ],
    );
  }
}

class _PrefChip extends StatefulWidget {
  const _PrefChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PrefChip> createState() => _PrefChipState();
}

class _PrefChipState extends State<_PrefChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? WelcomeTheme.violet.withValues(alpha: 0.28)
              : _hover
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? WelcomeTheme.violet.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    widget.label,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  const _TwoCol({required this.wide, required this.children});
  final bool wide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            children[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 16),
            Expanded(
              child: i + 1 < children.length ? children[i + 1] : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < children.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _DarkDropdown extends StatefulWidget {
  const _DarkDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  State<_DarkDropdown> createState() => _DarkDropdownState();
}

class _DarkDropdownState extends State<_DarkDropdown> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final valid = widget.items.contains(widget.value) ? widget.value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hover
                    ? WelcomeTheme.violet.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valid,
                isExpanded: true,
                dropdownColor: const Color(0xFF160E28),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                hint: Text(
                  widget.hint,
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                style: getTextStyle(fontSize: 14, color: Colors.white),
                items: widget.items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: getTextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DarkSwitch extends StatelessWidget {
  const _DarkSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: getTextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: WelcomeTheme.violetSoft,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.ok});
  final String message;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.error_outline,
            color: color[300],
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: getTextStyle(fontSize: 13, color: color[200]),
            ),
          ),
        ],
      ),
    );
  }
}
