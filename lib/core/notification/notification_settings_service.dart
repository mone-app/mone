// lib/core/services/notification_settings_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mone/core/notification/notification_service.dart';

class NotificationSettingsService extends ChangeNotifier {
  static const String _notificationEnabledKey = 'notifications_enabled';
  bool _notificationsEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;

  String get notificationStatus {
    return _notificationsEnabled ? 'Enabled' : 'Disabled';
  }

  IconData get notificationIcon {
    return _notificationsEnabled
        ? Icons.notifications_outlined
        : Icons.notifications_off_outlined;
  }

  Future<void> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationEnabledKey) ?? false;
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  Future<bool> requestNotificationPermissions() async {
    final isAllowed = await NotificationService.requestPermissions();
    if (isAllowed) {
      await setNotificationEnabled(true);
      return true;
    } else {
      await setNotificationEnabled(false);
      return false;
    }
  }
}
