// lib/features/transactions/widgets/date_range_filter.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mone/core/themes/app_color.dart';
import 'package:mone/data/models/date_range_model.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/data/providers/user_provider.dart';

class DateRangeFilter extends ConsumerStatefulWidget {
  const DateRangeFilter({super.key});

  @override
  ConsumerState<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends ConsumerState<DateRangeFilter> {
  DateTimeRange? _selectedRange;
  bool _showIncome = true;
  bool _showExpenses = true;

  @override
  void initState() {
    super.initState();
    final chartState = ref.read(chartProvider);
    _selectedRange = DateTimeRange(
      start: chartState.dateRange.startDate,
      end: chartState.dateRange.endDate,
    );
    _showIncome = chartState.showIncome;
    _showExpenses = chartState.showExpenses;
  }

  Future<void> _selectDateRange() async {
    try {
      // Set proper date boundaries
      final firstDate = DateTime(2020, 1, 1);
      final lastDate = DateTime.now();

      // Ensure initialDateRange is within bounds
      DateTimeRange? safeInitialRange = _selectedRange;
      if (_selectedRange != null) {
        // Clamp the dates to be within the allowed range
        final clampedStart =
            _selectedRange!.start.isBefore(firstDate)
                ? firstDate
                : (_selectedRange!.start.isAfter(lastDate)
                    ? lastDate
                    : _selectedRange!.start);
        final clampedEnd =
            _selectedRange!.end.isAfter(lastDate)
                ? lastDate
                : (_selectedRange!.end.isBefore(firstDate)
                    ? firstDate
                    : _selectedRange!.end);

        safeInitialRange = DateTimeRange(start: clampedStart, end: clampedEnd);
      }

      final dateRange = await showDateRangePicker(
        context: context,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDateRange: safeInitialRange,
        helpText: 'Select Date Range',
        cancelText: 'Cancel',
        confirmText: 'OK',
        saveText: 'Save',
        errorFormatText: 'Enter valid date',
        errorInvalidText: 'Enter date in valid range',
        errorInvalidRangeText: 'Invalid range',
        fieldStartHintText: 'Start Date',
        fieldEndHintText: 'End Date',
        fieldStartLabelText: 'Start Date',
        fieldEndLabelText: 'End Date',
      );

      if (dateRange != null && mounted) {
        setState(() {
          _selectedRange = dateRange;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening date picker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    if (_selectedRange == null) return;

    try {
      // Update date range
      final newDateRange = DateRangeModel(
        startDate: _selectedRange!.start,
        endDate: _selectedRange!.end,
      );

      final chartController = ref.read(chartProvider.notifier);

      // Update visibility settings first
      chartController.updateVisibilitySettings(_showIncome, _showExpenses);

      // Try to get transactions from the provider state first
      final currentTransactions = ref.read(transactionProvider);

      if (currentTransactions.isNotEmpty) {
        chartController.updateDateRange(newDateRange, currentTransactions);
      } else {
        // Try to fetch transactions directly
        _fetchTransactionsAndApplyFilter(newDateRange, chartController);
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying filters: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchTransactionsAndApplyFilter(
    DateRangeModel newDateRange,
    dynamic chartController,
  ) async {
    try {
      // Get user from provider
      final user = ref.read(userProvider);
      if (user == null) {
        return;
      }

      // Try to use the transaction repository directly
      final transactionRepo = ref.read(transactionRepositoryProvider);
      final transactions = await transactionRepo.fetchUserTransactions(user.id);

      chartController.updateDateRange(newDateRange, transactions);
    } catch (e) {
      // Show specific error message for permission issues
      if (e.toString().contains('permission-denied')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Permission denied. Please check your Firestore security rules.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chartState = ref.watch(chartProvider);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.containerSurface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transactions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Column(
            children: [
              // Income Toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Show Income',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _showIncome,
                    onChanged: (value) {
                      setState(() {
                        _showIncome = value;
                      });
                    },
                    activeColor: Colors.green.shade600,
                  ),
                ],
              ),

              // Expense Toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_down,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Show Expenses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _showExpenses,
                    onChanged: (value) {
                      setState(() {
                        _showExpenses = value;
                      });
                    },
                    activeColor: Colors.red.shade600,
                  ),
                ],
              ),

              // Warning when both are disabled
              if (!_showIncome && !_showExpenses) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'At least one transaction type should be selected',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Custom date range - IMPROVED SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Range',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedRange != null
                                ? '${dateFormat.format(_selectedRange!.start)} - ${dateFormat.format(_selectedRange!.end)}'
                                : 'No range selected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // IMPROVED: Custom Range Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: const Text('Select Custom Range'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Loading indicator
          if (chartState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  (chartState.isLoading || (!_showIncome && !_showExpenses))
                      ? null
                      : _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Add some bottom padding for better spacing
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Updated helper function to show the filter modal with userId
void showDateRangeFilter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder:
        (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DateRangeFilter(),
        ),
  );
}
