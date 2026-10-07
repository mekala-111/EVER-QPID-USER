import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/model/user_profile_model.dart';
import 'package:everqpidapp/Features/profile/view/profile_actions.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_action_card.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_completion.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_summary_card.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop profile content — shell sidebar/top bar live in [MainScreen].
class DesktopProfileView extends StatelessWidget {
  const DesktopProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<GetProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: WelcomeTheme.violetLight),
            );
          }
          if (vm.errorMessage != null && vm.profile == null) {
            return _ErrorState(
              message: vm.errorMessage!,
              onRetry: vm.fetchProfile,
            );
          }
          final profile = vm.profile;
          if (profile == null) {
            return Center(
              child: Text(
                'No profile data found',
                style: getTextStyle(color: Colors.white70),
              ),
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 48),
                child: _DesktopBody(profile: profile),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DesktopBody extends StatelessWidget {
  const _DesktopBody({required this.profile});
  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Profile',
              style: getTextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.favorite_border_rounded,
              size: 22,
              color: WelcomeTheme.violetLight.withValues(alpha: 0.85),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your account and preferences',
          style: getTextStyle(fontSize: 14, color: const Color(0xFFB9B2C8)),
        ),
        const SizedBox(height: 32),
        ProfileHeroCard(profile: profile),
        const SizedBox(height: 28),
        _PremiumBanner(),
        const SizedBox(height: 48),
        _SectionTitle('Profile Management'),
        const SizedBox(height: 16),
        _CardGrid(
          columns: 4,
          cards: [
            (
              Icons.edit_outlined,
              'Edit Profile',
              'Update your photos, bio and personal details',
              () => ProfileActions.openEditProfile(context),
            ),
            (
              Icons.tune,
              'Preferences',
              'Set your match preferences and filters',
              () => ProfileActions.openPreferences(context),
            ),
            (
              Icons.favorite_border,
              'Your Likes',
              'See people who liked you and your likes',
              () => ProfileActions.openYourLikes(context),
            ),
            (
              Icons.replay,
              'Recent Passes',
              "View profiles you've passed on",
              () => ProfileActions.openRecentPasses(context),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _SectionTitle('Account & Safety'),
        const SizedBox(height: 16),
        _CardGrid(
          columns: 3,
          cards: [
            (
              Icons.workspace_premium_outlined,
              'Subscriptions',
              'Manage your subscriptions and payment',
              () => ProfileActions.openSubscriptions(context),
            ),
            (
              Icons.shield_outlined,
              'Safety Tips',
              'Learn how to stay safe while connecting',
              () => ProfileActions.openSafetyTips(context),
            ),
            (
              Icons.settings_outlined,
              'Settings',
              'Manage account, privacy and notifications',
              () => ProfileActions.openSettings(context, profile.id),
            ),
          ],
        ),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (context, c) {
            final stack = c.maxWidth < 900;
            final preview = _ProfilePreviewCard(profile: profile);
            final details = _AccountDetailsCard(profile: profile);
            if (stack) {
              return Column(
                children: [
                  preview,
                  const SizedBox(height: 20),
                  details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: preview),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: details),
              ],
            );
          },
        ),
        const SizedBox(height: 40),
        _SectionTitle('Quick Settings'),
        const SizedBox(height: 16),
        _QuickSettingsRow(userId: profile.id),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: getTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.columns, required this.cards});

  final int columns;
  final List<(IconData, String, String, VoidCallback)> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 700 ? 1 : (c.maxWidth < 1000 ? 2 : columns);
        const gap = 16.0;
        final tileW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards)
              SizedBox(
                width: tileW,
                child: ProfileActionCard(
                  icon: card.$1,
                  title: card.$2,
                  description: card.$3,
                  onTap: card.$4,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            WelcomeTheme.violet.withValues(alpha: 0.55),
            WelcomeTheme.violetDeep.withValues(alpha: 0.35),
            const Color(0xFF1D0B3D),
          ],
        ),
        border: Border.all(
          color: WelcomeTheme.violetLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: WelcomeTheme.violet.withValues(alpha: 0.25),
            blurRadius: 28,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final stack = c.maxWidth < 640;
          final copy = Column(
            crossAxisAlignment:
                stack ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    stack ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(Icons.workspace_premium,
                      color: Colors.amber[300], size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'EverQpid Premium',
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Stand out. Connect more. Find better matches.',
                textAlign: stack ? TextAlign.center : TextAlign.left,
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          );
          final btn = FilledButton(
            onPressed: () => ProfileActions.openPremium(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: WelcomeTheme.violetDeep,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Upgrade to Premium',
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: WelcomeTheme.violetDeep,
              ),
            ),
          );
          if (stack) {
            return Column(
              children: [copy, const SizedBox(height: 16), btn],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              btn,
            ],
          );
        },
      ),
    );
  }
}

class _ProfilePreviewCard extends StatelessWidget {
  const _ProfilePreviewCard({required this.profile});
  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final age = ProfileCompletion.ageFromDob(profile.dateOfBirth);
    final title = age != null ? '${profile.fullName}, $age' : profile.fullName;
    final job = profile.currentProfession?.trim();
    final loc = profile.locationString?.trim();
    final interests = profile.interests ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Profile Preview'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: AppNetworkImage(
                    url: profile.profileImageUrl ??
                        AppConfig.placeholderImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified,
                        size: 18, color: WelcomeTheme.violetLight),
                  ],
                ],
              ),
              if (job != null && job.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  job,
                  style: getTextStyle(
                    fontSize: 13,
                    color: const Color(0xFFB9B2C8),
                  ),
                ),
              ],
              if (loc != null && loc.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  loc,
                  style: getTextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
              if (interests.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in interests.take(5))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: WelcomeTheme.violet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: getTextStyle(
                            fontSize: 11,
                            color: WelcomeTheme.violetLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if ((profile.aboutMe ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  profile.aboutMe!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPreviewSheet(context, profile),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Preview Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: WelcomeTheme.violet.withValues(alpha: 0.45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPreviewSheet(BuildContext context, UserProfileModel profile) {
    // Lightweight preview — ProfileDetailScreen is match-browse oriented.
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF15082D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'How others see you',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: AppNetworkImage(
                      url: profile.profileImageUrl ??
                          AppConfig.placeholderImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.fullName,
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if ((profile.aboutMe ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    profile.aboutMe!,
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ProfileActions.openEditProfile(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: WelcomeTheme.violet,
                    ),
                    child: const Text('Edit Profile'),
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

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.profile});
  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final phone = '${profile.countryCode ?? ''} ${profile.phoneNumber}'.trim();
    final rows = <(String, String)>[
      if (phone.isNotEmpty) ('Phone Number', phone),
      if (profile.email.isNotEmpty) ('Email', profile.email),
      (
        'Account Verification',
        profile.isVerified ? 'Verified' : 'Not Verified',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Account Details'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                      color: Colors.white.withValues(alpha: 0.08), height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        rows[i].$1,
                        style: getTextStyle(
                          fontSize: 12,
                          color: const Color(0xFFB9B2C8),
                        ),
                      ),
                    ),
                    Flexible(
                      child: rows[i].$1 == 'Account Verification' &&
                              !profile.isVerified
                          ? InkWell(
                              onTap: () =>
                                  ProfileActions.openVerify(context, profile),
                              child: Text(
                                rows[i].$2,
                                textAlign: TextAlign.right,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          : Text(
                              rows[i].$2,
                              textAlign: TextAlign.right,
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickSettingsRow extends StatelessWidget {
  const _QuickSettingsRow({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.block,
        'Blocked Users',
        () => ProfileActions.openBlockedUsers(context),
      ),
      (
        Icons.visibility_off_outlined,
        'Hide Contacts',
        () => ProfileActions.openHideContacts(context),
      ),
      (
        Icons.lock_outline,
        'Privacy',
        () => ProfileActions.openPrivacyPolicy(context),
      ),
      (
        Icons.headset_mic_outlined,
        'Customer Support',
        () => ProfileActions.openSupport(context, userId),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wrap = c.maxWidth < 700;
          if (wrap) {
            return Column(
              children: [
                for (final item in items)
                  ListTile(
                    leading: Icon(item.$1, color: WelcomeTheme.violetLight),
                    title: Text(
                      item.$2,
                      style: getTextStyle(fontSize: 14, color: Colors.white),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    onTap: item.$3,
                  ),
              ],
            );
          }
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                Expanded(
                  child: InkWell(
                    onTap: items[i].$3,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(items[i].$1,
                              size: 18, color: WelcomeTheme.violetLight),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              items[i].$2,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: getTextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: WelcomeTheme.violet,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
