// lib/features/bill/widgets/participants_list_card.dart
import 'package:flutter/material.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/models/participant_model.dart';

class ParticipantsListCard extends StatelessWidget {
  final BillEntity bill;
  final String currentUserId;

  const ParticipantsListCard({
    super.key,
    required this.bill,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...bill.participants.map((participant) {
              return _ParticipantTile(
                participant: participant,
                payerId: bill.payerId,
                currentUserId: currentUserId,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final ParticipantModel participant;
  final String payerId;
  final String currentUserId;

  const _ParticipantTile({
    required this.participant,
    required this.payerId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isPayer = participant.userId == payerId;
    final isCurrentUser = participant.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isPayer ? Colors.blue[100] : Colors.grey[200],
            child: Text(
              participant.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isPayer ? Colors.blue[800] : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      participant.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (isPayer) ...[
                      const SizedBox(width: 8),
                      _buildBadge('Payer', Colors.blue),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      _buildBadge('You', Colors.green),
                    ],
                  ],
                ),
                Text(
                  participant.formattedSplitAmount,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: participant.isSettled ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              participant.isSettled ? 'Settled' : 'Pending',
              style: TextStyle(
                color: participant.isSettled ? Colors.green[800] : Colors.orange[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color[800], fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
