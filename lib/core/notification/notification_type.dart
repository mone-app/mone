// lib/data/services/notification/notification_types.dart
import 'package:awesome_notifications/awesome_notifications.dart';

@pragma('vm:entry-point')
class NotificationTypes {
  /// Creates a simple notification with title and body
  @pragma('vm:entry-point')
  static Future<bool> createBasicNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? payload,
    String channelKey = 'basic_channel',
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Creates a notification with an image
  static Future<bool> createImageNotification({
    required int id,
    required String title,
    required String body,
    required String imagePath,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        bigPicture: imagePath,
        notificationLayout: NotificationLayout.BigPicture,
        payload: payload,
      ),
    );
  }

  /// Creates a notification that shows progress (for file downloads, etc.)
  static Future<bool> createProgressNotification({
    required int id,
    required String title,
    required String body,
    required double? progress,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress,
      ),
    );
  }

  /// Creates a silent notification (no sound or vibration)
  static Future<bool> createSilentNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'silenced_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Creates a scheduled notification to be delivered at a specific date/time
  static Future<bool> createScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  /// Creates a notification with action buttons
  static Future<bool> createActionNotification({
    required int id,
    required String title,
    required String body,
    required List<NotificationActionButton> actionButtons,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: actionButtons,
    );
  }

  /// Creates a notification with a message/chat style
  static Future<bool> createMessagingNotification({
    required int id,
    required String title,
    required String body,
    required String sender,
    String? profileImage,
    Map<String, String>? payload,
  }) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        summary: sender,
        largeIcon: profileImage,
        payload: payload,
        notificationLayout: NotificationLayout.Messaging,
      ),
    );
  }
}
