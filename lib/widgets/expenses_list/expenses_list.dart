import 'package:expensetracker/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';
import '../../models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.onEditExpense,
  });
  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;
  final void Function(Expense expense) onEditExpense;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (content, index) => Dismissible(
        key: ValueKey(expenses[index]),
        background: Container(
          // color: Colors.blue.shade300,
          color: Theme.of(content).colorScheme.primaryContainer,
          margin: EdgeInsets.symmetric(
              horizontal: Theme.of(context).cardTheme.margin?.horizontal ?? 16),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 30,
          ),
        ),
        secondaryBackground: Container(
          color: Theme.of(content).colorScheme.error,
          margin: EdgeInsets.symmetric(
            horizontal: Theme.of(context).cardTheme.margin?.horizontal ?? 16,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onEditExpense(expenses[index]);
            return false;
          } else if (direction == DismissDirection.endToStart) {
            return true;
          }
          return false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onRemoveExpense(expenses[index]);
          }
        },
        child: ExpenseItem(
          expenses[index],
          onTap: onEditExpense,
        ),
      ),
    );
  }
}
