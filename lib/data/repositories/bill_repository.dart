// lib/data/repositories/bill_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mone/data/entities/bill_entity.dart';

class BillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get user's bill collection reference
  CollectionReference _getUserBillCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('bills');
  }

  // Create a new bill under user's subcollection
  Future<void> createBill(String userId, BillEntity bill) async {
    await _getUserBillCollection(userId).doc(bill.id).set(bill.toMap());
  }

  // Update an existing bill
  Future<void> updateBill(String userId, BillEntity bill) async {
    await _getUserBillCollection(userId).doc(bill.id).update(bill.toMap());
  }

  // Delete a bill
  Future<void> deleteBill(String userId, String billId) async {
    await _getUserBillCollection(userId).doc(billId).delete();
  }

  // Fetch a single bill
  Future<BillEntity?> fetchBill(String userId, String billId) async {
    DocumentSnapshot doc = await _getUserBillCollection(userId).doc(billId).get();

    if (doc.exists) {
      return BillEntity.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Fetch all bills for a user
  Future<List<BillEntity>> fetchUserBills(String userId) async {
    QuerySnapshot snapshot =
        await _getUserBillCollection(userId).orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => BillEntity.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Watch all bills for a user (real-time)
  Stream<List<BillEntity>> watchUserBills(String userId) {
    return _getUserBillCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BillEntity.fromMap(doc.data() as Map<String, dynamic>))
                  .toList(),
        );
  }

  // Create bill for multiple participants
  Future<void> createBillForParticipants(
    BillEntity bill,
    List<String> participantUserIds,
  ) async {
    // Create a batch to ensure all operations succeed or fail together
    WriteBatch batch = _firestore.batch();

    // Add bill to each participant's bill collection
    for (String userId in participantUserIds) {
      DocumentReference billRef = _getUserBillCollection(userId).doc(bill.id);
      batch.set(billRef, bill.toMap());
    }

    // Also add to payer's collection if not already included
    if (!participantUserIds.contains(bill.payerId)) {
      DocumentReference payerBillRef = _getUserBillCollection(bill.payerId).doc(bill.id);
      batch.set(payerBillRef, bill.toMap());
    }

    await batch.commit();
  }

  // Update bill for all participants
  Future<void> updateBillForAllParticipants(
    BillEntity bill,
    List<String> participantUserIds,
  ) async {
    WriteBatch batch = _firestore.batch();

    // Update bill in each participant's collection
    for (String userId in participantUserIds) {
      DocumentReference billRef = _getUserBillCollection(userId).doc(bill.id);
      batch.update(billRef, bill.toMap());
    }

    // Also update in payer's collection if not already included
    if (!participantUserIds.contains(bill.payerId)) {
      DocumentReference payerBillRef = _getUserBillCollection(bill.payerId).doc(bill.id);
      batch.update(payerBillRef, bill.toMap());
    }

    await batch.commit();
  }

  // Delete bill from all participants
  Future<void> deleteBillFromAllParticipants(
    String billId,
    List<String> participantUserIds,
    String payerId,
  ) async {
    WriteBatch batch = _firestore.batch();

    // Delete from each participant's collection
    for (String userId in participantUserIds) {
      DocumentReference billRef = _getUserBillCollection(userId).doc(billId);
      batch.delete(billRef);
    }

    // Also delete from payer's collection if not already included
    if (!participantUserIds.contains(payerId)) {
      DocumentReference payerBillRef = _getUserBillCollection(payerId).doc(billId);
      batch.delete(payerBillRef);
    }

    await batch.commit();
  }
}
