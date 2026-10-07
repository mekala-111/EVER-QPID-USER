// lib/features/subscription/models/subscription_models.dart

class SubscriptionFeature {
  final String id;
  final String feature;
  // final List<String> subFeatures;

  SubscriptionFeature({
    required this.id,
    required this.feature,
    // required this.subFeatures,
  });

  factory SubscriptionFeature.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeature(
      id: json['_id']?.toString() ?? '',
      feature: json['feature']?.toString() ?? '',
      // subFeatures:
      //     (json['subFeatures'] as List<dynamic>?)
      //         ?.map((e) => e.toString())
      //         .toList() ??
      //     [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, 'feature': feature,
      // 'subFeatures': subFeatures
    };
  }
}

class SubscriptionPlan {
  final String id;
  final String planName;
  final int price;
  final int sellingPrice;
  final List<SubscriptionFeature> features;
  final int durationValue;
  final String durationUnit;
  final bool unlimitedLikes;
  final bool seeWhoLikesYou;
  final bool isSubscribed;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.price,
    required this.sellingPrice,
    required this.features,
    required this.durationValue,
    required this.durationUnit,
    required this.unlimitedLikes,
    required this.seeWhoLikesYou,
    required this.isSubscribed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      price: json['price'] as int? ?? 0,
      sellingPrice: json['sellingPrice'] as int? ?? 0,
      features: (json['features'] as List<dynamic>?)
              ?.map(
                (e) => SubscriptionFeature.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      durationValue: json['durationValue'] as int? ?? 0,
      durationUnit: json['durationUnit']?.toString() ?? '',
      unlimitedLikes: json['unlimitedLikes'] == true,
      seeWhoLikesYou: json['seeWhoLikesYou'] == true,
      isSubscribed: json['isSubscribed'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'price': price,
      'sellingPrice': sellingPrice,
      'features': features.map((f) => f.toJson()).toList(),
      'durationValue': durationValue,
      'durationUnit': durationUnit,
      'unlimitedLikes': unlimitedLikes,
      'seeWhoLikesYou': seeWhoLikesYou,
      'isSubscribed': isSubscribed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper to get formatted price
  String get formattedPrice => '₹$price';

  // Helper to get duration text
  String get durationText => '$durationValue ${durationUnit.toLowerCase()}';

  // Helper to get price per period
  String get pricePerPeriod {
    if (durationUnit.toLowerCase() == 'months' && durationValue == 12) {
      return '₹${(price / 12).toStringAsFixed(0)}/mo';
    } else if (durationUnit.toLowerCase() == 'months') {
      return '₹${(price / durationValue).toStringAsFixed(0)}/mo';
    } else if (durationUnit.toLowerCase() == 'weeks') {
      return '₹${(price / durationValue).toStringAsFixed(0)}/week';
    }
    return formattedPrice;
  }

  // Helper to calculate discount
  int calculateDiscount(int originalPrice) {
    if (originalPrice <= price) return 0;
    return ((originalPrice - price) / originalPrice * 100).round();
  }
}

class SubscriptionsResponse {
  final bool status;
  final int statusCode;
  final String message;
  final List<SubscriptionPlan> subscriptions;
  final bool hasNext;
  final int totalCount;

  SubscriptionsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.subscriptions,
    required this.hasNext,
    required this.totalCount,
  });

  factory SubscriptionsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final subscriptionsList = data['subscriptions'] as List<dynamic>? ?? [];

    return SubscriptionsResponse(
      status: json['status'] == true,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message']?.toString() ?? '',
      subscriptions: subscriptionsList
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: data['hasNext'] == true,
      totalCount: data['totalCount'] as int? ?? 0,
    );
  }
}

class PaymentOrderResponse {
  final bool status;
  final int statusCode;
  final String message;
  final OrderDetails orderDetails;

  PaymentOrderResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.orderDetails,
  });

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final orderData = data['orderDetails'] as Map<String, dynamic>? ?? {};

    return PaymentOrderResponse(
      status: json['status'] == true,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message']?.toString() ?? '',
      orderDetails: OrderDetails.fromJson(orderData),
    );
  }
}

class OrderDetails {
  final int amount;
  final int amountDue;
  final int amountPaid;
  final int attempts;
  final int createdAt;
  final String currency;
  final String entity;
  final String id;
  final Map<String, dynamic> notes;
  final String? offerId;
  final String receipt;
  final String status;
  final String keyId;

  OrderDetails({
    required this.amount,
    required this.amountDue,
    required this.amountPaid,
    required this.attempts,
    required this.createdAt,
    required this.currency,
    required this.entity,
    required this.id,
    required this.notes,
    this.offerId,
    required this.receipt,
    required this.status,
    required this.keyId,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      amount: json['amount'] as int? ?? 0,
      amountDue: json['amount_due'] as int? ?? 0,
      amountPaid: json['amount_paid'] as int? ?? 0,
      attempts: json['attempts'] as int? ?? 0,
      createdAt: json['created_at'] as int? ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      entity: json['entity']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      notes: json['notes'] as Map<String, dynamic>? ?? {},
      offerId: json['offer_id']?.toString(),
      receipt: json['receipt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      keyId: json['key_id']?.toString() ?? '',
    );
  }

  // Helper to get amount in rupees
  double get amountInRupees => amount / 100;
}
