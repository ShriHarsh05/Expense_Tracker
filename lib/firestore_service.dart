import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expensetracker/models/expense.dart';

class FirestoreService {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference get userExpensesCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('expenses');
  }

  Future<void> addExpense(Expense expense) async {
    await userExpensesCollection.add({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category.name,
    });
  }

  Future<void> deleteExpense(String docId) async {
    await userExpensesCollection.doc(docId).delete();
  }

  Future<void> updateExpense(String docId, Expense expense) async {
    await userExpensesCollection.doc(docId).update({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category.name,
    });
  }
}
