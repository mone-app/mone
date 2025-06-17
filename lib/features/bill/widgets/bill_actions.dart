// lib/features/bill/widgets/bill_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/providers/bill_provider.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/widgets/confirmation_dialog.dart';

class BillActions {
  static Future<void> settleBill({
    required BuildContext context,
    required WidgetRef ref,
    required BillEntity bill,
  }) async {
    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    final currentUserParticipant = bill.getParticipant(currentUser.id);
    if (currentUserParticipant == null) return;

    final payerName =
        bill.participants.firstWhere((p) => p.userId == bill.payerId).name;

    // Show confirmation dialog
    await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Settle Bill',
            description:
                'Are you sure you want to mark your share as settled?\n\n'
                'Amount: ${currentUserParticipant.formattedSplitAmount}\n'
                'Payer: $payerName\n\n'
                'This will create an expense transaction in your account and notify the payer.',
            confirmButtonText: 'Settle Bill',
            cancelButtonText: 'Cancel',
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            onConfirm: () async {
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
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('Bill settled successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Error settling bill: $e'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
          ),
    );
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

    if (hasSettledParticipants) {
      final settledNames = otherParticipants
          .where((p) => p.isSettled)
          .map((p) => p.name)
          .join(', ');

      // Show warning dialog for bills with settled participants
      await showDialog(
        context: context,
        builder:
            (context) => ConfirmationDialog(
              title: 'Cannot Delete Bill',
              description:
                  'This bill cannot be deleted because the following participant${settledNames.contains(',') ? 's have' : ' has'} already settled:\n\n'
                  '$settledNames\n\n'
                  'To resolve this bill, please contact the settled participants or wait for all participants to settle.',
              confirmButtonText: 'Understood',
              cancelButtonText: null, // Hide cancel button
              icon: Icons.warning_amber,
              iconColor: Colors.orange,
              onConfirm: () {
                // Do nothing, just close the dialog
              },
            ),
      );
      return;
    }

    // Show delete confirmation dialog
    await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Delete Bill',
            description:
                'Are you sure you want to delete this bill?\n\n'
                'This will:\n'
                '• Remove the bill for all participants\n'
                '• Delete your related transactions\n'
                '• Restore your account balance\n\n'
                'This action cannot be undone.',
            confirmButtonText: 'Delete Bill',
            cancelButtonText: 'Cancel',
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            onConfirm: () async {
              try {
                await ref
                    .read(billProvider.notifier)
                    .deleteBill(bill.id, currentUser.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('Bill deleted successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Error deleting bill: $e'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
          ),
    );
  }
}
