import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/core/services/navigation_service.dart';
import 'package:mone/data/enums/route_enum.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/firebase_options.dart';
import 'package:mone/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mone',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(),
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings, ref),
      initialRoute: RouteEnum.login,
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
                NavigationService.replaceWith(RouteEnum.home);
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
