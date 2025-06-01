// lib/features/bill/bill_detail_screen.dart (Refactored)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/enums/bill_status_enum.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/bill/widgets/bill_actions.dart';
import 'package:mone/features/bill/widgets/bill_overview_card.dart';
import 'package:mone/features/bill/widgets/participant_list_card.dart';
import 'package:mone/features/bill/widgets/payer_summary_card.dart';
import 'package:mone/features/bill/widgets/settlement_progress_card.dart';
import 'package:mone/features/bill/widgets/user_share_card.dart';

class BillDetailScreen extends ConsumerStatefulWidget {
  final BillEntity bill;

  const BillDetailScreen({super.key, required this.bill});

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  bool _isSettling = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCreator = widget.bill.payerId == currentUser.id;
    final currentUserParticipant =
        widget.bill.participants.where((p) => p.userId == currentUser.id).firstOrNull;
    final canSettle =
        currentUserParticipant != null &&
        !currentUserParticipant.isSettled &&
        !isCreator &&
        widget.bill.status == BillStatusEnum.active;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill.title),
        actions: [
          if (isCreator && widget.bill.status == BillStatusEnum.active)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  BillActions.deleteBill(context: context, ref: ref, bill: widget.bill);
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Bill'),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Overview
            BillOverviewCard(bill: widget.bill),
            const SizedBox(height: 16),

            // Settlement Progress (for active bills)
            SettlementProgressCard(bill: widget.bill),
            if (!widget.bill.isSettled) const SizedBox(height: 16),

            // Participants List
            ParticipantsListCard(bill: widget.bill, currentUserId: currentUser.id),

            // User Share Information (for non-payers)
            if (currentUserParticipant != null && !isCreator) ...[
              const SizedBox(height: 16),
              UserShareCard(
                bill: widget.bill,
                currentUserParticipant: currentUserParticipant,
                canSettle: canSettle,
              ),
            ],

            // Payer Summary (for bill creator)
            if (isCreator) ...[
              const SizedBox(height: 16),
              PayerSummaryCard(bill: widget.bill),
            ],
          ],
        ),
      ),
      bottomNavigationBar:
          canSettle
              ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isSettling ? null : _settleBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSettling
                            ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Settling...'),
                              ],
                            )
                            : Text(
                              'Mark as Settled (\$${currentUserParticipant.splitAmount.toStringAsFixed(2)})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              )
              : null,
    );
  }

  Future<void> _settleBill() async {
    setState(() {
      _isSettling = true;
    });

    try {
      await BillActions.settleBill(context: context, ref: ref, bill: widget.bill);
    } finally {
      if (mounted) {
        setState(() {
          _isSettling = false;
        });
      }
    }
  }
}
