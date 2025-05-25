// lib/features/transactions/widgets/transaction_card_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mone/data/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.isIncome ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            transaction.category.icon,
            color: transaction.isIncome ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        title: Text(
          transaction.category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(transaction.method.icon, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    transaction.method.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${dateFormat.format(transaction.date)} ${timeFormat.format(transaction.date)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: transaction.isIncome ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        isThreeLine:
            transaction.description != null && transaction.description!.isNotEmpty,
        onTap: onTap,
      ),
    );
  }
}
