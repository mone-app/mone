// lib/data/providers/bill_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/controllers/bill_controller.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/data/repositories/bill_repository.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository();
});

// Bill Controller Provider
final billProvider = StateNotifierProvider<BillController, List<BillEntity>>((ref) {
  final billRepository = ref.watch(billRepositoryProvider);
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final transactionController = ref.watch(transactionProvider.notifier);
  return BillController(
    billRepository,
    transactionRepository,
    transactionController,
    ref,
  );
});

// Stream provider for real-time bill updates
final billStreamProvider = StreamProvider.family<List<BillEntity>, String>((ref, userId) {
  final billRepository = ref.watch(billRepositoryProvider);
  return billRepository.watchUserBills(userId);
});
