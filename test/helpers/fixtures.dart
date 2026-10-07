/// Shared JSON fixtures for repository / ViewModel tests.
class Fixtures {
  static Map<String, dynamic> ok([Map<String, dynamic>? data]) => {
        'status': true,
        'statusCode': 200,
        'message': 'ok',
        'data': data ?? <String, dynamic>{},
      };

  static Map<String, dynamic> profileData() => {
        'userProfile': {
          '_id': 'u1',
          'fullName': 'Test User',
          'email': 't@example.com',
          'mobileNumber': '9999999999',
          'profilePhotos': <String>[],
          'isVerified': false,
          'customerStatus': 'active',
          'isActive': true,
        },
      };

  static Map<String, dynamic> discoveryData() => {
        'users': [
          {
            '_id': 'p1',
            'fullName': 'Alex',
            'age': 28,
            'education': 'BSc',
            'aboutMe': 'hi',
            'profileImageUrl': '',
            'interests': <String>[],
            'otherLanguages': <String>[],
            'profilePhotos': <String>[],
            'isVerified': true,
            'locationString': 'Kochi',
            'religion': '',
            'height': 170,
            'relationshipStatus': '',
            'zodiacSign': '',
            'smokingHabit': '',
            'alcoholConsumption': '',
            'workoutFrequency': '',
          },
        ],
        'hasNext': false,
        'totalCount': 1,
      };

  static Map<String, dynamic> subscriptionsData() => {
        'subscriptions': [
          {
            '_id': 'plan1',
            'planName': 'Monthly',
            'price': 499,
            'sellingPrice': 399,
            'features': [
              {'_id': 'f1', 'feature': 'Unlimited likes'},
            ],
            'durationValue': 1,
            'durationUnit': 'months',
            'unlimitedLikes': true,
            'seeWhoLikesYou': true,
            'isSubscribed': false,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ],
        'hasNext': false,
        'totalCount': 1,
      };

  static Map<String, dynamic> recentChats() => {
        'status': true,
        'statusCode': 200,
        'message': 'ok',
        'data': {
          'data': <Map<String, dynamic>>[],
          'hasNext': false,
          'totalCount': 0,
          'pageNumber': 1,
          'pageSize': 10,
        },
      };

  static Map<String, dynamic> chatHistory() => {
        'status': true,
        'statusCode': 200,
        'message': 'ok',
        'data': {
          'messages': <Map<String, dynamic>>[],
          'totalCount': 0,
          'hasNext': false,
          'isMatch': true,
          'isBlock': false,
          'isOppositeBlock': false,
        },
      };

  static Map<String, dynamic> emailOtpSent() => {
        'status': true,
        'statusCode': 200,
        'message': 'OTP sent',
      };

  static Map<String, dynamic> likeMatch() => {
        'status': true,
        'statusCode': 200,
        'message': 'liked',
        'data': {'isMatch': true},
      };

  static Map<String, dynamic> clanProfiles() => {
        'profiles': <Map<String, dynamic>>[],
        'isSubscribed': true,
        'totalCount': 0,
        'totalPages': 0,
        'currentPage': 1,
      };
}
