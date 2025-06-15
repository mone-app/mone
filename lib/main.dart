import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/core/services/navigation/navigation_service.dart';
import 'package:mone/core/services/notification/fcm_service.dart';
import 'package:mone/core/services/notification/notification_service.dart';
import 'package:mone/core/services/notification/notification_settings_service.dart';
import 'package:mone/core/services/theme/theme_service.dart';
import 'package:mone/core/themes/app_theme.dart';
import 'package:mone/data/enums/route_enum.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/firebase_options.dart';
import 'package:mone/route.dart';

late ThemeService themeService;
late NotificationSettingsService notificationSettingsService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Crashlytics
  await _initializeCrashlytics();

  // Initialize FCM service
  await NotificationService.initializeLocalNotifications(debug: true);
  await NotificationService.initializeRemoteNotifications(debug: true);

  // Initialize services
  themeService = ThemeService();
  await themeService.loadTheme();

  notificationSettingsService = NotificationSettingsService();
  await notificationSettingsService.loadNotificationSettings();

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mone',
      navigatorKey: NavigationService.navigatorKey,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,

      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings, ref),
      builder: (context, child) {
        return StreamBuilder<User?>(
          stream: ref.read(authRepositoryProvider).auth.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (authSnapshot.hasData) {
                FcmTokenService().updateFcmToken();
                NavigationService.replaceWith(RouteEnum.transaction);
              } else {
                NavigationService.replaceWith(RouteEnum.login);
              }
            });

            return child ?? const SizedBox();
          },
        );
      },
    );
  }
}

Future<void> _initializeCrashlytics() async {
  // Pass all uncaught "fatal errors" from the framework to Crashlytics.
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // Prevents the default error handling.
  };

  // Enable Crashlytics collection.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Log that Crashlytics has been initialized
  FirebaseCrashlytics.instance.log('Crashlytics initialized successfully');
}
