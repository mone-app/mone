// lib/features/transaction/screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/transactions/widgets/transaction_header.dart';
import 'package:mone/features/transactions/widgets/transaction_list.dart';

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
          TransactionHeader(user: user),

          // Real-time transaction list using StreamBuilder
          Expanded(child: TransactionList(user: user)),
        ],
      ),
    );
  }
}
