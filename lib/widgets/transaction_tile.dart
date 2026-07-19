import 'package:flutter/material.dart';
import '../models/transaction.dart' as app;

class TransactionTile extends StatelessWidget {
  final app.Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == app.TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: amountColor,
        ),
      ),
      title: Text(
        transaction.note ?? transaction.category,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Text(
              transaction.paymentMethod,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                transaction.source.name.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign ₹${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
