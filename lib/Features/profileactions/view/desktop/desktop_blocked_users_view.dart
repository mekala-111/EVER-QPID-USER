import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profileactions/model/block_reason_model.dart';
import 'package:everqpidapp/Features/profileactions/view_model/profile_actions_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Blocked Users — presentation only; actions from [BlockedUsersListScreen].
class DesktopBlockedUsersView extends StatelessWidget {
  const DesktopBlockedUsersView({
    super.key,
    required this.scrollController,
    required this.onUnblock,
  });

  final ScrollController scrollController;
  final ValueChanged<BlockedUser> onUnblock;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width >= 1100 ? 44.0 : 28.0;
    final twoCol = width >= 900;

    return ColoredBox(
      color: const Color(0xFF04000F),
      child: Stack(
        children: [
          const IgnorePointer(child: _AmbientDecor()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 32),
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
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad - 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color:
                              const Color(0xFF0A041C).withValues(alpha: 0.78),
                          border: Border.all(
                            color:
                                const Color(0xFFA855F7).withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color:
                                  WelcomeTheme.violet.withValues(alpha: 0.14),
                              blurRadius: 36,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _BlockedHeader(),
                            const SizedBox(height: 28),
                            Expanded(
                              child: Consumer<ProfileActionsViewModel>(
                                builder: (context, vm, _) {
                                  if (vm.isLoading && vm.blockedUsers.isEmpty) {
                                    return _LoadingState(twoCol: twoCol);
                                  }

                                  if (vm.errorMessage != null &&
                                      vm.blockedUsers.isEmpty) {
                                    return _ErrorState(
                                      message: vm.errorMessage!,
                                      onRetry: () =>
                                          vm.fetchBlockedUsers(refresh: true),
                                    );
                                  }

                                  if (vm.blockedUsers.isEmpty) {
                                    return const _EmptyState();
                                  }

                                  return _BlockedUsersGrid(
                                    users: vm.blockedUsers,
                                    loadingMore: vm.isLoadingMore,
                                    twoCol: twoCol,
                                    controller: scrollController,
                                    onUnblock: onUnblock,
                                    onRefresh: () =>
                                        vm.fetchBlockedUsers(refresh: true),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
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

Future<bool?> showWebUnblockConfirmDialog(
  BuildContext context, {
  required String name,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color.fromRGBO(2, 0, 12, 0.72),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF0D061D),
              border: Border.all(
                color: const Color(0xFFA855F7).withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: WelcomeTheme.violet.withValues(alpha: 0.2),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unblock this user?',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name.isEmpty
                      ? 'They will be able to interact with your profile again, depending on your privacy settings.'
                      : 'Unblock $name? They will be able to interact with your profile again, depending on your privacy settings.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: const Color(0xFFB8B2C7),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC8C2D3),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFC8C2D3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WelcomeTheme.violetSoft,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Unblock',
                          style: getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _BlockedHeader extends StatelessWidget {
  const _BlockedHeader();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final iconSize = compact ? 60.0 : 72.0;
    final titleSize = compact ? 32.0 : 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B126E), Color(0xFF6D28D9)],
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.4),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(
            Icons.block_flipped,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blocked Users',
                style: getTextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage users you have blocked. You can unblock them anytime.',
                style: getTextStyle(
                  fontSize: 16,
                  color: const Color(0xFFB8B2C7),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        WelcomeTheme.violet.withValues(alpha: 0.22),
                        WelcomeTheme.violet.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.block_flipped,
                  size: 132,
                  color: const Color(0xFF817A91).withValues(alpha: 0.85),
                  shadows: [
                    Shadow(
                      color: WelcomeTheme.violet.withValues(alpha: 0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                const Positioned(
                  top: 18,
                  right: 28,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Color(0xFFA855F7),
                  ),
                ),
                const Positioned(
                  bottom: 30,
                  left: 24,
                  child: Icon(
                    Icons.favorite,
                    size: 12,
                    color: Color(0xFFC084FC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'No blocked users',
            style: getTextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Users you block will appear here',
            style: getTextStyle(
              fontSize: 17,
              color: const Color(0xFFA9A3B3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: WelcomeTheme.violetSoft.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 18),
            Text(
              "Couldn't load blocked users",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message.isEmpty
                  ? 'Something went wrong while loading your blocked list.'
                  : message,
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 15,
                height: 1.45,
                color: const Color(0xFFA9A3B3),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: WelcomeTheme.violetSoft,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Try again',
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.twoCol});
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final cards = List.generate(4, (_) => const _SkeletonCard());
    if (!twoCol) {
      return ListView.separated(
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => cards[i],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 3.2,
      children: cards,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF14092A).withValues(alpha: 0.7),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WelcomeTheme.violet.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: WelcomeTheme.violet.withValues(alpha: 0.18),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: WelcomeTheme.violet.withValues(alpha: 0.12),
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

class _BlockedUsersGrid extends StatelessWidget {
  const _BlockedUsersGrid({
    required this.users,
    required this.loadingMore,
    required this.twoCol,
    required this.controller,
    required this.onUnblock,
    required this.onRefresh,
  });

  final List<BlockedUser> users;
  final bool loadingMore;
  final bool twoCol;
  final ScrollController controller;
  final ValueChanged<BlockedUser> onUnblock;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: WelcomeTheme.violetSoft,
      backgroundColor: const Color(0xFF16082B),
      onRefresh: onRefresh,
      child: twoCol
          ? GridView.builder(
              controller: controller,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 3.1,
              ),
              itemCount: users.length + (loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= users.length) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: WelcomeTheme.violetSoft,
                    ),
                  );
                }
                return _WebBlockedUserCard(
                  user: users[index],
                  onUnblock: () => onUnblock(users[index]),
                );
              },
            )
          : ListView.separated(
              controller: controller,
              itemCount: users.length + (loadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: WelcomeTheme.violetSoft,
                      ),
                    ),
                  );
                }
                return _WebBlockedUserCard(
                  user: users[index],
                  onUnblock: () => onUnblock(users[index]),
                );
              },
            ),
    );
  }
}

class _WebBlockedUserCard extends StatefulWidget {
  const _WebBlockedUserCard({
    required this.user,
    required this.onUnblock,
  });

  final BlockedUser user;
  final VoidCallback onUnblock;

  @override
  State<_WebBlockedUserCard> createState() => _WebBlockedUserCardState();
}

class _WebBlockedUserCardState extends State<_WebBlockedUserCard> {
  bool _hover = false;

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pic = widget.user.blockedAccount.profileImageUrl.trim();
    final name = widget.user.blockedAccount.fullName.trim().isEmpty
        ? 'Unknown'
        : widget.user.blockedAccount.fullName.trim();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF14092A).withValues(alpha: 0.82),
          border: Border.all(
            color: _hover
                ? WelcomeTheme.violetSoft.withValues(alpha: 0.5)
                : const Color(0xFFA855F7).withValues(alpha: 0.2),
          ),
          boxShadow: [
            if (_hover)
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 58,
                height: 58,
                child: pic.isEmpty
                    ? ColoredBox(
                        color: WelcomeTheme.violet.withValues(alpha: 0.25),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                    : AppNetworkImage(url: pic),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Blocked ${_formatDate(widget.user.dateBlocked)}',
                    style: getTextStyle(
                      fontSize: 12.5,
                      color: const Color(0xFFA9A3B3),
                    ),
                  ),
                  if (widget.user.selectedReasons.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.user.selectedReasons.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        fontSize: 11.5,
                        color: const Color(0xFF817A91),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _UnblockChip(onPressed: widget.onUnblock),
          ],
        ),
      ),
    );
  }
}

class _UnblockChip extends StatefulWidget {
  const _UnblockChip({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_UnblockChip> createState() => _UnblockChipState();
}

class _UnblockChipState extends State<_UnblockChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _hover
                ? const Color(0xFFA855F7).withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: _hover ? const Color(0xFFA855F7) : const Color(0xFF8B5CF6),
            ),
          ),
          child: Text(
            'Unblock',
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB66CFF),
            ),
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
    canvas.drawCircle(Offset(size.width * 0.88, 90), 150, glow);
    canvas.drawCircle(Offset(36, size.height * 0.7), 120, glow);

    final star = Paint()..color = Colors.white.withValues(alpha: 0.32);
    for (final o in [
      Offset(size.width * 0.2, 64),
      Offset(size.width * 0.72, 44),
      Offset(size.width * 0.55, size.height * 0.86),
      Offset(size.width * 0.12, size.height * 0.42),
    ]) {
      canvas.drawCircle(o, 1.2, star);
    }

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.7, 0)
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.25,
          size.width,
          size.height * 0.48,
        ),
      line,
    );

    final heart = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.13)
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

    drawHeart(Offset(48, 140), 9);
    drawHeart(Offset(size.width - 64, size.height * 0.55), 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
