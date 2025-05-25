import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/apis/push_notification_api.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi();
});
