import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('welcome desktop breakpoint is 900', () {
    expect(WelcomeTheme.desktopBreakpoint, 900);
  });

  test('headline highlights partner', () {
    expect(WelcomeTheme.headline.contains(WelcomeTheme.highlightWord), isTrue);
  });

  test('landing sections have content', () {
    expect(WelcomeTheme.features, isNotEmpty);
    expect(WelcomeTheme.howItWorks.length, 4);
    expect(WelcomeTheme.stories, isNotEmpty);
    expect(WelcomeTheme.blogs, isNotEmpty);
  });
}
