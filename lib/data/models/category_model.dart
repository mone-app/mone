// lib/data/models/category_model.dart

import 'package:flutter/material.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final TransactionTypeEnum type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  // Centralized list of all categories
  static final List<CategoryModel> _allCategories = [
    // Income Categories
    CategoryModel(
      id: 'salary',
      name: 'Salary',
      icon: Icons.work,
      type: TransactionTypeEnum.income,
    ),
    CategoryModel(
      id: 'business',
      name: 'Business',
      icon: Icons.business,
      type: TransactionTypeEnum.income,
    ),
    CategoryModel(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up,
      type: TransactionTypeEnum.income,
    ),
    CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.laptop_mac,
      type: TransactionTypeEnum.income,
    ),
    CategoryModel(
      id: 'bonus',
      name: 'Bonus',
      icon: Icons.card_giftcard,
      type: TransactionTypeEnum.income,
    ),
    CategoryModel(
      id: 'rental',
      name: 'Rental Income',
      icon: Icons.home_work,
      type: TransactionTypeEnum.income,
    ),

    // Expense Categories
    CategoryModel(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.electrical_services,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'healthcare',
      name: 'Healthcare',
      icon: Icons.local_hospital,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills',
      icon: Icons.receipt_long,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.local_grocery_store,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'gas',
      name: 'Gas & Fuel',
      icon: Icons.local_gas_station,
      type: TransactionTypeEnum.expense,
    ),
    CategoryModel(
      id: 'insurance',
      name: 'Insurance',
      icon: Icons.security,
      type: TransactionTypeEnum.expense,
    ),

    // Others (can be both)
    CategoryModel(
      id: 'others_income',
      name: 'Others',
      icon: Icons.help_outline,
      type: TransactionTypeEnum.income,
    ),
    CategoryModel(
      id: 'others_expense',
      name: 'Others',
      icon: Icons.help_outline,
      type: TransactionTypeEnum.expense,
    ),
  ];

  // Get all categories
  static List<CategoryModel> getAllCategories() => _allCategories;

  // Get categories by type
  static List<CategoryModel> getCategoriesByType(TransactionTypeEnum type) {
    return _allCategories.where((category) => category.type == type).toList();
  }

  // Get income categories
  static List<CategoryModel> getIncomeCategories() {
    return getCategoriesByType(TransactionTypeEnum.income);
  }

  // Get expense categories
  static List<CategoryModel> getExpenseCategories() {
    return getCategoriesByType(TransactionTypeEnum.expense);
  }

  // Helper method to parse CategoryModel from id (with fallback)
  static CategoryModel parseCategoryFromId(String categoryId) {
    try {
      return _allCategories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      // Fallback to others_expense if not found
      return _allCategories.firstWhere(
        (category) => category.id == 'others_expense',
        orElse:
            () => CategoryModel(
              id: categoryId,
              name: categoryId,
              icon: Icons.help_outline,
              type: TransactionTypeEnum.expense,
            ),
      );
    }
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: IconData(${icon.codePoint}), type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.icon.codePoint == icon.codePoint &&
        other.type == type;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ icon.codePoint.hashCode ^ type.hashCode;
}
