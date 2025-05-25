// lib/data/repository/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mone/core/services/notification/notification_service.dart';

class AuthRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "users";

  Future<User?> login(String email, String password) async {
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<UserCredential> register(String email, String password) async {
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  void logout() {
    auth.signOut();
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  Future<void> updateFcmToken() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final String fcmToken =
          await NotificationService.getFirebaseMessagingToken();
      if (fcmToken.isNotEmpty) {
        await _firestore.collection(collectionPath).doc(currentUser.uid).update(
          {'fcmToken': fcmToken, 'updatedAt': DateTime.now().toIso8601String()},
        );
      }
    }
  }
}
