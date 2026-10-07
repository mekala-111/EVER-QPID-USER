import 'package:everqpidapp/Features/messages/view_model/chat_view_model.dart';
import 'package:everqpidapp/Features/subscription/models/subscription_models.dart';
import 'package:everqpidapp/Features/subscription/view_model/subscription_view_model.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'subscription_screen.dart';

void showSubscriptionBottomSheet({
  required BuildContext context,
  String? title,
  String? message,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (context) =>
        SubscriptionBottomSheet(title: title, message: message),
  );
}

class SubscriptionBottomSheet extends StatefulWidget {
  final String? title;
  final String? message;

  const SubscriptionBottomSheet({super.key, this.title, this.message});

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  SubscriptionViewModel? _vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm = context.read<SubscriptionViewModel>();
      _vm!.onPaymentSuccess = _handlePaymentSuccess;
      _vm!.onPaymentError = _handlePaymentError;

      if (_vm!.plans.isEmpty) {
        _vm!.fetchSubscriptionPlans();
      }
    });
  }

  @override
  void dispose() {
    if (_vm?.onPaymentSuccess == _handlePaymentSuccess) {
      _vm!.onPaymentSuccess = null;
    }
    if (_vm?.onPaymentError == _handlePaymentError) {
      _vm!.onPaymentError = null;
    }
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Navigator.pop(context); // Close bottom sheet
    try {
      final chatVM = context.read<ChatViewModel>();
      chatVM.isSubscriptionRestricted == true
          ? await chatVM.clearSubscriptionRestriction()
          : null;
    } catch (e) {
      // ChatViewModel might not be available in all contexts
      AppLogger.d('ChatViewModel not available: $e');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '🎉 Payment Successful!\nYour subscription is now active.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment Failed',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToFullScreen() {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionViewModel>(
      builder: (context, vm, _) {
        // Get the first plan (usually monthly) to show
        final featuredPlan = vm.plans.isNotEmpty ? vm.plans.first : null;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.title ?? 'Subscription',
                          style: getTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the close button
                      ],
                    ),
                  ),

                  // Scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Everqpid Plus Logo
                          Image.asset(Images.everqpidPlus, height: 50),

                          const SizedBox(height: 24),

                          // Show loading state
                          if (vm.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            )
                          else if (vm.error != null)
                            // Show error state
                            _buildErrorState(vm)
                          else if (vm.plans.isEmpty)
                            // Show empty state
                            _buildEmptyState()
                          else
                            Column(
                              children: [
                                // Feature List
                                if (featuredPlan != null)
                                  ...featuredPlan.features.expand((feature) {
                                    // return feature.subFeatures.map((
                                    //   subFeature,
                                    // ) {
                                    //   return _buildFeature(subFeature);
                                    // }).toList();
                                    return [_buildFeature(feature.feature)];
                                  }),

                                const SizedBox(height: 24),

                                // Featured Subscription Card
                                if (featuredPlan != null)
                                  _buildFeaturedCard(featuredPlan, vm),

                                const SizedBox(height: 20),

                                // Purchase Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: vm.isProcessingPayment
                                        ? null
                                        : () {
                                            if (featuredPlan != null) {
                                              vm.selectPlan(featuredPlan);
                                              vm.initiatePayment();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      backgroundColor: PColors.primaryColor,
                                      disabledBackgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: vm.isProcessingPayment
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            "Purchase",
                                            style: getTextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // View All Plans
                                GestureDetector(
                                  onTap: _navigateToFullScreen,
                                  child: Text(
                                    "View All",
                                    style: getTextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: PColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Processing overlay
              if (vm.isProcessingPayment)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Processing payment...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------------
  // Feature Row Builder
  // -----------------------------------
  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------
  // Featured Card (Single Plan) - UPDATED WITH SELLING PRICE
  // -----------------------------------
  Widget _buildFeaturedCard(SubscriptionPlan plan, SubscriptionViewModel vm) {
    // Calculate discount percentage
    final discount = plan.sellingPrice > 0
        ? (((plan.sellingPrice - plan.price) / plan.sellingPrice) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: PColors.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Left circle check
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: PColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),

          const SizedBox(width: 14),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name with selling price (strikethrough)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        plan.planName,
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Selling price (strikethrough) next to plan name
                    if (plan.sellingPrice > 0)
                      Text(
                        '₹${plan.sellingPrice}',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Actual price below
                Text(
                  plan.formattedPrice,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ).copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey[500],
                    decorationThickness: 2,
                  ),
                ),
              ],
            ),
          ),

          // Discount Badge
          if (discount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$discount% OFF',
                style: getTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -----------------------------------
  // Error State
  // -----------------------------------
  Widget _buildErrorState(SubscriptionViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Payment Failed',
              style: getTextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.fetchSubscriptionPlans(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------
  // Empty State
  // -----------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No subscription plans available',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check back later',
              style: getTextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
