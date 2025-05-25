// lib/data/repositories/transaction_repository.dart (Using subcollections)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mone/data/entities/transaction_entity.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get user's transaction collection reference
  CollectionReference _getUserTransactionCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  // Create a new transaction under user's subcollection
  Future<void> createTransaction(String userId, TransactionEntity transaction) async {
    await _getUserTransactionCollection(
      userId,
    ).doc(transaction.id).set(transaction.toMap());
  }

  // Update an existing transaction
  Future<void> updateTransaction(String userId, TransactionEntity transaction) async {
    await _getUserTransactionCollection(
      userId,
    ).doc(transaction.id).update(transaction.toMap());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _getUserTransactionCollection(userId).doc(transactionId).delete();
  }

  // Fetch a single transaction
  Future<TransactionEntity?> fetchTransaction(String userId, String transactionId) async {
    DocumentSnapshot doc =
        await _getUserTransactionCollection(userId).doc(transactionId).get();

    if (doc.exists) {
      return TransactionEntity.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Fetch all transactions for a user
  Future<List<TransactionEntity>> fetchUserTransactions(String userId) async {
    QuerySnapshot snapshot =
        await _getUserTransactionCollection(
          userId,
        ).orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => TransactionEntity.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Watch all transactions for a user (real-time)
  Stream<List<TransactionEntity>> watchUserTransactions(String userId) {
    return _getUserTransactionCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        TransactionEntity.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }
}
