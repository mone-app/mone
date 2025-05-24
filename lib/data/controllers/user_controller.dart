// lib/data/controller/user_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/repositories/auth_repository.dart';
import 'package:mone/data/repositories/user_repository.dart';

class UserController extends StateNotifier<UserEntity?> {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  UserController(this._userRepository, this._authRepository) : super(null);

  Future<void> getUser() async {
    try {
      state = await _userRepository.getUser(
        _authRepository.auth.currentUser!.uid,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user: $e');
    }
  }

  Future<void> upsertUser(UserEntity user) async {
    try {
      await _userRepository.saveUser(user);
      state = user;
    } catch (e) {
      // ignore: avoid_print
      print('Error saving user: $e');
    }
  }

  Future<void> clearUser() async {
    try {
      state = null;
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing user: $e');
    }
  }
}
