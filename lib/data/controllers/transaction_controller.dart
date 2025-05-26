// lib/data/controllers/transaction_controller.dart (Simplified - no setUser needed)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/data/repositories/transaction_repository.dart';
import 'package:mone/data/repositories/user_repository.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';

class TransactionController extends StateNotifier<List<TransactionEntity>> {
  final TransactionRepository _transactionRepository;
  final UserRepository _userRepository;
  final Ref _ref;

  TransactionController(
    this._transactionRepository,
    this._userRepository,
    this._ref,
  ) : super([]);

  // Create a new transaction and update user balance
  Future<void> createTransaction(
    String userId,
    TransactionEntity transaction,
  ) async {
    try {
      // Create the transaction in user's subcollection
      await _transactionRepository.createTransaction(userId, transaction);

      // Update user balance
      await _updateUserBalance(userId, transaction, isAdding: true);

      // Update local state
      state = [...state, transaction];

      // Sort by date (newest first)
      state.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(
    String userId,
    String transactionId,
    TransactionEntity updatedTransaction,
  ) async {
    try {
      // Find the original transaction to calculate balance difference
      final originalTransaction = state.firstWhere(
        (t) => t.id == transactionId,
      );

      // Revert the original transaction's effect on balance
      await _updateUserBalance(userId, originalTransaction, isAdding: false);

      // Apply the updated transaction's effect on balance
      await _updateUserBalance(userId, updatedTransaction, isAdding: true);

      // Update the transaction in Firestore subcollection
      await _transactionRepository.updateTransaction(
        userId,
        updatedTransaction,
      );

      // Update local state
      state =
          state
              .map((t) => t.id == transactionId ? updatedTransaction : t)
              .toList();

      // Sort by date (newest first)
      state.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      rethrow;
    }
  }

  // Delete a transaction and update user balance
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      // Find the transaction to calculate balance adjustment
      final transaction = state.firstWhere((t) => t.id == transactionId);

      // Revert the transaction's effect on balance
      await _updateUserBalance(userId, transaction, isAdding: false);

      // Delete from Firestore subcollection
      await _transactionRepository.deleteTransaction(userId, transactionId);

      // Update local state
      state = state.where((t) => t.id != transactionId).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Private method to update user balance
  Future<void> _updateUserBalance(
    String userId,
    TransactionEntity transaction, {
    required bool isAdding,
  }) async {
    try {
      // Fetch current user
      final user = await _userRepository.fetchUser(userId);
      if (user == null) return;

      double balanceChange = transaction.amount;

      // Determine how the transaction affects balance
      if (transaction.type == TransactionTypeEnum.expense) {
        balanceChange = -balanceChange; // Expenses decrease balance
      }

      // If we're removing/reverting, invert the change
      if (!isAdding) {
        balanceChange = -balanceChange;
      }

      // Update user balance
      final updatedUser = user.copyWith(
        balance: user.balance + balanceChange,
        updatedAt: DateTime.now(),
      );

      await _userRepository.upsertUser(updatedUser);

      // Update local state in user provider
      _ref.read(userProvider.notifier).updateUserLocally(updatedUser);
    } catch (e) {
      rethrow;
    }
  }
}
