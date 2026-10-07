// ignore_for_file: use_build_context_synchronously

import 'package:everqpidapp/Features/splash/widgets/everqpid_loading_screen.dart';
import 'package:everqpidapp/Settings/helper/app_start_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../Data/services/notificationhelper.dart';
import '../../../Settings/helper/app_logger.dart';

/// Kept only so `/splash` deep links still resolve. Immediately hands off to
/// Home or Login with no branded delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final route = await AppStartRouter.resolve();
    if (!mounted) return;

    if (route == AppStartRouter.homeRoute) {
      AppStartRouter.onAuthenticated(context);
      if (initialMessage != null) {
        AppLogger.d(
          '🚀 App opened from notification, passing to MainScreen...',
        );
        NotificationNavigator.handle(initialMessage);
        return;
      }
    }
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const EverQpidLoadingScreen();
  }
}
