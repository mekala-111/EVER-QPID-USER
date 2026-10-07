import 'dart:ui';

import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profileactions/view/report_account_screen.dart';
import 'package:everqpidapp/Features/profileactions/view_model/profile_actions_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop Report Account — modal over current page; reuses [submitReport].
Future<void> showWebReportAccountDialog({
  required BuildContext context,
  required String userId,
  required String userName,
  VoidCallback? onReportSubmitted,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Report Account',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, __) {
      return WebReportAccountDialog(
        userId: userId,
        userName: userName,
        onReportSubmitted: onReportSubmitted,
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class WebReportAccountDialog extends StatefulWidget {
  const WebReportAccountDialog({
    super.key,
    required this.userId,
    required this.userName,
    this.onReportSubmitted,
  });

  final String userId;
  final String userName;
  final VoidCallback? onReportSubmitted;

  @override
  State<WebReportAccountDialog> createState() => _WebReportAccountDialogState();
}

class _WebReportAccountDialogState extends State<WebReportAccountDialog> {
  final _detailsController = TextEditingController();
  String? _selectedReason;
  bool _submitted = false;
  String? _inlineError;
  bool _closeHover = false;

  bool get _hasDraft =>
      _selectedReason != null || _detailsController.text.trim().isNotEmpty;

  bool get _canSubmit => _selectedReason != null;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _tryClose() async {
    final vm = context.read<ProfileActionsViewModel>();
    if (vm.isSubmitting) return;
    if (!_hasDraft || _submitted) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF160A27),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Discard report?',
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          "Your report hasn't been submitted.",
          style: getTextStyle(fontSize: 14, color: const Color(0xFFAAA3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Keep Editing',
              style: getTextStyle(color: const Color(0xFFD4CEDD)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Discard',
              style: getTextStyle(
                fontWeight: FontWeight.w600,
                color: WelcomeTheme.violetSoft,
              ),
            ),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    final vm = context.read<ProfileActionsViewModel>();
    if (!_canSubmit || vm.isSubmitting) return;
    final reporterId = LoggedInUser.id;
    if (reporterId == null) {
      setState(() => _inlineError = 'User not logged in');
      return;
    }

    setState(() => _inlineError = null);
    final details = _detailsController.text.trim();
    // API only has `reason` — fold optional details into that string.
    final String finalReason;
    if (_selectedReason == 'Other') {
      finalReason = details.isNotEmpty ? details : 'Other';
    } else if (details.isNotEmpty) {
      finalReason = '$_selectedReason. $details';
    } else {
      finalReason = _selectedReason!;
    }

    final success = await vm.submitReport(
      reporterId: reporterId,
      reportedUserId: widget.userId,
      reason: finalReason,
    );

    if (!mounted) return;
    if (success) {
      setState(() => _submitted = true);
    } else {
      setState(() {
        _inlineError = "Couldn't submit your report. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth =
        width >= 700 ? 560.0 : (width * 0.88).clamp(300.0, 560.0);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: Consumer<ProfileActionsViewModel>(
              builder: (context, vm, _) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF16082A),
                        Color(0xFF10051F),
                        Color(0xFF0C0318)
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: WelcomeTheme.violet.withValues(alpha: 0.18),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _submitted
                        ? _SuccessBody(
                            onDone: () {
                              Navigator.of(context).pop();
                              widget.onReportSubmitted?.call();
                            },
                          )
                        : _FormBody(
                            selectedReason: _selectedReason,
                            detailsController: _detailsController,
                            submitting: vm.isSubmitting,
                            canSubmit: _canSubmit,
                            inlineError: _inlineError,
                            closeHover: _closeHover,
                            onCloseHover: (v) =>
                                setState(() => _closeHover = v),
                            onClose: _tryClose,
                            onCancel: _tryClose,
                            onReasonChanged: (v) =>
                                setState(() => _selectedReason = v),
                            onDetailsChanged: (_) => setState(() {}),
                            onSubmit: _submit,
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.selectedReason,
    required this.detailsController,
    required this.submitting,
    required this.canSubmit,
    required this.inlineError,
    required this.closeHover,
    required this.onCloseHover,
    required this.onClose,
    required this.onCancel,
    required this.onReasonChanged,
    required this.onDetailsChanged,
    required this.onSubmit,
  });

  final String? selectedReason;
  final TextEditingController detailsController;
  final bool submitting;
  final bool canSubmit;
  final String? inlineError;
  final bool closeHover;
  final ValueChanged<bool> onCloseHover;
  final VoidCallback onClose;
  final VoidCallback onCancel;
  final ValueChanged<String?> onReasonChanged;
  final ValueChanged<String> onDetailsChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFA855F7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Account',
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Help us understand what happened. Your report helps us keep EverQpid safe.',
                      style: getTextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: const Color(0xFFAAA3B8),
                      ),
                    ),
                  ],
                ),
              ),
              MouseRegion(
                onEnter: (_) => onCloseHover(true),
                onExit: (_) => onCloseHover(false),
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: submitting ? null : onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: closeHover ? Colors.white : const Color(0xFFC8C2D3),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: closeHover
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Reason for reporting',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE8E4EE),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedReason,
            dropdownColor: const Color(0xFF160A27),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFC8C2D3)),
            style: getTextStyle(fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Select a reason',
              hintStyle:
                  getTextStyle(fontSize: 15, color: const Color(0xFF81798F)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFA855F7), width: 1.5),
              ),
            ),
            items: [
              for (final reason in kReportReasons)
                DropdownMenuItem(
                  value: reason,
                  child: Text(
                    reason,
                    style: getTextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
            ],
            onChanged: submitting ? null : onReasonChanged,
          ),
          const SizedBox(height: 20),
          Text(
            'Additional details',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE8E4EE),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: detailsController,
            enabled: !submitting,
            maxLength: kReportDetailsMaxLength,
            maxLines: 4,
            minLines: 3,
            onChanged: onDetailsChanged,
            style: getTextStyle(fontSize: 14, color: Colors.white),
            cursorColor: WelcomeTheme.violetSoft,
            decoration: InputDecoration(
              hintText: 'Tell us more about what happened...',
              hintStyle:
                  getTextStyle(fontSize: 14, color: const Color(0xFF81798F)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              counterStyle:
                  getTextStyle(fontSize: 12, color: const Color(0xFF81798F)),
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFA855F7), width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFA855F7).withValues(alpha: 0.06),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reports are reviewed to help keep the EverQpid community safe.',
                    style: getTextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: const Color(0xFFAAA3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (inlineError != null) ...[
            const SizedBox(height: 14),
            Text(
              inlineError!,
              style: getTextStyle(fontSize: 13, color: const Color(0xFFF87171)),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: submitting ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4CEDD),
                  side: const BorderSide(color: Color(0xFF51465F)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4CEDD),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _SubmitButton(
                enabled: canSubmit && !submitting,
                loading: submitting,
                onPressed: onSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled || widget.loading;
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (widget.enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? LinearGradient(
                    colors: _hover && !widget.loading
                        ? const [Color(0xFFB65CFF), Color(0xFF8B5CF6)]
                        : const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                  )
                : null,
            color:
                active ? null : const Color(0xFFA855F7).withValues(alpha: 0.25),
            boxShadow: active && _hover
                ? [
                    BoxShadow(
                      color: WelcomeTheme.violet.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: widget.loading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Submitting...',
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Submit Report',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.enabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WelcomeTheme.violet.withValues(alpha: 0.18),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Color(0xFFA855F7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Report submitted',
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for helping us keep EverQpid safe.',
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 14,
              height: 1.45,
              color: const Color(0xFFAAA3B8),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: WelcomeTheme.violetSoft,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
