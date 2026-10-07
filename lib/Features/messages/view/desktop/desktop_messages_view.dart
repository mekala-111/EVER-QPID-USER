import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Features/messages/view/chat_screen.dart';
import 'package:everqpidapp/Features/messages/view_model/messages_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Messages — same [MessagesViewModel] / [ChatViewModel] as mobile.
class DesktopMessagesView extends StatefulWidget {
  const DesktopMessagesView({super.key});

  @override
  State<DesktopMessagesView> createState() => _DesktopMessagesViewState();
}

class _DesktopMessagesViewState extends State<DesktopMessagesView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RecentChatUser? _selectedChat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MessagesViewModel>();
      if (vm.chats.isEmpty && !vm.isLoading) {
        vm.fetchRecentChats();
      }
    });
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final vm = context.read<MessagesViewModel>();
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        vm.loadMoreChats();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectChat(RecentChatUser chat) {
    if (chat.isBlock || chat.isOppositeBlock) return;
    context.read<MessagesViewModel>().forceResetUnreadCount(chat.id);
    setState(() => _selectedChat = chat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 400,
            child: _ConversationColumn(
              searchController: _searchController,
              scrollController: _scrollController,
              selectedId: _selectedChat?.id,
              onSelect: _selectChat,
              onDiscover: () => MainScreenBridge.navigateToTab(0),
            ),
          ),
          Container(
            width: 1,
            color: Colors.white.withValues(alpha: 0.07),
          ),
          Expanded(
            child: _selectedChat == null
                ? const _SelectConversationEmpty()
                : ChatScreen(
                    key: ValueKey(_selectedChat!.id),
                    receiverId: _selectedChat!.id,
                    name: _selectedChat!.name,
                    imageUrl: _selectedChat!.profileImageUrl,
                    isOnline: _selectedChat!.isOnline,
                    embedded: true,
                    darkChrome: true,
                    onClose: () => setState(() => _selectedChat = null),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation list ──────────────────────────────────────────────────────

class _ConversationColumn extends StatefulWidget {
  const _ConversationColumn({
    required this.searchController,
    required this.scrollController,
    required this.selectedId,
    required this.onSelect,
    required this.onDiscover,
  });

  final TextEditingController searchController;
  final ScrollController scrollController;
  final String? selectedId;
  final ValueChanged<RecentChatUser> onSelect;
  final VoidCallback onDiscover;

  @override
  State<_ConversationColumn> createState() => _ConversationColumnState();
}

class _ConversationColumnState extends State<_ConversationColumn> {
  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearch);
    super.dispose();
  }

  void _onSearch() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B0615).withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Messages',
                      style: getTextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: WelcomeTheme.violetLight.withValues(alpha: 0.9),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Your conversations',
                  style: getTextStyle(
                    fontSize: 13,
                    color: const Color(0xFFB9B2C8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: widget.searchController,
                style: getTextStyle(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: getTextStyle(
                    fontSize: 14,
                    color: const Color(0xFF7A728C),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7A728C),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MessagesViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading && vm.chats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: WelcomeTheme.violetLight,
                    ),
                  );
                }
                if (vm.error != null && vm.chats.isEmpty) {
                  return _ListError(
                    message: vm.error!,
                    onRetry: () => vm.fetchRecentChats(refresh: true),
                  );
                }
                if (vm.chats.isEmpty) {
                  return _NoConversations(onDiscover: widget.onDiscover);
                }

                final query = widget.searchController.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? vm.chats
                    : vm.chats.where((c) {
                        return c.name.toLowerCase().contains(query) ||
                            c.lastMessage.toLowerCase().contains(query);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found',
                      style: getTextStyle(color: const Color(0xFF9A92AB)),
                    ),
                  );
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  itemCount: filtered.length +
                      (vm.hasNext && query.isEmpty ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= filtered.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: vm.isLoadingMore
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: WelcomeTheme.violetLight,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }
                    final chat = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _DesktopChatTile(
                        chat: chat,
                        selected: widget.selectedId == chat.id,
                        onTap: () => widget.onSelect(chat),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopChatTile extends StatefulWidget {
  const _DesktopChatTile({
    required this.chat,
    required this.selected,
    required this.onTap,
  });

  final RecentChatUser chat;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DesktopChatTile> createState() => _DesktopChatTileState();
}

class _DesktopChatTileState extends State<_DesktopChatTile> {
  bool _hover = false;

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final d = now.difference(time);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inHours < 24) {
      return TimeOfDay.fromDateTime(time.toLocal()).format(context);
    }
    if (d.inDays == 1) return 'Yesterday';
    if (d.inDays < 7) return '${d.inDays}d';
    return '${time.day}/${time.month}';
  }

  bool _isVoice(String msg) {
    final m = msg.toLowerCase();
    return m.contains('voice message') ||
        m.contains('🎤') ||
        m.endsWith('.m4a') ||
        m.endsWith('.mp3') ||
        m.endsWith('.aac');
  }

  bool _isPhoto(String msg) =>
      msg.contains('📷') || msg.toLowerCase().contains('photo');

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final blocked = chat.isBlock || chat.isOppositeBlock;
    final preview = chat.lastMessage.isEmpty
        ? 'No messages yet'
        : _isVoice(chat.lastMessage)
            ? null
            : _isPhoto(chat.lastMessage)
                ? '📷 Photo'
                : chat.lastMessage;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: blocked ? null : widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: widget.selected
                  ? WelcomeTheme.violet.withValues(alpha: 0.18)
                  : _hover
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.transparent,
              border: Border.all(
                color: widget.selected
                    ? WelcomeTheme.violetLight.withValues(alpha: 0.55)
                    : Colors.transparent,
              ),
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: WelcomeTheme.violet.withValues(alpha: 0.2),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      backgroundImage: chat.profileImageUrl.isNotEmpty
                          ? AppNetworkImage.provider(
                              chat.profileImageUrl,
                              memCacheWidth: 104,
                            )
                          : null,
                      child: chat.profileImageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                    if (chat.isOnline && !blocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0B0615),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(context, chat.sentAt),
                            style: getTextStyle(
                              fontSize: 11,
                              color: const Color(0xFF8E879E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: preview == null
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.mic,
                                        size: 14,
                                        color: WelcomeTheme.violetLight
                                            .withValues(alpha: 0.85),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Voice message',
                                        style: getTextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFFB9B2C8),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    preview,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getTextStyle(
                                      fontSize: 13,
                                      color: const Color(0xFFB9B2C8),
                                    ),
                                  ),
                          ),
                          if (chat.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: WelcomeTheme.violetSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chat.unreadCount > 99
                                    ? '99+'
                                    : '${chat.unreadCount}',
                                style: getTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty / error ──────────────────────────────────────────────────────────

class _SelectConversationEmpty extends StatelessWidget {
  const _SelectConversationEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: WelcomeTheme.violet.withValues(alpha: 0.35),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: WelcomeTheme.violetLight.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a conversation',
            style: getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose someone from your messages to start chatting.',
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 14,
              color: const Color(0xFFB9B2C8),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoConversations extends StatelessWidget {
  const _NoConversations({required this.onDiscover});
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: WelcomeTheme.violetLight.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: getTextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start discovering people and make meaningful connections.',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 13,
                color: const Color(0xFFB9B2C8),
              ),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [WelcomeTheme.violetDeep, WelcomeTheme.violetSoft],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDiscover,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Text(
                      'Discover People',
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListError extends StatelessWidget {
  const _ListError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: WelcomeTheme.violetLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
