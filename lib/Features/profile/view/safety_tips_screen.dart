import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_safety_tips_view.dart';
import 'package:everqpidapp/Features/settings/view/support_screen.dart';
import 'package:everqpidapp/Features/settings/view_model/support_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  void _openSupport(BuildContext context) {
    final userId = LoggedInUser.id ?? '';
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

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(context),
      desktop: (_) => DesktopSafetyTipsView(
        onSupport: () => _openSupport(context),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Safety Tips",
                style: getTextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                """At Everqpid, we’re here to help you find a meaningful relationship that leads to a lifelong commitment. We take your safety seriously and strive to create a space where trust, respect, and genuine intentions come first.

We encourage all users to use the app mindfully, stay cautious when sharing information, and report any suspicious behavior immediately. Your safety is our top priority.

Here are a few important things to keep in mind:""",
                style: getTextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 25),
              _safetyCard(
                title: "Sharing Personal Details",
                items: [
                  "🔒 Your privacy matters. Don’t share personal info too soon.",
                  "🚩 If someone rushes to move off Everqpid, stay cautious.",
                  "💖 Take it slow — your comfort and safety come first.",
                ],
              ),
              const SizedBox(height: 18),
              _safetyCard(
                title: "Meeting in Person",
                items: [
                  "🍷 Your safety comes first.",
                  "📍 Meet in public places for the first few times.",
                  "👥 Let a friend or family member know your plans.",
                  "📱 Keep your phone charged and with you.",
                  "💗 Take your time — real connections don’t need rushing.",
                ],
              ),
              const SizedBox(height: 18),
              _safetyCard(
                title: "Sharing Photos & Media",
                items: [
                  "📸 Be mindful of what you share.",
                  "🔒 Avoid sending personal or revealing photos — once shared, you lose control.",
                  "🤝 Keep chats respectful and build trust slowly.",
                  "💖 Real connections grow with time, not haste.",
                ],
              ),
              const SizedBox(height: 18),
              _safetyCard(
                title: "Sharing Financial Information",
                items: [
                  "💰 Keep your money safe.",
                  "⛔ Don’t share bank details, UPI IDs, or financial info on Everqpid.",
                  "⚠️ Genuine connections never ask for money or favors.",
                  "🧠 Scammers may build trust to request help — stay alert.",
                  "💳 Once money or data is sent, it can’t be taken back. When in doubt, don’t share.",
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _safetyCard({required String title, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(
              fontSize: 17,
              color: PColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                text,
                style: getTextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
