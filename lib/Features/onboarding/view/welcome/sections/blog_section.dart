import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/glass_card.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class BlogSection extends StatelessWidget {
  const BlogSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSectionPad(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Blog',
            title: 'Dating, relationships &\n',
            highlight: 'everything between.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 960
                  ? 3
                  : c.maxWidth >= 640
                      ? 2
                      : 1;
              const gap = 18.0;
              final tileW = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final b in WelcomeTheme.blogs)
                    SizedBox(
                      width: tileW,
                      child: _BlogCard(blog: b),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BlogCard extends StatefulWidget {
  const _BlogCard({required this.blog});
  final WelcomeBlog blog;

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GlassCard(
        padding: EdgeInsets.zero,
        // Non-destructive: no blog routes yet.
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: AnimatedScale(
                  scale: _hover ? 1.06 : 1,
                  duration: const Duration(milliseconds: 280),
                  child: Image.network(
                    blog.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: WelcomeTheme.violetDeep.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.tag.toUpperCase(),
                    style: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: WelcomeTheme.violetLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    blog.title,
                    style: getTextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.description,
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${blog.date} · ${blog.readTime}',
                    style: getTextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Read article →',
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WelcomeTheme.violetLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
