// lib/features/transaction/transaction_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mone/core/theme/app_color.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/method_model.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/widgets/custom_button.dart';
import 'package:mone/widgets/custom_input_field.dart';
import 'package:mone/widgets/confirmation_dialog.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionEntity? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
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
  final bool _isBordered = true;

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
          _selectedCategory =
              incomeCategories.isNotEmpty ? incomeCategories.first : null;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
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
        title:
            "${_selectedType.name} - ${_selectedCategory!.name}", // TODO: implement to get title from form
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Delete Transaction',
          description:
              'Are you sure you want to delete this transaction? This action cannot be undone.',
          confirmButtonText: 'Delete',
          cancelButtonText: 'Cancel',
          icon: Icons.delete_outline,
          iconColor: Colors.red,
          onConfirm: () async {
            await _deleteTransaction();
          },
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

  @override
  Widget build(BuildContext context) {
    final availableCategories = _getAvailableCategories();
    final availableMethods = _getAvailableMethods();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Transaction Type Selection
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.containerSurface(context),
                      borderRadius: BorderRadius.circular(15),
                      border:
                          _isBordered
                              ? Border.all(color: colorScheme.primary)
                              : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            context,
                            'Income',
                            Icons.trending_up,
                            TransactionTypeEnum.income,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildTypeButton(
                            context,
                            'Expense',
                            Icons.trending_down,
                            TransactionTypeEnum.expense,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount Field
                  CustomInputField(
                    controller: _amountController,
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    prefixIcon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    isBordered: _isBordered,
                  ),

                  const SizedBox(height: 16),

                  // Category Dropdown
                  if (availableCategories.isNotEmpty)
                    _buildDropdownField(
                      'Category',
                      Icons.category,
                      availableCategories,
                      _selectedCategory,
                      (value) => setState(() => _selectedCategory = value),
                      (category) => category.name,
                      (category) => category.icon,
                    ),

                  const SizedBox(height: 16),

                  // Payment Method Dropdown
                  if (availableMethods.isNotEmpty)
                    _buildDropdownField(
                      'Payment Method',
                      Icons.payment,
                      availableMethods,
                      _selectedMethod,
                      (value) => setState(() => _selectedMethod = value),
                      (method) => method.name,
                      (method) => method.icon,
                    ),

                  const SizedBox(height: 16),

                  // Description Field
                  CustomInputField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hintText: 'Add a note about this transaction...',
                    prefixIcon: Icons.note_outlined,
                    isBordered: _isBordered,
                  ),

                  const SizedBox(height: 24),

                  // Date and Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimeCard(
                          'Date',
                          Icons.calendar_today,
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          _selectDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimeCard(
                          'Time',
                          Icons.access_time,
                          _selectedTime.format(context),
                          _selectTime,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: isEditing ? 'Update Transaction' : 'Save Transaction',
                    onPressed: _submitForm,
                    isLoading: _isLoading,
                    icon: isEditing ? Icons.update : Icons.save,
                  ),

                  // Delete button for editing mode
                  if (isEditing) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _showDeleteConfirmation,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Transaction'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    String title,
    IconData icon,
    TransactionTypeEnum type,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    IconData icon,
    List<T> items,
    T? selectedValue,
    void Function(T?) onChanged,
    String Function(T) getTitle,
    IconData Function(T) getIcon,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.containerSurface(context),
      ),
      child: DropdownButtonFormField<T>(
        value: items.contains(selectedValue) ? selectedValue : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.transparent,
          border:
              _isBordered
                  ? OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                  : InputBorder.none,
          enabledBorder:
              _isBordered
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                  : InputBorder.none,
          focusedBorder:
              _isBordered
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                  )
                  : InputBorder.none,
        ),
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(getIcon(item), size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        getTitle(item),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select a $label';
          }
          return null;
        },
        icon: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }

  Widget _buildDateTimeCard(
    String title,
    IconData icon,
    String value,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.containerSurface(context),
          borderRadius: BorderRadius.circular(15),
          border: _isBordered ? Border.all(color: colorScheme.primary) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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
