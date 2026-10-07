/// Max content widths (dp) for tablet/desktop. Mobile ignores these via
/// [AppContentFrame] (passthrough below the mobile breakpoint).
abstract final class ContentMaxWidth {
  /// Auth, settings, and single-column forms.
  static const double form = 480;

  /// Home swipe deck / profile card.
  static const double homeCard = 480;

  /// Chat thread composer + bubbles column.
  static const double chat = 800;

  /// Inbox / clan rows / similar lists.
  static const double list = 840;

  /// Tablet shell around main tabs.
  static const double tabletShell = 840;

  /// Desktop shell around main tabs (beside rail).
  static const double shell = 1280;
}
