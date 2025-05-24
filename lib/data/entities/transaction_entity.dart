// lib/data/entities/transaction_entity.dart

import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/method_model.dart';

enum TransactionType { income, expense }

class TransactionEntity {
  final String id;
  final TransactionType type;
  final DateTime date;
  final double amount;
  final MethodModel method;
  final CategoryModel category;
  final String? description;

  TransactionEntity({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.method,
    required this.category,
    this.description,
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
      'description': description,
    };
  }

  // Create TransactionEntity from Firebase Map
  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] ?? '',
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: MethodModel.parseMethodFromId(map['method'] ?? ''),
      category: CategoryModel.parseCategoryFromId(map['category'] ?? ''),
      description: map['description'],
    );
  }

  // Create a copy with modified fields
  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    DateTime? date,
    double? amount,
    MethodModel? method,
    CategoryModel? category,
    String? description,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'TransactionEntity(id: $id, type: $type, date: $date, amount: $amount, method: $method, category: $category, description: $description)';
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
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        date.hashCode ^
        amount.hashCode ^
        method.hashCode ^
        category.hashCode ^
        description.hashCode;
  }
}
