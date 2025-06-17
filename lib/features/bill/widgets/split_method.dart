// lib/features/bill/widgets/split_method.dart
import 'package:flutter/material.dart';
import 'package:mone/core/theme/app_color.dart';
import 'package:mone/utils/currency_formatter.dart';

class SplitMethod extends StatelessWidget {
  final bool isEvenSplit;
  final Function(bool) onSplitMethodChanged;
  final double totalAmount;
  final double splitTotal;
  final int participantCount;

  const SplitMethod({
    super.key,
    required this.isEvenSplit,
    required this.onSplitMethodChanged,
    required this.totalAmount,
    required this.splitTotal,
    required this.participantCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Split Method Selection
        Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calculate,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Split Method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'How should we divide the bill?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Split Options
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSplitOption(
                          context,
                          'Split Evenly',
                          'Equal amounts for everyone',
                          Icons.pie_chart,
                          true,
                          isEvenSplit,
                          onSplitMethodChanged,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildSplitOption(
                          context,
                          'Custom Split',
                          'Set individual amounts',
                          Icons.tune,
                          false,
                          isEvenSplit,
                          onSplitMethodChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Split Summary
        Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Split Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Review the split calculation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Summary Items
                _buildSummaryRow(
                  context,
                  'Total Participants',
                  '$participantCount',
                  Icons.group,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  context,
                  'Total Amount',
                  CurrencyFormatter.formatToRupiahWithDecimal(totalAmount),
                  Icons.attach_money,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  context,
                  'Split Total',
                  CurrencyFormatter.formatToRupiahWithDecimal(splitTotal),
                  Icons.calculate,
                  isHighlight: splitTotal == totalAmount,
                  isError: splitTotal != totalAmount && participantCount > 0,
                ),

                // Remaining amount (if any)
                if (splitTotal != totalAmount && participantCount > 0) ...[
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    'Remaining',
                    CurrencyFormatter.formatToRupiahWithDecimal(
                      totalAmount - splitTotal,
                    ),
                    Icons.warning,
                    isError: true,
                  ),
                ],

                // Success message
                if (splitTotal == totalAmount && participantCount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Split is balanced! Ready to create bill.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    bool currentValue,
    Function(bool) onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 4),
            // Text(
            //   subtitle,
            //   style: TextStyle(
            //     fontSize: 10,
            //     color:
            //         isSelected
            //             ? colorScheme.onPrimary.withValues(alpha: 0.8)
            //             : colorScheme.onSurfaceVariant,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isError = false,
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color iconColor = colorScheme.onSurfaceVariant;
    Color valueColor = colorScheme.onSurface;

    if (isError) {
      iconColor = Colors.red.shade600;
      valueColor = Colors.red.shade600;
    } else if (isHighlight) {
      iconColor = Colors.green.shade600;
      valueColor = Colors.green.shade600;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
