// lib/features/transactions/widgets/transaction_header_widget.dart
import 'package:flutter/material.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/features/transactions/transaction_form_screen.dart';

class TransactionHeader extends StatelessWidget {
  final UserEntity user;

  const TransactionHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineSmall),
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
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => TransactionFormScreen()));
            },
            child: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
