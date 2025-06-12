// lib/features/transactions/widgets/category_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/models/chart_model.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/utils/currency_formatter.dart';

class CategoryPieChart extends ConsumerStatefulWidget {
  final String userId;

  const CategoryPieChart({super.key, required this.userId});

  @override
  ConsumerState<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends ConsumerState<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(chartProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Show loading state
    if (chartState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        child: const Center(
          child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
        ),
      );
    }

    // Show error state
    if (chartState.error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                'Error loading chart data',
                style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                chartState.error!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final chartData = chartState.chartData;
    if (chartData == null) {
      return _buildEmptyState(context);
    }

    // Get both income and expense data
    final incomeData = chartData.incomeCategories;
    final expenseData = chartData.expenseCategories;

    // Sort by amount (descending)
    incomeData.sort((a, b) => b.amount.compareTo(a.amount));
    expenseData.sort((a, b) => b.amount.compareTo(a.amount));

    // Determine which data to display based on active selections
    List<CategoryChartDataModel> displayData = [];
    if (chartState.showIncome && chartState.showExpenses) {
      // Show both - combine data
      displayData = [...incomeData, ...expenseData];
      displayData.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (chartState.showIncome) {
      displayData = incomeData;
    } else if (chartState.showExpenses) {
      displayData = expenseData;
    }

    final total = displayData.fold(0.0, (sum, data) => sum + data.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),

      child: Column(
        children: [
          if (displayData.isEmpty || (!chartState.showIncome && !chartState.showExpenses))
            _buildEmptyState(context)
          else
            _buildChartContent(
              context,
              displayData,
              total,
              colorScheme,
              chartState.showIncome,
              chartState.showExpenses,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(
    BuildContext context,
    List<CategoryChartDataModel> displayData,
    double total,
    ColorScheme colorScheme,
    bool showIncome,
    bool showExpenses,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildPieChartSections(
                displayData,
                total,
                showIncome,
                showExpenses,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Legend
        _buildLegend(context, displayData, total, showIncome, showExpenses),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<CategoryChartDataModel> data,
    double total,
    bool showIncome,
    bool showExpenses,
  ) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryData = entry.value;
      final isTouched = index == touchedIndex;
      final percentage = (categoryData.amount / total) * 100;

      // Use mixed colors when both types are active
      Color sectionColor;
      if (showIncome && showExpenses) {
        final colors = _getMixedChartColors();
        sectionColor = colors[index % colors.length];
      } else {
        final colors = _getChartColors(categoryData.type);
        sectionColor = colors[index % colors.length];
      }

      return PieChartSectionData(
        color: sectionColor,
        value: percentage,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildLegend(
    BuildContext context,
    List<CategoryChartDataModel> data,
    double total,
    bool showIncome,
    bool showExpenses,
  ) {
    return Column(
      children:
          data.asMap().entries.map((entry) {
            final index = entry.key;
            final categoryData = entry.value;
            final percentage = (categoryData.amount / total) * 100;

            // Use mixed colors when both types are active
            Color legendColor;
            if (showIncome && showExpenses) {
              final colors = _getMixedChartColors();
              legendColor = colors[index % colors.length];
            } else {
              final colors = _getChartColors(categoryData.type);
              legendColor = colors[index % colors.length];
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: legendColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(categoryData.category.icon, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          categoryData.category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Type indicator when both are shown
                        if (showIncome && showExpenses)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (categoryData.type == TransactionTypeEnum.income
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryData.type == TransactionTypeEnum.income ? 'I' : 'E',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    categoryData.type == TransactionTypeEnum.income
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatToCompactRupiah(categoryData.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  List<Color> _getChartColors(TransactionTypeEnum type) {
    if (type == TransactionTypeEnum.income) {
      return [
        Colors.green.shade400,
        Colors.green.shade500,
        Colors.green.shade600,
        Colors.green.shade700,
        Colors.teal.shade400,
        Colors.teal.shade500,
        Colors.teal.shade600,
        Colors.lightGreen.shade400,
        Colors.lightGreen.shade500,
        Colors.lightGreen.shade600,
      ];
    } else {
      return [
        Colors.red.shade400,
        Colors.red.shade500,
        Colors.red.shade600,
        Colors.red.shade700,
        Colors.orange.shade400,
        Colors.orange.shade500,
        Colors.orange.shade600,
        Colors.deepOrange.shade400,
        Colors.deepOrange.shade500,
        Colors.pink.shade400,
      ];
    }
  }

  List<Color> _getMixedChartColors() {
    return [
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.indigo.shade400,
      Colors.teal.shade400,
      Colors.cyan.shade400,
      Colors.amber.shade400,
      Colors.brown.shade400,
      Colors.blueGrey.shade400,
      Colors.lime.shade400,
      Colors.deepPurple.shade400,
      Colors.pink.shade300,
      Colors.orange.shade300,
    ];
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
