import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Features/messages/repository/chat_repository.dart';
import 'package:everqpidapp/Features/messages/service/chat_socket_service.dart';
import 'package:flutter/material.dart';

class MessagesViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final ChatSocketService _socket = ChatSocketService.instance;
  String? _myUserId;

  void Function(Map<String, dynamic>)? _newMessageHandler;
  void Function(Map<String, dynamic>)? _userStatusHandler;
  void Function(Map<String, dynamic>)? _readStatusHandler;
  void Function(Map<String, dynamic>)? _messageSeenHandler;

  bool _listenersAttached = false;

  MessagesViewModel() {
    _initializeSocket();
  }

  List<RecentChatUser> _chats = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasNext = false;
  int _totalCount = 0;

  List<RecentChatUser> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasChats => _chats.isNotEmpty;
  bool get hasNext => _hasNext;
  int get totalCount => _totalCount;
  Future<void> fetchRecentChats({
    bool refresh = false,
    bool silent = false,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasNext = true;
      _error = null;
    }

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      log('MessagesVM: 📞 Initial fetch (page: $_currentPage)');

      final response = await _repository.getRecentChats(
        page: _currentPage,
        pageSize: _pageSize,
      );

      _mergeChatsWithServerData(response.chats);

      _hasNext = response.hasNext;
      _totalCount = response.totalCount;

      _error = null;
    } catch (e) {
      log('MessagesVM: ❌ Error: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mergeChatsWithServerData(List<RecentChatUser> serverChats) {
    final Map<String, RecentChatUser> localChatsMap = {
      for (var chat in _chats) chat.id: chat
    };

    final mergedChats = <RecentChatUser>[];

    for (final serverChat in serverChats) {
      final localChat = localChatsMap[serverChat.id];

      if (localChat != null) {
        final resolvedUnread = localChat.unreadCount == 0
            ? 0
            : localChat.unreadCount > serverChat.unreadCount
                ? localChat.unreadCount
                : serverChat.unreadCount;

        mergedChats.add(serverChat.copyWith(unreadCount: resolvedUnread));
      } else {
        mergedChats.add(serverChat);
      }
    }

    _chats = mergedChats;
    log('MessagesVM: ✅ Merged ${_chats.length} chats');
  }

  Future<void> loadMoreChats() async {
    if (_isLoadingMore || !_hasNext) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      log('MessagesVM: 📞 Load more (page: $nextPage)');

      final response = await _repository.getRecentChats(
        page: nextPage,
        pageSize: _pageSize,
      );

      final existingIds = _chats.map((c) => c.id).toSet();

      final newChats =
          response.chats.where((c) => !existingIds.contains(c.id)).toList();

      _chats.addAll(newChats);

      _currentPage = nextPage; // ✅ update ONLY after success
      _hasNext = response.hasNext;

      log('MessagesVM: ➕ Added ${newChats.length}, total: ${_chats.length}');
    } catch (e) {
      log('MessagesVM: ❌ Load more error: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshChats() async {
    await fetchRecentChats(refresh: true);
  }

  Future<void> refreshChatsSilently() async {
    await fetchRecentChats(refresh: true, silent: true);
  }

  Future<void> _initializeSocket() async {
    await LoggedInUser.getUserDetails();
    _myUserId = LoggedInUser.id;

    if (_myUserId == null || _myUserId!.isEmpty) {
      log('MessagesVM: ⚠️ No user ID, skipping socket init');
      return;
    }

    await _socket.initialize();
    _attachSocketListeners();
    log('MessagesVM: ✅ Socket initialized (myUserId: $_myUserId)');
  }

  void _attachSocketListeners() {
    if (_listenersAttached) {
      log('MessagesVM: ⚠️ Listeners already attached');
      return;
    }

    log('MessagesVM: 🔧 Attaching socket listeners');

    _newMessageHandler = (data) {
      log('MessagesVM: 📩 NEW MESSAGE EVENT');
      try {
        final msg = ChatMessageModel.fromJson(data);
        log('MessagesVM: 📩 From: ${msg.senderId}, To: ${msg.receiverId}');

        final otherUserId =
            msg.senderId == _myUserId ? msg.receiverId : msg.senderId;
        final shouldIncrementUnread = msg.receiverId == _myUserId;

        log('MessagesVM: 📊 Should increment unread? $shouldIncrementUnread');

        updateChatMessage(
          otherUserId,
          _getMessagePreview(msg),
          msg.sentAt,
          incrementUnread: shouldIncrementUnread,
        );
      } catch (e) {
        log('MessagesVM: ❌ Error in newMessage: $e');
      }
    };

    _userStatusHandler = (data) {
      log('MessagesVM: 🟢 USER STATUS CHANGED');
      final userId = data['userId']?.toString() ?? '';
      final isOnline = data['isOnline'] == true;

      if (userId.isNotEmpty) {
        updateOnlineStatus(userId, isOnline);
      }
    };

    _readStatusHandler = (data) {
      log('MessagesVM: ✅ READ STATUS UPDATED EVENT');
      final userId = data['userId']?.toString() ?? '';
      final withUserId = data['withUserId']?.toString() ?? '';

      if (userId.isNotEmpty && userId != _myUserId) {
        resetUnreadCount(userId);
      } else if (withUserId.isNotEmpty && withUserId != _myUserId) {
        resetUnreadCount(withUserId);
      }
    };

    _messageSeenHandler = (data) {
      log('MessagesVM: 👁️ MESSAGE SEEN EVENT');
      final userId = data['userId']?.toString() ?? '';
      final withUserId = data['withUserId']?.toString() ?? '';

      if (userId.isNotEmpty && userId != _myUserId) {
        resetUnreadCount(userId);
      } else if (withUserId.isNotEmpty && withUserId != _myUserId) {
        resetUnreadCount(withUserId);
      }
    };

    if (_newMessageHandler != null) {
      _socket.addNewMessageListener(_newMessageHandler!);
    }
    if (_userStatusHandler != null) {
      _socket.addUserStatusListener(_userStatusHandler!);
    }
    if (_readStatusHandler != null) {
      _socket.addReadStatusListener(_readStatusHandler!);
    }
    if (_messageSeenHandler != null) {
      _socket.addMessageSeenListener(_messageSeenHandler!);
    }

    _listenersAttached = true;
    log('MessagesVM: ✅ All listeners registered');
  }

  void _detachSocketListeners() {
    if (!_listenersAttached) return;

    log('MessagesVM: 🗑️ Detaching socket listeners');

    if (_newMessageHandler != null) {
      _socket.removeNewMessageListener(_newMessageHandler!);
    }
    if (_userStatusHandler != null) {
      _socket.removeUserStatusListener(_userStatusHandler!);
    }
    if (_readStatusHandler != null) {
      _socket.removeReadStatusListener(_readStatusHandler!);
    }
    if (_messageSeenHandler != null) {
      _socket.removeMessageSeenListener(_messageSeenHandler!);
    }

    _newMessageHandler = null;
    _userStatusHandler = null;
    _readStatusHandler = null;
    _messageSeenHandler = null;

    _listenersAttached = false;
    log('MessagesVM: ✅ Listeners detached and nullified');
  }

  String _getMessagePreview(ChatMessageModel msg) {
    switch (msg.type) {
      case ChatMessageType.text:
        return msg.content;
      case ChatMessageType.image:
        return '📷 Photo';
      case ChatMessageType.audio:
        return '🎤 Voice message';
    }
  }

  void updateChatMessage(
    String userId,
    String message,
    DateTime sentAt, {
    bool incrementUnread = false,
  }) {
    log('MessagesVM: 🔄 updateChatMessage for $userId');
    final index = _chats.indexWhere((chat) => chat.id == userId);

    if (index != -1) {
      final currentChat = _chats[index];
      final newUnreadCount = incrementUnread
          ? currentChat.unreadCount + 1
          : currentChat.unreadCount;

      final updatedChat = currentChat.copyWith(
        lastMessage: message,
        sentAt: sentAt,
        unreadCount: newUnreadCount,
      );

      _chats.removeAt(index);
      _chats.insert(0, updatedChat);
      log('MessagesVM: ✅ Updated & moved to top (unread: ${updatedChat.unreadCount})');
      notifyListeners();
    } else {
      log('MessagesVM: ⚠️ Chat not found for userId: $userId, refreshing');
      fetchRecentChats(refresh: true);
    }
  }

  void resetUnreadCount(String userId) {
    final index = _chats.indexWhere((chat) => chat.id == userId);

    if (index != -1 && _chats[index].unreadCount > 0) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      log('MessagesVM: ✅ Reset unread for $userId → 0');
      notifyListeners();
    }
  }

  void forceResetUnreadCount(String userId) {
    final index = _chats.indexWhere((chat) => chat.id == userId);

    if (index != -1 && _chats[index].unreadCount != 0) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      log('MessagesVM: ✅ FORCE reset unread for $userId → 0');
      notifyListeners();
    }
  }

  int get totalUnreadCount {
    return _chats.fold(0, (sum, chat) => sum + chat.unreadCount);
  }

  void updateOnlineStatus(String userId, bool isOnline) {
    final index = _chats.indexWhere((chat) => chat.id == userId);

    if (index != -1 && _chats[index].isOnline != isOnline) {
      _chats[index] = _chats[index].copyWith(isOnline: isOnline);
      log('MessagesVM: ✅ Online status: $userId = ${isOnline ? "ONLINE" : "OFFLINE"}');
      notifyListeners();
    }
  }

  void removeChat(String userId) {
    final before = _chats.length;
    _chats.removeWhere((chat) => chat.id == userId);
    if (_chats.length < before) {
      _totalCount--;
      notifyListeners();
    }
  }

  void addNewChat(RecentChatUser chat) {
    final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
    if (existingIndex != -1) _chats.removeAt(existingIndex);
    _chats.insert(0, chat);
    if (existingIndex == -1) _totalCount++;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('404')) {
      return 'No chats found.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    log('MessagesVM: 🔄 Resetting...');
    _detachSocketListeners();
    _chats = [];
    _currentPage = 1;
    _hasNext = false;
    _totalCount = 0;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
    _myUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    log('MessagesVM: 🗑️ Disposing');
    _detachSocketListeners();
    super.dispose();
  }
}
