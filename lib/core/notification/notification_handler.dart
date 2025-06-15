// lib/data/services/notification/notification_handler.dart

import 'package:mone/core/notification/notification_type.dart';
import 'package:mone/data/enums/route_enum.dart';

@pragma('vm:entry-point')
class NotificationTypeHandler {
  // These methods should be static
  @pragma('vm:entry-point')
  static Future<void> addedFriend({
    String? userId,
    String? connectionId,
    String? username,
    String? title,
    String? body,
  }) async {
    await NotificationTypes.createBasicNotification(
      id: _generateNotificationId(connectionId ?? ''),
      title: "Someone has added you as a friend",
      body:
          body ??
          (username != null
              ? "@$username added you as a friend"
              : "someone added you as a friend"),
      payload: {
        'type': 'added_friend',
        'userId': userId ?? '',
        'screen': RouteEnum.searchFriend,
      },
      channelKey: 'social_channel',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> newBill({
    String? userId,
    String? username,
    String? title,
    String? body,
  }) async {
    await NotificationTypes.createBasicNotification(
      id: _generateNotificationId(''),
      title: title ?? "New bill Added",
      body:
          body ??
          (username != null
              ? "@$username added you to a new bill"
              : "someone added you to a new bill"),
      payload: {
        'type': 'bill_created',
        'userId': userId ?? '',
        'screen': RouteEnum.searchFriend,
      },
      channelKey: 'social_channel',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> settledBill({
    String? userId,
    String? username,
    String? title,
    String? body,
  }) async {
    await NotificationTypes.createBasicNotification(
      id: _generateNotificationId(''),
      title: title ?? "Bill Settled",
      body:
          body ??
          (username != null
              ? "@$username settled a bill with you"
              : "someone settled a bill with you"),
      payload: {
        'type': 'bill_settled',
        'userId': userId ?? '',
        'screen': RouteEnum.searchFriend,
      },
      channelKey: 'social_channel',
    );
  }

  // This helper method should be static
  @pragma('vm:entry-point')
  static int _generateNotificationId(String connectionId) {
    // Use the hashCode of the connection ID to create a unique int ID
    // Add a base value to avoid potential negative numbers
    return (connectionId.hashCode.abs() % 100000) + 1000;
  }
}
