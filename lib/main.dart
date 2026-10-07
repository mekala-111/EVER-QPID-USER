import 'dart:async';

import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Data/services/performance_monitor.dart';
import 'package:everqpidapp/Settings/helper/app_start_router.dart';
import 'package:everqpidapp/Settings/helper/providers.dart';
import 'package:everqpidapp/Settings/utils/app_navigator.dart';
import 'package:everqpidapp/Settings/utils/restart_widget.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:everqpidapp/firebase_options.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Settings/utils/p_colors.dart';
import 'Settings/utils/p_routes.dart';
import 'package:everqpidapp/Features/splash/widgets/everqpid_loading_screen.dart';
import 'package:everqpidapp/Data/services/fcm_service.dart';
import 'package:everqpidapp/Data/services/notificationhelper.dart';
import 'package:everqpidapp/Features/location/view/location_block_screen.dart';
import 'package:everqpidapp/Features/location/view_model/location_view_model.dart';

/// Mobile-only — [facebook_app_events] has no web implementation.
final FacebookAppEvents? facebookAppEvents =
    kIsWeb ? null : FacebookAppEvents();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LoggerService.instance.debug('Background notification received');
}

Future<void> main() async {
  PerformanceMonitor.instance.markAppStart();

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Clean URLs on web (no #/) — refresh, deep links, back button, direct nav.
    usePathUrlStrategy();

    // Warm Unicode fallbacks before first paint (family names must match getTextStyle).
    if (kIsWeb) {
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSans(),
        GoogleFonts.notoSansTelugu(),
      ]);
    }

    // Cap decoded image memory (evicts least-recent).
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Web: persist Firebase Auth across refresh / tab close (not SESSION).
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    } else {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        LoggerService.instance.error(
          'FlutterError',
          details.exception,
          details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        LoggerService.instance.error('PlatformDispatcher', error, stack);
        return true;
      };
    }

    await FCM().initFCM();

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    configLoading();

    // Restore session → Home or Login (no branded splash on any platform).
    final initialRoute =
        kIsWeb ? await AppStartRouter.resolveForWeb() : await AppStartRouter.resolve();

    runApp(
      MultiProvider(
        providers: providers,
        child: RestartWidget(child: MyApp(initialRoute: initialRoute)),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PerformanceMonitor.instance.recordStartupComplete();
      if (!kIsWeb) {
        facebookAppEvents?.logEvent(
          name: 'fb_mobile_install',
          parameters: {'source': 'Facebook Ads'},
        );
      }
    });
  }, (error, stack) {
    LoggerService.instance.error('Uncaught zone error', error, stack, true);
  });
}

final GlobalKey<NavigatorState> navigatorKey = AppNavigator.key;

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationHandlers();
    if (AppStartRouter.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) AppStartRouter.onAuthenticated(ctx);
      });
    }
  }

  void _setupNotificationHandlers() {
    FirebaseMessaging.instance.getInitialMessage().then(
          NotificationNavigator.handle,
        );

    FirebaseMessaging.onMessageOpenedApp.listen(
      NotificationNavigator.handle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: mainShellProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        navigatorObservers: [
          AnalyticsService.instance.observer,
        ],
        title: AppConfig.appName,
        theme: ThemeData(
          brightness: Brightness.light,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          // Web: match boot shell so first Flutter frame isn't white.
          scaffoldBackgroundColor:
              kIsWeb ? EverQpidLoadingScreen.bg : PColors.colorFFFFFF,
          colorScheme: ColorScheme.fromSeed(seedColor: PColors.primaryColor),
          iconTheme: IconThemeData(color: PColors.colorFFFFFF),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: PColors.colorFFFFFF,
            surfaceTintColor: PColors.primaryColor,
            foregroundColor: PColors.colorFFFFFF,
            centerTitle: true,
          ),
        ),
        initialRoute: widget.initialRoute,
        onGenerateRoute: Routes.genericRoute,
        builder: (context, child) {
          final gate = context.select<LocationViewModel, (bool, bool)>(
            (vm) => (vm.isCheckingLocation, vm.isBlocked),
          );

          Widget page;
          if (gate.$1) {
            page = const EverQpidLoadingScreen(key: ValueKey('boot-loading'));
          } else if (!kIsWeb && gate.$2) {
            page = const LocationBlockScreen(key: ValueKey('location-block'));
          } else {
            page = KeyedSubtree(
              key: const ValueKey('app-shell'),
              child: child!,
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: page,
          );
        },
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.white
    ..maskColor = Colors.white
    ..indicatorColor = Colors.black
    ..userInteractions = false
    ..dismissOnTap = false
    ..textColor = Colors.transparent
    ..contentPadding = const EdgeInsets.all(8)
    ..textPadding = EdgeInsets.zero
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..indicatorSize = 23
    ..lineWidth = 2.2
    ..radius = 20
    ..boxShadow = <BoxShadow>[
      const BoxShadow(
        offset: Offset(2, 2),
        blurRadius: 10,
        color: Color.fromRGBO(0, 0, 0, .15),
      ),
    ];
}
