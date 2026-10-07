import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key, required this.onNavTap});

  final ValueChanged<String> onNavTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final padH = WelcomeTheme.horizontalPad(w);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(padH, 56, padH, 36),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        color: Colors.black.withValues(alpha: 0.28),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: WelcomeTheme.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EverQpid',
                style: getTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your partner in life.',
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth >= 900
                      ? 4
                      : c.maxWidth >= 600
                          ? 2
                          : 1;
                  final gap = 28.0;
                  final colW = (c.maxWidth - gap * (cols - 1)) / cols;
                  final groups = <_FooterCol>[
                    _FooterCol(
                      title: 'Company',
                      links: [
                        _Link('About', () => onNavTap('Home')),
                        _Link('Blog', () => onNavTap('Blog')),
                        _Link('Contact', () => onNavTap('Contact')),
                      ],
                    ),
                    _FooterCol(
                      title: 'Discover',
                      links: [
                        _Link('How it works', () => onNavTap('How it works')),
                        _Link('Success stories', () => onNavTap('Success stories')),
                        _Link('Features', () => onNavTap('Features')),
                      ],
                    ),
                    _FooterCol(
                      title: 'Safety',
                      links: [
                        _Link(
                          'Safety tips',
                          () => Navigator.pushNamed(
                            context,
                            PPages.safetyTipsScreen,
                          ),
                        ),
                        _Link(
                          'Help',
                          () => Navigator.pushNamed(
                            context,
                            PPages.supportScreen,
                          ),
                        ),
                      ],
                    ),
                    _FooterCol(
                      title: 'Legal',
                      links: [
                        _Link(
                          'Privacy',
                          () => Navigator.pushNamed(
                            context,
                            PPages.privacyPolicyScreen,
                          ),
                        ),
                        _Link(
                          'Terms',
                          () => Navigator.pushNamed(
                            context,
                            PPages.termsConditionsScreen,
                          ),
                        ),
                      ],
                    ),
                  ];
                  return Wrap(
                    spacing: gap,
                    runSpacing: 28,
                    children: [
                      for (final g in groups)
                        SizedBox(width: colW, child: g),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 18),
              Text(
                '© ${DateTime.now().year} EverQpid. All rights reserved.',
                style: getTextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  const _FooterCol({required this.title, required this.links});
  final String title;
  final List<_Link> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        for (final link in links) ...[
          InkWell(
            onTap: link.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                link.label,
                style: getTextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Link {
  const _Link(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
}
