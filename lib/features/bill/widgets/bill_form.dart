// lib/features/bill/widgets/bill_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mone/core/theme/app_color.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/widgets/custom_input_field.dart';

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
          CustomInputField(
            controller: titleController,
            labelText: 'Bill Title',
            hintText: 'e.g., Dinner at Restaurant',
            prefixIcon: Icons.receipt_long,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a bill title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Bill Description
          CustomInputField(
            controller: descriptionController,
            labelText: 'Description',
            hintText: 'Add more details about the bill...',
            prefixIcon: Icons.note_outlined,
            // No validator for optional field
          ),
          const SizedBox(height: 16),

          // Total Amount
          CustomInputField(
            controller: amountController,
            labelText: 'Total Amount',
            hintText: 'Enter total amount',
            prefixIcon: Icons.attach_money,
            prefixText: "Rp ",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          _buildCategoryDropdown(context),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    final categories = CategoryModel.getExpenseCategories();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.containerSurface(context),
      ),
      child: DropdownButtonFormField<CategoryModel>(
        value: categories.contains(selectedCategory) ? selectedCategory : null,
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(Icons.category),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
        items:
            categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
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
        icon: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}
