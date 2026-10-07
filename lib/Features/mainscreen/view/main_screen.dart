import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/clan2.0/view/clan_screen.dart';
import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/home/view/home_screen.dart';
import 'package:everqpidapp/Features/home/view_model/home_view_model.dart';
import 'package:everqpidapp/Features/matches/model/match_response_model.dart';
import 'package:everqpidapp/Features/matches/view/matches_screen.dart';
import 'package:everqpidapp/Features/matches/view_model/likes_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/matches_view_model.dart';
import 'package:everqpidapp/Features/messages/view/messages_screen.dart';
import 'package:everqpidapp/Features/messages/view_model/messages_view_model.dart';
import 'package:everqpidapp/Features/mainscreen/view/widgets/desktop_sidebar.dart';
import 'package:everqpidapp/Features/profile/view/profile_actions.dart';
import 'package:everqpidapp/Features/profile/view/profile_screen.dart';
import 'package:everqpidapp/Settings/helper/fcm_token_refresh_handler.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tab bridge without [GlobalKey] — avoids Duplicate GlobalKey when Navigator
/// builds a second [MainScreen] (push / replacement / restart).
class MainScreenBridge {
  static _MainScreenState? _state;

  static void navigateToTab(int index) => _state?.navigateToTab(index);

  static void _attach(_MainScreenState state) => _state = state;

  static void _detach(_MainScreenState state) {
    if (identical(_state, state)) _state = null;
  }
}

class MainScreen extends StatefulWidget {
  final int initialTab;

  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Map<String, dynamic>? _notificationArgs;
  bool _tabletSidebarCollapsed = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MatchesScreen(),
    ClanScreen(userId: LoggedInUser.id ?? ''),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    MainScreenBridge._attach(this);

    WidgetsBinding.instance.addObserver(this);

    _currentIndex = widget.initialTab;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMTokenRefreshService.initialize(context);

      _refreshTabData(_currentIndex);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notificationArgs == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _notificationArgs = args;

        _currentIndex = args['tabIndex'] ?? 0;

        final navigateToProfile = args['navigateToProfile'] ?? false;
        final profileUserId = args['profileUserId'];

        if (navigateToProfile && profileUserId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToProfile(profileUserId);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    MainScreenBridge._detach(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ✅ Common method to refresh data per tab
  void _refreshTabData(int index) {
    switch (index) {
      case 0:
        context.read<HomeViewModel>().fetchProfiles();
        break;
      case 1:
        context.read<MatchesViewModel>().fetchMatches();
        context.read<LikesViewModel>().fetchReceivedLikes();
        break;
      case 3:
        context.read<MessagesViewModel>().fetchRecentChats();
        break;
    }
  }

  /// ✅ External navigation (used globally)
  void navigateToTab(int index) {
    if (!mounted) return;

    setState(() => _currentIndex = index);
    _refreshTabData(index);
  }

  void _navigateToProfile(String userId) {
    final profile = MatchUserProfile(
      id: userId,
      fullName: 'User',
      age: 0,
      profileImageUrl: '',
      isVerified: false,
      locationString: 'Unknown',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(
          profile: profile,
          profileTitle: 'notification',
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _refreshTabData(index);
  }

  Widget get _tabStack => IndexedStack(
        index: _currentIndex,
        children: _screens,
      );

  Widget _buildBottomNav() {
    final tabs = [
      (Images.home, 'Discover'),
      (Images.matches, 'Matches'),
      (Images.clan, 'Clan'),
      (Images.chat, 'Messages'),
      (Images.profile, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _NavBarItem(
                  imagePath: tabs[i].$1,
                  isSelected: _currentIndex == i,
                  onTap: () => _onTabTapped(i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _webShell({
    required bool collapsed,
    VoidCallback? onToggleCollapse,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFF090416),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Images.bg,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            // Decode closer to display size — full PNG was janking route pushes.
            cacheWidth: 1600,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF090416)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesktopSidebar(
                selectedIndex: _currentIndex,
                onSelect: _onTabTapped,
                collapsed: collapsed,
                onToggleCollapse: onToggleCollapse,
                onPremiumTap: () => ProfileActions.openSubscriptions(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    const DesktopContentTopBar(),
                    Expanded(child: _tabStack),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = breakpointOf(constraints.maxWidth);

        if (bp == AppBreakpoint.mobile) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: _tabStack,
            bottomNavigationBar: _buildBottomNav(),
          );
        }

        if (bp == AppBreakpoint.desktop) {
          return _webShell(collapsed: false);
        }

        // Tablet: compact/collapsible sidebar, no bottom nav.
        return _webShell(
          collapsed: _tabletSidebarCollapsed,
          onToggleCollapse: () {
            setState(
              () => _tabletSidebarCollapsed = !_tabletSidebarCollapsed,
            );
          },
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: PColors.primaryColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            imagePath,
            height: 28,
            width: 28,
            color: isSelected ? PColors.primaryColor : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
