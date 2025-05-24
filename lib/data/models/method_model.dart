// lib/data/models/method_model.dart

import 'package:flutter/material.dart';

class MethodModel {
  final String id;
  final String name;
  final IconData icon;

  MethodModel({required this.id, required this.name, required this.icon});

  // Helper method to parse MethodModel from id
  static MethodModel parseMethodFromId(String methodId) {
    // You can customize this mapping based on your app's methods
    switch (methodId.toLowerCase()) {
      case 'cash':
        return MethodModel(id: 'cash', name: 'Cash', icon: Icons.money);
      case 'credit_card':
        return MethodModel(
          id: 'credit_card',
          name: 'Credit Card',
          icon: Icons.credit_card,
        );
      case 'debit_card':
        return MethodModel(id: 'debit_card', name: 'Debit Card', icon: Icons.payment);
      case 'bank_transfer':
        return MethodModel(
          id: 'bank_transfer',
          name: 'Bank Transfer',
          icon: Icons.account_balance,
        );
      case 'digital_wallet':
        return MethodModel(
          id: 'digital_wallet',
          name: 'Digital Wallet',
          icon: Icons.wallet,
        );
      case 'paypal':
        return MethodModel(
          id: 'paypal',
          name: 'PayPal',
          icon: Icons.account_balance_wallet,
        );
      default:
        return MethodModel(id: methodId, name: methodId, icon: Icons.help_outline);
    }
  }

  // Create a copy with modified fields
  MethodModel copyWith({String? id, String? name, IconData? icon}) {
    return MethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'MethodModel(id: $id, name: $name, icon: IconData(${icon.codePoint}))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MethodModel &&
        other.id == id &&
        other.name == name &&
        other.icon.codePoint == icon.codePoint;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.codePoint.hashCode;
}
