// lib/controller/expenses_controller.dart
import 'package:expensetracker/models/expense.dart'; // Import your Expense model
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/foundation.dart'; // For debugPrint

class ExpensesController {
  // Use a static instance for easy access throughout the app
  static final ExpensesController _instance = ExpensesController._internal();

  factory ExpensesController() {
    return _instance;
  }

  ExpensesController._internal(); // Private constructor

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // You might also add a Stream or StreamController here to notify UI listeners
  // For now, we'll just handle adding to Firestore.

  Future<void> addExpense(Expense expense) async {
    try {
      debugPrint('Attempting to add expense to Firestore: ${expense.toMap()}');
      // Add the expense to a 'expenses' collection
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toMap());
      debugPrint(
          '✅ Expense "${expense.title}" added to Firestore successfully!');
    } catch (e) {
      debugPrint('❌ Error adding expense to Firestore: $e');
      // Handle error, e.g., show a toast or log more details
    }
  }

  // You can add more methods here, e.g.:
  // Future<List<Expense>> fetchExpenses() async { ... }
  // Future<void> deleteExpense(String expenseId) async { ... }
  // Future<void> updateExpense(Expense expense) async { ... }
}
