// lib/features/bill/widgets/settlement_progress_card.dart
import 'package:flutter/material.dart';
import 'package:mone/data/entities/bill_entity.dart';

class SettlementProgressCard extends StatelessWidget {
  final BillEntity bill;

  const SettlementProgressCard({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    if (bill.isSettled) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settlement Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: bill.totalSettledAmount / bill.amount,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settled: \$${bill.totalSettledAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green[700]),
                ),
                Text(
                  'Remaining: \$${bill.totalUnsettledAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
