// lib/data/models/method_model.dart (Updated with centralized data)

import 'package:flutter/material.dart';

class MethodModel {
  final String id;
  final String name;
  final IconData icon;
  final String? description; // NEW: Optional description

  MethodModel({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
  });

  // Centralized list of all payment methods
  static final List<MethodModel> _allMethods = [
    MethodModel(
      id: 'cash',
      name: 'Cash',
      icon: Icons.money,
      description: 'Physical cash payment',
    ),
    MethodModel(
      id: 'credit_card',
      name: 'Credit Card',
      icon: Icons.credit_card,
      description: 'Credit card payment',
    ),
    MethodModel(
      id: 'debit_card',
      name: 'Debit Card',
      icon: Icons.payment,
      description: 'Debit card payment',
    ),
    MethodModel(
      id: 'bank_transfer',
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      description: 'Direct bank transfer',
    ),
    MethodModel(
      id: 'digital_wallet',
      name: 'Digital Wallet',
      icon: Icons.wallet,
      description: 'Digital wallet (e.g., Apple Pay, Google Pay)',
    ),
    MethodModel(
      id: 'paypal',
      name: 'PayPal',
      icon: Icons.account_balance_wallet,
      description: 'PayPal payment',
    ),
    MethodModel(
      id: 'cryptocurrency',
      name: 'Cryptocurrency',
      icon: Icons.currency_bitcoin,
      description: 'Bitcoin, Ethereum, etc.',
    ),
    MethodModel(
      id: 'check',
      name: 'Check',
      icon: Icons.receipt,
      description: 'Paper check payment',
    ),
    MethodModel(
      id: 'mobile_payment',
      name: 'Mobile Payment',
      icon: Icons.phone_android,
      description: 'Mobile payment apps (Venmo, Zelle, etc.)',
    ),
    MethodModel(
      id: 'gift_card',
      name: 'Gift Card',
      icon: Icons.card_giftcard,
      description: 'Gift card or voucher',
    ),
  ];

  // Get all payment methods
  static List<MethodModel> getAllMethods() => _allMethods;

  // Helper method to parse MethodModel from id (with fallback)
  static MethodModel parseMethodFromId(String methodId) {
    try {
      return _allMethods.firstWhere((method) => method.id == methodId);
    } catch (e) {
      // Fallback to cash if not found
      return _allMethods.firstWhere(
        (method) => method.id == 'cash',
        orElse: () => MethodModel(id: methodId, name: methodId, icon: Icons.help_outline),
      );
    }
  }

  @override
  String toString() {
    return 'MethodModel(id: $id, name: $name, icon: IconData(${icon.codePoint}), description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MethodModel &&
        other.id == id &&
        other.name == name &&
        other.icon.codePoint == icon.codePoint &&
        other.description == description;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ icon.codePoint.hashCode ^ description.hashCode;
}
