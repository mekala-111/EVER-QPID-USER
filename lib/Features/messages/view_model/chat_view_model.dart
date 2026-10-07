import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Data/services/performance_monitor.dart';
import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Features/messages/model/other_user_profile_model.dart';
import 'package:everqpidapp/Features/messages/repository/chat_repository.dart';
import 'package:everqpidapp/Features/messages/service/chat_socket_service.dart';
import 'package:everqpidapp/Features/messages/service/message_local_storage.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();
  final ChatSocketService _socket = ChatSocketService.instance;
  final MessageLocalStorage _localStorage = MessageLocalStorage();

  String? myUserId;
  String receiverId = '';
  String receiverName = '';
  String receiverImage = '';
  bool isReceiverOnline = false;
  DateTime? lastActive;

  bool isLoadingHistory = false;
  bool isSending = false;
  bool isTyping = false;

  bool isSubscriptionRestricted = false;
  String subscriptionErrorMessage = 'Please subscribe to continue chatting';

  List<ChatMessageModel> messages = [];

  bool isMatch = false;
  bool isBlock = false;
  bool isOppositeBlock = false;

  void Function()? onScrollToBottom;

  // Handler references
  void Function(Map<String, dynamic>)? _newMessageHandler;
  void Function(Map<String, dynamic>)? _userTypingHandler;
  void Function(Map<String, dynamic>)? _userStopTypingHandler;
  void Function(Map<String, dynamic>)? _readStatusHandler;
  void Function(Map<String, dynamic>)? _messageSeenHandler;
  void Function(Map<String, dynamic>)? _userStatusHandler;
  void Function(Map<String, dynamic>)? _errorHandler;
  void Function(Map<String, dynamic>)? _chatBlockedHandler;
  void Function(Map<String, dynamic>)? _hostMessageHandler;
  void Function(Map<String, dynamic>)? _hostTypingHandler;
  void Function(Map<String, dynamic>)? _hostStopTypingHandler;

  bool _listenersAttached = false;
  bool _isInitialized = false;
  bool _isChatVisible = true;

  // ✅ NEW: Debounce timer for read status
  Timer? _readStatusDebounce;

  Future<void> initChat({
    required String receiverId,
    required String name,
    required String imageUrl,
    required bool isOnline,
  }) async {
    log('ChatVM: 🚀 initChat called for receiverId: $receiverId');

    if (_isInitialized && this.receiverId != receiverId) {
      log('ChatVM: 🔄 Different chat detected, cleaning up previous session');
      _detachSocketListeners();
      messages.clear();
      _isInitialized = false;
    }

    this.receiverId = receiverId;
    receiverName = name;
    receiverImage = imageUrl;
    isReceiverOnline = isOnline;

    await LoggedInUser.getUserDetails();
    myUserId = LoggedInUser.id;
    ChatMessageModel.myUserId = myUserId ?? '';

    log('ChatVM: 💬 Initialized (myId: $myUserId, receiverId: $receiverId)');
    AnalyticsService.instance.logChatOpened();
    PerformanceMonitor.instance.start('chat_load');

    await _socket.initialize();
    _attachSocketListeners();

    await fetchHistory();
    await PerformanceMonitor.instance.stop('chat_load', toCrashlytics: true);

    // ✅ CRITICAL: Mark as read AFTER messages load
    Future.delayed(const Duration(milliseconds: 500), () {
      _markAllMessagesAsReadAndSeen();
    });

    _isChatVisible = true;
    _isInitialized = true;
  }

  void _markAllMessagesAsReadAndSeen() {
    if (!_isChatVisible) return;

    log('ChatVM: 📖 Marking all messages as read & seen');

    // Debounce to avoid multiple rapid calls
    _readStatusDebounce?.cancel();
    _readStatusDebounce = Timer(const Duration(milliseconds: 300), () {
      _socket.sendMessageRead(withUserId: receiverId);
      _socket.sendMessageSeen(withUserId: receiverId);

      // Update local state
      bool hasUnreadMessages = messages.any(
        (msg) => msg.receiverId == myUserId && !msg.isRead,
      );

      if (hasUnreadMessages) {
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].receiverId == myUserId && !messages[i].isRead) {
            messages[i] = messages[i].copyWith(isRead: true);
          }
        }
        _localStorage.markMessagesAsSeen(receiverId, receiverId);
        notifyListeners();
        log('ChatVM: ✅ Local messages marked as read');
      }
    });
  }

  void _attachSocketListeners() {
    if (_listenersAttached) {
      log('ChatVM: ⚠️ Listeners already attached, skipping');
      return;
    }

    log('ChatVM: 🔧 Creating new handler functions');

    _newMessageHandler = (data) {
      log('ChatVM: 📩 NEW MESSAGE EVENT');
      try {
        final msg = ChatMessageModel.fromJson(data);

        if ((msg.senderId == receiverId && msg.receiverId == myUserId) ||
            (msg.senderId == myUserId && msg.receiverId == receiverId)) {
          final isDuplicate = messages.any((m) => m.id == msg.id);
          if (!isDuplicate) {
            messages.add(msg);
            _localStorage.appendMessage(receiverId, msg);

            log('ChatVM: ✅ Message added: ${msg.content}');
            notifyListeners();

            Future.delayed(const Duration(milliseconds: 150), () {
              onScrollToBottom?.call();
            });

            // ✅ CRITICAL: Send read status for incoming messages
            if (msg.senderId == receiverId && _isChatVisible) {
              log('ChatVM: 👁️ Auto-sending read status for new message');
              Future.delayed(const Duration(milliseconds: 500), () {
                _socket.sendMessageRead(withUserId: receiverId);
                _socket.sendMessageSeen(withUserId: receiverId);
              });
            }
          }
        }
      } catch (e) {
        log('ChatVM: ❌ Error in newMessage: $e');
      }
    };

    _userTypingHandler = (data) {
      final senderId = data['senderId'] ?? '';
      if (senderId == receiverId) {
        isTyping = true;
        notifyListeners();
      }
    };

    _userStopTypingHandler = (data) {
      final senderId = data['senderId'] ?? '';
      if (senderId == receiverId) {
        isTyping = false;
        notifyListeners();
      }
    };

    // ✅ FIXED: Correct read status handling
    _readStatusHandler = (data) {
      log('ChatVM: ✅ READ STATUS UPDATED EVENT');
      log('ChatVM: 📊 Raw data: $data');

      final userId = data['userId']?.toString() ?? '';
      final withUserId = data['withUserId']?.toString() ?? '';

      log('ChatVM: 📊 userId (who read): $userId');
      log('ChatVM: 📊 withUserId (chat partner): $withUserId');
      log('ChatVM: 📊 myUserId: $myUserId');
      log('ChatVM: 📊 receiverId: $receiverId');

      // ✅ CRITICAL FIX: Check if the other user read MY messages
      // If userId == receiverId, it means the receiver read my messages
      if (userId == receiverId) {
        log(
          'ChatVM: 🔄 Receiver read my messages → Mark sent messages as read',
        );

        bool updated = false;
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].senderId == myUserId && !messages[i].isRead) {
            messages[i] = messages[i].copyWith(isRead: true);
            updated = true;
            log('ChatVM: ✅ Marked message ${messages[i].id} as read');
          }
        }

        if (updated) {
          _localStorage.markMessagesAsRead(receiverId, myUserId!);
          log('ChatVM: ✅ Read status updated in UI');
          notifyListeners();
        }
      }
    };

    _messageSeenHandler = (data) {
      log('ChatVM: 👁️ MESSAGE SEEN EVENT');
      log('ChatVM: 📊 Data: $data');

      final userId = data['userId']?.toString() ?? '';

      // ✅ Same logic as readStatusHandler
      if (userId == receiverId) {
        log('ChatVM: 🔄 Receiver saw my messages → Purple tick');

        bool updated = false;
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].senderId == myUserId) {
            messages[i] = messages[i].copyWith(isRead: true);
            updated = true;
          }
        }

        if (updated) {
          _localStorage.markMessagesAsSeen(receiverId, myUserId!);
          log('ChatVM: 👁️ Seen status updated (purple tick)');
          notifyListeners();
        }
      }
    };

    // ✅ CRITICAL FIX: Proper online status handling
    _userStatusHandler = (data) {
      log('ChatVM: 🟢 USER STATUS CHANGED EVENT');
      log('ChatVM: 📊 Data: $data');

      final userId = data['userId']?.toString() ?? '';
      final isOnline = data['isOnline'] == true;
      final lastActiveStr = data['lastActive']?.toString();

      log('ChatVM: 🟢 userId: $userId, isOnline: $isOnline');
      log('ChatVM: 🟢 Expected receiverId: $receiverId');

      if (userId == receiverId) {
        log('ChatVM: ✅ Updating receiver online status: $isOnline');

        isReceiverOnline = isOnline;
        if (lastActiveStr != null) {
          lastActive = DateTime.tryParse(lastActiveStr);
        }

        notifyListeners();
        log('ChatVM: ✅ UI notified of status change');
      } else {
        log('ChatVM: ℹ️ Status update for different user: $userId');
      }
    };

    _errorHandler = (data) {
      log('ChatVM: ⚠️ ERROR MESSAGE - Subscription required');
      isSubscriptionRestricted = true;
      isSending = false;
      notifyListeners();
    };

    // ✅ NEW: Chat blocked handler
    _chatBlockedHandler = (data) {
      log('ChatVM: 🚫 CHAT BLOCKED EVENT');
      log('ChatVM: 📊 Data: $data');

      final blockedBy = data['blockedBy']?.toString() ?? '';
      final blockedUser = data['blockedUser']?.toString() ?? '';

      // Check if this chat is affected
      if (blockedBy == receiverId || blockedUser == receiverId) {
        isBlock = blockedBy == myUserId;
        isOppositeBlock = blockedUser == myUserId;

        log(
          'ChatVM: 🚫 Chat blocked - isBlock: $isBlock, isOppositeBlock: $isOppositeBlock',
        );
        notifyListeners();
      }
    };

    // ✅ NEW: Host message handler (admin/system messages)
    _hostMessageHandler = (data) {
      log('ChatVM: 🏠 HOST MESSAGE EVENT');
      try {
        final msg = ChatMessageModel.fromJson(data);

        // Add host message to chat
        messages.add(msg);
        _localStorage.appendMessage(receiverId, msg);

        log('ChatVM: ✅ Host message added');
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 150), () {
          onScrollToBottom?.call();
        });
      } catch (e) {
        log('ChatVM: ❌ Error in hostMessage: $e');
      }
    };

    // ✅ NEW: Host typing indicators
    _hostTypingHandler = (data) {
      log('ChatVM: ⌨️ HOST TYPING');
      // You can show "Admin is typing..." if needed
    };

    _hostStopTypingHandler = (data) {
      log('ChatVM: ⌨️ HOST STOP TYPING');
    };

    // Register all listeners
    if (_newMessageHandler != null) {
      _socket.addNewMessageListener(_newMessageHandler!);
    }
    if (_userTypingHandler != null) {
      _socket.addUserTypingListener(_userTypingHandler!);
    }
    if (_userStopTypingHandler != null) {
      _socket.addUserStopTypingListener(_userStopTypingHandler!);
    }
    if (_readStatusHandler != null) {
      _socket.addReadStatusListener(_readStatusHandler!);
    }
    if (_messageSeenHandler != null) {
      _socket.addMessageSeenListener(_messageSeenHandler!);
    }
    if (_userStatusHandler != null) {
      _socket.addUserStatusListener(_userStatusHandler!);
    }
    if (_errorHandler != null) {
      _socket.addErrorListener(_errorHandler!);
    }
    if (_chatBlockedHandler != null) {
      _socket.addChatBlockedListener(_chatBlockedHandler!);
    }
    if (_hostMessageHandler != null) {
      _socket.addHostMessageListener(_hostMessageHandler!);
    }
    if (_hostTypingHandler != null) {
      _socket.addHostTypingListener(_hostTypingHandler!);
    }
    if (_hostStopTypingHandler != null) {
      _socket.addHostStopTypingListener(_hostStopTypingHandler!);
    }

    _listenersAttached = true;
    log('ChatVM: ✅ All listeners registered');
  }

  void _detachSocketListeners() {
    if (!_listenersAttached) {
      log('ChatVM: ⚠️ No listeners to detach');
      return;
    }

    log('ChatVM: 🗑️ Detaching socket listeners');

    if (_newMessageHandler != null) {
      _socket.removeNewMessageListener(_newMessageHandler!);
    }
    if (_userTypingHandler != null) {
      _socket.removeUserTypingListener(_userTypingHandler!);
    }
    if (_userStopTypingHandler != null) {
      _socket.removeUserStopTypingListener(_userStopTypingHandler!);
    }
    if (_readStatusHandler != null) {
      _socket.removeReadStatusListener(_readStatusHandler!);
    }
    if (_messageSeenHandler != null) {
      _socket.removeMessageSeenListener(_messageSeenHandler!);
    }
    if (_userStatusHandler != null) {
      _socket.removeUserStatusListener(_userStatusHandler!);
    }
    if (_errorHandler != null) {
      _socket.removeErrorListener(_errorHandler!);
    }
    if (_chatBlockedHandler != null) {
      _socket.removeChatBlockedListener(_chatBlockedHandler!);
    }
    if (_hostMessageHandler != null) {
      _socket.removeHostMessageListener(_hostMessageHandler!);
    }
    if (_hostTypingHandler != null) {
      _socket.removeHostTypingListener(_hostTypingHandler!);
    }
    if (_hostStopTypingHandler != null) {
      _socket.removeHostStopTypingListener(_hostStopTypingHandler!);
    }

    _newMessageHandler = null;
    _userTypingHandler = null;
    _userStopTypingHandler = null;
    _readStatusHandler = null;
    _messageSeenHandler = null;
    _userStatusHandler = null;
    _errorHandler = null;
    _chatBlockedHandler = null;
    _hostMessageHandler = null;
    _hostTypingHandler = null;
    _hostStopTypingHandler = null;

    _listenersAttached = false;
    log('ChatVM: ✅ Listeners detached and nullified');
  }

  // Continue in Part 2...
  // ... Continued from Part 1

  Future<void> fetchHistory() async {
    try {
      isLoadingHistory = true;
      notifyListeners();

      final response = await _repo.getChatHistory(receiverId);

      final serverMessages = response.messages;
      final mergedMessages = <ChatMessageModel>[];

      mergedMessages.addAll(serverMessages);

      for (final localMsg in messages) {
        final existsInServer = serverMessages.any((m) => m.id == localMsg.id);
        if (!existsInServer) {
          mergedMessages.add(localMsg);
        }
      }

      mergedMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      messages = mergedMessages;
      isMatch = response.isMatch;
      isBlock = response.isBlock;
      isOppositeBlock = response.isOppositeBlock;

      log('ChatVM: ✅ Loaded ${messages.length} messages');

      isLoadingHistory = false;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 200), () {
        onScrollToBottom?.call();
      });
    } catch (e) {
      log('ChatVM: ❌ Error fetching history: $e');
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || myUserId == null) return;

    if (isSubscriptionRestricted) {
      log('ChatVM: ⚠️ Cannot send (subscription required)');
      return;
    }

    isSending = true;
    notifyListeners();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final tempMsg = ChatMessageModel(
      id: tempId,
      senderId: myUserId!,
      receiverId: receiverId,
      type: ChatMessageType.text,
      content: text.trim(),
      mediaUrl: '',
      isRead: false,
      sentAt: DateTime.now(),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      onScrollToBottom?.call();
    });

    _socket.sendPrivateMessage(
      receiverId: receiverId,
      type: 'text',
      content: text.trim(),
      mediaUrl: '',
    );

    AnalyticsService.instance.logMessageSent(type: 'text');

    await _localStorage.appendMessage(receiverId, tempMsg);

    isSending = false;
    notifyListeners();
  }

  void startTyping() {
    if (isSubscriptionRestricted) return;
    _socket.sendTyping(receiverId: receiverId);
  }

  void stopTyping() {
    _socket.sendStopTyping(receiverId: receiverId);
  }

  void markMessagesAsViewed() {
    if (!_isChatVisible) return;

    log('ChatVM: 👁️ User viewed messages (scrolled to bottom)');
    _markAllMessagesAsReadAndSeen();
  }

  Future<void> sendImageMessage(String imageUrl) async {
    if (myUserId == null || isSubscriptionRestricted) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final tempMsg = ChatMessageModel(
      id: tempId,
      senderId: myUserId!,
      receiverId: receiverId,
      type: ChatMessageType.image,
      content: '',
      mediaUrl: imageUrl,
      isRead: false,
      sentAt: DateTime.now(),
    );

    await _localStorage.appendMessage(receiverId, tempMsg);
    notifyListeners();

    _socket.sendPrivateMessage(
      receiverId: receiverId,
      type: 'image',
      content: '',
      mediaUrl: imageUrl,
    );
    AnalyticsService.instance.logMessageSent(type: 'image');
  }

  Future<void> sendAudioMessage(String audioUrl) async {
    if (myUserId == null || isSubscriptionRestricted) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final tempMsg = ChatMessageModel(
      id: tempId,
      senderId: myUserId!,
      receiverId: receiverId,
      type: ChatMessageType.audio,
      content: '',
      mediaUrl: audioUrl,
      isRead: false,
      sentAt: DateTime.now(),
    );

    await _localStorage.appendMessage(receiverId, tempMsg);
    notifyListeners();

    _socket.sendPrivateMessage(
      receiverId: receiverId,
      type: 'audio',
      content: '',
      mediaUrl: audioUrl,
    );
    AnalyticsService.instance.logMessageSent(type: 'audio');

    Future.delayed(const Duration(milliseconds: 100), () {
      onScrollToBottom?.call();
    });
  }

  Future<void> uploadAndSendAudio(Uint8List bytes) async {
    if (myUserId == null || isSubscriptionRestricted) return;

    try {
      log('ChatVM: 📤 Uploading audio');

      isSending = true;
      notifyListeners();

      final audioUrl = await _repo.uploadAudioBytes(bytes);

      log('ChatVM: ✅ Audio uploaded');

      await sendAudioMessage(audioUrl);
    } catch (e) {
      log('ChatVM: ❌ Audio upload error: $e');
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> uploadAndSendImage(Uint8List bytes) async {
    if (myUserId == null || isSubscriptionRestricted) return;

    try {
      log('ChatVM: 📤 Uploading image');

      isSending = true;
      notifyListeners();

      final imageUrl = await _repo.uploadImageBytes(bytes);

      log('ChatVM: ✅ Image uploaded');

      await sendImageMessage(imageUrl);
    } catch (e) {
      log('ChatVM: ❌ Image upload error: $e');
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  // ✅ CRITICAL FIX: Proper subscription unlock
  Future<void> clearSubscriptionRestriction() async {
    log('ChatVM: 🔓 Clearing subscription restriction...');

    isSubscriptionRestricted = false;

    // ✅ Step 1: Force socket reconnect
    await _socket.forceReconnect();

    // ✅ Step 2: Re-attach listeners (they were removed on error)
    _detachSocketListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _attachSocketListeners();

    // ✅ Step 3: Refresh chat history
    await fetchHistory();

    notifyListeners();
    log('ChatVM: ✅ Subscription restriction cleared & chat resumed');
  }

  void onChatInvisible() {
    _isChatVisible = false;
    _readStatusDebounce?.cancel();
    _detachSocketListeners();
    log('ChatVM: 📴 Chat is now invisible');
  }

  void onChatVisible() {
    _isChatVisible = true;
    log('ChatVM: 📱 Chat is now visible');

    // Re-send read status when coming back
    _markAllMessagesAsReadAndSeen();
  }

  @override
  void dispose() {
    log('ChatVM: 🗑️ Disposing');
    _isChatVisible = false;
    _readStatusDebounce?.cancel();
    _detachSocketListeners();
    super.dispose();
  }

  void reset() {
    log('ChatVM: 🔄 Resetting ChatViewModel...');

    _readStatusDebounce?.cancel();
    _detachSocketListeners();

    myUserId = null;
    receiverId = '';
    receiverName = '';
    receiverImage = '';
    isReceiverOnline = false;
    lastActive = null;

    isLoadingHistory = false;
    isSending = false;
    isTyping = false;

    isSubscriptionRestricted = false;
    subscriptionErrorMessage = 'Please subscribe to continue chatting';

    messages.clear();
    messages = [];

    isMatch = false;
    isBlock = false;
    isOppositeBlock = false;

    onScrollToBottom = null;

    _isInitialized = false;
    _isChatVisible = false;

    log('ChatVM: ✅ Reset completed');

    notifyListeners();
  }

  // Add to ChatViewModel class properties
  bool isLoadingProfile = false;
  OtherProfileDetails? receiverProfile;
  String? profileError;

// Add this method
  Future<void> fetchReceiverProfile() async {
    if (receiverId.isEmpty) {
      log('ChatVM: ⚠️ Cannot fetch profile - receiverId is empty');
      return;
    }

    try {
      isLoadingProfile = true;
      profileError = null;
      notifyListeners();

      log('ChatVM: 📥 Fetching receiver profile: $receiverId');

      receiverProfile = await _repo.getProfile(profileId: receiverId);

      log('ChatVM: ✅ Receiver profile loaded');

      isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      log('ChatVM: ❌ Error fetching receiver profile: $e');
      profileError = 'Failed to load profile';
      isLoadingProfile = false;
      notifyListeners();
    }
  }
}
