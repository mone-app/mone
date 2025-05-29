// lib/data/controllers/chart_controller.dart - UPDATED VERSION
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/enums/chart_type_enum.dart';
import 'package:mone/data/models/date_range_model.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/chart_model.dart';

class ChartController extends StateNotifier<ChartStateModel> {
  List<TransactionEntity>? _cachedTransactions;

  ChartController()
    : super(
        ChartStateModel(
          dateRange: DateRangeModel.currentMonth(),
          chartType: ChartTypeEnum.pie,
        ),
      );

  // Update date range and recalculate chart data
  void updateDateRange(
    DateRangeModel newDateRange,
    List<TransactionEntity> allTransactions,
  ) {
    state = state.copyWith(
      dateRange: newDateRange,
      isLoading: true,
      error: null,
    );

    _cachedTransactions = allTransactions;
    _calculateChartData(allTransactions);
  }

  // Update chart type
  void updateChartType(ChartTypeEnum newChartType) {
    state = state.copyWith(chartType: newChartType);
  }

  // Update income visibility and recalculate
  void updateIncomeVisibility(bool showIncome) {
    state = state.copyWith(
      showIncome: showIncome,
      isLoading: true,
      error: null,
    );

    if (_cachedTransactions != null) {
      _calculateChartData(_cachedTransactions!);
    }
  }

  // Update expense visibility and recalculate
  void updateExpenseVisibility(bool showExpenses) {
    state = state.copyWith(
      showExpenses: showExpenses,
      isLoading: true,
      error: null,
    );

    if (_cachedTransactions != null) {
      _calculateChartData(_cachedTransactions!);
    }
  }

  // Update both visibility settings and recalculate
  void updateVisibilitySettings(bool showIncome, bool showExpenses) {
    state = state.copyWith(
      showIncome: showIncome,
      showExpenses: showExpenses,
      isLoading: true,
      error: null,
    );

    if (_cachedTransactions != null) {
      _calculateChartData(_cachedTransactions!);
    }
  }

  // Calculate chart data based on current filters and transactions
  void calculateChartData(List<TransactionEntity> allTransactions) {
    state = state.copyWith(isLoading: true, error: null);
    _cachedTransactions = allTransactions;
    _calculateChartData(allTransactions);
  }

  void _calculateChartData(List<TransactionEntity> allTransactions) {
    try {
      // Filter transactions based on date range
      final dateFilteredTransactions = _filterTransactionsByDateRange(
        allTransactions,
      );

      // Filter transactions based on visibility settings
      final visibilityFilteredTransactions = _filterTransactionsByVisibility(
        dateFilteredTransactions,
      );

      // Process chart data
      final chartData = _processTransactionData(visibilityFilteredTransactions);

      state = state.copyWith(chartData: chartData, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  List<TransactionEntity> _filterTransactionsByDateRange(
    List<TransactionEntity> transactions,
  ) {
    final startDate = DateTime(
      state.dateRange.startDate.year,
      state.dateRange.startDate.month,
      state.dateRange.startDate.day,
    );
    final endDate = DateTime(
      state.dateRange.endDate.year,
      state.dateRange.endDate.month,
      state.dateRange.endDate.day,
      23,
      59,
      59, // Include the full end date
    );

    final filtered =
        transactions.where((transaction) {
          final transactionDate = transaction.date;
          final isInRange =
              transactionDate.isAfter(
                startDate.subtract(const Duration(milliseconds: 1)),
              ) &&
              transactionDate.isBefore(
                endDate.add(const Duration(milliseconds: 1)),
              );

          return isInRange;
        }).toList();

    return filtered;
  }

  // NEW: Filter transactions based on visibility settings
  List<TransactionEntity> _filterTransactionsByVisibility(
    List<TransactionEntity> transactions,
  ) {
    return transactions.where((transaction) {
      // If both are disabled, show nothing
      if (!state.showIncome && !state.showExpenses) {
        return false;
      }

      // If only income is visible, show only income transactions
      if (state.showIncome && !state.showExpenses) {
        return transaction.type == TransactionTypeEnum.income;
      }

      // If only expenses are visible, show only expense transactions
      if (!state.showIncome && state.showExpenses) {
        return transaction.type == TransactionTypeEnum.expense;
      }

      // If both are visible, show all transactions
      return true;
    }).toList();
  }

  TransactionChartData _processTransactionData(
    List<TransactionEntity> filteredTransactions,
  ) {
    // Process Category Data
    final Map<String, CategoryChartDataModel> categoryMap = {};

    for (final transaction in filteredTransactions) {
      final key = '${transaction.category.id}_${transaction.type.name}';

      if (categoryMap.containsKey(key)) {
        final existing = categoryMap[key]!;
        categoryMap[key] = CategoryChartDataModel(
          category: existing.category,
          amount: existing.amount + transaction.amount,
          type: existing.type,
        );
      } else {
        categoryMap[key] = CategoryChartDataModel(
          category: transaction.category,
          amount: transaction.amount,
          type: transaction.type,
        );
      }
    }

    final categoryData = categoryMap.values.toList();

    // Process Daily Data
    final dailyData = _processDailyData(filteredTransactions);

    // Calculate totals based on visibility settings
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    if (state.showIncome) {
      totalIncome = filteredTransactions
          .where((t) => t.type == TransactionTypeEnum.income)
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    if (state.showExpenses) {
      totalExpenses = filteredTransactions
          .where((t) => t.type == TransactionTypeEnum.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    return TransactionChartData(
      categoryData: categoryData,
      dailyData: dailyData,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
    );
  }

  List<DailyChartDataModel> _processDailyData(
    List<TransactionEntity> filteredTransactions,
  ) {
    final Map<String, DailyChartDataModel> dailyMap = {};

    // Initialize all days in range with zero values
    DateTime current = DateTime(
      state.dateRange.startDate.year,
      state.dateRange.startDate.month,
      state.dateRange.startDate.day,
    );
    final endDate = DateTime(
      state.dateRange.endDate.year,
      state.dateRange.endDate.month,
      state.dateRange.endDate.day,
    );

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final key =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      dailyMap[key] = DailyChartDataModel(
        date: current,
        incomeAmount: 0.0,
        expenseAmount: 0.0,
      );
      current = current.add(const Duration(days: 1));
    }

    // Add actual transaction data based on visibility settings
    for (final transaction in filteredTransactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final key =
          '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}';

      if (dailyMap.containsKey(key)) {
        final existing = dailyMap[key]!;

        if (transaction.type == TransactionTypeEnum.income &&
            state.showIncome) {
          dailyMap[key] = DailyChartDataModel(
            date: existing.date,
            incomeAmount: existing.incomeAmount + transaction.amount,
            expenseAmount: existing.expenseAmount,
          );
        } else if (transaction.type == TransactionTypeEnum.expense &&
            state.showExpenses) {
          dailyMap[key] = DailyChartDataModel(
            date: existing.date,
            incomeAmount: existing.incomeAmount,
            expenseAmount: existing.expenseAmount + transaction.amount,
          );
        }
      }
    }

    return dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // Helper methods for getting specific data
  List<TransactionEntity> getFilteredTransactions(
    List<TransactionEntity> allTransactions,
  ) {
    final dateFiltered = _filterTransactionsByDateRange(allTransactions);
    return _filterTransactionsByVisibility(dateFiltered);
  }

  // Reset to default state
  void reset() {
    state = ChartStateModel(
      dateRange: DateRangeModel.currentMonth(),
      chartType: ChartTypeEnum.pie,
    );
    _cachedTransactions = null;
  }

  // Clear cached transactions (useful when switching users or major data changes)
  void clearCache() {
    _cachedTransactions = null;
  }
}
