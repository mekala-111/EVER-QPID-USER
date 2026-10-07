import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profileactions/view/blocked_users_list_screen.dart';
import 'package:everqpidapp/Features/settings/view/delete_account_screen.dart';
import 'package:everqpidapp/Features/settings/view/desktop/desktop_settings_view.dart';
import 'package:everqpidapp/Features/settings/view/desktop/web_delete_account_dialog.dart';
import 'package:everqpidapp/Features/settings/view/hide_contact_screen.dart';
import 'package:everqpidapp/Features/settings/view/privacy_policy_screen.dart';
import 'package:everqpidapp/Features/settings/view/support_screen.dart';
import 'package:everqpidapp/Features/settings/view/terms_conditions_screen.dart';
import 'package:everqpidapp/Features/settings/view_model/contact_view_model.dart';
import 'package:everqpidapp/Features/settings/view_model/support_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  final String userId;
  const SettingsScreen({super.key, required this.userId});

  void _openHideContacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ContactsViewModel(),
          child: const HideContactsScreen(),
        ),
      ),
    );
  }

  void _openBlocked(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BlockedUsersListScreen(),
      ),
    );
  }

  void _openPrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _openSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => SupportViewModel(),
          child: SupportScreen(userId: userId),
        ),
      ),
    );
  }

  void _openTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsConditionsScreen(),
      ),
    );
  }

  void _openDelete(BuildContext context) {
    // Tablet/desktop: modal over Settings. Mobile: existing full-screen page.
    if (breakpointOf(MediaQuery.sizeOf(context).width) !=
        AppBreakpoint.mobile) {
      showWebDeleteAccountDialog(context, userId: userId);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteAccountScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(context),
      desktop: (_) => DesktopSettingsView(
        onHideContacts: () => _openHideContacts(context),
        onBlockedContacts: () => _openBlocked(context),
        onPrivacyPolicy: () => _openPrivacy(context),
        onSupport: () => _openSupport(context),
        onTerms: () => _openTerms(context),
        onDeleteAccount: () => _openDelete(context),
        onLogout: () => showLogoutDialog(context),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: getTextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Settings'),
              const SizedBox(height: 12),
              _SettingsItem(
                icon: Icons.visibility_off_outlined,
                title: 'Hide Contacts',
                onTap: () => _openHideContacts(context),
              ),
              const SizedBox(height: 12),
              _SettingsItem(
                icon: Icons.block_flipped,
                title: 'Blocked Contacts',
                onTap: () => _openBlocked(context),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Others'),
              const SizedBox(height: 12),
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Privacy Policy',
                onTap: () => _openPrivacy(context),
              ),
              _SettingsItem(
                icon: Icons.chat_bubble_outline,
                title: 'Customer Support',
                onTap: () => _openSupport(context),
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () => _openTerms(context),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Danger Actions'),
              const SizedBox(height: 12),
              _SettingsItem(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                onTap: () => _openDelete(context),
                isDestructive: true,
              ),
              _SettingsItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () => showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: getTextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? Colors.red : Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  color: isDestructive ? Colors.red : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
