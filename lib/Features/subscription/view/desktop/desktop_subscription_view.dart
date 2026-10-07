import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/subscription/models/subscription_models.dart';
import 'package:everqpidapp/Features/subscription/view_model/subscription_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Subscriptions — presentation only; same [SubscriptionViewModel].
class DesktopSubscriptionView extends StatelessWidget {
  const DesktopSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubscriptionViewModel>();
    SubscriptionPlan? activePlan;
    for (final p in vm.plans) {
      if (p.isSubscribed) {
        activePlan = p;
        break;
      }
    }

    return ColoredBox(
      color: const Color(0xFF05030D),
      child: Stack(
        children: [
          const IgnorePointer(child: _AmbientDecor()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1220),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 8, 40, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BackLink(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Subscriptions',
                          style: getTextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 28,
                          color: WelcomeTheme.violetLight.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upgrade to EverQpid Premium and enjoy exclusive benefits.',
                      style: getTextStyle(
                        fontSize: 15,
                        color: const Color(0xFFB8B3C7),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (activePlan != null) ...[
                      _ActiveBanner(plan: activePlan),
                      const SizedBox(height: 20),
                    ],
                    if (vm.isLoading && vm.plans.isEmpty)
                      const _LoadingSkeleton()
                    else if (vm.error != null && vm.plans.isEmpty)
                      _ErrorCard(
                        message: vm.error!,
                        onRetry: () {
                          vm.clearError();
                          vm.fetchSubscriptionPlans();
                        },
                      )
                    else if (vm.plans.isEmpty)
                      _EmptyPlans(onRetry: () => vm.fetchSubscriptionPlans())
                    else
                      PremiumHeroCard(
                        vm: vm,
                        onNotNow: () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (vm.isProcessingPayment)
            const ColoredBox(
              color: Color(0x88000000),
              child: Center(
                child: Card(
                  color: Color(0xFF160B24),
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: WelcomeTheme.violetLight,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── hero ────────────────────────────────────────────────────────────────────

class PremiumHeroCard extends StatelessWidget {
  const PremiumHeroCard({
    super.key,
    required this.vm,
    required this.onNotNow,
  });

  final SubscriptionViewModel vm;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final selected = vm.selectedPlan;
    final features = selected?.features ?? const <SubscriptionFeature>[];
    final width = MediaQuery.sizeOf(context).width;
    final stackHero = width < 1100;

    return Container(
      padding: EdgeInsets.all(stackHero ? 28 : 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF120A1F).withValues(alpha: 0.72),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: WelcomeTheme.violet.withValues(alpha: 0.14),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stackHero) ...[
            const PremiumBrandMark(),
            const SizedBox(height: 28),
            PremiumFeatureList(plan: selected, features: features),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 4, child: PremiumBrandMark()),
                const SizedBox(width: 28),
                Expanded(
                  flex: 6,
                  child: PremiumFeatureList(plan: selected, features: features),
                ),
              ],
            ),
          const SizedBox(height: 28),
          SubscriptionPlanSection(vm: vm),
          const SizedBox(height: 28),
          PurchaseSection(vm: vm, onNotNow: onNotNow),
          const SizedBox(height: 28),
          const SubscriptionTrustBar(),
        ],
      ),
    );
  }
}

class PremiumBrandMark extends StatelessWidget {
  const PremiumBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              Images.everqpid,
              height: 44,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 10),
            Text(
              '+',
              style: getTextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: WelcomeTheme.violetSoft,
                height: 0.9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Unlock exciting features and connect without limits.',
          style: getTextStyle(
            fontSize: 14,
            color: const Color(0xFFB8B3C7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class PremiumFeatureList extends StatelessWidget {
  const PremiumFeatureList({
    super.key,
    required this.plan,
    required this.features,
  });

  final SubscriptionPlan? plan;
  final List<SubscriptionFeature> features;

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String? body})>[];
    for (final f in features) {
      final t = f.feature.trim();
      if (t.isNotEmpty) items.add((title: t, body: null));
    }
    if (plan != null) {
      if (plan!.unlimitedLikes &&
          !items.any((e) => e.title.toLowerCase().contains('like'))) {
        items.add((
          title: 'Unlimited Likes',
          body: 'Like as many profiles as you want.',
        ));
      }
      if (plan!.seeWhoLikesYou &&
          !items.any((e) => e.title.toLowerCase().contains('who likes'))) {
        items.add((
          title: 'See Who Likes You',
          body: 'Know who’s interested before you match.',
        ));
      }
    }

    if (items.isEmpty) {
      return Text(
        'Choose a plan to see included benefits.',
        style: getTextStyle(fontSize: 14, color: const Color(0xFFB8B3C7)),
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PremiumFeatureItem(title: item.title, body: item.body),
          ),
      ],
    );
  }
}

class PremiumFeatureItem extends StatelessWidget {
  const PremiumFeatureItem({super.key, required this.title, this.body});
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WelcomeTheme.violet.withValues(alpha: 0.25),
            border: Border.all(
              color: WelcomeTheme.violetLight.withValues(alpha: 0.5),
            ),
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (body != null) ...[
                const SizedBox(height: 4),
                Text(
                  body!,
                  style: getTextStyle(
                    fontSize: 14,
                    color: const Color(0xFFB8B3C7),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── plans ───────────────────────────────────────────────────────────────────

class SubscriptionPlanSection extends StatelessWidget {
  const SubscriptionPlanSection({super.key, required this.vm});
  final SubscriptionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final plans = vm.plans;
    final cols = plans.length == 1
        ? 1
        : (MediaQuery.sizeOf(context).width >= 1100 && plans.length >= 3
            ? 3
            : (plans.length >= 2 ? 2 : 1));

    if (cols == 1) {
      return Column(
        children: [
          for (final plan in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SubscriptionPlanCard(
                plan: plan,
                selected: vm.selectedPlan?.id == plan.id,
                onTap: () => vm.selectPlan(plan),
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final gap = 12.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final plan in plans)
              SizedBox(
                width: w,
                child: SubscriptionPlanCard(
                  plan: plan,
                  selected: vm.selectedPlan?.id == plan.id,
                  onTap: () => vm.selectPlan(plan),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SubscriptionPlanCard extends StatefulWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<SubscriptionPlanCard> createState() => _SubscriptionPlanCardState();
}

class _SubscriptionPlanCardState extends State<SubscriptionPlanCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final selected = widget.selected;
    final original = plan.sellingPrice;
    final current = plan.price;
    final showOriginal = original > current && original > 0;
    final discount = showOriginal
        ? (((original - current) / original) * 100).round()
        : 0;
    final lift = _hover && !MediaQuery.disableAnimationsOf(context) ? -2.0 : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, lift, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? WelcomeTheme.violet.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected || _hover
                ? WelcomeTheme.violetSoft.withValues(alpha: selected ? 0.85 : 0.45)
                : Colors.white.withValues(alpha: 0.1),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.28),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? WelcomeTheme.violetSoft
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: selected ? Colors.white : Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.planName,
                          style: getTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full access for ${plan.durationText}',
                          style: getTextStyle(
                            fontSize: 13,
                            color: const Color(0xFFB8B3C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹$current',
                        style: getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (showOriginal)
                        Text(
                          '₹$original',
                          style: getTextStyle(
                            fontSize: 13,
                            color: const Color(0xFF8E879D),
                          ).copyWith(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: const Color(0xFF8E879D),
                          ),
                        ),
                      if (discount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: WelcomeTheme.violet.withValues(alpha: 0.28),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: getTextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: WelcomeTheme.violetLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── purchase / trust ────────────────────────────────────────────────────────

class PurchaseSection extends StatefulWidget {
  const PurchaseSection({
    super.key,
    required this.vm,
    required this.onNotNow,
  });

  final SubscriptionViewModel vm;
  final VoidCallback onNotNow;

  @override
  State<PurchaseSection> createState() => _PurchaseSectionState();
}

class _PurchaseSectionState extends State<PurchaseSection> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final busy = widget.vm.isProcessingPayment;
    final webBlocked = !widget.vm.paymentsAvailable;

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: WelcomeTheme.violet
                      .withValues(alpha: _hover && !busy ? 0.45 : 0.28),
                  blurRadius: _hover ? 22 : 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: busy
                    ? null
                    : () {
                        widget.vm.clearError();
                        widget.vm.initiatePayment();
                      },
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: busy
                          ? [Colors.grey.shade700, Colors.grey.shade600]
                          : const [
                              Color(0xFFA855F7),
                              Color(0xFF7C3AED),
                              Color(0xFF5B21B6),
                            ],
                    ),
                  ),
                  child: Center(
                    child: busy
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Processing...',
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Purchase Now',
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (webBlocked) ...[
          const SizedBox(height: 10),
          Text(
            'In-app payments complete in the EverQpid mobile app. Plans still load here.',
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 12, color: const Color(0xFFB8B3C7)),
          ),
        ],
        if (widget.vm.error != null && widget.vm.plans.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            widget.vm.error!,
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 13, color: const Color(0xFFFCA5A5)),
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: widget.onNotNow,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB8B3C7),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Not now'),
        ),
      ],
    );
  }
}

class SubscriptionTrustBar extends StatelessWidget {
  const SubscriptionTrustBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ponytail: no auto-renewal in payment flow — truthful trust copy only.
    const items = [
      (Icons.verified_user_outlined, 'Secure Payment'),
      (Icons.shopping_cart_checkout_rounded, 'Secure Checkout'),
      (Icons.lock_outline_rounded, '100% Safe & Private'),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 10,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white.withValues(alpha: 0.12),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(items[i].$1, size: 15, color: const Color(0xFF9B95A8)),
              const SizedBox(width: 6),
              Text(
                items[i].$2,
                style: getTextStyle(
                  fontSize: 12,
                  color: const Color(0xFF9B95A8),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── states ──────────────────────────────────────────────────────────────────

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner({required this.plan});
  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: WelcomeTheme.violet.withValues(alpha: 0.18),
        border: Border.all(
          color: WelcomeTheme.violetSoft.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: WelcomeTheme.violetLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EverQpid Premium Active',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current plan: ${plan.planName}',
                  style: getTextStyle(
                    fontSize: 13,
                    color: const Color(0xFFB8B3C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block({double h = 20, double? w}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withValues(alpha: 0.06),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: WelcomeTheme.violet.withValues(alpha: 0.22),
        ),
        color: const Color(0xFF120A1F).withValues(alpha: 0.55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(h: 48, w: 220),
          const SizedBox(height: 24),
          block(h: 18, w: 320),
          const SizedBox(height: 12),
          block(h: 18, w: 280),
          const SizedBox(height: 28),
          block(h: 72),
          const SizedBox(height: 12),
          block(h: 72),
          const SizedBox(height: 24),
          block(h: 60),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF120A1F).withValues(alpha: 0.55),
        border: Border.all(
          color: WelcomeTheme.violet.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFCA5A5), size: 40),
          const SizedBox(height: 16),
          Text(
            'Unable to load plans',
            style: getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.isNotEmpty
                ? message
                : 'We couldn’t load subscription plans right now.',
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 14, color: const Color(0xFFB8B3C7)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: WelcomeTheme.violetSoft,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _ErrorCard(
      message: 'No subscription plans available right now.',
      onRetry: onRetry,
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Back'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFB8B3C7),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _AmbientDecor extends StatelessWidget {
  const _AmbientDecor();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFF9B4DFF).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.88, 80), 170, glow);
    canvas.drawCircle(Offset(40, size.height * 0.7), 140, glow);

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.65, 0)
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.2,
          size.width,
          size.height * 0.4,
        ),
      line,
    );

    final heart = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    void drawHeart(Offset c, double s) {
      final p = Path()
        ..moveTo(c.dx, c.dy + s * 0.3)
        ..cubicTo(
          c.dx - s,
          c.dy - s * 0.4,
          c.dx - s * 1.1,
          c.dy + s * 0.6,
          c.dx,
          c.dy + s * 1.2,
        )
        ..cubicTo(
          c.dx + s * 1.1,
          c.dy + s * 0.6,
          c.dx + s,
          c.dy - s * 0.4,
          c.dx,
          c.dy + s * 0.3,
        );
      canvas.drawPath(p, heart);
    }

    drawHeart(Offset(56, 120), 9);
    drawHeart(Offset(size.width - 70, size.height * 0.45), 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
