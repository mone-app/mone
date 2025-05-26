// lib/data/api/notification_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationApi {
  static const String _baseUrl =
      'https://us-central1-mone-e04a0.cloudfunctions.net/moneapi';

  Future<bool> sendAddFriendNotification({
    required String targetUserId,
    required String fromUserId,
  }) async {
    return _sendNotification(
      targetUserId: targetUserId,
      type: 'added_friend',
      fromUserId: fromUserId,
    );
  }

  Future<bool> _sendNotification({
    required String targetUserId,
    required String type,
    required String fromUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'targetUserId': fromUserId,
          'type': type,
          'connectionId': 'connectionId',
          'fromUserId': fromUserId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
