// Models for Contacts API

class ImportContactsRequest {
  final String loginUserId;
  final List<String> contacts;

  ImportContactsRequest({
    required this.loginUserId,
    required this.contacts,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginUserId': loginUserId,
      'contacts': contacts,
    };
  }
}

class ImportContactsResponse {
  final bool status;
  final int statusCode;
  final String message;
  final ImportContactsData? data;

  ImportContactsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ImportContactsResponse.fromJson(Map<String, dynamic> json) {
    return ImportContactsResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ImportContactsData.fromJson(json['data'])
          : null,
    );
  }
}

class ImportContactsData {
  final List<String> hiddenContacts;

  ImportContactsData({required this.hiddenContacts});

  factory ImportContactsData.fromJson(Map<String, dynamic> json) {
    return ImportContactsData(
      hiddenContacts: json['hiddenContacts'] != null
          ? List<String>.from(json['hiddenContacts'])
          : [],
    );
  }
}

class GetHiddenContactsResponse {
  final bool status;
  final int statusCode;
  final String message;
  final GetHiddenContactsData? data;

  GetHiddenContactsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory GetHiddenContactsResponse.fromJson(Map<String, dynamic> json) {
    return GetHiddenContactsResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? GetHiddenContactsData.fromJson(json['data'])
          : null,
    );
  }
}

class GetHiddenContactsData {
  final List<String> hiddenContacts;

  GetHiddenContactsData({required this.hiddenContacts});

  factory GetHiddenContactsData.fromJson(Map<String, dynamic> json) {
    return GetHiddenContactsData(
      hiddenContacts: json['hiddenContacts'] != null
          ? List<String>.from(json['hiddenContacts'])
          : [],
    );
  }
}

class RemoveHiddenContactsRequest {
  final String loginUserId;
  final List<String> contacts;

  RemoveHiddenContactsRequest({
    required this.loginUserId,
    required this.contacts,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginUserId': loginUserId,
      'contacts': contacts,
    };
  }
}

class RemoveHiddenContactsResponse {
  final bool status;
  final int statusCode;
  final String message;
  final RemoveHiddenContactsData? data;

  RemoveHiddenContactsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory RemoveHiddenContactsResponse.fromJson(Map<String, dynamic> json) {
    return RemoveHiddenContactsResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RemoveHiddenContactsData.fromJson(json['data'])
          : null,
    );
  }
}

class RemoveHiddenContactsData {
  final List<String> getHiddenContacts;

  RemoveHiddenContactsData({required this.getHiddenContacts});

  factory RemoveHiddenContactsData.fromJson(Map<String, dynamic> json) {
    return RemoveHiddenContactsData(
      getHiddenContacts: json['getHiddenContacts'] != null
          ? List<String>.from(json['getHiddenContacts'])
          : [],
    );
  }
}

// Helper model for displaying contacts in UI
class ContactItem {
  final String phoneNumber;
  final String? displayName;
  final bool isHidden;

  ContactItem({
    required this.phoneNumber,
    this.displayName,
    this.isHidden = false,
  });

  ContactItem copyWith({
    String? phoneNumber,
    String? displayName,
    bool? isHidden,
  }) {
    return ContactItem(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
