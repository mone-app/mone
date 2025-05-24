import 'package:flutter/widgets.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> replaceWith(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    return navigator!.pop();
  }

  static void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }

  static bool canGoBack() {
    return navigator!.canPop();
  }
}
