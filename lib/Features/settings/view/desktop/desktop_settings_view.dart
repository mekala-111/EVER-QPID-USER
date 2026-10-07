import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

/// Desktop/tablet Settings — presentation only; actions passed from [SettingsScreen].
class DesktopSettingsView extends StatelessWidget {
  const DesktopSettingsView({
    super.key,
    required this.onHideContacts,
    required this.onBlockedContacts,
    required this.onPrivacyPolicy,
    required this.onSupport,
    required this.onTerms,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  final VoidCallback onHideContacts;
  final VoidCallback onBlockedContacts;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onSupport;
  final VoidCallback onTerms;
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final name = (LoggedInUser.name ?? LoggedInUser.userName ?? 'You').trim();
    final email = (LoggedInUser.email ?? '').trim();
    final pic = (LoggedInUser.profilePic ?? '').trim();

    return ColoredBox(
      color: const Color(0xFF050315),
      child: Stack(
        children: [
          const IgnorePointer(child: _AmbientDecor()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
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
                    Row(
                      children: [
                        Text(
                          'Settings',
                          style: getTextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.settings_outlined,
                          size: 26,
                          color: WelcomeTheme.violetSoft.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your privacy, account and security preferences.',
                      style: getTextStyle(
                        fontSize: 15,
                        color: const Color(0xFFB9AFC8),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 11,
                            child: _GlassPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  WebSettingsSection(
                                    title: 'Privacy & Connections',
                                    children: [
                                      WebSettingsTile(
                                        icon: Icons.visibility_off_outlined,
                                        title: 'Hide Contacts',
                                        subtitle:
                                            'Control which contacts are hidden from your experience.',
                                        onTap: onHideContacts,
                                      ),
                                      WebSettingsTile(
                                        icon: Icons.block_flipped,
                                        title: 'Blocked Contacts',
                                        subtitle:
                                            "View and manage people you've blocked.",
                                        onTap: onBlockedContacts,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  WebSettingsSection(
                                    title: 'Account & Support',
                                    children: [
                                      WebSettingsTile(
                                        icon: Icons.lock_outline,
                                        title: 'Privacy Policy',
                                        subtitle:
                                            'Learn how EverQpid protects and uses your information.',
                                        onTap: onPrivacyPolicy,
                                      ),
                                      WebSettingsTile(
                                        icon: Icons.chat_bubble_outline,
                                        title: 'Customer Support',
                                        subtitle:
                                            'Need help? Contact the EverQpid support team.',
                                        onTap: onSupport,
                                      ),
                                      WebSettingsTile(
                                        icon: Icons.description_outlined,
                                        title: 'Terms & Conditions',
                                        subtitle:
                                            "Review the terms governing your use of EverQpid.",
                                        onTap: onTerms,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 9,
                            child: Column(
                              children: [
                                _AccountCard(
                                  name: name,
                                  email: email,
                                  photoUrl: pic,
                                ),
                                const SizedBox(height: 18),
                                _DangerPanel(
                                  onDeleteAccount: onDeleteAccount,
                                  onLogout: onLogout,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      _GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AccountCard(
                              name: name,
                              email: email,
                              photoUrl: pic,
                            ),
                            const SizedBox(height: 22),
                            WebSettingsSection(
                              title: 'Privacy & Connections',
                              children: [
                                WebSettingsTile(
                                  icon: Icons.visibility_off_outlined,
                                  title: 'Hide Contacts',
                                  subtitle:
                                      'Control which contacts are hidden from your experience.',
                                  onTap: onHideContacts,
                                ),
                                WebSettingsTile(
                                  icon: Icons.block_flipped,
                                  title: 'Blocked Contacts',
                                  subtitle:
                                      "View and manage people you've blocked.",
                                  onTap: onBlockedContacts,
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            WebSettingsSection(
                              title: 'Account & Support',
                              children: [
                                WebSettingsTile(
                                  icon: Icons.lock_outline,
                                  title: 'Privacy Policy',
                                  subtitle:
                                      'Learn how EverQpid protects and uses your information.',
                                  onTap: onPrivacyPolicy,
                                ),
                                WebSettingsTile(
                                  icon: Icons.chat_bubble_outline,
                                  title: 'Customer Support',
                                  subtitle:
                                      'Need help? Contact the EverQpid support team.',
                                  onTap: onSupport,
                                ),
                                WebSettingsTile(
                                  icon: Icons.description_outlined,
                                  title: 'Terms & Conditions',
                                  subtitle:
                                      "Review the terms governing your use of EverQpid.",
                                  onTap: onTerms,
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            _DangerPanel(
                              onDeleteAccount: onDeleteAccount,
                              onLogout: onLogout,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebSettingsSection extends StatelessWidget {
  const WebSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: WelcomeTheme.violetSoft,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }
}

class WebSettingsTile extends StatefulWidget {
  const WebSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  State<WebSettingsTile> createState() => _WebSettingsTileState();
}

class _WebSettingsTileState extends State<WebSettingsTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final danger = widget.isDanger;
    final accent = danger ? const Color(0xFFEF4444) : WelcomeTheme.violet;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final chevronShift = !reduce && _hover ? 3.0 : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: danger
              ? const Color(0xFF2A1014).withValues(alpha: _hover ? 0.95 : 0.75)
              : Colors.white.withValues(alpha: _hover ? 0.08 : 0.05),
          border: Border.all(
            color: accent.withValues(
                alpha: _hover ? 0.55 : (danger ? 0.35 : 0.22)),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(15),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: danger
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : WelcomeTheme.violet.withValues(alpha: 0.18),
                  ),
                  child: Icon(
                    widget.icon,
                    color: danger
                        ? const Color(0xFFF87171)
                        : WelcomeTheme.violetSoft,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              danger ? const Color(0xFFFCA5A5) : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: getTextStyle(
                          fontSize: 12,
                          color: const Color(0xFFB9AFC8),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  transform: Matrix4.translationValues(chevronShift, 0, 0),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: danger
                        ? const Color(0xFFF87171)
                        : Colors.white.withValues(alpha: 0.45),
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

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF120A1F).withValues(alpha: 0.72),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: WelcomeTheme.violet.withValues(alpha: 0.1),
            blurRadius: 36,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String name;
  final String email;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: WelcomeTheme.violet.withValues(alpha: 0.1),
        border: Border.all(
          color: WelcomeTheme.violet.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 56,
              height: 56,
              child: photoUrl.isEmpty
                  ? ColoredBox(
                      color: WelcomeTheme.violet.withValues(alpha: 0.3),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 28),
                    )
                  : AppNetworkImage(url: photoUrl),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: getTextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: getTextStyle(
                      fontSize: 13,
                      color: const Color(0xFFB9AFC8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerPanel extends StatelessWidget {
  const _DangerPanel({
    required this.onDeleteAccount,
    required this.onLogout,
  });

  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF1A0A10).withValues(alpha: 0.75),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DANGER ZONE',
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF87171),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          WebSettingsTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and associated data.',
            onTap: onDeleteAccount,
            isDanger: true,
          ),
          const SizedBox(height: 10),
          WebSettingsTile(
            icon: Icons.logout,
            title: 'Log out',
            subtitle: 'Sign out of EverQpid on this device.',
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _AmbientDecor extends StatelessWidget {
  const _AmbientDecor();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFF9B51E0).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.88, 80), 150, glow);
    canvas.drawCircle(Offset(40, size.height * 0.75), 120, glow);

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.65, 0)
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.22,
          size.width,
          size.height * 0.4,
        ),
      line,
    );

    final heart = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    void drawHeart(Offset c, double s) {
      final p = Path()
        ..moveTo(c.dx, c.dy + s * 0.3)
        ..cubicTo(
          c.dx - s,
          c.dy - s * 0.4,
          c.dx - s * 1.1,
          c.dy + s * 0.6,
          c.dx,
          c.dy + s * 1.2,
        )
        ..cubicTo(
          c.dx + s * 1.1,
          c.dy + s * 0.6,
          c.dx + s,
          c.dy - s * 0.4,
          c.dx,
          c.dy + s * 0.3,
        );
      canvas.drawPath(p, heart);
    }

    drawHeart(Offset(52, 130), 9);
    drawHeart(Offset(size.width - 70, size.height * 0.55), 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
