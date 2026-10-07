import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';

void showSubscriptionRequiredDialog({
  required BuildContext context,
  String? message,
  VoidCallback? onSubscribe,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (context) => _SubscriptionRequiredDialog(
      message: message,
      onSubscribe: onSubscribe,
    ),
  );
}

class _SubscriptionRequiredDialog extends StatelessWidget {
  final String? message;
  final VoidCallback? onSubscribe;

  const _SubscriptionRequiredDialog({this.message, this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF6F0FA),
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PColors.primaryColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.star_rounded,
                  size: 30,
                  color: PColors.primaryColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Subscription Required',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message ?? 'Please subscribe to send super likes',
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE8E4EE),
                          foregroundColor: Colors.grey[700],
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Cancel',
                          style: getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSubscribe?.call();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: PColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Subscribe',
                          style: getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
