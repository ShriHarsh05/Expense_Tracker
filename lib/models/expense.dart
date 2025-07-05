import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const uuid = Uuid();
final formatter = DateFormat('dd/MM/yyyy');

enum Category {
  Food,
  Leisure,
  Travel,
  Miscellaneous,
  Work,
}

const categoryIcons = {
  Category.Food: Icons.lunch_dining,
  Category.Travel: Icons.flight_takeoff,
  Category.Miscellaneous: Icons.query_stats_outlined,
  Category.Work: Icons.work,
  Category.Leisure: Icons.movie,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }

  /// 🔹 Convert Expense object to Firestore-friendly Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }

  /// 🔹 Factory constructor to create Expense from Firestore data
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? uuid.v4(),
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      category: Category.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => Category.Miscellaneous,
      ),
    );
  }
}

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
