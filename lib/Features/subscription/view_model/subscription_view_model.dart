import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Data/services/performance_monitor.dart';
import 'package:everqpidapp/Features/subscription/models/subscription_models.dart';
import 'package:everqpidapp/Features/subscription/repository/subscription_repository.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionViewModel extends ChangeNotifier {
  final SubscriptionRepository _repository = SubscriptionRepository();
  Razorpay? _razorpay;

  // State
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = false;
  String? _error;
  SubscriptionPlan? _selectedPlan;
  bool _isProcessingPayment = false;

  // Payment callbacks
  void Function(PaymentSuccessResponse)? onPaymentSuccess;
  void Function(PaymentFailureResponse)? onPaymentError;

  // Getters
  List<SubscriptionPlan> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SubscriptionPlan? get selectedPlan => _selectedPlan;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get hasPlans => _plans.isNotEmpty;
  bool get paymentsAvailable => !kIsWeb;

  SubscriptionViewModel() {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    if (kIsWeb) return;
    try {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e, st) {
      LoggerService.instance.warning('Razorpay init skipped', e, st);
      _razorpay = null;
    }
  }

  /// Fetch all subscription plans
  Future<void> fetchSubscriptionPlans() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllSubscriptions();
      _plans = response.subscriptions;

      // Auto-select monthly plan if available
      if (_plans.isNotEmpty) {
        _selectedPlan = _plans.firstWhere(
          (plan) => plan.planName.toLowerCase().contains('monthly'),
          orElse: () => _plans.first,
        );
      }

      log('✅ Loaded ${_plans.length} subscription plans');
      AnalyticsService.instance.logSubscriptionViewed(source: 'plans');
    } catch (e) {
      _error = _getErrorMessage(e);
      log('❌ Error fetching plans: $e');
      LoggerService.instance.error('subscription plans fetch', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a subscription plan
  void selectPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    log('✅ Selected plan: ${plan.planName}');
    notifyListeners();
  }

  /// Initiate Razorpay payment
  Future<void> initiatePayment() async {
    if (kIsWeb || _razorpay == null) {
      _error =
          'In-app payments are available in the EverQpid mobile app. Plans still load on web.';
      notifyListeners();
      return;
    }

    if (_selectedPlan == null) {
      _error = 'Please select a subscription plan';
      notifyListeners();
      return;
    }

    if (_isProcessingPayment) {
      log('⚠️ Payment already in progress');
      return;
    }

    _isProcessingPayment = true;
    _error = null;
    notifyListeners();
    PerformanceMonitor.instance.start('subscription_purchase');

    try {
      // Get user ID
      await LoggedInUser.getUserDetails();
      final userId = LoggedInUser.id;

      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Create payment order
      log('📡 Creating payment order for ${_selectedPlan!.planName}');
      final orderResponse = await _repository.createPaymentSubscription(
        userId: userId,
        subscriptionId: _selectedPlan!.id,
      );
      if (orderResponse.statusCode == 409) {
        _isProcessingPayment = false;
        _error = 'You already have an active subscription.';
        notifyListeners();
      } else {
        _openRazorpayCheckout(orderResponse.orderDetails);
      }
      // Open Razorpay checkout
      // orderResponse.statusCode != 409
      //     ?
      //     : Fluttertoast.showToast(
      //         msg: 'You already have an active subscription.',
      //       );
    } catch (e) {
      _error = _getErrorMessage(e);
      _isProcessingPayment = false;
      log('❌ Error initiating payment: $e');
      notifyListeners();
    }
  }

  /// Open Razorpay checkout
  void _openRazorpayCheckout(OrderDetails orderDetails) {
    if (kIsWeb || _razorpay == null) {
      _isProcessingPayment = false;
      _error =
          'In-app payments are available in the EverQpid mobile app. Plans still load on web.';
      notifyListeners();
      return;
    }

    final options = {
      'key': orderDetails.keyId.isNotEmpty
          ? orderDetails.keyId
          : AppConfig.razorpayKey,
      'amount': orderDetails.amount,
      'currency': orderDetails.currency,
      'name': AppConfig.appName,
      'description': _selectedPlan?.planName ?? 'Subscription',
      'order_id': orderDetails.id,
      'prefill': {
        'contact': orderDetails.notes['phone'] ?? '',
        'email': orderDetails.notes['email'] ?? '',
        'name': orderDetails.notes['name'] ?? '',
      },
      'theme': {
        'color': '#D63384', // Your primary color
      },
      'retry': {'enabled': true, 'max_count': 3},
      'timeout': 300, // 5 minutes
      'notes': orderDetails.notes,
    };

    try {
      _razorpay!.open(options);
      log('✅ Razorpay checkout opened');
    } catch (e) {
      _isProcessingPayment = false;
      _error = 'Failed to open payment gateway';
      log('❌ Error opening Razorpay: $e');
      notifyListeners();
    }
  }

  /// Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('✅ Payment successful'); // never log paymentId/orderId/signature

    _isProcessingPayment = false;
    notifyListeners();
    PerformanceMonitor.instance.stop('subscription_purchase', toCrashlytics: true);
    AnalyticsService.instance.logSubscriptionPurchased(
      planId: _selectedPlan?.id,
    );

    // Call the callback if set
    onPaymentSuccess?.call(response);

    // Optional: Verify payment on backend
    _verifyPayment(response);
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    log('❌ Payment failed: ${response.message}');
    log('Code: ${response.code}');

    _isProcessingPayment = false;
    _error = response.message ?? 'Payment failed';
    notifyListeners();

    // Call the callback if set
    onPaymentError?.call(response);
  }

  /// Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('💳 External wallet selected: ${response.walletName}');
    _isProcessingPayment = false;
    notifyListeners();
  }

  /// Verify payment on backend
  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    if (_selectedPlan == null) return;

    try {
      await _repository.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        subscriptionId: _selectedPlan!.id,
      );

      log('✅ Payment verification successful');
    } catch (e) {
      log('⚠️ Payment verification failed: $e');
      // Payment was successful but verification failed
      // You might want to handle this differently
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Helper to format error messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('404')) {
      return 'Subscription plans not found.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    onPaymentSuccess = null;
    onPaymentError = null;
    try {
      _razorpay?.clear();
    } catch (_) {}
    log('🗑️ Disposing SubscriptionViewModel');
    super.dispose();
  }

  void reset() {
    onPaymentSuccess = null;
    onPaymentError = null;
    _plans = [];
    _isLoading = false;
    _error = null;
    _selectedPlan = null;
    _isProcessingPayment = false;
    notifyListeners();
  }
}
