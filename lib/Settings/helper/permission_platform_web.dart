// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Capability check beats UA sniffing. `window.Notification` is:
/// - absent in iOS/iPadOS browser *tabs* — Apple does not allow Web Push in
///   Safari tabs, and Chrome/Firefox/Edge on iOS are WebKit shells with the
///   same restriction (CriOS/FxiOS/EdgiOS);
/// - present in an installed Home Screen PWA on iOS 16.4+ (Web Push via
///   VAPID), Android Chrome, and all desktop browsers.
bool get supportsNotificationPermission => html.Notification.supported;

/// Human-readable platform label for permission debug logs.
String get platformDebugDescription {
  final ua = html.window.navigator.userAgent;
  final standalone =
      html.window.matchMedia('(display-mode: standalone)').matches;
  // iPadOS 13+ Safari masquerades as macOS; multi-touch gives it away.
  final isIos = RegExp(r'iPhone|iPad|iPod').hasMatch(ua) ||
      (ua.contains('Macintosh') &&
          (html.window.navigator.maxTouchPoints ?? 0) > 1);
  final String browser;
  if (ua.contains('CriOS')) {
    browser = 'chrome-on-ios(webkit)';
  } else if (isIos) {
    browser = 'ios-safari(webkit)';
  } else if (ua.contains('Android')) {
    browser = 'android-chrome';
  } else {
    browser = 'desktop-browser';
  }
  return standalone ? '$browser-pwa' : browser;
}
