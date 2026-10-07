import 'dart:ui';

import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/settings/view/delete_account_screen.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium web/desktop delete confirmation — stays on Settings (no route push).
Future<void> showWebDeleteAccountDialog(
  BuildContext context, {
  required String userId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      return WebDeleteAccountDialog(userId: userId);
    },
  );
}

class WebDeleteAccountDialog extends StatefulWidget {
  const WebDeleteAccountDialog({super.key, required this.userId});

  final String userId;

  @override
  State<WebDeleteAccountDialog> createState() => _WebDeleteAccountDialogState();
}

class _WebDeleteAccountDialogState extends State<WebDeleteAccountDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _canDelete = false;
  bool _deleting = false;
  bool _closeHover = false;
  bool _btnHover = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onText() {
    final ok = _controller.text.trim() == 'CONFIRM';
    if (ok != _canDelete) setState(() => _canDelete = ok);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _close() {
    if (_deleting) return;
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (!_canDelete || _deleting) return;
    setState(() => _deleting = true);

    final success = await performDeleteAccount(
      context: context,
      userId: widget.userId,
    );

    if (!mounted) return;
    if (!success) {
      setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth =
        width >= 1100 ? 650.0 : (width * 0.86).clamp(320.0, 650.0);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: !_deleting,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: const Color.fromRGBO(2, 0, 12, 0.72),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: dialogWidth,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.92,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _DialogCard(
                      closeHover: _closeHover,
                      onCloseHover: (v) => setState(() => _closeHover = v),
                      onClose: _close,
                      deleting: _deleting,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _DeleteWarningIcon(),
                          const SizedBox(height: 28),
                          Text(
                            'You are going to delete your account.',
                            textAlign: TextAlign.center,
                            style: getTextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: Text(
                              "We are very sorry to see you leaving. Deleting your account will permanently delete all of the data plus any active subscriptions and this action can't be undone!",
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: const Color(0xFFC2BCCB),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: Text.rich(
                              TextSpan(
                                style: getTextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: const Color(0xFFC2BCCB),
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'If you still want to delete your account, enter ',
                                  ),
                                  TextSpan(
                                    text: '“CONFIRM”',
                                    style: getTextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFE8E2F2),
                                    ),
                                  ),
                                  const TextSpan(text: ' to proceed.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _ConfirmField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: !_deleting,
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 18),
                          _DeleteButton(
                            enabled: _canDelete && !_deleting,
                            loading: _deleting,
                            hover: _btnHover,
                            onHover: (v) => setState(() => _btnHover = v),
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.child,
    required this.onClose,
    required this.closeHover,
    required this.onCloseHover,
    required this.deleting,
  });

  final Widget child;
  final VoidCallback onClose;
  final bool closeHover;
  final ValueChanged<bool> onCloseHover;
  final bool deleting;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(44, 36, 44, 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16082B), Color(0xFF0D061D), Color(0xFF080312)],
        ),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 48,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: WelcomeTheme.violet.withValues(alpha: 0.18),
            blurRadius: 36,
          ),
        ],
      ),
      child: Stack(
        children: [
          child,
          Positioned(
            top: -8,
            right: -8,
            child: MouseRegion(
              onEnter: (_) => onCloseHover(true),
              onExit: (_) => onCloseHover(false),
              child: IconButton(
                tooltip: 'Close',
                onPressed: deleting ? null : onClose,
                icon: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: closeHover ? Colors.white : const Color(0xFFC8C2D3),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: closeHover
                      ? WelcomeTheme.violet.withValues(alpha: 0.22)
                      : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteWarningIcon extends StatelessWidget {
  const _DeleteWarningIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF3B62).withValues(alpha: 0.28),
                  WelcomeTheme.violet.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A0A22),
              border: Border.all(
                width: 2,
                color: const Color(0xFFFF3B62).withValues(alpha: 0.65),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B62).withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
                BoxShadow(
                  color: WelcomeTheme.violet.withValues(alpha: 0.25),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 34,
              color: Color(0xFFFF3B62),
            ),
          ),
          const Positioned(
            top: 10,
            right: 14,
            child: Icon(Icons.favorite, size: 12, color: Color(0xFFC084FC)),
          ),
          const Positioned(
            bottom: 16,
            left: 12,
            child: Icon(Icons.favorite, size: 10, color: Color(0xFFA855F7)),
          ),
          const Positioned(
            top: 18,
            left: 16,
            child: Icon(Icons.auto_awesome, size: 11, color: Color(0xFFC084FC)),
          ),
        ],
      ),
    );
  }
}

class _ConfirmField extends StatelessWidget {
  const _ConfirmField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: true,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [],
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      style: getTextStyle(fontSize: 16, color: Colors.white),
      cursorColor: WelcomeTheme.violetSoft,
      decoration: InputDecoration(
        hintText: 'Enter "CONFIRM"',
        hintStyle: getTextStyle(fontSize: 16, color: const Color(0xFF81798F)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.025),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFA855F7).withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFA855F7), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFA855F7).withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.enabled,
    required this.loading,
    required this.hover,
    required this.onHover,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final bool hover;
  final ValueChanged<bool> onHover;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = enabled || loading;

    return MouseRegion(
      cursor: active && !loading
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (enabled) onHover(true);
      },
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: active ? null : const Color(0xFF292431),
            gradient: active
                ? LinearGradient(
                    colors: hover && !loading
                        ? const [Color(0xFFE91E63), Color(0xFFFF4D73)]
                        : const [Color(0xFFD81B60), Color(0xFFFF3B62)],
                  )
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF3B62)
                          .withValues(alpha: hover ? 0.4 : 0.22),
                      blurRadius: hover ? 20 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Delete account',
                  style: getTextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : const Color(0xFF716B78),
                  ),
                ),
        ),
      ),
    );
  }
}
