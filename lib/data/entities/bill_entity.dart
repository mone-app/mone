// lib/data/entities/bill_entity.dart

import 'package:flutter/foundation.dart';
import 'package:mone/data/enums/bill_status_enum.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/participant_model.dart';

class BillEntity {
  final String id;
  final String userId;
  final DateTime date;
  final double amount;
  final String title;
  final String? description;
  final List<ParticipantModel> participants;
  final CategoryModel category;
  final String payerId;
  final BillStatusEnum status;
  final String? billReceiptImageUrl;

  BillEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.title,
    this.description,
    required this.participants,
    required this.category,
    required this.payerId,
    required this.status,
    this.billReceiptImageUrl,
  });

  // Convert BillEntity to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'title': title,
      'description': description,
      'participants': participants.map((p) => p.toMap()).toList(),
      'category': category.id,
      'payerId': payerId,
      'status': status.name,
      'billReceiptImageUrl': billReceiptImageUrl,
    };
  }

  // Create BillEntity from Firebase Map
  factory BillEntity.fromMap(Map<String, dynamic> map) {
    return BillEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      amount: (map['amount'] ?? 0.0).toDouble(),
      title: map['title'] ?? '',
      description: map['description'],
      participants:
          (map['participants'] as List<dynamic>?)
              ?.map((p) => ParticipantModel.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      category: CategoryModel.parseCategoryFromId(map['category'] ?? ''),
      payerId: map['payerId'] ?? '',
      status: BillStatusEnum.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BillStatusEnum.active,
      ),
      billReceiptImageUrl: map['billReceiptImageUrl'],
    );
  }

  // Create a copy with modified fields
  BillEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? amount,
    String? title,
    String? description,
    List<ParticipantModel>? participants,
    CategoryModel? category,
    String? payerId,
    BillStatusEnum? status,
    String? billReceiptImageUrl,
  }) {
    return BillEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      category: category ?? this.category,
      payerId: payerId ?? this.payerId,
      status: status ?? this.status,
      billReceiptImageUrl: billReceiptImageUrl ?? this.billReceiptImageUrl,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'BillEntity(id: $id, userId: $userId, date: $date, amount: $amount, title: $title, description: $description, participants: $participants, category: $category, payerId: $payerId, status: $status, billReceiptImageUrl: $billReceiptImageUrl)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillEntity &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.amount == amount &&
        other.title == title &&
        other.description == description &&
        listEquals(other.participants, participants) &&
        other.category == category &&
        other.payerId == payerId &&
        other.status == status &&
        other.billReceiptImageUrl == billReceiptImageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        date.hashCode ^
        amount.hashCode ^
        title.hashCode ^
        description.hashCode ^
        participants.hashCode ^
        category.hashCode ^
        payerId.hashCode ^
        status.hashCode ^
        billReceiptImageUrl.hashCode;
  }

  // Helper methods for bill management

  /// Check if the bill is settled
  bool get isSettled => status == BillStatusEnum.settled;

  /// Check if the bill is active
  bool get isActive => status == BillStatusEnum.active;

  /// Check if a user is a participant in this bill
  bool isParticipant(String userId) {
    return participants.any((p) => p.userId == userId);
  }

  /// Check if a user is the payer of this bill
  bool isPayer(String userId) {
    return payerId == userId;
  }

  /// Get the number of participants
  int get participantCount => participants.length;

  /// Get total amount settled by participants
  double get totalSettledAmount {
    return participants
        .where((p) => p.isSettled)
        .fold(0.0, (sum, p) => sum + p.splitAmount);
  }

  /// Get total amount unsettled
  double get totalUnsettledAmount {
    return participants
        .where((p) => !p.isSettled)
        .fold(0.0, (sum, p) => sum + p.splitAmount);
  }

  /// Check if all participants have settled their amounts
  bool get isFullySettled {
    return participants.every((p) => p.isSettled);
  }

  /// Get list of settled participants
  List<ParticipantModel> get settledParticipants {
    return participants.where((p) => p.isSettled).toList();
  }

  /// Get list of unsettled participants
  List<ParticipantModel> get unsettledParticipants {
    return participants.where((p) => !p.isSettled).toList();
  }

  /// Get participant by userId
  ParticipantModel? getParticipant(String userId) {
    try {
      return participants.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }
}
