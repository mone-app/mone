// lib/features/transactions/widgets/transaction_list_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mone/data/entities/transaction_entity.dart';
import 'package:mone/data/enums/transaction_type_enum.dart';
import 'package:mone/data/providers/transaction_provider.dart';
import 'package:mone/features/transactions/transaction_form_screen.dart';

class TransactionListSection extends ConsumerWidget {
  final String userId;

  const TransactionListSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartProvider);
    final transactionAsyncValue = ref.watch(transactionStreamProvider(userId));

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                if (chartState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Transaction List Content
          transactionAsyncValue.when(
            data: (allTransactions) {
              // Get filtered transactions from chart provider
              final filteredTransactions =
                  chartState.chartData != null
                      ? ref
                          .read(chartProvider.notifier)
                          .getFilteredTransactions(allTransactions)
                      : <TransactionEntity>[];

              if (chartState.isLoading) {
                return _buildLoadingState();
              }

              if (chartState.error != null) {
                return _buildErrorState(context, chartState.error!);
              }

              if (filteredTransactions.isEmpty) {
                return _buildEmptyState(context, chartState);
              }

              // Group filtered transactions by date
              final groupedTransactions = _groupTransactionsByDate(
                filteredTransactions,
              );

              return _buildTransactionList(context, groupedTransactions);
            },
            loading: () => _buildLoadingState(),
            error:
                (error, stack) => _buildErrorState(context, error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic chartState) {
    final colorScheme = Theme.of(context).colorScheme;

    // Different messages based on filter state
    String title;
    String subtitle;

    if (!chartState.showIncome && !chartState.showExpenses) {
      title = 'No transaction types selected';
      subtitle =
          'Enable income or expense visibility in the filter to see transactions';
    } else if (chartState.showIncome && !chartState.showExpenses) {
      title = 'No income transactions';
      subtitle = 'No income transactions found in the selected date range';
    } else if (!chartState.showIncome && chartState.showExpenses) {
      title = 'No expense transactions';
      subtitle = 'No expense transactions found in the selected date range';
    } else {
      title = 'No transactions found';
      subtitle = 'No transactions found in the selected date range and filters';
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    Map<String, List<TransactionEntity>> groupedTransactions,
  ) {
    final sortedDates =
        groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Sort dates in descending order

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final transactions = groupedTransactions[dateKey]!;

        return _buildDateGroup(context, dateKey, transactions);
      },
    );
  }

  Widget _buildDateGroup(
    BuildContext context,
    String dateKey,
    List<TransactionEntity> transactions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = DateTime.parse(dateKey);
    final isToday = _isToday(date);
    final isYesterday = _isYesterday(date);

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('EEEE, MMM dd').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header with daily totals
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (!isToday && !isYesterday) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yyyy').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),

        // Transaction items for this date
        ...transactions.map(
          (transaction) => _buildTransactionItem(context, transaction),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = transaction.type == TransactionTypeEnum.income;
    final amountColor = isIncome ? Colors.green.shade600 : Colors.red.shade600;
    final amountPrefix = isIncome ? '+' : '-';

    return Material(
      child: InkWell(
        onTap: () {
          // Navigate to edit transaction
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => TransactionFormScreen(transaction: transaction),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Center(
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      transaction.category.icon,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                transaction.category.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: amountColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              transaction.method.icon,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              transaction.method.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (transaction.description != null &&
                                transaction.description!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  transaction.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              DateFormat('HH:mm').format(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Map<String, List<TransactionEntity>> _groupTransactionsByDate(
    List<TransactionEntity> transactions,
  ) {
    final Map<String, List<TransactionEntity>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);

      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(transaction);
      } else {
        grouped[dateKey] = [transaction];
      }
    }

    // Sort transactions within each day by time (newest first)
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.date.compareTo(a.date));
    }

    return grouped;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
