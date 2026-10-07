import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/settings/view_model/contact_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Hide Contacts — presentation only; actions from [HideContactsScreen].
class DesktopHideContactsView extends StatelessWidget {
  const DesktopHideContactsView({
    super.key,
    required this.onImportContacts,
    required this.onManageHidden,
  });

  final VoidCallback onImportContacts;
  final VoidCallback onManageHidden;

  static const _description =
      "We understand that your dating journey is personal. With "
      "Everqpid's privacy settings, you can choose to hide your profile "
      'from contacts or people you may know — like friends, colleagues, '
      'or relatives. This feature gives you the space to explore serious '
      'connections confidently, without the pressure of familiar eyes. '
      "Your comfort comes first, and we're here to keep your experience "
      'discreet and secure.';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1100;
    final headingSize = width >= 1100 ? 44.0 : 36.0;
    final pad = width >= 1100 ? 44.0 : 28.0;

    return ColoredBox(
      color: const Color(0xFF04000F),
      child: Stack(
        children: [
          const IgnorePointer(child: _AmbientDecor()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 40),
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
                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height - 140,
                      ),
                      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad - 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFF0A041C).withValues(alpha: 0.78),
                        border: Border.all(
                          color:
                              const Color(0xFFA855F7).withValues(alpha: 0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: WelcomeTheme.violet.withValues(alpha: 0.14),
                            blurRadius: 36,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 11,
                                  child: _PrivacyContent(
                                    headingSize: headingSize,
                                    description: _description,
                                    onManageHidden: onManageHidden,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                const Expanded(
                                  flex: 9,
                                  child: _PrivacyIllustration(size: 400),
                                ),
                              ],
                            )
                          else ...[
                            _PrivacyContent(
                              headingSize: headingSize,
                              description: _description,
                              onManageHidden: onManageHidden,
                            ),
                            const SizedBox(height: 28),
                            const Center(
                              child: _PrivacyIllustration(size: 300),
                            ),
                          ],
                          const SizedBox(height: 36),
                          Selector<ContactsViewModel, bool>(
                            selector: (_, vm) => vm.isLoading,
                            builder: (context, loading, _) {
                              return _ImportContactsButton(
                                loading: loading,
                                onPressed: onImportContacts,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: const Color(0xFF9F98AB)
                                    .withValues(alpha: 0.95),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Your privacy is important to us. We never share your contacts.',
                                  textAlign: TextAlign.center,
                                  style: getTextStyle(
                                    fontSize: 14.5,
                                    color: const Color(0xFF9F98AB),
                                  ),
                                ),
                              ),
                            ],
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

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent({
    required this.headingSize,
    required this.description,
    required this.onManageHidden,
  });

  final double headingSize;
  final String description;
  final VoidCallback onManageHidden;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PrivacyBadgeIcon(),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Hide your profile from\npeople you know, and date\nconfidently.',
            style: getTextStyle(
              fontSize: headingSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            description,
            style: getTextStyle(
              fontSize: 16.5,
              height: 1.65,
              color: const Color(0xFFC3BDCC),
            ),
          ),
        ),
        Selector<ContactsViewModel, ({int count, bool fetching})>(
          selector: (_, vm) => (count: vm.hiddenCount, fetching: vm.isFetching),
          builder: (context, state, _) {
            if (state.fetching) {
              return const Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: WelcomeTheme.violetSoft,
                  ),
                ),
              );
            }
            if (state.count <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: onManageHidden,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: WelcomeTheme.violet.withValues(alpha: 0.12),
                    border: Border.all(
                      color: WelcomeTheme.violet.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: WelcomeTheme.violetSoft,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'You have hidden ${state.count} contact${state.count > 1 ? 's' : ''}',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Manage',
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: WelcomeTheme.violetSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PrivacyBadgeIcon extends StatelessWidget {
  const _PrivacyBadgeIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WelcomeTheme.violet.withValues(alpha: 0.18),
              border: Border.all(
                color: WelcomeTheme.violetSoft.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: WelcomeTheme.violet.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 40,
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.95),
                ),
                const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A0A2E),
                border: Border.all(
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.55),
                ),
              ),
              child: const Icon(
                Icons.visibility_off_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyIllustration extends StatelessWidget {
  const _PrivacyIllustration({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final shield = size * 0.55;
    return SizedBox(
      width: size,
      height: size * 0.95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  WelcomeTheme.violetSoft.withValues(alpha: 0.32),
                  WelcomeTheme.violet.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Container(
              width: size * 0.42,
              height: size * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: [
                    WelcomeTheme.violetDeep.withValues(alpha: 0.1),
                    WelcomeTheme.violetSoft.withValues(alpha: 0.55),
                    WelcomeTheme.violetDeep.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.4),
                    blurRadius: 22,
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.shield_rounded,
            size: shield,
            color: WelcomeTheme.violetSoft.withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.7),
                blurRadius: 28,
              ),
            ],
          ),
          Icon(
            Icons.person_rounded,
            size: shield * 0.38,
            color: Colors.white.withValues(alpha: 0.95),
          ),
          Positioned(
            right: size * 0.22,
            bottom: size * 0.28,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16082B),
                border: Border.all(
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.7),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.45),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.visibility_off_rounded,
                size: size * 0.055,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: size * 0.12,
            right: size * 0.18,
            child: Icon(
              Icons.favorite,
              size: size * 0.045,
              color: WelcomeTheme.violetLight,
            ),
          ),
          Positioned(
            top: size * 0.22,
            left: size * 0.16,
            child: Icon(
              Icons.favorite,
              size: size * 0.035,
              color: WelcomeTheme.violetSoft.withValues(alpha: 0.8),
            ),
          ),
          Positioned(
            bottom: size * 0.22,
            left: size * 0.2,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.04,
              color: WelcomeTheme.violetLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportContactsButton extends StatefulWidget {
  const _ImportContactsButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  State<_ImportContactsButton> createState() => _ImportContactsButtonState();
}

class _ImportContactsButtonState extends State<_ImportContactsButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.loading;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform:
              Matrix4.translationValues(0, _hover && enabled ? -1 : 0, 0),
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: _hover && enabled
                  ? const [
                      Color(0xFF5B1CF0),
                      Color(0xFF8B2FFA),
                      Color(0xFFB62AF0),
                    ]
                  : const [
                      Color(0xFF4F16E8),
                      Color(0xFF7C24F5),
                      Color(0xFFA623E8),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet
                    .withValues(alpha: _hover && enabled ? 0.45 : 0.28),
                blurRadius: _hover && enabled ? 24 : 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              else ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Import contacts',
                  style: getTextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
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
      ..color = const Color(0xFF9B4DFF).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.88, 100), 160, glow);
    canvas.drawCircle(Offset(40, size.height * 0.72), 130, glow);

    final star = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (final o in [
      Offset(size.width * 0.18, 70),
      Offset(size.width * 0.7, 50),
      Offset(size.width * 0.5, size.height * 0.88),
      Offset(size.width * 0.12, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.38),
    ]) {
      canvas.drawCircle(o, 1.2, star);
    }

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.68, 0)
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.28,
          size.width,
          size.height * 0.5,
        ),
      line,
    );

    final heart = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.14)
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

    drawHeart(Offset(48, 150), 10);
    drawHeart(Offset(size.width - 70, size.height * 0.55), 9);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
