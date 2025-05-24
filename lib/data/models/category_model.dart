// lib/data/models/category_model.dart

import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;

  CategoryModel({required this.id, required this.name, required this.icon});

  // Helper method to parse CategoryModel from id
  static CategoryModel parseCategoryFromId(String categoryId) {
    // You can customize this mapping based on your app's categories
    switch (categoryId.toLowerCase()) {
      case 'food':
        return CategoryModel(id: 'food', name: 'Food', icon: Icons.restaurant);
      case 'transport':
        return CategoryModel(
          id: 'transport',
          name: 'Transport',
          icon: Icons.directions_car,
        );
      case 'shopping':
        return CategoryModel(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag);
      case 'entertainment':
        return CategoryModel(
          id: 'entertainment',
          name: 'Entertainment',
          icon: Icons.movie,
        );
      case 'utilities':
        return CategoryModel(id: 'utilities', name: 'Utilities', icon: Icons.home);
      case 'healthcare':
        return CategoryModel(
          id: 'healthcare',
          name: 'Healthcare',
          icon: Icons.local_hospital,
        );
      case 'education':
        return CategoryModel(id: 'education', name: 'Education', icon: Icons.school);
      case 'salary':
        return CategoryModel(id: 'salary', name: 'Salary', icon: Icons.work);
      case 'business':
        return CategoryModel(id: 'business', name: 'Business', icon: Icons.business);
      case 'investment':
        return CategoryModel(
          id: 'investment',
          name: 'Investment',
          icon: Icons.trending_up,
        );
      case 'others':
        return CategoryModel(id: 'others', name: 'Others', icon: Icons.help_outline);
      default:
        return CategoryModel(id: categoryId, name: categoryId, icon: Icons.help_outline);
    }
  }

  // Create a copy with modified fields
  CategoryModel copyWith({String? id, String? name, IconData? icon}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: IconData(${icon.codePoint}))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.icon.codePoint == icon.codePoint;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.codePoint.hashCode;
}
