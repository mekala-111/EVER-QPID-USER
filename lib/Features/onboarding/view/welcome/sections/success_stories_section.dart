import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/glass_card.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class SuccessStoriesSection extends StatelessWidget {
  const SuccessStoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSectionPad(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Success stories',
            title: 'Real people.\n',
            highlight: 'Real connections.',
            subtitle:
                'See how people found meaningful connections through EverQpid.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 768) {
                return SizedBox(
                  height: 420,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: WelcomeTheme.stories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => SizedBox(
                      width: c.maxWidth * 0.82,
                      child: _StoryCard(
                        story: WelcomeTheme.stories[i],
                        heightBoost: i == 1 ? 24 : 0,
                      ),
                    ),
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < WelcomeTheme.stories.length; i++) ...[
                    if (i > 0) const SizedBox(width: 18),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: i == 1 ? 28 : (i == 2 ? 12 : 0)),
                        child: _StoryCard(
                          story: WelcomeTheme.stories[i],
                          heightBoost: i == 1 ? 20 : 0,
                        ),
                      ),
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

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, this.heightBoost = 0});
  final WelcomeStory story;
  final double heightBoost;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 1.35 - (heightBoost / 200),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    story.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: WelcomeTheme.violetDeep.withValues(alpha: 0.4),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Icon(
                      Icons.favorite,
                      color: WelcomeTheme.violetLight.withValues(alpha: 0.9),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: WelcomeTheme.violet.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    story.label,
                    style: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: WelcomeTheme.violetLight,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '"${story.quote}"',
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: WelcomeTheme.violetSoft),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        story.names,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story.location,
                  style: getTextStyle(
                    fontSize: 12,
                    color: WelcomeTheme.violetLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
