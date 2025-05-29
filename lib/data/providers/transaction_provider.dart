import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/controllers/chart_controller.dart';
import 'package:mone/data/controllers/transaction_controller.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/models/chart_model.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Transaction Controller Provider
final transactionProvider =
    StateNotifierProvider<TransactionController, List<TransactionEntity>>((
      ref,
    ) {
      final transactionRepository = ref.watch(transactionRepositoryProvider);
      final userRepository = ref.watch(userRepositoryProvider);
      return TransactionController(transactionRepository, userRepository, ref);
    });

// Stream provider for real-time transaction updates
final transactionStreamProvider =
    StreamProvider.family<List<TransactionEntity>, String>((ref, userId) {
      final transactionRepository = ref.watch(transactionRepositoryProvider);
      return transactionRepository.watchUserTransactions(userId);
    });

final chartProvider = StateNotifierProvider<ChartController, ChartStateModel>((
  ref,
) {
  return ChartController();
});
