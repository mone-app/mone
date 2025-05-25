// lib/data/controller/user_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/repositories/auth_repository.dart';
import 'package:mone/data/repositories/user_repository.dart';

class UserController extends StateNotifier<UserEntity?> {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  UserController(this._userRepository, this._authRepository) : super(null);

  Future<void> fetchUser() async {
    state = await _userRepository.fetchUser(_authRepository.auth.currentUser!.uid);
  }

  Future<void> upsertUser(UserEntity user) async {
    await _userRepository.upsertUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    state = null;
  }

  Future<void> login(String email, String password) async {
    final user = await _authRepository.login(email, password);
    if (user != null) {
      await fetchUser();
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String username, [
    String? profilePicture,
  ]) async {
    final userCredential = await _authRepository.register(email, password);

    if (userCredential.user != null) {
      final newUser = UserEntity(
        id: userCredential.user!.uid,
        name: name,
        username: username.toLowerCase(),
        email: email,
        profilePicture: profilePicture,
        balance: 0.0,
        bill: [],
        friend: [],
        createdAt: DateTime.now(),
      );

      await upsertUser(newUser);
    }
  }

  void updateUserLocally(UserEntity updatedUser) {
    state = updatedUser;
  }

  Future<void> logout() async {
    _authRepository.logout();
    await clearUser();
  }

  /// Updates FCM token for the current user
  Future<void> updateFcmToken() async {
    await _authRepository.updateFcmToken();
    if (state != null) {
      final updatedUser = await _userRepository.fetchUser(state!.id);
      if (updatedUser != null) {
        state = updatedUser;
      }
    }
  }
}
