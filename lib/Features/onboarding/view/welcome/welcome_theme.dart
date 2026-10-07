import 'package:flutter/material.dart';

/// Shared EverQpid welcome design tokens (mobile + web).
abstract final class WelcomeTheme {
  /// Width at which the desktop landing layout takes over.
  static const double desktopBreakpoint = 900;

  static const Color pageBg = Color(0xFF090415);
  static const Color bgTop = Color(0xFF090415);
  static const Color bgMid = Color(0xFF140E28);
  static const Color bgBottom = Color(0xFF1E1238);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetSoft = Color(0xFFA855F7);
  static const Color violetDeep = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFC084FC);
  static const Color violetGlow = Color(0xFF9B5DE5);

  static const headline = 'Find your partner in life';
  static const highlightWord = 'partner';
  static const subtitle =
      'We created to bring together amazing singles who want to find love, laughter and happily ever after!';

  static const navItems = <String>[
    'Home',
    'Features',
    'How it works',
    'Success stories',
    'Blog',
    'Contact',
  ];

  static const double contentMaxWidth = 1400;
  static const double sectionPadV = 140;
  static const double navHeight = 88;

  static const features = <WelcomeFeature>[
    WelcomeFeature(
      icon: Icons.verified_user_outlined,
      title: 'Verified Profiles',
      subtitle: 'Connect with real people through profile verification.',
    ),
    WelcomeFeature(
      icon: Icons.favorite_rounded,
      title: 'Smart Matching',
      subtitle:
          'Personalized recommendations based on interests and compatibility.',
    ),
    WelcomeFeature(
      icon: Icons.shield_outlined,
      title: 'Safe & Secure',
      subtitle:
          'Privacy controls, reporting and blocking built into the experience.',
    ),
    WelcomeFeature(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Instant Messaging',
      subtitle: 'Start conversations with your matches quickly and naturally.',
    ),
    WelcomeFeature(
      icon: Icons.groups_outlined,
      title: 'Meaningful Connections',
      subtitle: 'Matching designed around values, interests and intent.',
    ),
    WelcomeFeature(
      icon: Icons.workspace_premium_outlined,
      title: 'Premium Experience',
      subtitle: 'Advanced discovery and additional matching features.',
    ),
  ];

  static const howItWorks = <WelcomeStep>[
    WelcomeStep(
      number: '01',
      icon: Icons.person_outline_rounded,
      title: 'Create your profile',
      subtitle: 'Add photos, interests, and what you are looking for.',
    ),
    WelcomeStep(
      number: '02',
      icon: Icons.explore_outlined,
      title: 'Discover your matches',
      subtitle: 'Browse verified profiles that fit your preferences.',
    ),
    WelcomeStep(
      number: '03',
      icon: Icons.favorite_border_rounded,
      title: 'Start connecting',
      subtitle: 'When the feeling is mutual, start a real conversation.',
    ),
  ];

  static const stories = <WelcomeStory>[
    WelcomeStory(
      names: 'Ananya & Rohan',
      quote:
          'We matched on a Tuesday and met for coffee that weekend. Two years later, we are planning our wedding.',
      location: 'Bangalore',
      label: 'Engaged',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&q=80',
    ),
    WelcomeStory(
      names: 'Meera & Arjun',
      quote:
          'EverQpid felt different — verified faces, clear intent. We found each other within a month.',
      location: 'Mumbai',
      label: 'Together',
      imageUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=600&q=80',
    ),
    WelcomeStory(
      names: 'Priya & Kabir',
      quote:
          'From a Super Like to late-night chats to our first trip together. Still our favorite story.',
      location: 'Hyderabad',
      label: 'Matched',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&q=80',
    ),
  ];

  static const blogs = <WelcomeBlog>[
    WelcomeBlog(
      tag: 'Dating tips',
      title: 'How to write a bio that gets replies',
      description: 'Simple prompts that make your profile feel human.',
      date: 'Mar 12, 2026',
      readTime: '4 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
    ),
    WelcomeBlog(
      tag: 'Safety',
      title: 'First-date safety checklist for modern dating',
      description: 'Practical steps before you meet someone new.',
      date: 'Mar 4, 2026',
      readTime: '5 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
    ),
    WelcomeBlog(
      tag: 'Relationships',
      title: 'Signs you are ready for a serious relationship',
      description: 'Intent, timing, and what “ready” actually looks like.',
      date: 'Feb 22, 2026',
      readTime: '6 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=800&q=80',
    ),
  ];

  static const partnerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violetLight, violetSoft, violetDeep],
  );

  static const ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [violetSoft, violet, violetDeep],
  );

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgBottom],
    stops: [0.0, 0.5, 1.0],
  );

  static const double desktopHeadingMin = 80;
  static const double desktopHeadingMax = 96;
  static const double ctaWidth = 220;
  static const double ctaHeight = 70;
  static const double ctaRadius = 18;

  static double horizontalPad(double width) {
    if (width >= 1200) return 72;
    if (width >= 768) return 48;
    return 24;
  }
}

class WelcomeFeature {
  const WelcomeFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class WelcomeStep {
  const WelcomeStep({
    required this.number,
    required this.title,
    required this.subtitle,
    this.icon = Icons.circle_outlined,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
}

class WelcomeStory {
  const WelcomeStory({
    required this.names,
    required this.quote,
    required this.location,
    required this.label,
    required this.imageUrl,
  });

  final String names;
  final String quote;
  final String location;
  final String label;
  final String imageUrl;
}

class WelcomeBlog {
  const WelcomeBlog({
    required this.tag,
    required this.title,
    required this.description,
    required this.date,
    required this.readTime,
    required this.imageUrl,
  });

  final String tag;
  final String title;
  final String description;
  final String date;
  final String readTime;
  final String imageUrl;
}
