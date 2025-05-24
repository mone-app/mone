// lib/core/routes/route.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/enums/route_enum.dart';
import 'package:mone/features/auth/login_screen.dart';
import 'package:mone/features/auth/register_screen.dart';
import 'package:mone/widgets/navigation_wrapper.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, WidgetRef ref) {
    // final args = settings.arguments as Map<String, dynamic>? ?? {}; //  later for notification

    switch (settings.name) {
      case RouteEnum.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      case RouteEnum.register:
        return MaterialPageRoute(builder: (context) => RegisterScreen());

      case RouteEnum.home:
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 0),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 0),
        );
    }
  }
}
