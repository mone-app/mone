// lib/features/bill/widgets/split_method_widget.dart
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        // Split Type Toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Split Method', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Split Evenly'),
                        subtitle: const Text('Equal amounts for everyone'),
                        value: true,
                        groupValue: isEvenSplit,
                        onChanged: (value) => onSplitMethodChanged(value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Custom Split'),
                        subtitle: const Text('Set individual amounts'),
                        value: false,
                        groupValue: isEvenSplit,
                        onChanged: (value) => onSplitMethodChanged(value!),
                      ),
                    ),
                  ],
                ),
                if (!isEvenSplit) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can edit everyone\'s amount including your own',
                            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
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

        // Split Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Split Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow('Total Participants', '$participantCount'),
                _buildSummaryRow('Total Amount', '\$${totalAmount.toStringAsFixed(2)}'),
                _buildSummaryRow('Split Total', '\$${splitTotal.toStringAsFixed(2)}'),
                if (splitTotal != totalAmount)
                  _buildSummaryRow(
                    'Remaining',
                    '\$${(totalAmount - splitTotal).toStringAsFixed(2)}',
                    isError: true,
                  ),
                if (splitTotal == totalAmount && participantCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Split is balanced!',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isError ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
