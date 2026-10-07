import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_form_controls.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class EditRelationshipGoalsScreen extends StatefulWidget {
  const EditRelationshipGoalsScreen({super.key});

  @override
  State<EditRelationshipGoalsScreen> createState() =>
      _EditRelationshipGoalsScreenState();
}

class _EditRelationshipGoalsScreenState
    extends State<EditRelationshipGoalsScreen> {
  String? _selectedGoal;

  final List<String> _goals = [
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

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ProfileViewModel>();
    if (viewModel.relationshipGoals.isNotEmpty) {
      _selectedGoal = viewModel.relationshipGoals.first;
    }
  }

  void _saveAndGoBack() {
    if (_selectedGoal == null) return;

    final viewModel = context.read<ProfileViewModel>();
    viewModel.setRelationshipGoals([_selectedGoal!]);
    Fluttertoast.showToast(msg: 'Relationship goals updated successfully');
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
    return DesktopSubpageBody(
      header: const DesktopSubpageHeader(
        title: 'Relationship Goals',
        subtitle: "What are you looking for?",
      ),
      tip: DesktopTipCard(
        title: 'Your Goal',
        tips: [
          if (_selectedGoal != null) _selectedGoal!,
          'You can change this later.',
        ],
      ),
      saveBar: DesktopSaveBar(
        onSave: _saveAndGoBack,
        enabled: _selectedGoal != null,
      ),
      form: DesktopFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "It's your journey. Choose the option that feels right for you.",
              style: getTextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, c) {
                final two = c.maxWidth >= 520;
                final cards = [
                  for (final goal in _goals)
                    _GoalCard(
                      text: goal,
                      selected: _selectedGoal == goal,
                      onTap: () => setState(() => _selectedGoal = goal),
                    ),
                ];
                if (!two) {
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        cards[i],
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < cards.length; i += 2) ...[
                      if (i > 0) const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: cards[i]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: i + 1 < cards.length
                                ? cards[i + 1]
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
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
                    'I\'m looking for...',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'It\'s your journey. choose the option that feels\nright for you.',
                    style: getTextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ..._goals.map((goal) {
                    final isSelected = _selectedGoal == goal;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionTile(
                        text: goal,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedGoal = goal;
                          });
                        },
                      ),
                    );
                  }),
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
                  onPressed: _selectedGoal != null ? _saveAndGoBack : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGoal != null
                        ? PColors.primaryColor
                        : Colors.grey[300],
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
                      color: _selectedGoal != null
                          ? Colors.white
                          : Colors.grey[500],
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

  Widget _buildOptionTile({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? PColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: getTextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.check,
              color: isSelected ? PColors.primaryColor : Colors.transparent,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatefulWidget {
  const _GoalCard({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
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
              ? WelcomeTheme.violet.withValues(alpha: 0.22)
              : _hover
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? WelcomeTheme.violet.withValues(alpha: 0.55)
                : _hover
                    ? WelcomeTheme.violet.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: selected || _hover
              ? [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.2),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: selected
                        ? WelcomeTheme.violetLight
                        : Colors.white54,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: selected
                        ? WelcomeTheme.violetLight
                        : Colors.transparent,
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
