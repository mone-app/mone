// lib/features/transactions/widgets/chart_container.dart - Updated with Header
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/core/themes/app_color.dart';
import 'package:mone/data/enums/chart_type_enum.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/features/transactions/widgets/category_pie_chart.dart';
import 'package:mone/features/transactions/widgets/daily_line_chart.dart';

class ChartContainer extends ConsumerWidget {
  final String userId;

  const ChartContainer({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartProvider);
    final transactions = ref.watch(transactionStreamProvider(userId));
    final colorScheme = Theme.of(context).colorScheme;

    transactions.whenData((transactionList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(transactionProvider.notifier).setTransactions(transactionList);
        ref.read(chartProvider.notifier).calculateChartData(transactionList);
      });
    });

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.containerSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chartState.chartType == ChartTypeEnum.pie
                            ? 'Category Breakdown'
                            : 'Daily Timeline',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chartState.chartType == ChartTypeEnum.pie
                            ? 'Track spending by category'
                            : 'Monitor daily transactions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chart Type Toggle Switch
                GestureDetector(
                  onTap: () {
                    final currentType = chartState.chartType;
                    final newType =
                        currentType == ChartTypeEnum.pie
                            ? ChartTypeEnum.line
                            : ChartTypeEnum.pie;
                    ref.read(chartProvider.notifier).updateChartType(newType);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pie Chart Option
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                chartState.chartType == ChartTypeEnum.pie
                                    ? colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.pie_chart,
                            size: 18,
                            color:
                                chartState.chartType == ChartTypeEnum.pie
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // Line Chart Option
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                chartState.chartType == ChartTypeEnum.line
                                    ? colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.show_chart,
                            size: 18,
                            color:
                                chartState.chartType == ChartTypeEnum.line
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chart Content
          chartState.chartType == ChartTypeEnum.pie
              ? CategoryPieChart(
                key: const ValueKey('pie_chart'),
                userId: userId,
              )
              : DailyLineChart(
                key: const ValueKey('line_chart'),
                userId: userId,
              ),
        ],
      ),
    );
  }
}
