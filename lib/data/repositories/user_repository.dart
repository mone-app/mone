// lib/data/repository/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/user_entity.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "users";

  Future<UserEntity?> getUser(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection(collectionPath).doc(userId).get();
    if (doc.exists) {
      return UserEntity.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> saveUser(UserEntity user) async {
    await _firestore
        .collection(collectionPath)
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection(collectionPath).doc(userId).delete();
  }

  Stream<UserEntity> watchUser(String userId) {
    return _firestore
        .collection(collectionPath)
        .doc(userId)
        .snapshots()
        .map(
          (doc) =>
              UserEntity.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        );
  }

  Stream<List<String>> watchAllUsernames() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => (doc.data())['username'] as String?)
          .whereType<String>()
          .toList();
    });
  }

  Stream<List<UserEntity>> watchAllUsers() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserEntity.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
