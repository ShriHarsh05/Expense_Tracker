import 'package:expensetracker/widgets/chart/chart.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/widgets/expenses_list/expenses_list.dart';
import 'package:expensetracker/models/expense.dart';
import 'package:expensetracker/widgets/summary/totalSummaryCard.dart';
import 'package:expensetracker/widgets/summary/categorySummaryCard.dart';

enum ExpenseFilter { all, today, week, month, year }

enum ExpenseCategoryFilter { all, Food, Travel, Leisure, Work, Misslalenious }

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({
    super.key,
    required this.allExpense,
    required this.onRemoveExpense,
    required this.onEditExpense,
  });

  final List<Expense> allExpense;
  final void Function(Expense expense) onRemoveExpense;
  final void Function(Expense expense) onEditExpense;

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  ExpenseFilter _selectedTimeFilter = ExpenseFilter.all;
  ExpenseCategoryFilter _selectedCategoryFilter = ExpenseCategoryFilter.all;

  List<Expense> get _filteredByTime {
    final now = DateTime.now();
    switch (_selectedTimeFilter) {
      case ExpenseFilter.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return widget.allExpense
            .where((expense) =>
                expense.date
                    .isAfter(weekStart.subtract(const Duration(days: 1))) &&
                expense.date.isBefore(now.add(const Duration(days: 1))))
            .toList();
      case ExpenseFilter.today:
        return widget.allExpense
            .where((expense) =>
                expense.date.year == now.year &&
                expense.date.month == now.month &&
                expense.date.day == now.day)
            .toList();
      case ExpenseFilter.month:
        return widget.allExpense
            .where((expense) =>
                expense.date.year == now.year &&
                expense.date.month == now.month)
            .toList();
      case ExpenseFilter.year:
        return widget.allExpense
            .where((expense) => expense.date.year == now.year)
            .toList();
      case ExpenseFilter.all:
      default:
        return widget.allExpense;
    }
  }

  List<Expense> get _filteredExpenses {
    final timeFiltered = _filteredByTime;
    if (_selectedCategoryFilter == ExpenseCategoryFilter.all) {
      return timeFiltered;
    } else {
      return timeFiltered.where((expense) {
        return expense.category.toString().split('.').last ==
            _selectedCategoryFilter.toString().split('.').last;
      }).toList();
    }
  }

  Map<String, double> get _categoryTotals {
    Map<String, double> totals = {};
    for (var expense in _filteredExpenses) {
      String category = expense.category.toString().split('.').last;
      totals[category] = (totals[category] ?? 0) + expense.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Filter Dropdown
              DropdownButtonFormField<ExpenseFilter>(
                value: _selectedTimeFilter,
                decoration: const InputDecoration(
                  labelText: 'Time Filter',
                  border: OutlineInputBorder(),
                ),
                onChanged: (newFilter) {
                  if (newFilter != null) {
                    setState(() {
                      _selectedTimeFilter = newFilter;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(
                      value: ExpenseFilter.all, child: Text('All Time')),
                  DropdownMenuItem(
                      value: ExpenseFilter.today, child: Text('Today')),
                  DropdownMenuItem(
                      value: ExpenseFilter.week, child: Text('This Week')),
                  DropdownMenuItem(
                      value: ExpenseFilter.month, child: Text('This Month')),
                  DropdownMenuItem(
                      value: ExpenseFilter.year, child: Text('This Year')),
                ],
              ),

              const SizedBox(height: 12),

              // Category Filter Dropdown
              DropdownButtonFormField<ExpenseCategoryFilter>(
                value: _selectedCategoryFilter,
                decoration: const InputDecoration(
                  labelText: 'Category Filter',
                  border: OutlineInputBorder(),
                ),
                onChanged: (newFilter) {
                  if (newFilter != null) {
                    setState(() {
                      _selectedCategoryFilter = newFilter;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(
                      value: ExpenseCategoryFilter.all,
                      child: Text('All Categories')),
                  DropdownMenuItem(
                      value: ExpenseCategoryFilter.Food, child: Text('Food')),
                  DropdownMenuItem(
                      value: ExpenseCategoryFilter.Travel,
                      child: Text('Travel')),
                  DropdownMenuItem(
                      value: ExpenseCategoryFilter.Leisure,
                      child: Text('Leisure')),
                  DropdownMenuItem(
                      value: ExpenseCategoryFilter.Work, child: Text('Work')),
                  DropdownMenuItem(
                      value: ExpenseCategoryFilter.Misslalenious,
                      child: Text('Miscellaneous')),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text('Total Expenses',
                  style: Theme.of(context).textTheme.titleMedium),
              // Total Summary
              Totalsummarycard(expenses: _filteredExpenses),
              // Chart
              if (_filteredExpenses.isNotEmpty)
                SizedBox(
                    height: 200, child: Chart(expenses: _filteredExpenses)),
              // Category Summary Card
              Categorysummarycard(categoryTotals: _categoryTotals),
              Text(
                'Expenses List',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // Expenses List
              _filteredExpenses.isEmpty
                  ? const Center(child: Text('No expenses found'))
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ExpensesList(
                        expenses: _filteredExpenses,
                        onRemoveExpense: widget.onRemoveExpense,
                        onEditExpense: widget.onEditExpense,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
