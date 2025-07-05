import 'package:flutter/material.dart';
import 'package:expensetracker/models/expense.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('dd/MM/yyyy');

class NewExpense extends StatefulWidget {
  const NewExpense({
    super.key,
    required this.onAddExpense,
    this.existingExpense,
  });

  final void Function(Expense expense) onAddExpense;
  final Expense? existingExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category _selectedCategory = Category.Food;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      _titleController.text = widget.existingExpense!.title;
      _amountController.text = widget.existingExpense!.amount.toString();
      _selectedDate = widget.existingExpense!.date;
      _selectedCategory = widget.existingExpense!.category;
    }
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsValid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty || amountIsValid) {
      showDialog(
        context: context,
        builder: (cxt) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text(
              'Please make sure a valid title, amount (positive number), and date were entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enteredAmount!,
        date: _selectedDate,
        category: _selectedCategory,
      ),
    ); // Close the modal after submitting
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    // The LayoutBuilder is useful here if you want to make the modal responsive
    // based on the available width within the bottom sheet itself.
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // You can use 'constraints.maxWidth' here if needed for responsive layouts
        return SizedBox(
          // Ensure the modal takes up appropriate height
          // It's often good practice to make it wrap content or set a max height
          height: MediaQuery.of(context).size.height *
              0.75, // Adjust height as needed, e.g., 75% of screen height
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                keyboardSpace + 16, // Adjust padding when keyboard is up
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Essential for Column inside SingleChildScrollView
                children: [
                  TextField(
                    controller: _titleController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Title'),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text('Amount'),
                            prefixText: '\u{20B9}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(formatter.format(_selectedDate)),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_month_rounded),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          // Adjusted maxWidth: 0.43 to 0.4 to give more breathing room
                          // in the smaller modal context. You might need to fine-tune this.
                          maxWidth: MediaQuery.of(context).size.width *
                              0.4, // Adjusted for modal
                          minWidth: 100,
                        ),
                        child: DropdownButton<Category>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: Category.values
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.name.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value == null) {
                                return;
                              }
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _submitExpenseData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical:
                                  10), // Further reduced padding for potentially smaller modal
                        ),
                        child: const Text('Save Expense'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
