import 'package:flutter/material.dart';
import 'package:expensetracker/models/expense.dart';

class Totalsummarycard extends StatelessWidget {
  const Totalsummarycard({
    super.key,
    required this.expenses,
  });
  final List<Expense> expenses;
  double get totalAmount {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Total Spent: ₹${totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: Text(
                'Expenses: ${expenses.length}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.right,
              ),
            )
          ],
        ),
      ),
    );
  }
}
