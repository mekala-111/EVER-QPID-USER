import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/subscription/models/subscription_models.dart';
import 'package:everqpidapp/Features/subscription/view/desktop/desktop_subscription_view.dart';
import 'package:everqpidapp/Features/subscription/view_model/subscription_view_model.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = breakpointOf(constraints.maxWidth);
        if (bp != AppBreakpoint.mobile) {
          return DesktopEditSubpageShell(
            initiallyCollapsed: bp == AppBreakpoint.tablet,
            premiumSelected: true,
            onPremiumTap: () {}, // already on Premium
            child: const DesktopSubscriptionView(),
          );
        }
        return _buildMobile(context);
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Consumer<SubscriptionViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: PColors.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: false,
            title: Text(
              'Back',
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Subscriptions',
                          style: getTextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Center(
                          child: Image.asset(Images.everqpidPlus, height: 60),
                        ),
                        const SizedBox(height: 50),
                        if (vm.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (vm.error != null)
                          _buildErrorState(vm)
                        else if (vm.plans.isEmpty)
                          _buildEmptyState()
                        else
                          Column(
                            children: [
                              if (vm.selectedPlan != null)
                                ...vm.selectedPlan!.features.expand((feature) {
                                  return [_buildFeature(feature.feature)];
                                }),
                              const SizedBox(height: 30),
                              ...vm.plans.map((plan) {
                                final isSelected =
                                    vm.selectedPlan?.id == plan.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildSubscriptionCard(
                                    plan: plan,
                                    isSelected: isSelected,
                                    onTap: () => vm.selectPlan(plan),
                                  ),
                                );
                              }),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: vm.isProcessingPayment
                                      ? null
                                      : () => vm.initiatePayment(),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: PColors.primaryColor,
                                    disabledBackgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: Text(
                                    "Not now",
                                    style: getTextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                if (vm.isProcessingPayment)
                  Container(
                    color: Colors.black54,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.grey[300], size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final discount = plan.sellingPrice > 0
        ? (((plan.sellingPrice - plan.price) / plan.sellingPrice) * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? PColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: isSelected ? PColors.primaryColor : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: isSelected ? Colors.white : Colors.grey[500],
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 5),
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
            if (discount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$discount% OFF',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

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
              'Payment Failed!',
              style: getTextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.fetchSubscriptionPlans(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No subscription plans available',
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check back later',
              style: getTextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
