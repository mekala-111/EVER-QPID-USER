// lib/features/subscription/repository/subscription_repository.dart

import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/subscription/models/subscription_models.dart';

class SubscriptionRepository {
  final NetworkApiServiceV2 _api = NetworkApiServiceV2.instance;

  /// Get all subscription plans
  Future<SubscriptionsResponse> getAllSubscriptions({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      log('📡 Fetching subscription plans');

      final response = await _api.getGetApiResponse(
        '/api/v1/subscription-plans/user/get-all-subscriptions?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      if (response is Map<String, dynamic>) {
        log('✅ Subscription plans fetched successfully');
        return SubscriptionsResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error fetching subscriptions: $e');
      rethrow;
    }
  }

  /// Create payment order for subscription
  Future<PaymentOrderResponse> createPaymentSubscription({
    required String userId,
    required String subscriptionId,
  }) async {
    try {
      log('📡 Creating payment subscription');
      log('userId: $userId, subscriptionId: $subscriptionId');

      final response = await _api.getPostApiResponse(
        '/api/v1/subscription-purchase/create-payment-subscription',
        body: {'userId': userId, 'subscriptionId': subscriptionId},
      );

      if (response is Map<String, dynamic>) {
        log('✅ Payment order created successfully');
        return PaymentOrderResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error creating payment subscription: $e');
      rethrow;
    }
  }

  /// Verify payment (you'll need to create this endpoint on backend)
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String subscriptionId,
  }) async {
    try {
      log('📡 Verifying payment');

      final response = await _api.getPostApiResponse(
        '/api/v1/subscription-purchase/verify-payment-subscription',
        body: {
          'userId': LoggedInUser.id,
          'orderId': razorpayOrderId,
          'paymentId': razorpayPaymentId,
        },
        headers: {'x-razorpay-signature': razorpaySignature},
      );

      log('✅ Payment verified successfully');
      return response;
    } catch (e) {
      log('❌ Error verifying payment: $e');
      rethrow;
    }
  }
}
