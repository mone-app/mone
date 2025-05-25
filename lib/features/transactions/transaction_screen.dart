// lib/features/transaction/screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/features/transactions/transaction_form_screen.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    _handleUserFetch();
  }

  Future<void> _handleUserFetch() async {
    final user = ref.read(userProvider);
    if (user == null) {
      ref.read(userProvider.notifier).fetchUser();
    }
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionFormScreen()),
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

  Future<void> _deleteTransaction(String userId, String transactionId) async {
    try {
      await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(userId, transactionId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting transaction: $e')));
      }
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String userId,
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
                _deleteTransaction(userId, transaction.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return _buildContent(context, user);
  }

  Widget _buildContent(BuildContext context, UserEntity? user) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _buildTransactionContent(context, user);
  }

  Widget _buildTransactionContent(BuildContext context, UserEntity user) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          // Fixed header section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Welcome, ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Balance: \$${user.balance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: user.balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _navigateToAddTransaction(context),
                  child: const Text('Add Transaction'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Real-time transaction list using StreamBuilder
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final transactionStream = ref.watch(transactionStreamProvider(user.id));

                return transactionStream.when(
                  data:
                      (transactions) =>
                          _buildTransactionList(context, user, transactions),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(
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
                              onPressed:
                                  () => ref.refresh(transactionStreamProvider(user.id)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    UserEntity user,
    List<TransactionEntity> transactions,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Transactions Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Transaction" to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(context, user, transaction);
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    UserEntity user,
    TransactionEntity transaction,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.isIncome ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            transaction.category.icon,
            color: transaction.isIncome ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        title: Text(
          transaction.category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(transaction.method.icon, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    transaction.method.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${dateFormat.format(transaction.date)} ${timeFormat.format(transaction.date)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: transaction.isIncome ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEditTransaction(context, transaction);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, user.id, transaction);
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        isThreeLine:
            transaction.description != null && transaction.description!.isNotEmpty,
        onTap: () => _navigateToEditTransaction(context, transaction),
      ),
    );
  }
}
