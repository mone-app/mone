// lib/features/transaction/transaction_form_screen.dart (Using models)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/method_model.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/data/providers/user_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionTypeEnum _selectedType = TransactionTypeEnum.expense;
  CategoryModel? _selectedCategory;
  MethodModel? _selectedMethod;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize with default values
    _selectedCategory = CategoryModel.getExpenseCategories().first;
    _selectedMethod = MethodModel.getAllMethods().first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionTypeEnum? type) {
    if (type != null) {
      setState(() {
        _selectedType = type;
        // Reset category when type changes
        if (type == TransactionTypeEnum.income) {
          _selectedCategory = CategoryModel.getIncomeCategories().first;
        } else {
          _selectedCategory = CategoryModel.getExpenseCategories().first;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Just show success message for now
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction saved successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = _getAvailableCategories();
    final availableMethods = _getAvailableMethods();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Transaction Type
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TransactionTypeEnum>(
                      title: const Text('Income'),
                      value: TransactionTypeEnum.income,
                      groupValue: _selectedType,
                      onChanged: _onTypeChanged,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TransactionTypeEnum>(
                      title: const Text('Expense'),
                      value: TransactionTypeEnum.expense,
                      groupValue: _selectedType,
                      onChanged: _onTypeChanged,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: const OutlineInputBorder(),
                  prefixIcon:
                      _selectedCategory != null
                          ? Icon(_selectedCategory!.icon)
                          : const Icon(Icons.category),
                ),
                items:
                    availableCategories.map((category) {
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
                onChanged: (CategoryModel? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Payment Method Dropdown
              DropdownButtonFormField<MethodModel>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: const OutlineInputBorder(),
                  prefixIcon:
                      _selectedMethod != null
                          ? Icon(_selectedMethod!.icon)
                          : const Icon(Icons.payment),
                ),
                items:
                    availableMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Row(
                          children: [
                            Icon(method.icon, size: 20),
                            const SizedBox(width: 8),
                            Text(method.name),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (MethodModel? value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Date Picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Transaction', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get available categories based on selected type
  List<CategoryModel> _getAvailableCategories() {
    return CategoryModel.getCategoriesByType(_selectedType);
  }

  // Get available payment methods (using common methods for simplicity)
  List<MethodModel> _getAvailableMethods() {
    return MethodModel.getAllMethods(); // or use getCommonMethods() for fewer options
  }
}
