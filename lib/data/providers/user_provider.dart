import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/controllers/user_controller.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/repositories/auth_repository.dart';
import 'package:mone/data/repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = StateNotifierProvider<UserController, UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return UserController(userRepository, authRepository);
});

final allUsersStreamProvider = StreamProvider<List<UserEntity>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchAllUsers();
});

final allUsernamesStreamProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchAllUsernames();
});
