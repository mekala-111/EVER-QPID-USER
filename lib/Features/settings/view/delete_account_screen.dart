import 'dart:developer';

import 'package:everqpidapp/Features/clan2.0/view_model/clan_view_model.dart';
import 'package:everqpidapp/Features/home/view_model/home_view_model.dart';
import 'package:everqpidapp/Features/mainscreen/view_model/main_screen_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/likes_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/matches_view_model.dart';
import 'package:everqpidapp/Features/messages/service/chat_socket_service.dart';
import 'package:everqpidapp/Features/messages/service/message_local_storage.dart';
import 'package:everqpidapp/Features/messages/view_model/chat_view_model.dart';
import 'package:everqpidapp/Features/messages/view_model/messages_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/logout_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/recent_pass_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Features/profileactions/view_model/profile_actions_view_model.dart';
import 'package:everqpidapp/Features/subscription/view_model/subscription_view_model.dart';
import 'package:everqpidapp/Features/superlikes/view_model/super_likes_view_model.dart';
import 'package:everqpidapp/Features/messages/service/audio_recording_service.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String userId;
  const DeleteAccountScreen({super.key, required this.userId});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isConfirmEnabled = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isConfirmEnabled = _confirmController.text.trim() == 'CONFIRM';
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_isConfirmEnabled) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeletingOverlay(),
    );

    final success = await performDeleteAccount(
      context: context,
      userId: widget.userId,
    );

    if (!mounted) return;
    if (!success) {
      Navigator.pop(context); // Close loading overlay
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      // Just to be explicit (default is true, but ok to keep):
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Back',
          style: getTextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // This makes the content scroll when the keyboard appears
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + viewInsets, // add bottom padding equal to keyboard height
              ),
              child: ConstrainedBox(
                // Ensures the Column can stretch to full height when no keyboard
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'You are going to delete your account.',
                        style: getTextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Warning text
                      Text(
                        'We are very sorry to see you leaving. Deleting your account will permanently delete all of the data plus any active subscriptions and this action can\'t be undone!',
                        style: getTextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instruction text
                      Text(
                        'If you still want to delete your account, enter "CONFIRM" to proceed.',
                        style: getTextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Confirmation input
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _confirmController,
                          style: getTextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter "CONFIRM"',
                            hintStyle: getTextStyle(
                              fontSize: 15,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Delete account button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isConfirmEnabled ? _deleteAccount : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isConfirmEnabled
                                ? Colors.red
                                : Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Delete account',
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isConfirmEnabled
                                  ? Colors.white
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shared delete + session teardown used by mobile page and web dialog.
///
/// On success: cleanup, sign-out, VM reset, [RestartWidget.restartApp].
/// On failure: snackbar; returns `false` (caller keeps UI open).
Future<bool> performDeleteAccount({
  required BuildContext context,
  required String userId,
}) async {
  if (userId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User ID not found'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }

  final profileVM = context.read<GetProfileViewModel>();
  final mainVM = context.read<MainScreenViewModel>();

  final success = await profileVM.deleteAccount(
    userId: userId,
    reason: 'User requested to delete account',
  );

  if (!context.mounted) return false;

  if (success) {
    await _cleanupBeforeLogout();
    await mainVM.signOut();
    if (!context.mounted) return true;
    await _resetAllViewModels(context);
    if (!context.mounted) return true;
    RestartWidget.restartApp(context);
    return true;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(profileVM.deleteError ?? 'Failed to delete account'),
      backgroundColor: Colors.red,
    ),
  );
  return false;
}

Future<void> _resetAllViewModels(BuildContext context) async {
  log('🔄 Resetting session ViewModels...');

  try {
    // Root VMs survive RestartWidget — clear them explicitly.
    context.read<ChatViewModel>().reset();
    context.read<AuthViewModel>().reset();
    context.read<LogoutViewModel>().reset();
    context.read<GetProfileViewModel>().reset();

    // Shell VMs dispose on RestartWidget remount; reset while still mounted.
    void tryReset(void Function() fn) {
      try {
        fn();
      } catch (_) {}
    }

    tryReset(() => context.read<HomeViewModel>().reset());
    tryReset(() => context.read<MessagesViewModel>().reset());
    tryReset(() => context.read<MatchesViewModel>().reset());
    tryReset(() => context.read<LikesViewModel>().reset());
    tryReset(() => context.read<ClanViewModel>().reset());
    tryReset(() => context.read<SubscriptionViewModel>().reset());
    tryReset(() => context.read<ProfileViewModel>().reset());
    tryReset(() => context.read<ProfileActionsViewModel>().reset());
    tryReset(() => context.read<SuperLikesViewModel>().reset());
    tryReset(() => context.read<RecentPassViewModel>().reset());

    log('✅ Session ViewModels reset');
  } catch (e) {
    log('⚠️ Error resetting ViewModels: $e');
  }
}

// Loading overlay widget
class _LogoutLoadingOverlay extends StatelessWidget {
  const _LogoutLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Logging out...',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure?',
                  style: getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure, you want to log out from this account?',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!, width: 1),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          log('🚪 Logout button pressed');

                          // Close dialog first
                          Navigator.pop(dialogContext);

                          // Show loading overlay
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const _LogoutLoadingOverlay(),
                          );

                          // ✅ Get LogoutViewModel from PARENT context
                          final logoutVM = context.read<LogoutViewModel>();

                          // ✅ CRITICAL: Disconnect socket and clean local storage BEFORE logout
                          await _cleanupBeforeLogout();

                          // Perform logout
                          final success = await logoutVM.logout();

                          // Close loading overlay
                          if (context.mounted) {
                            Navigator.pop(context);
                          }

                          if (!context.mounted) return;

                          if (success) {
                            log('✅ Logout successful, navigating to login');

                            // ✅ Reset ALL ViewModels before navigation
                            await _resetAllViewModels(context);

                            // ✅ Navigate to login and clear entire stack
                            RestartWidget.restartApp(context);
                          } else {
                            log('❌ Logout failed');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  logoutVM.error ??
                                      'Logout failed. Please try again.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Log out',
                          style: getTextStyle(
                            fontSize: 15,
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
      );
    },
  );
}

Future<void> _cleanupBeforeLogout() async {
  log('🧹 Starting pre-logout cleanup...');

  try {
    log('🔌 Disconnecting socket...');
    ChatSocketService.instance.dispose();
    log('✅ Socket disconnected');

    log('🗑️ Clearing local message cache...');
    await MessageLocalStorage().clearAllChatHistories();
    log('✅ Local storage cleared');

    try {
      AudioRecordingService.instance.dispose();
    } catch (_) {}

    log('✅ Pre-logout cleanup completed');
  } catch (e) {
    log('⚠️ Error in cleanup: $e');
  }
}

// Future<void> _resetAllViewModels(BuildContext context) async {
//   log('🔄 Resetting all ViewModels...');

//   try {
//     // ✅ IMPORTANT: Reset chat-related ViewModels FIRST
//     context.read<ChatViewModel>().reset();
//     context.read<MessagesViewModel>().reset();

//     // Then reset other ViewModels
//     context.read<HomeViewModel>().reset();
//     context.read<AuthViewModel>().reset();
//     context.read<MatchesViewModel>().reset();
//     context.read<LikesViewModel>().reset();
//     context.read<ClanViewModel>().reset();
//     context.read<LogoutViewModel>().reset();
//     context.read<GetProfileViewModel>().reset();
//     context.read<SupportViewModel>().reset();
//     context.read<LikedProfilesViewModel>().reset();
//     context.read<SubscriptionViewModel>().reset();
//     context.read<ProfileViewModel>().reset();
//     context.read<PreferencesViewModel>().reset();
//     context.read<ProfileActionsViewModel>().reset();
//     context.read<SuperLikesViewModel>().reset();
//     context.read<VerificationViewModel>().reset();
//     context.read<RecentPassViewModel>().reset();

//     log('✅ All ViewModels reset');
//   } catch (e) {
//     log('⚠️ Error resetting ViewModels: $e');
//     // Continue anyway - this is cleanup, not critical
//   }
// }

// ✅ Loading overlay widget
// class _LogoutLoadingOverlay extends StatelessWidget {
//   const _LogoutLoadingOverlay();

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Logging out...',
//                   style: getTextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DeletingOverlay extends StatelessWidget {
  const _DeletingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text(
              "Deleting your account...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
