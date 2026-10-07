import 'package:everqpidapp/Features/matches/model/received_like_profile_model.dart';

class ReceivedLikesResponse {
  final int statusCode; // Default status code
  // final Map<String, dynamic> data; // Default data
  final List<ReceivedLikeProfile> receivedProfiles;
  final bool hasNext;
  final int totalCount;
  final bool isSubscribed;

  ReceivedLikesResponse({
    required this.statusCode, // Default status code
    // required this.data, // Default data
    required this.receivedProfiles,
    required this.hasNext,
    required this.totalCount,
    required this.isSubscribed,
  });

  factory ReceivedLikesResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedLikesResponse(
      statusCode: json['statusCode'] ?? 0, // Default status code
      // data: json['data'] ?? {}, // Default data
      receivedProfiles: (json['data']['receivedProfiles'] as List)
          .map((e) => ReceivedLikeProfile.fromJson(e))
          .toList(),
      hasNext: json['data']['hasNext'] ?? false,
      totalCount: json['data']['totalCount'] ?? 0,
      isSubscribed: json['data']['isSubscribed'] ?? false,
    );
  }
}
