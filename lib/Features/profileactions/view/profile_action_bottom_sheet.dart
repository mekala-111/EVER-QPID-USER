import 'package:everqpidapp/Features/profileactions/view/block_account_dialog.dart';
import 'package:everqpidapp/Features/profileactions/view/desktop/web_report_account_dialog.dart';
import 'package:everqpidapp/Features/profileactions/view/report_account_screen.dart';
import 'package:everqpidapp/Features/profileactions/view_model/profile_actions_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileActionsBottomSheet extends StatelessWidget {
  final String userId;
  final String userName;
  final VoidCallback? onActionCompleted;

  const ProfileActionsBottomSheet({
    super.key,
    required this.userId,
    required this.userName,
    this.onActionCompleted,
  });

  void _openReport(BuildContext context) {
    final isMobile = context.isMobile;
    final navigator = Navigator.of(context);
    final vm = context.read<ProfileActionsViewModel>();
    navigator.pop();
    // Use navigator.context — sheet context is deactivated after pop.
    final navContext = navigator.context;
    if (isMobile) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: ReportAccountScreen(
              userId: userId,
              userName: userName,
              onReportSubmitted: onActionCompleted,
            ),
          ),
        ),
      );
      return;
    }
    showWebReportAccountDialog(
      context: navContext,
      userId: userId,
      userName: userName,
      onReportSubmitted: onActionCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.flag_outlined,
              title: 'Report Account',
              onTap: () => _openReport(context),
            ),
            const Divider(height: 1),
            _ActionTile(
              icon: Icons.block_outlined,
              title: 'Block Account',
              onTap: () {
                Navigator.pop(context);
                showBlockAccountDialog(
                  context: context,
                  userId: userId,
                  userName: userName,
                  onBlocked: onActionCompleted,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
