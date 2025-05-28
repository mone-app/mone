// lib/data/models/chart_model.dart
import 'package:mone/data/enums/chart_type_enum.dart';
import 'package:mone/data/models/date_range_model.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/category_model.dart';

class CategoryChartDataModel {
  final CategoryModel category;
  final double amount;
  final TransactionTypeEnum type;

  CategoryChartDataModel({
    required this.category,
    required this.amount,
    required this.type,
  });

  CategoryChartDataModel copyWith({
    CategoryModel? category,
    double? amount,
    TransactionTypeEnum? type,
  }) {
    return CategoryChartDataModel(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'CategoryChartDataModel(category: $category, amount: $amount, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryChartDataModel &&
        other.category == category &&
        other.amount == amount &&
        other.type == type;
  }

  @override
  int get hashCode => category.hashCode ^ amount.hashCode ^ type.hashCode;
}

class DailyChartDataModel {
  final DateTime date;
  final double incomeAmount;
  final double expenseAmount;

  DailyChartDataModel({
    required this.date,
    required this.incomeAmount,
    required this.expenseAmount,
  });

  double get netAmount => incomeAmount - expenseAmount;
  double get totalAmount => incomeAmount + expenseAmount;

  DailyChartDataModel copyWith({
    DateTime? date,
    double? incomeAmount,
    double? expenseAmount,
  }) {
    return DailyChartDataModel(
      date: date ?? this.date,
      incomeAmount: incomeAmount ?? this.incomeAmount,
      expenseAmount: expenseAmount ?? this.expenseAmount,
    );
  }

  @override
  String toString() {
    return 'DailyChartDataModel(date: $date, incomeAmount: $incomeAmount, expenseAmount: $expenseAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChartDataModel &&
        other.date == date &&
        other.incomeAmount == incomeAmount &&
        other.expenseAmount == expenseAmount;
  }

  @override
  int get hashCode =>
      date.hashCode ^ incomeAmount.hashCode ^ expenseAmount.hashCode;
}

class TransactionChartData {
  final List<CategoryChartDataModel> categoryData;
  final List<DailyChartDataModel> dailyData;
  final double totalIncome;
  final double totalExpenses;

  TransactionChartData({
    required this.categoryData,
    required this.dailyData,
    required this.totalIncome,
    required this.totalExpenses,
  });

  double get netAmount => totalIncome - totalExpenses;
  double get totalAmount => totalIncome + totalExpenses;

  // Get category data filtered by type
  List<CategoryChartDataModel> getCategoryDataByType(TransactionTypeEnum type) {
    return categoryData.where((data) => data.type == type).toList();
  }

  // Get income categories
  List<CategoryChartDataModel> get incomeCategories {
    return getCategoryDataByType(TransactionTypeEnum.income);
  }

  // Get expense categories
  List<CategoryChartDataModel> get expenseCategories {
    return getCategoryDataByType(TransactionTypeEnum.expense);
  }

  TransactionChartData copyWith({
    List<CategoryChartDataModel>? categoryData,
    List<DailyChartDataModel>? dailyData,
    double? totalIncome,
    double? totalExpenses,
  }) {
    return TransactionChartData(
      categoryData: categoryData ?? this.categoryData,
      dailyData: dailyData ?? this.dailyData,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }

  @override
  String toString() {
    return 'TransactionChartData(categoryData: $categoryData, dailyData: $dailyData, totalIncome: $totalIncome, totalExpenses: $totalExpenses)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionChartData &&
        other.categoryData == categoryData &&
        other.dailyData == dailyData &&
        other.totalIncome == totalIncome &&
        other.totalExpenses == totalExpenses;
  }

  @override
  int get hashCode =>
      categoryData.hashCode ^
      dailyData.hashCode ^
      totalIncome.hashCode ^
      totalExpenses.hashCode;
}

class ChartStateModel {
  final DateRangeModel dateRange;
  final ChartTypeEnum chartType;
  final TransactionChartData? chartData;
  final bool isLoading;
  final String? error;
  final bool showIncome;
  final bool showExpenses;

  ChartStateModel({
    required this.dateRange,
    required this.chartType,
    this.chartData,
    this.isLoading = false,
    this.error,
    this.showIncome = true,
    this.showExpenses = true,
  });

  ChartStateModel copyWith({
    DateRangeModel? dateRange,
    ChartTypeEnum? chartType,
    TransactionChartData? chartData,
    bool? isLoading,
    String? error,
    bool? showIncome,
    bool? showExpenses,
  }) {
    return ChartStateModel(
      dateRange: dateRange ?? this.dateRange,
      chartType: chartType ?? this.chartType,
      chartData: chartData ?? this.chartData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showIncome: showIncome ?? this.showIncome,
      showExpenses: showExpenses ?? this.showExpenses,
    );
  }
}
