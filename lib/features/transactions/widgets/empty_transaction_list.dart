// lib/features/transactions/widgets/empty_transactions_widget.dart
import 'package:flutter/material.dart';

class EmptyTransactionsList extends StatelessWidget {
  const EmptyTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
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
}
