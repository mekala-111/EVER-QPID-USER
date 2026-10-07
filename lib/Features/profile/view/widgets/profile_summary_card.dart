import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/model/user_profile_model.dart';
import 'package:everqpidapp/Features/profile/view/profile_actions.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_completion.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/material.dart';

/// Desktop/tablet profile hero with real completion %.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final contact = profile.email.isEmpty
        ? '${profile.countryCode ?? ''} ${profile.phoneNumber}'.trim()
        : profile.email;
    final strength = ProfileCompletion.percent(profile);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final stack = c.maxWidth < 720;
          final identity = _IdentityColumn(profile: profile, contact: contact);
          final strengthCol = _StrengthColumn(percent: strength);

          if (stack) {
            return Column(
              children: [
                _Avatar(profile: profile),
                const SizedBox(height: 20),
                identity,
                const SizedBox(height: 24),
                strengthCol,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(profile: profile),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: identity),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: strengthCol),
            ],
          );
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});
  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: WelcomeTheme.partnerGradient,
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipOval(
            child: AppNetworkImage(
              url: profile.profileImageUrl ?? AppConfig.placeholderImageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 4,
          child: Material(
            color: WelcomeTheme.violet,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => ProfileActions.openEditProfile(context),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityColumn extends StatelessWidget {
  const _IdentityColumn({required this.profile, required this.contact});
  final UserProfileModel profile;
  final String contact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                profile.fullName,
                style: getTextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.isVerified) ...[
              const SizedBox(width: 8),
              Icon(Icons.verified, color: WelcomeTheme.violetLight, size: 22),
            ],
          ],
        ),
        if (contact.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            contact,
            style: getTextStyle(fontSize: 14, color: const Color(0xFFB9B2C8)),
          ),
        ],
        const SizedBox(height: 14),
        InkWell(
          onTap: () => ProfileActions.openVerify(context, profile),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: profile.isVerified
                  ? WelcomeTheme.violet.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: profile.isVerified ? WelcomeTheme.violet : Colors.orange,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profile.isVerified ? Icons.verified : Icons.shield_outlined,
                  size: 16,
                  color: profile.isVerified
                      ? WelcomeTheme.violetLight
                      : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  profile.isVerified ? 'Verified' : 'Verify Now',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: profile.isVerified
                        ? WelcomeTheme.violetLight
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => ProfileActions.openEditProfile(context),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: WelcomeTheme.violet.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthColumn extends StatelessWidget {
  const _StrengthColumn({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Strength',
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: WelcomeTheme.violetSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$percent%',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: WelcomeTheme.violetLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Complete your profile to improve your matches.',
          style: getTextStyle(
            fontSize: 12,
            color: const Color(0xFFB9B2C8),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
