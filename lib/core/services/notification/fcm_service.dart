// lib/data/services/notification/fcm_token_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mone/core/services/notification/notification_service.dart';

class FcmTokenService {
  static final FcmTokenService _instance = FcmTokenService._internal();

  factory FcmTokenService() {
    return _instance;
  }

  FcmTokenService._internal();

  Future<void> updateFcmToken() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final String fcmToken =
          await NotificationService.getFirebaseMessagingToken();
      if (fcmToken.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'fcmToken': fcmToken});
      }
    }
  }
}
