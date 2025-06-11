// lib/features/bill/widgets/user_share_card.dart
import 'package:flutter/material.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/models/participant_model.dart';

class UserShareCard extends StatelessWidget {
  final BillEntity bill;
  final ParticipantModel currentUserParticipant;
  final bool canSettle;

  const UserShareCard({
    super.key,
    required this.bill,
    required this.currentUserParticipant,
    required this.canSettle,
  });

  @override
  Widget build(BuildContext context) {
    final payerName = bill.participants.firstWhere((p) => p.userId == bill.payerId).name;

    return Card(
      color: canSettle ? Colors.blue[50] : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: canSettle ? Colors.blue[800] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentUserParticipant.formattedSplitAmount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: canSettle ? Colors.blue[800] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentUserParticipant.isSettled
                  ? 'You have settled this bill'
                  : 'Amount you owe to $payerName',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
