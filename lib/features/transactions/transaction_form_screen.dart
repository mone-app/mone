// lib/features/transaction/transaction_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/method_model.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/data/providers/transaction_provider.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionEntity? transaction; // For editing existing transactions

  const TransactionFormScreen({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionTypeEnum _selectedType = TransactionTypeEnum.expense;
  CategoryModel? _selectedCategory;
  MethodModel? _selectedMethod;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (isEditing) {
      // Populate form with existing transaction data
      final transaction = widget.transaction!;
      _selectedType = transaction.type;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _descriptionController.text = transaction.description ?? '';
      _selectedCategory = transaction.category;
      _selectedMethod = transaction.method;
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
    } else {
      // Initialize with default values for new transaction
      final expenseCategories = CategoryModel.getExpenseCategories();
      final allMethods = MethodModel.getAllMethods();

      if (expenseCategories.isNotEmpty) {
        _selectedCategory = expenseCategories.first;
      }
      if (allMethods.isNotEmpty) {
        _selectedMethod = allMethods.first;
      }
    }
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
          final incomeCategories = CategoryModel.getIncomeCategories();
          _selectedCategory = incomeCategories.isNotEmpty ? incomeCategories.first : null;
        } else {
          final expenseCategories = CategoryModel.getExpenseCategories();
          _selectedCategory =
              expenseCategories.isNotEmpty ? expenseCategories.first : null;
        }
      });
    }
  }

  Future<void> _selectDate() async {
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
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProvider);
    if (user == null) {
      _showErrorMessage('User not found. Please try again.');
      return;
    }

    if (_selectedCategory == null || _selectedMethod == null) {
      _showErrorMessage('Please select category and payment method.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final transaction = TransactionEntity(
        id: isEditing ? widget.transaction!.id : const Uuid().v4(),
        type: _selectedType,
        date: combinedDateTime,
        amount: double.parse(_amountController.text),
        method: _selectedMethod!,
        category: _selectedCategory!,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      );

      if (isEditing) {
        await ref
            .read(transactionProvider.notifier)
            .updateTransaction(user.id, transaction.id, transaction);
        _showSuccessMessage('Transaction updated successfully!');
      } else {
        await ref
            .read(transactionProvider.notifier)
            .createTransaction(user.id, transaction);
        _showSuccessMessage('Transaction created successfully!');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorMessage('Error saving transaction: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = _getAvailableCategories();
    final availableMethods = _getAvailableMethods();

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TransactionTypeEnum>(
                                title: const Text('Income'),
                                value: TransactionTypeEnum.income,
                                groupValue: _selectedType,
                                onChanged: _onTypeChanged,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<TransactionTypeEnum>(
                                title: const Text('Expense'),
                                value: TransactionTypeEnum.expense,
                                groupValue: _selectedType,
                                onChanged: _onTypeChanged,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                if (availableCategories.isNotEmpty)
                  DropdownButtonFormField<CategoryModel>(
                    value:
                        availableCategories.contains(_selectedCategory)
                            ? _selectedCategory
                            : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        availableCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(category.icon, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    category.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                if (availableMethods.isNotEmpty)
                  DropdownButtonFormField<MethodModel>(
                    value:
                        availableMethods.contains(_selectedMethod)
                            ? _selectedMethod
                            : null,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        availableMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(method.icon, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    method.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                    hintText: 'Add a note about this transaction...',
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),

                const SizedBox(height: 16),

                // Date and Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Date'),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                          ),
                          onTap: _selectDate,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Time'),
                          subtitle: Text(_selectedTime.format(context)),
                          onTap: _selectTime,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              isEditing ? 'Update Transaction' : 'Save Transaction',
                              style: const TextStyle(fontSize: 16),
                            ),
                  ),
                ),

                // Delete button for editing mode
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _showDeleteConfirmation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Delete Transaction',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTransaction();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction() async {
    final user = ref.read(userProvider);
    if (user == null || !isEditing) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(transactionProvider.notifier)
          .deleteTransaction(user.id, widget.transaction!.id);

      _showSuccessMessage('Transaction deleted successfully!');

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorMessage('Error deleting transaction: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Get available categories based on selected type
  List<CategoryModel> _getAvailableCategories() {
    return CategoryModel.getCategoriesByType(_selectedType);
  }

  // Get available payment methods
  List<MethodModel> _getAvailableMethods() {
    return MethodModel.getAllMethods();
  }
}
