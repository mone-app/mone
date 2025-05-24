// lib/features/transaction/screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.name}'),
            const SizedBox(height: 20),
            Text('Balance: \$${user.balance.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _navigateToAddTransaction(context),
              child: const Text('Add Transaction'),
            ),
            // Add more transaction-related widgets here
          ],
        ),
      ),
    );
  }
}
