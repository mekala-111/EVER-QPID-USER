// lib/features/messages/model/chat_model.dart

class RecentChatUser {
  final String id;
  final String lastMessage;
  final DateTime sentAt;
  final String name;
  final String profileImageUrl;
  final bool isOnline;
  final String gender;
  final bool isBlock;
  final bool isOppositeBlock;
  final int unreadCount;

  RecentChatUser({
    required this.id,
    required this.lastMessage,
    required this.sentAt,
    required this.name,
    required this.profileImageUrl,
    required this.isOnline,
    required this.gender,
    required this.isBlock,
    required this.isOppositeBlock,
    this.unreadCount = 0,
  });

  factory RecentChatUser.fromJson(Map<String, dynamic> json) {
    final userDetails = json['userDetails'] as Map<String, dynamic>? ?? {};

    return RecentChatUser(
      id: json['withUserId']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '',
      sentAt:
          DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
      name: userDetails['name']?.toString() ?? 'Unknown',
      profileImageUrl: userDetails['profileImageUrl']?.toString() ?? '',
      isOnline: userDetails['isOnline'] == true,
      gender: userDetails['gender']?.toString() ?? '',
      isBlock: json['isBlock'] == true,
      isOppositeBlock: json['isOppositeBlock'] == true,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'withUserId': id,
      'lastMessage': lastMessage,
      'sentAt': sentAt.toIso8601String(),
      'userDetails': {
        'name': name,
        'profileImageUrl': profileImageUrl,
        'isOnline': isOnline,
        'gender': gender,
      },
      'isBlock': isBlock,
      'isOppositeBlock': isOppositeBlock,
      'unreadCount': unreadCount,
    };
  }

  RecentChatUser copyWith({
    String? id,
    String? lastMessage,
    DateTime? sentAt,
    String? name,
    String? profileImageUrl,
    bool? isOnline,
    String? gender,
    bool? isBlock,
    bool? isOppositeBlock,
    int? unreadCount,
  }) {
    return RecentChatUser(
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      sentAt: sentAt ?? this.sentAt,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnline: isOnline ?? this.isOnline,
      gender: gender ?? this.gender,
      isBlock: isBlock ?? this.isBlock,
      isOppositeBlock: isOppositeBlock ?? this.isOppositeBlock,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class RecentChatsResponse {
  final bool status;
  final int statusCode;
  final String message;
  final List<RecentChatUser> chats;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool hasNext;

  RecentChatsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.chats,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNext,
  });

  factory RecentChatsResponse.fromJson(Map<String, dynamic> json) {
    final outerData = json['data'] as Map<String, dynamic>? ?? {};
    final chatList = outerData['data'] as List<dynamic>? ?? [];

    return RecentChatsResponse(
      status: json['status'] == true,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message']?.toString() ?? '',
      chats: chatList
          .map((e) => RecentChatUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: outerData['totalCount'] as int? ?? 0,
      pageNumber: outerData['pageNumber'] as int? ?? 1,
      pageSize: outerData['pageSize'] as int? ?? 10,
      hasNext: outerData['hasNext'] == true,
    );
  }
}

enum ChatMessageType { text, image, audio }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final ChatMessageType type;
  final String content;
  final String mediaUrl;
  final bool isRead;
  // final bool isSeen; // ✅ NEW: For purple double tick
  final DateTime sentAt;
  final DateTime createdAt;
  final List<String>? deletedBy;

  bool get isSentByMe => senderId == myUserId;
  static String myUserId = '';

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.mediaUrl,
    required this.isRead,
    // this.isSeen = false, // ✅ NEW: Default false
    required this.sentAt,
    DateTime? createdAt,
    this.deletedBy,
  }) : createdAt = createdAt ?? sentAt;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final messageContent =
        json['content']?.toString() ?? json['message']?.toString() ?? '';

    final typeString = json['type']?.toString().toLowerCase() ?? '';
    final hasImage = (json['imageUrl'] ?? '').toString().isNotEmpty;

    ChatMessageType messageType;
    if (typeString == 'image' || hasImage) {
      messageType = ChatMessageType.image;
    } else if (typeString == 'audio') {
      messageType = ChatMessageType.audio;
    } else {
      messageType = ChatMessageType.text;
    }

    return ChatMessageModel(
      id: json['_id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      type: messageType,
      content: messageContent,
      mediaUrl:
          json['mediaUrl']?.toString() ?? json['imageUrl']?.toString() ?? '',
      isRead: json['isRead'] == true,
      // isSeen: json['isSeen'] == true, // ✅ NEW: Parse from backend
      sentAt:
          DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      deletedBy: json['deletedBy'] != null
          ? List<String>.from(json['deletedBy'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'content': content,
      'mediaUrl': mediaUrl,
      'imageUrl': mediaUrl,
      'message': content,
      'isRead': isRead,
      // 'isSeen': isSeen, // ✅ NEW: Include in JSON
      'sentAt': sentAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'deletedBy': deletedBy,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    ChatMessageType? type,
    String? content,
    String? mediaUrl,
    bool? isRead,
    // bool? isSeen, // ✅ NEW: Can be updated
    DateTime? sentAt,
    DateTime? createdAt,
    List<String>? deletedBy,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      // isSeen: isSeen ?? this.isSeen, // ✅ NEW
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }
}

class ChatHistoryResponse {
  final bool status;
  final int statusCode;
  final String message;
  final List<ChatMessageModel> messages;
  final int totalCount;
  final bool hasNext;
  final bool isMatch;
  final bool isBlock;
  final bool isOppositeBlock;

  ChatHistoryResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.messages,
    required this.totalCount,
    required this.hasNext,
    required this.isMatch,
    required this.isBlock,
    required this.isOppositeBlock,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final messagesList = data['messages'] as List<dynamic>? ?? [];

    return ChatHistoryResponse(
      status: json['status'] == true,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message']?.toString() ?? '',
      messages: messagesList
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: data['totalCount'] as int? ?? 0,
      hasNext: data['hasNext'] == true,
      isMatch: data['isMatch'] == true,
      isBlock: data['isBlock'] == true,
      isOppositeBlock: data['isOppositeBlock'] == true,
    );
  }
}
