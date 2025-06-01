// lib/data/entities/transaction_entity.dart

import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/method_model.dart';

class TransactionEntity {
  final String id;
  final TransactionTypeEnum type;
  final DateTime date;
  final double amount;
  final MethodModel method;
  final CategoryModel category;
  final String? description;
  final String title;
  final bool isEditableAndDeletable;
  final String? relatedBillId;

  TransactionEntity({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.method,
    required this.category,
    required this.title,
    this.isEditableAndDeletable = true,
    this.description,
    this.relatedBillId,
  });

  // Convert TransactionEntity to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'method': method.id,
      'category': category.id,
      'title': title,
      'isEditableAndDeletable': isEditableAndDeletable,
      'relatedBillId': relatedBillId,
      'description': description,
    };
  }

  // Create TransactionEntity from Firebase Map
  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] ?? '',
      type:
          map['type'] == 'income'
              ? TransactionTypeEnum.income
              : TransactionTypeEnum.expense,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: MethodModel.parseMethodFromId(map['method'] ?? ''),
      category: CategoryModel.parseCategoryFromId(map['category'] ?? ''),
      description: map['description'],
      isEditableAndDeletable: map['isEditableAndDeletable'] ?? true,
      title: map['title'] ?? '',
      relatedBillId: map['relatedBillId'],
    );
  }

  // Create a copy with modified fields
  TransactionEntity copyWith({
    String? id,
    TransactionTypeEnum? type,
    DateTime? date,
    double? amount,
    MethodModel? method,
    CategoryModel? category,
    String? description,
    bool? isEditableAndDeletable,
    String? title,
    String? relatedBillId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      category: category ?? this.category,
      description: description ?? this.description,
      isEditableAndDeletable: isEditableAndDeletable ?? this.isEditableAndDeletable,
      title: title ?? this.title,
      relatedBillId: relatedBillId ?? this.relatedBillId,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'TransactionEntity(id: $id, type: $type, date: $date, amount: $amount, method: $method, category: $category, description: $description, isEditableAndDeletable: $isEditableAndDeletable, title: $title, relatedBillId: $relatedBillId)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity &&
        other.id == id &&
        other.type == type &&
        other.date == date &&
        other.amount == amount &&
        other.method == method &&
        other.category == category &&
        other.description == description &&
        other.isEditableAndDeletable == isEditableAndDeletable &&
        other.relatedBillId == relatedBillId &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        date.hashCode ^
        amount.hashCode ^
        method.hashCode ^
        category.hashCode ^
        description.hashCode ^
        isEditableAndDeletable.hashCode ^
        relatedBillId.hashCode ^
        title.hashCode;
  }

  /// Check if this is an income transaction
  bool get isIncome => type == TransactionTypeEnum.income;

  /// Check if this is an expense transaction
  bool get isExpense => type == TransactionTypeEnum.expense;

  /// Get the formatted amount with proper sign
  double get signedAmount => isIncome ? amount : -amount;
}
