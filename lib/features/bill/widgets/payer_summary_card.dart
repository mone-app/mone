// lib/features/bill/widgets/payer_summary_card.dart
import 'package:flutter/material.dart';
import 'package:mone/data/entities/bill_entity.dart';

class PayerSummaryCard extends StatelessWidget {
  final BillEntity bill;

  const PayerSummaryCard({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You paid', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      bill.formattedAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Still owed', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      bill.formattedUnsettledAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            bill.totalUnsettledAmount > 0
                                ? Colors.orange[800]
                                : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
