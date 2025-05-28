// lib/features/transactions/transaction2_screen.dart (Updated)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/transactions/widgets/balance_section.dart';
import 'package:mone/features/transactions/widgets/chart_container.dart';
import 'package:mone/features/transactions/transaction_form_screen.dart';
import 'package:mone/features/transactions/widgets/transaction_list_section.dart';

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
    ref.read(userProvider.notifier).fetchUser();
  }

  void _navigateToAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
      // Simple AppBar
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddTransaction,
          ),
        ],

        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: CustomScrollView(
        slivers: [
          // Balance Section with Filter
          SliverToBoxAdapter(child: BalanceSection()),

          // Chart container
          SliverToBoxAdapter(child: ChartContainer(userId: user.id)),

          // Placeholder for transaction list (to be added later)
          SliverToBoxAdapter(child: TransactionListSection(userId: user.id)),
        ],
      ),
    );
  }
}
