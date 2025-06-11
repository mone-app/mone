// lib/features/transactions/widgets/balance_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/core/themes/app_color.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/features/transactions/widgets/date_range_filter.dart';
import 'package:mone/utils/currency_formatter.dart';

class BalanceSection extends ConsumerWidget {
  const BalanceSection({super.key});

  void _showFilterModal(BuildContext context) {
    showDateRangeFilter(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final chartState = ref.watch(chartProvider);

    // Get combined total from chart data
    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    double combinedTotal = 0.0;

    if (chartState.chartData != null) {
      totalIncome = chartState.chartData!.totalIncome;
      totalExpenses = chartState.chartData!.totalExpenses;
      combinedTotal = totalIncome - totalExpenses;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Combined Total Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chartState.showIncome && !chartState.showExpenses
                      ? 'Income'
                      : chartState.showExpenses && !chartState.showIncome
                      ? 'Expense'
                      : 'Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                if (chartState.isLoading)
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loading...',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                      ),
                    ],
                  )
                else if (chartState.error != null)
                  Text(
                    'Error loading data',
                    style: TextStyle(fontSize: 16, color: Colors.red.shade600),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chartState.showIncome && !chartState.showExpenses
                            ? CurrencyFormatter.formatToRupiahWithDecimal(totalIncome)
                            : chartState.showExpenses && !chartState.showIncome
                            ? CurrencyFormatter.formatToRupiahWithDecimal(totalExpenses)
                            : CurrencyFormatter.formatToRupiahWithDecimal(combinedTotal),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
              ],
            ),
          ),

          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => _showFilterModal(context),
              icon: Icon(Icons.tune, color: colorScheme.onPrimary, size: 20),
              style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
          ),
        ],
      ),
    );
  }
}
