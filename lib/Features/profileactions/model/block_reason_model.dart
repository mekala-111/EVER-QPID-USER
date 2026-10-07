class BlockedUser {
  final String id;
  final BlockedAccount blockedAccount;
  final String blockedBy;
  final String dateBlocked;
  final List<String> selectedReasons;
  final String createdAt;

  BlockedUser({
    required this.id,
    required this.blockedAccount,
    required this.blockedBy,
    required this.dateBlocked,
    required this.selectedReasons,
    required this.createdAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['_id'] ?? '',
      blockedAccount: BlockedAccount.fromJson(json['blockedAccount'] ?? {}),
      blockedBy: json['blockedBy'] ?? '',
      dateBlocked: json['dateBlocked'] ?? '',
      selectedReasons: List<String>.from(json['selectedReasons'] ?? []),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class BlockedAccount {
  final String id;
  final String fullName;
  final String profileImageUrl;

  BlockedAccount({
    required this.id,
    required this.fullName,
    required this.profileImageUrl,
  });

  factory BlockedAccount.fromJson(Map<String, dynamic> json) {
    return BlockedAccount(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

class BlockedUsersResponse {
  final bool status;
  final int statusCode;
  final String message;
  final List<BlockedUser> blockedUsers;
  final bool hasNext;
  final int totalCount;

  BlockedUsersResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.blockedUsers,
    required this.hasNext,
    required this.totalCount,
  });

  factory BlockedUsersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return BlockedUsersResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      blockedUsers: (data?['blockedUsers'] as List?)
              ?.map((item) => BlockedUser.fromJson(item))
              .toList() ??
          [],
      hasNext: data?['hasNext'] ?? false,
      totalCount: data?['totalCount'] ?? 0,
    );
  }
}

// Predefined block reasons
class BlockReasons {
  static const List<String> reasons = [
    'Inappropriate behavior',
    'Offensive language',
    'Unwanted contact',
    'Not what I expected',
    'Privacy concerns',
    'Other',
  ];
}
