// lib/features/bill/widgets/bill_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/providers/bill_provider.dart';
import 'package:mone/data/providers/user_provider.dart';

class BillActions {
  static Future<void> settleBill({
    required BuildContext context,
    required WidgetRef ref,
    required BillEntity bill,
  }) async {
    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Settle Bill'),
            content: Text(
              'Are you sure you want to mark your share (${bill.getParticipant(currentUser.id)?.formattedSplitAmount}) as settled?\n\nThis will create an expense transaction in your account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Settle'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(billProvider.notifier)
          .settleParticipant(
            billId: bill.id,
            participantUserId: currentUser.id,
            currentUserId: currentUser.id,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill settled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error settling bill: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<void> deleteBill({
    required BuildContext context,
    required WidgetRef ref,
    required BillEntity bill,
  }) async {
    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    // Check if any other participants have settled
    final otherParticipants =
        bill.participants.where((p) => p.userId != currentUser.id).toList();
    final hasSettledParticipants = otherParticipants.any((p) => p.isSettled);

    Widget content;
    String title;
    String actionText;
    bool canDelete = true;

    if (hasSettledParticipants) {
      final settledNames = otherParticipants
          .where((p) => p.isSettled)
          .map((p) => p.name)
          .join(', ');

      title = 'Cannot Delete Bill';
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Settlement Detected', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This bill cannot be deleted because the following participant${settledNames.contains(',') ? 's have' : ' has'} already settled:',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              settledNames,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'To resolve this bill, please contact the settled participants or wait for all participants to settle.',
          ),
        ],
      );
      actionText = 'Understood';
      canDelete = false;
    } else {
      title = 'Delete Bill';
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this bill?'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This will:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('• Remove the bill for all participants'),
                Text('• Delete your related transactions'),
                Text('• Restore your account balance'),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      );
      actionText = 'Delete';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: content,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, canDelete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canDelete ? Colors.red : null,
                ),
                child: Text(actionText),
              ),
            ],
          ),
    );

    if (confirmed != true || !canDelete) return;

    try {
      await ref.read(billProvider.notifier).deleteBill(bill.id, currentUser.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting bill: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
