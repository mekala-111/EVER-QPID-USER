import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import '../view_model/profile_actions_view_model.dart';
import '../model/block_reason_model.dart';

void showBlockAccountDialog({
  required BuildContext context,
  required String userId,
  required String userName,
  VoidCallback? onBlocked,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => _BlockAccountDialog(
      userId: userId,
      userName: userName,
      onBlocked: onBlocked,
    ),
  );
}

class _BlockAccountDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final VoidCallback? onBlocked;

  const _BlockAccountDialog({
    required this.userId,
    required this.userName,
    this.onBlocked,
  });

  @override
  State<_BlockAccountDialog> createState() => _BlockAccountDialogState();
}

class _BlockAccountDialogState extends State<_BlockAccountDialog> {
  bool _isBlocking = false;
  final Set<String> _selectedReasons = {};

  Future<void> _handleBlock() async {
    if (_selectedReasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one reason'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isBlocking = true);

    final viewModel = context.read<ProfileActionsViewModel>();
    final success = await viewModel.blockUser(
      blockedAccountId: widget.userId,
      selectedReasons: _selectedReasons.toList(),
    );

    if (mounted) {
      setState(() => _isBlocking = false);

      if (success) {
        Navigator.of(context).pop(); // Close dialog
        widget.onBlocked?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.userName} has been blocked'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Failed to block user',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Block ${widget.userName}?',
                  style: getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You won\'t be able to view this profile again. Please select the reason(s):',
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Reasons checkboxes
                ...BlockReasons.reasons.map((reason) {
                  final isSelected = _selectedReasons.contains(reason);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedReasons.add(reason);
                        } else {
                          _selectedReasons.remove(reason);
                        }
                      });
                    },
                    title: Text(
                      reason,
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: PColors.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isBlocking
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side:
                              BorderSide(color: Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isBlocking ? null : _handleBlock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColors.primaryColor,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isBlocking
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Block',
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
      ),
    );
  }
}
