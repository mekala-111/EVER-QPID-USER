import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/home/view/home_web_discover.dart';
import 'package:everqpidapp/Features/messages/view_model/messages_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Features/settings/view/delete_account_screen.dart';
import 'package:everqpidapp/Features/settings/view/support_screen.dart';
import 'package:everqpidapp/Features/settings/view_model/support_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Fixed left nav for desktop/tablet shell. Major destinations only.
class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.collapsed = false,
    this.onToggleCollapse,
    this.premiumSelected = false,
    this.onPremiumTap,
  });

  /// Tab indices: 0 Discover, 1 Matches, 2 Clan, 3 Messages, 4 Profile.
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback? onToggleCollapse;
  final bool premiumSelected;
  final VoidCallback? onPremiumTap;

  static const double expandedWidth = 228;
  static const double collapsedWidth = 74;

  @override
  Widget build(BuildContext context) {
    final unread = context.select<MessagesViewModel, int>(
      (vm) => vm.totalUnreadCount,
    );
    final profileVm = context.watch<GetProfileViewModel>();
    if (profileVm.profile == null && !profileVm.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final vm = context.read<GetProfileViewModel>();
        if (vm.profile == null && !vm.isLoading) vm.fetchProfile();
      });
    }
    final profile = profileVm.profile;
    final displayName = () {
      final fromApi = profile?.fullName.trim() ?? '';
      if (fromApi.isNotEmpty) return fromApi;
      return (LoggedInUser.name ?? LoggedInUser.userName ?? 'You').trim();
    }();
    final displayPic = () {
      final fromApi = profile?.profileImageUrl?.trim() ?? '';
      if (fromApi.isNotEmpty) return fromApi;
      return (LoggedInUser.profilePic ?? '').trim();
    }();

    return AnimatedContainer(
      duration: onToggleCollapse == null
          ? Duration.zero
          : const Duration(milliseconds: 220),
      width: collapsed ? collapsedWidth : expandedWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0615),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 12 : 22,
                24,
                collapsed ? 12 : 18,
                28,
              ),
              child: collapsed
                  ? Center(
                      child: Image.asset(
                        Images.appIcon,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.favorite,
                          color: WelcomeTheme.violetLight,
                        ),
                      ),
                    )
                  : Image.asset(
                      Images.everqpidWhite,
                      width: 128,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        'EverQpid',
                        style: getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            if (onToggleCollapse != null)
              Align(
                alignment: collapsed ? Alignment.center : Alignment.centerRight,
                child: IconButton(
                  tooltip: collapsed ? 'Expand' : 'Collapse',
                  onPressed: onToggleCollapse,
                  icon: Icon(
                    collapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.white54,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 10 : 14,
                  vertical: 4,
                ),
                children: [
                  _NavItem(
                    icon: Icons.explore_outlined,
                    label: 'Discover',
                    selected: selectedIndex == 0,
                    collapsed: collapsed,
                    onTap: () => onSelect(0),
                  ),
                  _NavItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Matches',
                    selected: selectedIndex == 1,
                    collapsed: collapsed,
                    onTap: () => onSelect(1),
                  ),
                  _NavItem(
                    icon: Icons.groups_outlined,
                    label: 'Clan',
                    selected: selectedIndex == 2,
                    collapsed: collapsed,
                    onTap: () => onSelect(2),
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Messages',
                    selected: selectedIndex == 3,
                    collapsed: collapsed,
                    badge: unread > 0 ? unread : null,
                    onTap: () => onSelect(3),
                  ),
                  _NavItem(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Premium',
                    selected: premiumSelected,
                    collapsed: collapsed,
                    onTap: onPremiumTap ?? () => openPremiumSheet(context),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    selected: !premiumSelected && selectedIndex == 4,
                    collapsed: collapsed,
                    onTap: () => onSelect(4),
                  ),
                ],
              ),
            ),
            if (!collapsed) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: _PremiumCard(
                  onUpgrade: onPremiumTap ?? () => openPremiumSheet(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: _UserMini(
                  name: displayName,
                  photoUrl: displayPic,
                  onTap: () => onSelect(4),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: IconButton(
                    tooltip: displayName,
                    onPressed: () => onSelect(4),
                    icon: ClipOval(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: displayPic.isEmpty
                            ? ColoredBox(
                                color:
                                    WelcomeTheme.violet.withValues(alpha: 0.3),
                                child: Center(
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : '?',
                                    style: getTextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : AppNetworkImage(url: displayPic),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 8 : 14,
                0,
                collapsed ? 8 : 14,
                16,
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Help',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => SupportViewModel(),
                            child: SupportScreen(
                              userId: LoggedInUser.id ?? '',
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline,
                        color: Colors.white54, size: 22),
                  ),
                  if (!collapsed) const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Log out',
                    onPressed: () => showLogoutDialog(context),
                    icon: const Icon(Icons.logout,
                        color: Colors.white54, size: 22),
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

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.collapsed,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool collapsed;
  final int? badge;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final highlight = active || _hover;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: widget.collapsed ? widget.label : '',
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 48,
            decoration: BoxDecoration(
              gradient: active
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFA855F7).withValues(alpha: 0.25),
                        const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      ],
                    )
                  : null,
              color: active
                  ? null
                  : (_hover
                      ? const Color(0xFFA855F7).withValues(alpha: 0.08)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: active
                    ? const Color(0xFFA855F7).withValues(alpha: 0.45)
                    : Colors.transparent,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: WelcomeTheme.violet.withValues(alpha: 0.22),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (active && !widget.collapsed)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            color: WelcomeTheme.violetSoft,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.collapsed ? 0 : 14,
                      ),
                      child: widget.collapsed
                          ? Center(
                              child: Badge(
                                isLabelVisible: widget.badge != null,
                                label: Text('${widget.badge ?? ''}'),
                                child: Icon(
                                  widget.icon,
                                  size: 22,
                                  color: highlight
                                      ? WelcomeTheme.violetSoft
                                      : const Color(0xFFB9AFC8),
                                ),
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.icon,
                                  size: 22,
                                  color: highlight
                                      ? WelcomeTheme.violetSoft
                                      : const Color(0xFFB9AFC8),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.label,
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: active
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: highlight
                                          ? Colors.white
                                          : const Color(0xFFB9AFC8),
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                if (widget.badge != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: WelcomeTheme.violetSoft,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${widget.badge}',
                                      style: getTextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    // ponytail: LoggedInUser has no premium flag — always Upgrade; swap when API exposes membership.
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            WelcomeTheme.violet.withValues(alpha: 0.35),
            WelcomeTheme.violetDeep.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(
          color: WelcomeTheme.violet.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber[300], size: 18),
              const SizedBox(width: 6),
              Text(
                'EverQpid Premium',
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Stand out. Connect more.\nFind better matches.',
            style: getTextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onUpgrade,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                gradient: WelcomeTheme.ctaGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Upgrade to Premium →',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMini extends StatelessWidget {
  const _UserMini({
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });
  final String name;
  final String photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: photoUrl.isEmpty
                      ? ColoredBox(
                          color: WelcomeTheme.violet.withValues(alpha: 0.3),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: getTextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : AppNetworkImage(url: photoUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'View Profile',
                      style: getTextStyle(
                        fontSize: 11,
                        color: WelcomeTheme.violetLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coins + bell for the main content top-right (shared shell chrome).
class DesktopContentTopBar extends StatelessWidget {
  const DesktopContentTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<MessagesViewModel, int>(
      (vm) => vm.totalUnreadCount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 28, 0),
      child: Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.amber[600], size: 18),
                const SizedBox(width: 6),
                Text(
                  '${LoggedInUser.coinBalance ?? 0}',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                if (unread > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
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
