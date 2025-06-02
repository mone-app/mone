// lib/features/bill/widgets/bill_form_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mone/data/models/category_model.dart';

class BillForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final CategoryModel? selectedCategory;
  final Function(CategoryModel?) onCategoryChanged;
  final VoidCallback? onAmountChanged;

  const BillForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.amountController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill Title
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Bill Title *',
              hintText: 'e.g., Dinner at Restaurant',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a bill title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Bill Description
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add more details about the bill',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Total Amount
          TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Total Amount *',
              hintText: '0.00',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the total amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onChanged: (_) => onAmountChanged?.call(),
          ),
          const SizedBox(height: 16),

          // Category Selection
          DropdownButtonFormField<CategoryModel>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
            ),
            items:
                CategoryModel.getExpenseCategories().map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: onCategoryChanged,
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
