// lib/features/transactions/widgets/transaction_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/features/transactions/widgets/empty_transaction_list.dart';
import 'package:mone/features/transactions/widgets/transaction_card.dart';
import 'package:mone/features/transactions/transaction_form_screen.dart';

class TransactionList extends ConsumerWidget {
  final UserEntity user;

  const TransactionList({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionStream = ref.watch(transactionStreamProvider(user.id));

    return transactionStream.when(
      data: (transactions) => _buildTransactionList(context, ref, transactions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, ref, error),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    WidgetRef ref,
    List<TransactionEntity> transactions,
  ) {
    if (transactions.isEmpty) {
      return const EmptyTransactionsList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCard(
          transaction: transaction,
          onTap: () => _navigateToEditTransaction(context, transaction),
          onEdit: () => _navigateToEditTransaction(context, transaction),
          onDelete: () => _showDeleteConfirmation(context, ref, transaction),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading transactions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(transactionStreamProvider(user.id)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    TransactionEntity transaction,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete this transaction?\n\n'
            '${transaction.category.name} - \$${transaction.amount.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(context, ref, user.id, transaction.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditTransaction(BuildContext context, TransactionEntity transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String transactionId,
  ) async {
    try {
      await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(userId, transactionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
