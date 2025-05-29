// lib/core/routes/route.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/enums/route_enum.dart';
import 'package:mone/features/auth/login_screen.dart';
import 'package:mone/features/auth/register_screen.dart';
import 'package:mone/features/profile/edit_profile_screen.dart';
import 'package:mone/features/profile/search_friend_screen.dart';
import 'package:mone/widgets/navigation_wrapper.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, WidgetRef ref) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      case RouteEnum.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      case RouteEnum.register:
        return MaterialPageRoute(builder: (context) => RegisterScreen());

      case RouteEnum.transaction:
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 0),
        );

      case RouteEnum.bill:
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 1),
        );

      case RouteEnum.profile:
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 2),
        );

      case RouteEnum.editProfile:
        final user = args['user'] as UserEntity?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (context) => EditProfileScreen(user: user),
          );
        }

        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 2),
        );

      case RouteEnum.searchFriend:
        final user = args['user'] as UserEntity?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (context) => SearchFriendScreen(currentUser: user),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 2),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const NavigationWrapper(selectedPageIndex: 0),
        );
    }
  }
}
