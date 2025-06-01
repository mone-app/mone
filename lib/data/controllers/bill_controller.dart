// lib/data/controllers/bill_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/enums/bill_status_enum.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/method_model.dart';
import 'package:mone/data/models/participant_model.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/data/repositories/bill_repository.dart';
import 'package:uuid/uuid.dart';

class BillController extends StateNotifier<List<BillEntity>> {
  final BillRepository _billRepository;
  final Ref _ref;

  BillController(this._billRepository, this._ref) : super([]);

  void setBills(List<BillEntity> bills) {
    state = bills;
  }

  // Create a split bill
  Future<void> createSplitBill({
    required String payerId,
    required String title,
    required String? description,
    required double totalAmount,
    required CategoryModel category,
    required List<ParticipantModel> participants,
    required DateTime date,
    String? billReceiptImageUrl,
  }) async {
    try {
      const uuid = Uuid();
      final billId = uuid.v4();

      // Create the bill entity
      final bill = BillEntity(
        id: billId,
        userId: payerId, // Bill creator
        date: date,
        amount: totalAmount,
        title: title,
        description: description,
        participants: participants,
        category: category,
        payerId: payerId,
        status: BillStatusEnum.active,
        billReceiptImageUrl: billReceiptImageUrl,
      );

      // Get all participant user IDs
      final participantIds = participants.map((p) => p.userId).toList();

      // Create bill for all participants
      await _billRepository.createBillForParticipants(bill, participantIds);

      // Create transactions for the payer
      await _createPayerTransactions(
        payerId: payerId,
        bill: bill,
        participants: participants,
        category: category,
        date: date,
      );

      // Update local state
      state = [...state, bill];
      state.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      rethrow;
    }
  }

  // Create transactions for the payer when creating a bill
  Future<void> _createPayerTransactions({
    required String payerId,
    required BillEntity bill,
    required List<ParticipantModel> participants,
    required CategoryModel category,
    required DateTime date,
  }) async {
    const uuid = Uuid();

    // Find payer's split amount
    final payerParticipant = participants.firstWhere((p) => p.userId == payerId);
    final payerSplitAmount = payerParticipant.splitAmount;

    // Calculate others' total amount
    final othersTotalAmount = participants
        .where((p) => p.userId != payerId)
        .fold(0.0, (sum, p) => sum + p.splitAmount);

    // Transaction 1: Payer's own split (expense)
    final payerSplitTransaction = TransactionEntity(
      id: uuid.v4(),
      type: TransactionTypeEnum.expense,
      date: date,
      amount: payerSplitAmount,
      method: MethodModel.parseMethodFromId('cash'), // Default method
      category: category,
      description: 'Split bill - ${bill.title} (My share)',
    );

    // Transaction 2: Amount paid for others (expense)
    if (othersTotalAmount > 0) {
      final paidForOthersTransaction = TransactionEntity(
        id: uuid.v4(),
        type: TransactionTypeEnum.expense,
        date: date,
        amount: othersTotalAmount,
        method: MethodModel.parseMethodFromId('cash'), // Default method
        category: category,
        description: 'Split bill - ${bill.title} (Paid for others)',
      );

      // Create both transactions
      await _ref
          .read(transactionProvider.notifier)
          .createTransaction(payerId, paidForOthersTransaction);
    }

    await _ref
        .read(transactionProvider.notifier)
        .createTransaction(payerId, payerSplitTransaction);
  }

  // Mark participant as settled
  Future<void> settleParticipant({
    required String billId,
    required String participantUserId,
    required String currentUserId,
  }) async {
    try {
      // Find the bill
      final billIndex = state.indexWhere((bill) => bill.id == billId);
      if (billIndex == -1) return;

      final bill = state[billIndex];

      // Find the participant
      final participantIndex = bill.participants.indexWhere(
        (p) => p.userId == participantUserId,
      );
      if (participantIndex == -1) return;

      final participant = bill.participants[participantIndex];
      if (participant.isSettled) return; // Already settled

      // Update participant as settled
      final updatedParticipants = List<ParticipantModel>.from(bill.participants);
      updatedParticipants[participantIndex] = participant.copyWith(isSettled: true);

      // Check if all participants are now settled
      final allSettled = updatedParticipants.every((p) => p.isSettled);

      // Update bill
      final updatedBill = bill.copyWith(
        participants: updatedParticipants,
        status: allSettled ? BillStatusEnum.settled : BillStatusEnum.active,
      );

      // Get all participant IDs for updating
      final participantIds = bill.participants.map((p) => p.userId).toList();

      // Update bill for all participants
      await _billRepository.updateBillForAllParticipants(updatedBill, participantIds);

      // Create transactions for settlement
      await _createSettlementTransactions(
        bill: bill,
        participant: participant,
        settlerUserId: participantUserId,
        payerId: bill.payerId,
      );

      // Update local state
      final updatedState = List<BillEntity>.from(state);
      updatedState[billIndex] = updatedBill;
      state = updatedState;
    } catch (e) {
      rethrow;
    }
  }

  // Create transactions when a participant settles
  Future<void> _createSettlementTransactions({
    required BillEntity bill,
    required ParticipantModel participant,
    required String settlerUserId,
    required String payerId,
  }) async {
    const uuid = Uuid();

    // Create expense transaction for the participant (person who settled)
    final participantExpenseTransaction = TransactionEntity(
      id: uuid.v4(),
      type: TransactionTypeEnum.expense,
      date: DateTime.now(),
      amount: participant.splitAmount,
      method: MethodModel.parseMethodFromId('cash'), // Default method
      category: bill.category,
      description: 'Split bill payment - ${bill.title}',
    );

    // Create income transaction for the payer
    final payerIncomeTransaction = TransactionEntity(
      id: uuid.v4(),
      type: TransactionTypeEnum.income,
      date: DateTime.now(),
      amount: participant.splitAmount,
      method: MethodModel.parseMethodFromId('cash'), // Default method
      category: bill.category,
      description: 'Split bill received - ${bill.title} (from ${participant.name})',
    );

    // Create both transactions
    await _ref
        .read(transactionProvider.notifier)
        .createTransaction(settlerUserId, participantExpenseTransaction);

    await _ref
        .read(transactionProvider.notifier)
        .createTransaction(payerId, payerIncomeTransaction);
  }

  // Delete a bill (only by creator/payer)
  Future<void> deleteBill(String billId, String currentUserId) async {
    try {
      final bill = state.firstWhere((b) => b.id == billId);

      // Only payer can delete
      if (bill.payerId != currentUserId) {
        throw Exception('Only the bill creator can delete this bill');
      }

      // Get all participant IDs
      final participantIds = bill.participants.map((p) => p.userId).toList();

      // Delete bill from all participants
      await _billRepository.deleteBillFromAllParticipants(
        billId,
        participantIds,
        bill.payerId,
      );

      // Update local state
      state = state.where((b) => b.id != billId).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to calculate split amounts evenly
  static List<double> calculateEvenSplit(double totalAmount, int participantCount) {
    if (participantCount <= 0) return [];

    final baseAmount = totalAmount / participantCount;
    final roundedBaseAmount =
        (baseAmount * 100).floor() / 100; // Round down to 2 decimal places
    final remainder = totalAmount - (roundedBaseAmount * participantCount);

    final amounts = List.filled(participantCount, roundedBaseAmount);

    // Add remainder to the last person to ensure no money is left
    if (remainder > 0) {
      amounts[participantCount - 1] += remainder;
    }

    return amounts;
  }

  // Get bills where current user is the payer
  List<BillEntity> getPayerBills(String userId) {
    return state.where((bill) => bill.payerId == userId).toList();
  }

  // Get bills where current user is a participant (not payer)
  List<BillEntity> getParticipantBills(String userId) {
    return state
        .where(
          (bill) =>
              bill.payerId != userId && bill.participants.any((p) => p.userId == userId),
        )
        .toList();
  }

  // Get unsettled bills for current user
  List<BillEntity> getUnsettledBills(String userId) {
    return state.where((bill) {
      if (bill.status == BillStatusEnum.settled) return false;

      // If user is payer, show bills with unsettled participants
      if (bill.payerId == userId) {
        return bill.participants.any((p) => !p.isSettled);
      }

      // If user is participant, show bills where they haven't settled
      final participant = bill.participants.where((p) => p.userId == userId).firstOrNull;
      return participant != null && !participant.isSettled;
    }).toList();
  }
}
