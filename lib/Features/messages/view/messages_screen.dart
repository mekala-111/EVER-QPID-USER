import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Features/messages/view/chat_screen.dart';
import 'package:everqpidapp/Features/messages/view/desktop/desktop_messages_view.dart';
import 'package:everqpidapp/Features/messages/view_model/messages_view_model.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/responsive/responsive_builder.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

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

      const threshold = 300;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - threshold) {
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

  Future<void> _openChat(RecentChatUser chat) async {
    log('MessagesScreen: 🔄 Opening chat with ${chat.id}');
    log('MessagesScreen: 🔄 Current unread: ${chat.unreadCount}');

    final vm = context.read<MessagesViewModel>();
    vm.forceResetUnreadCount(chat.id);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: chat.id,
          name: chat.name,
          imageUrl: chat.profileImageUrl,
          isOnline: chat.isOnline,
        ),
      ),
    );
    log('MessagesScreen: 🔙 Returned from chat');
    await vm.refreshChatsSilently();
    log('MessagesScreen: ✅ Silent refresh completed');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ResponsiveBuilder(
      mobile: (_) => _buildMobile(),
      tablet: (_) => const DesktopMessagesView(),
      desktop: (_) => const DesktopMessagesView(),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppContentFrame(
          maxWidth: ContentMaxWidth.list,
          child: _buildInboxColumn(),
        ),
      ),
    );
  }

  Widget _buildInboxColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Text(
            'Messages',
            style: getTextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: getTextStyle(fontSize: 15, color: Colors.black),
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: getTextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Consumer<MessagesViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vm.error!,
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => vm.fetchRecentChats(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (vm.chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start matching to begin chatting!',
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        onPressed: () => vm.fetchRecentChats(refresh: true),
                        icon: const Icon(Icons.refresh),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            101,
                            101,
                            101,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final query = _searchController.text.trim().toLowerCase();
              final filteredChats = query.isEmpty
                  ? vm.chats
                  : vm.chats.where((chat) {
                      return chat.name.toLowerCase().contains(query) ||
                          chat.lastMessage.toLowerCase().contains(query);
                    }).toList();

              if (filteredChats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with a different keyword',
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final isSearching = query.isNotEmpty;
              final showLoadMoreFooter = !isSearching && vm.hasNext;

              return RefreshIndicator(
                onRefresh: () => vm.fetchRecentChats(refresh: true),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  cacheExtent: 400,
                  itemCount:
                      filteredChats.length + (showLoadMoreFooter ? 1 : 0),
                  separatorBuilder: (context, index) {
                    if (showLoadMoreFooter &&
                        index == filteredChats.length - 1) {
                      return const SizedBox.shrink();
                    }
                    return Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    );
                  },
                  itemBuilder: (context, index) {
                    if (showLoadMoreFooter && index == filteredChats.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: vm.isLoadingMore
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }

                    final chat = filteredChats[index];
                    return RepaintBoundary(
                      child: _ChatTile(
                        chat: chat,
                        onTap: () => _openChat(chat),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final RecentChatUser chat;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.onTap,
  });

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return TimeOfDay.fromDateTime(time.toLocal()).format(context);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = chat.profileImageUrl.isNotEmpty;

    return InkWell(
      onTap: chat.isBlock || chat.isOppositeBlock ? null : onTap,
      hoverColor: PColors.primaryColor.withOpacity(0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      hasImage ? Colors.transparent : Colors.grey[300],
                  backgroundImage: hasImage
                      ? AppNetworkImage.provider(
                          chat.profileImageUrl,
                          memCacheWidth: 112,
                        )
                      : null,
                  child: !hasImage
                      ? Icon(Icons.person, size: 32, color: Colors.grey[600])
                      : null,
                ),
                if (chat.isOnline && !chat.isBlock && !chat.isOppositeBlock)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.isBlock || chat.isOppositeBlock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Blocked',
                            style: getTextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage.isEmpty
                        ? 'No messages yet'
                        : chat.lastMessage,
                    style: getTextStyle(
                      fontSize: 14,
                      color: chat.lastMessage.isEmpty
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(context, chat.sentAt),
                  style: getTextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
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
    );
  }
}
