import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/core/navigation/navigation_service.dart';
import 'package:mone/core/notification/fcm_service.dart';
import 'package:mone/core/notification/notification_service.dart';
import 'package:mone/core/notification/notification_settings_service.dart';
import 'package:mone/core/services/crashlytics_service.dart';
import 'package:mone/core/theme/theme_service.dart';
import 'package:mone/core/theme/app_theme.dart';
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
  await CrashlyticsService.instance.initialize();

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
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
