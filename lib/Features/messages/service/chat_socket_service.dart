import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketEvents {
  static const String joinUserRoom = 'joinUserRoom';
  static const String privateMessage = 'privateMessage';
  static const String newMessage = 'newMessage';
  static const String userTyping = 'userTyping';
  static const String userStopTyping = 'userStopTyping';
  static const String readStatusUpdated = 'readStatusUpdated';
  static const String messageSeen = 'messageSeen';
  static const String messageSeenUpdated = 'messageSeenUpdated';
  static const String userStatusChanged = 'userStatusChanged';
  static const String errorMessage = 'errorMessage';
  static const String typing = 'typing';
  static const String stopTyping = 'stopTyping';
  static const String messageRead = 'messageRead';

  // ✅ NEW EVENTS
  static const String chatBlocked = 'chatBlocked';
  static const String hostMessage = 'hostMessage';
  static const String hostTyping = 'hostTyping';
  static const String hostStopTyping = 'hostStopTyping';
  static const String hostMessageRead = 'hostMessageRead';
}

class ChatSocketService {
  static ChatSocketService? _instance;
  ChatSocketService._();

  static ChatSocketService get instance {
    _instance ??= ChatSocketService._();
    return _instance!;
  }

  IO.Socket? _socket;
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _currentUserId;

  // Listener lists
  final List<void Function(Map<String, dynamic> data)> _newMessageListeners =
      [];
  final List<void Function(Map<String, dynamic> data)> _userTypingListeners =
      [];
  final List<void Function(Map<String, dynamic> data)>
      _userStopTypingListeners = [];
  final List<void Function(Map<String, dynamic> data)> _readStatusListeners =
      [];
  final List<void Function(Map<String, dynamic> data)> _messageSeenListeners =
      [];
  final List<void Function(Map<String, dynamic> data)> _userStatusListeners =
      [];
  final List<void Function(Map<String, dynamic> data)> _errorListeners = [];

  // ✅ NEW: Additional event listeners
  final List<void Function(Map<String, dynamic> data)> _chatBlockedListeners =
      [];
  final List<void Function(Map<String, dynamic> data)> _hostMessageListeners =
      [];
  final List<void Function(Map<String, dynamic> data)> _hostTypingListeners =
      [];
  final List<void Function(Map<String, dynamic> data)>
      _hostStopTypingListeners = [];
  final List<void Function(Map<String, dynamic> data)>
      _hostMessageReadListeners = [];

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    if (_isInitialized && _isConnected) {
      log('ChatSocket: ✅ Already connected, skipping re-init');
      return;
    }

    await LoggedInUser.getUserDetails();
    _currentUserId = LoggedInUser.id;

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      log('ChatSocket: ❌ userId not found');
      return;
    }

    if (_socket != null) {
      log('ChatSocket: ♻️ Socket already exists, reusing connection');
      if (!_isConnected) {
        _socket!.connect();
      }
      return;
    }

    log('ChatSocket: 🔌 Creating new socket connection');

    _socket = IO.io(
      AppUrl.socketUrl,
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
      },
    );

    _socket!.onConnect((_) {
      log('ChatSocket: ✅ Connected');
      _isConnected = true;
      _joinUserRoom();
      _setupListeners();
    });

    _socket!.onDisconnect((_) {
      log('ChatSocket: ❌ Disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((e) {
      log('ChatSocket: ⚠️ Connect error: $e');
      _isConnected = false;
    });

    _socket!.onError((e) {
      log('ChatSocket: ⚠️ Error: $e');
    });

    _socket!.onReconnect((attemptNumber) {
      log('ChatSocket: 🔄 Reconnected (attempt $attemptNumber)');
      _isConnected = true;
      _joinUserRoom();
    });

    _isInitialized = true;
  }

  void _joinUserRoom() {
    if (!_isConnected || _currentUserId == null) return;
    log('ChatSocket: 🚪 Joining user room: $_currentUserId');
    _socket!.emit(ChatSocketEvents.joinUserRoom, {"data": _currentUserId});
  }

  void _setupListeners() {
    if (_socket == null) return;

    // Remove old socket listeners
    _socket!
      ..off(ChatSocketEvents.newMessage)
      ..off(ChatSocketEvents.userTyping)
      ..off(ChatSocketEvents.userStopTyping)
      ..off(ChatSocketEvents.readStatusUpdated)
      ..off(ChatSocketEvents.messageSeen)
      ..off(ChatSocketEvents.userStatusChanged)
      ..off(ChatSocketEvents.errorMessage)
      ..off(ChatSocketEvents.chatBlocked)
      ..off(ChatSocketEvents.hostMessage)
      ..off(ChatSocketEvents.hostTyping)
      ..off(ChatSocketEvents.hostStopTyping)
      ..off(ChatSocketEvents.hostMessageRead);

    log('ChatSocket: 🔧 Setting up socket event listeners');

    _socket!.on(ChatSocketEvents.newMessage, (data) {
      log('ChatSocket: 📩 newMessage → ${_newMessageListeners.length} listeners');
      if (data is Map<String, dynamic>) {
        for (final listener in _newMessageListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in newMessage listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.userTyping, (data) {
      if (data is Map<String, dynamic>) {
        for (final listener in _userTypingListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in userTyping listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.userStopTyping, (data) {
      if (data is Map<String, dynamic>) {
        for (final listener in _userStopTypingListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in userStopTyping listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.readStatusUpdated, (data) {
      log('ChatSocket: ✅ readStatusUpdated → ${_readStatusListeners.length} listeners');
      if (data is Map<String, dynamic>) {
        for (final listener in _readStatusListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in readStatus listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.messageSeen, (data) {
      log('ChatSocket: 👁️ messageSeen → ${_messageSeenListeners.length} listeners');
      if (data is Map<String, dynamic>) {
        for (final listener in _messageSeenListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in messageSeen listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.userStatusChanged, (data) {
      log('ChatSocket: 🟢 userStatusChanged → ${_userStatusListeners.length} listeners');
      log('ChatSocket: userStatusChanged data: $data');
      if (data is Map<String, dynamic>) {
        for (final listener in _userStatusListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in userStatus listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.errorMessage, (data) {
      log('ChatSocket: ⚠️ errorMessage$data');
      if (data is Map<String, dynamic>) {
        for (final listener in _errorListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in userStatus listener: $e');
          }
        }
      }
    });

    // ✅ NEW EVENT HANDLERS
    _socket!.on(ChatSocketEvents.chatBlocked, (data) {
      log('ChatSocket: 🚫 chatBlocked → ${_chatBlockedListeners.length} listeners');
      if (data is Map<String, dynamic>) {
        for (final listener in _chatBlockedListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in chatBlocked listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.hostMessage, (data) {
      log('ChatSocket: 🏠 hostMessage → ${_hostMessageListeners.length} listeners');
      if (data is Map<String, dynamic>) {
        for (final listener in _hostMessageListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in hostMessage listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.hostTyping, (data) {
      log('ChatSocket: ⌨️ hostTyping');
      if (data is Map<String, dynamic>) {
        for (final listener in _hostTypingListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in hostTyping listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.hostStopTyping, (data) {
      log('ChatSocket: ⌨️ hostStopTyping');
      if (data is Map<String, dynamic>) {
        for (final listener in _hostStopTypingListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in hostStopTyping listener: $e');
          }
        }
      }
    });

    _socket!.on(ChatSocketEvents.hostMessageRead, (data) {
      log('ChatSocket: 👁️ hostMessageRead');
      if (data is Map<String, dynamic>) {
        for (final listener in _hostMessageReadListeners) {
          try {
            listener(data);
          } catch (e) {
            log('❌ Error in hostMessageRead listener: $e');
          }
        }
      }
    });
  }

  // Existing listener management methods...
  void addNewMessageListener(void Function(Map<String, dynamic>) callback) {
    if (!_newMessageListeners.contains(callback)) {
      _newMessageListeners.add(callback);
      log('➕ Added newMessage listener (total: ${_newMessageListeners.length})');
    }
  }

  void removeNewMessageListener(void Function(Map<String, dynamic>) callback) {
    _newMessageListeners.remove(callback);
    log('➖ Removed newMessage listener (total: ${_newMessageListeners.length})');
  }

  void addUserTypingListener(void Function(Map<String, dynamic>) callback) {
    if (!_userTypingListeners.contains(callback)) {
      _userTypingListeners.add(callback);
    }
  }

  void removeUserTypingListener(void Function(Map<String, dynamic>) callback) {
    _userTypingListeners.remove(callback);
  }

  void addUserStopTypingListener(void Function(Map<String, dynamic>) callback) {
    if (!_userStopTypingListeners.contains(callback)) {
      _userStopTypingListeners.add(callback);
    }
  }

  void removeUserStopTypingListener(
      void Function(Map<String, dynamic>) callback) {
    _userStopTypingListeners.remove(callback);
  }

  void addReadStatusListener(void Function(Map<String, dynamic>) callback) {
    if (!_readStatusListeners.contains(callback)) {
      _readStatusListeners.add(callback);
      log('➕ Added readStatus listener (total: ${_readStatusListeners.length})');
    }
  }

  void removeReadStatusListener(void Function(Map<String, dynamic>) callback) {
    _readStatusListeners.remove(callback);
    log('➖ Removed readStatus listener (total: ${_readStatusListeners.length})');
  }

  void addMessageSeenListener(void Function(Map<String, dynamic>) callback) {
    if (!_messageSeenListeners.contains(callback)) {
      _messageSeenListeners.add(callback);
      log('➕ Added messageSeen listener (total: ${_messageSeenListeners.length})');
    }
  }

  void removeMessageSeenListener(void Function(Map<String, dynamic>) callback) {
    _messageSeenListeners.remove(callback);
  }

  void addUserStatusListener(void Function(Map<String, dynamic>) callback) {
    if (!_userStatusListeners.contains(callback)) {
      _userStatusListeners.add(callback);
      log('➕ Added userStatus listener (total: ${_userStatusListeners.length})');
    }
  }

  void removeUserStatusListener(void Function(Map<String, dynamic>) callback) {
    _userStatusListeners.remove(callback);
  }

  void addErrorListener(void Function(Map<String, dynamic>) callback) {
    if (!_errorListeners.contains(callback)) {
      _errorListeners.add(callback);
    }
  }

  void removeErrorListener(void Function(Map<String, dynamic>) callback) {
    _errorListeners.remove(callback);
  }

  // ✅ NEW: Additional listener management
  void addChatBlockedListener(void Function(Map<String, dynamic>) callback) {
    if (!_chatBlockedListeners.contains(callback)) {
      _chatBlockedListeners.add(callback);
      log('➕ Added chatBlocked listener');
    }
  }

  void removeChatBlockedListener(void Function(Map<String, dynamic>) callback) {
    _chatBlockedListeners.remove(callback);
  }

  void addHostMessageListener(void Function(Map<String, dynamic>) callback) {
    if (!_hostMessageListeners.contains(callback)) {
      _hostMessageListeners.add(callback);
      log('➕ Added hostMessage listener');
    }
  }

  void removeHostMessageListener(void Function(Map<String, dynamic>) callback) {
    _hostMessageListeners.remove(callback);
  }

  void addHostTypingListener(void Function(Map<String, dynamic>) callback) {
    if (!_hostTypingListeners.contains(callback)) {
      _hostTypingListeners.add(callback);
    }
  }

  void removeHostTypingListener(void Function(Map<String, dynamic>) callback) {
    _hostTypingListeners.remove(callback);
  }

  void addHostStopTypingListener(void Function(Map<String, dynamic>) callback) {
    if (!_hostStopTypingListeners.contains(callback)) {
      _hostStopTypingListeners.add(callback);
    }
  }

  void removeHostStopTypingListener(
      void Function(Map<String, dynamic>) callback) {
    _hostStopTypingListeners.remove(callback);
  }

  void addHostMessageReadListener(
      void Function(Map<String, dynamic>) callback) {
    if (!_hostMessageReadListeners.contains(callback)) {
      _hostMessageReadListeners.add(callback);
    }
  }

  void removeHostMessageReadListener(
      void Function(Map<String, dynamic>) callback) {
    _hostMessageReadListeners.remove(callback);
  }

  // Emit methods
  void sendPrivateMessage({
    required String receiverId,
    required String type,
    required String content,
    required String mediaUrl,
  }) {
    // Read the access token live so messages sent after a refresh carry the
    // fresh token — no reconnect needed (token is per-message, not per-connection).
    final accessToken = LoggedInUser.accessToken;
    if (!_isConnected || _currentUserId == null || accessToken == null) {
      log('ChatSocket: ⚠️ Cannot send (not connected)');
      return;
    }

    _socket!.emit(ChatSocketEvents.privateMessage, {
      "senderId": _currentUserId,
      "receiverId": receiverId,
      "type": type,
      "content": content,
      "mediaUrl": mediaUrl,
      "token": accessToken,
    });
  }

  void sendTyping({required String receiverId}) {
    if (!_isConnected || _currentUserId == null) return;
    _socket!.emit(ChatSocketEvents.typing, {
      "senderId": _currentUserId,
      "receiverId": receiverId,
    });
  }

  void sendStopTyping({required String receiverId}) {
    if (!_isConnected || _currentUserId == null) return;
    _socket!.emit(ChatSocketEvents.stopTyping, {
      "senderId": _currentUserId,
      "receiverId": receiverId,
    });
  }

  void sendMessageRead({required String withUserId}) {
    if (!_isConnected || _currentUserId == null) return;
    log('ChatSocket: ✅ Marking as read: $withUserId');
    _socket!.emit(ChatSocketEvents.messageRead, {
      "userId": _currentUserId,
      "withUserId": withUserId,
    });
  }

  void sendMessageSeen({required String withUserId}) {
    if (!_isConnected || _currentUserId == null) return;
    log('ChatSocket: 👁️ Marking as seen: $withUserId');
    _socket!.emit(ChatSocketEvents.messageSeenUpdated, {
      "userId": _currentUserId,
      "withUserId": withUserId,
    });
  }

  // ✅ NEW: Force reconnect (for subscription unlock)
  Future<void> forceReconnect() async {
    log('ChatSocket: 🔄 Force reconnecting...');

    if (_socket != null) {
      _socket!.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
      _socket!.connect();
    } else {
      await initialize();
    }
  }

  void dispose() {
    log('ChatSocket: 🗑️ Disposing socket service');
    _socket?.dispose();
    _socket = null;
    _isInitialized = false;
    _isConnected = false;

    _newMessageListeners.clear();
    _userTypingListeners.clear();
    _userStopTypingListeners.clear();
    _readStatusListeners.clear();
    _messageSeenListeners.clear();
    _userStatusListeners.clear();
    _errorListeners.clear();
    _chatBlockedListeners.clear();
    _hostMessageListeners.clear();
    _hostTypingListeners.clear();
    _hostStopTypingListeners.clear();
    _hostMessageReadListeners.clear();
  }
}
