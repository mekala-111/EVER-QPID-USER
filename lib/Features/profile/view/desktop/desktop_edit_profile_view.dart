import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/widgets/image_slot.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_completion.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Edit Profile — presentation only; state stays in [EditProfileScreen].
class DesktopEditProfileView extends StatelessWidget {
  const DesktopEditProfileView({
    super.key,
    required this.imageSlots,
    required this.hasChanges,
    required this.isVerified,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSetPrimary,
    required this.onSave,
    required this.onReset,
    required this.onCancel,
    required this.onBack,
    required this.onEditBio,
    required this.onEditAbout,
    required this.onEditWork,
    required this.onEditGoals,
    required this.onEditInterests,
    required this.onPreview,
  });

  final List<ImageSlot> imageSlots;
  final bool hasChanges;
  final bool isVerified;
  final ValueChanged<int> onPickImage;
  final ValueChanged<int> onRemoveImage;
  final ValueChanged<int> onSetPrimary;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final VoidCallback onEditBio;
  final VoidCallback onEditAbout;
  final VoidCallback onEditWork;
  final VoidCallback onEditGoals;
  final VoidCallback onEditInterests;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final photoCount = imageSlots.where((s) => s.hasImage).length;
    final percent = ProfileCompletion.percentFromDraft(
      hasPhotos: photoCount > 0,
      fullName: vm.fullName,
      aboutMe: vm.aboutMe,
      dateOfBirth: vm.dateOfBirth,
      gender: vm.gender,
      interests: vm.interests,
      locationString: vm.locationString,
      education: vm.education,
      collegeName: vm.collegeName,
      currentProfession: vm.currentProfession,
    );
    final tips = ProfileCompletion.tipsFromDraft(
      photoCount: photoCount,
      aboutMe: vm.aboutMe,
      interests: vm.interests,
      currentProfession: vm.currentProfession,
      education: vm.education,
    );
    final wide = MediaQuery.sizeOf(context).width >= 1100;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(36, 8, 36, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      percent: percent,
                      onReset: hasChanges ? onReset : null,
                      onBack: onBack,
                    ),
                    const SizedBox(height: 24),
                    _PhotosCard(
                      slots: imageSlots,
                      onPick: onPickImage,
                      onRemove: onRemoveImage,
                      onSetPrimary: onSetPrimary,
                    ),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _InfoColumn(
                              vm: vm,
                              onEditBio: onEditBio,
                              onEditAbout: onEditAbout,
                              onEditWork: onEditWork,
                              onEditGoals: onEditGoals,
                              onEditInterests: onEditInterests,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: _SideColumn(
                              vm: vm,
                              percent: percent,
                              tips: tips,
                              isVerified: isVerified,
                              slots: imageSlots,
                              onPreview: onPreview,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _InfoColumn(
                        vm: vm,
                        onEditBio: onEditBio,
                        onEditAbout: onEditAbout,
                        onEditWork: onEditWork,
                        onEditGoals: onEditGoals,
                        onEditInterests: onEditInterests,
                      ),
                      const SizedBox(height: 20),
                      _SideColumn(
                        vm: vm,
                        percent: percent,
                        tips: tips,
                        isVerified: isVerified,
                        slots: imageSlots,
                        onPreview: onPreview,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _Footer(
              hasChanges: hasChanges,
              onCancel: onCancel,
              onSave: onSave,
              isSaving: vm.isLoading || vm.isUploadingPhotos,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.percent,
    required this.onReset,
    required this.onBack,
  });
  final int percent;
  final VoidCallback? onReset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack,
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
                    'Edit Profile',
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
                    color: WelcomeTheme.violetLight.withValues(alpha: 0.85),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Complete your profile, get matched better.',
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Profile $percent% complete',
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WelcomeTheme.violetLight,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: WelcomeTheme.violetSoft,
                ),
              ),
            ),
            if (onReset != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onReset,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: WelcomeTheme.violetLight,
                ),
                label: Text(
                  'Reset Changes',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WelcomeTheme.violetLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({
    required this.slots,
    required this.onPick,
    required this.onRemove,
    required this.onSetPrimary,
  });

  final List<ImageSlot> slots;
  final ValueChanged<int> onPick;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onSetPrimary;

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
            'Your Photos',
            style: getTextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add photos that show the real you.',
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final gap = 12.0;
              final count = slots.length;
              final w = ((c.maxWidth - gap * (count - 1)) / count)
                  .clamp(120.0, 170.0);
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < count; i++)
                    SizedBox(
                      width: w,
                      height: w * 1.15,
                      child: _PhotoTile(
                        slot: slots[i],
                        isPrimary: i == 0 && slots[i].hasImage,
                        onPick: () => onPick(i),
                        onRemove: () => onRemove(i),
                        onSetPrimary:
                            i == 0 || !slots[i].hasImage
                                ? null
                                : () => onSetPrimary(i),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Text(
                'You can add up to ${slots.length} photos',
                style: getTextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatefulWidget {
  const _PhotoTile({
    required this.slot,
    required this.isPrimary,
    required this.onPick,
    required this.onRemove,
    required this.onSetPrimary,
  });

  final ImageSlot slot;
  final bool isPrimary;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final VoidCallback? onSetPrimary;

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final has = widget.slot.hasImage;

    if (!has) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hover
                  ? WelcomeTheme.violet.withValues(alpha: 0.55)
                  : WelcomeTheme.violet.withValues(alpha: 0.28),
              width: 1.4,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: WelcomeTheme.violet.withValues(alpha: 0.25),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPick,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 28,
                    color: WelcomeTheme.violetLight,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add Photo',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.slot.localBytes != null)
              Image.memory(widget.slot.localBytes!, fit: BoxFit.cover)
            else
              AppNetworkImage(
                url: widget.slot.networkUrl!,
                fit: BoxFit.cover,
              ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: _hover ? 1 : 0,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: PopupMenuButton<String>(
                    color: const Color(0xFF160E28),
                    onSelected: (v) {
                      if (v == 'replace') widget.onPick();
                      if (v == 'delete') widget.onRemove();
                      if (v == 'primary') widget.onSetPrimary?.call();
                    },
                    itemBuilder: (_) => [
                      if (widget.onSetPrimary != null)
                        const PopupMenuItem(
                          value: 'primary',
                          child: Text('Set as primary',
                              style: TextStyle(color: Colors.white)),
                        ),
                      const PopupMenuItem(
                        value: 'replace',
                        child: Text('Replace',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                    child: const Icon(Icons.more_horiz, color: Colors.white),
                  ),
                ),
              ),
            ),
            if (widget.isPrimary)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: WelcomeTheme.violet.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Primary',
                    style: getTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.vm,
    required this.onEditBio,
    required this.onEditAbout,
    required this.onEditWork,
    required this.onEditGoals,
    required this.onEditInterests,
  });

  final ProfileViewModel vm;
  final VoidCallback onEditBio;
  final VoidCallback onEditAbout;
  final VoidCallback onEditWork;
  final VoidCallback onEditGoals;
  final VoidCallback onEditInterests;

  String get _aboutSummary {
    final parts = <String>[];
    if ((vm.relationshipStatus ?? '').isNotEmpty) {
      parts.add(vm.relationshipStatus!);
    }
    if (vm.height != null) parts.add('${vm.height} cm');
    if ((vm.religion ?? '').isNotEmpty) parts.add(vm.religion!);
    if (vm.otherLanguages.isNotEmpty) {
      parts.addAll(vm.otherLanguages.take(2));
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Complete your info';
  }

  String get _workSummary {
    final parts = <String>[];
    if ((vm.currentProfession ?? '').isNotEmpty) {
      parts.add(vm.currentProfession!);
    }
    if ((vm.companyName ?? '').isNotEmpty) parts.add(vm.companyName!);
    if ((vm.education ?? '').isNotEmpty) parts.add(vm.education!);
    if ((vm.collegeName ?? '').isNotEmpty) parts.add(vm.collegeName!);
    return parts.isNotEmpty ? parts.join(', ') : 'Add work & education';
  }

  @override
  Widget build(BuildContext context) {
    final bio = (vm.aboutMe ?? '').trim();
    final bioPreview = bio.isEmpty
        ? 'Add your bio'
        : (bio.length > 60 ? '${bio.substring(0, 60)}…' : bio);
    final goals = vm.relationshipGoals.isNotEmpty
        ? vm.relationshipGoals.join(', ')
        : 'Not specified';
    final interestsPreview = vm.interests.isNotEmpty
        ? vm.interests.take(4).join(', ')
        : 'Add your interests';

    return Container(
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
            'Profile Information',
            style: getTextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us more about yourself.',
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final two = c.maxWidth >= 520;
              final cards = [
                _InfoCard(
                  icon: Icons.favorite_border,
                  title: 'This is Me',
                  subtitle: bioPreview,
                  onTap: onEditBio,
                ),
                _InfoCard(
                  icon: Icons.person_outline,
                  title: 'About',
                  subtitle: _aboutSummary,
                  onTap: onEditAbout,
                ),
                _InfoCard(
                  icon: Icons.school_outlined,
                  title: 'Work & Education',
                  subtitle: _workSummary,
                  onTap: onEditWork,
                ),
                _InfoCard(
                  icon: Icons.favorite_outline,
                  title: 'Relationship Goals',
                  subtitle: goals,
                  onTap: onEditGoals,
                ),
                _InfoCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Hobbies & Interests',
                  subtitle: interestsPreview,
                  chips: vm.interests.take(6).toList(),
                  onTap: onEditInterests,
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
    );
  }
}

class _InfoCard extends StatefulWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.chips = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<String> chips;

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: _hover
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hover
                ? WelcomeTheme.violet.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.18),
                    blurRadius: 16,
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
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: WelcomeTheme.violet.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon,
                        size: 18, color: WelcomeTheme.violetLight),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (widget.chips.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final c in widget.chips)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WelcomeTheme.violet
                                        .withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    c,
                                    style: getTextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.35),
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

class _SideColumn extends StatelessWidget {
  const _SideColumn({
    required this.vm,
    required this.percent,
    required this.tips,
    required this.isVerified,
    required this.slots,
    required this.onPreview,
  });

  final ProfileViewModel vm;
  final int percent;
  final List<String> tips;
  final bool isVerified;
  final List<ImageSlot> slots;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final remaining = ((100 - percent) / 10).ceil().clamp(0, 5);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 7,
                      backgroundColor: Colors.white12,
                      color: WelcomeTheme.violetSoft,
                    ),
                    Text(
                      '$percent%',
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                remaining == 0
                    ? 'Looking great — your profile is strong.'
                    : 'Almost there! Complete a few more sections to improve your profile.',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PreviewCard(
          vm: vm,
          slots: slots,
          isVerified: isVerified,
          onPreview: onPreview,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
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
                'Profile Tips',
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
                      tip.startsWith('Great')
                          ? Icons.check_circle
                          : Icons.error_outline,
                      size: 16,
                      color: tip.startsWith('Great')
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
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
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.vm,
    required this.slots,
    required this.isVerified,
    required this.onPreview,
  });

  final ProfileViewModel vm;
  final List<ImageSlot> slots;
  final bool isVerified;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    ImageSlot? first;
    for (final s in slots) {
      if (s.hasImage) {
        first = s;
        break;
      }
    }
    final age = ProfileCompletion.ageFromDob(vm.dateOfBirth);
    final name = (vm.fullName ?? '').trim();
    final title = [
      if (name.isNotEmpty) name,
      if (age != null) '$age',
    ].join(', ');
    final job = [
      if ((vm.currentProfession ?? '').isNotEmpty) vm.currentProfession,
      if ((vm.locationString ?? '').isNotEmpty) vm.locationString,
    ].whereType<String>().join(' · ');

    return Container(
      width: double.infinity,
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
            'Profile Preview',
            style: getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'See how others view your profile.',
            style: getTextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: first?.localBytes != null
                  ? Image.memory(first!.localBytes!, fit: BoxFit.cover)
                  : AppNetworkImage(
                      url: first?.networkUrl ??
                          AppConfig.placeholderImageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'Your name' : title,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isVerified)
                Icon(Icons.verified, size: 18, color: WelcomeTheme.violetLight),
            ],
          ),
          if (job.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              job,
              style: getTextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (vm.interests.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final i in vm.interests.take(5))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: WelcomeTheme.violet.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      i,
                      style: getTextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
          if ((vm.aboutMe ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              vm.aboutMe!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPreview,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Preview Full Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: WelcomeTheme.violet.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.hasChanges,
    required this.onCancel,
    required this.onSave,
    required this.isSaving,
  });

  final bool hasChanges;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;

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
        children: [
          Icon(Icons.shield_outlined,
              size: 14, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Your information is secure and will never be shared',
              style: getTextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: getTextStyle(fontSize: 14, color: Colors.white60),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: hasChanges ? WelcomeTheme.ctaGradient : null,
              color: hasChanges ? null : Colors.white12,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasChanges && !isSaving ? onSave : null,
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSaving)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else ...[
                          const Icon(Icons.lock_outline,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Save Changes',
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
        ],
      ),
    );
  }
}
