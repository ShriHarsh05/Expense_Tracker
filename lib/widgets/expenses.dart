// import 'package:expensetracker/models/all_expenses.dart';
// import 'package:expensetracker/screens/settings_screen.dart';
// import 'package:expensetracker/services/auth_service.dart';
// import 'package:expensetracker/widgets/chart/chart.dart';
// import 'package:flutter/material.dart';
// import '../models/expense.dart';
// import 'package:expensetracker/widgets/expenses_list/expenses_list.dart';
// import 'package:expensetracker/widgets/new_expense.dart';
// import 'package:expensetracker/widgets/summary/totalSummaryCard.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:expensetracker/widgets/greeting_header.dart';

// class Expenses extends StatefulWidget {
//   final void Function(Color) onColorChanged;
//   const Expenses({super.key, required this.onColorChanged});

//   @override
//   State<Expenses> createState() => _ExpensesState();
// }

// class _ExpensesState extends State<Expenses> {
//   // final List<Expense> _registeredExpenses = [];
//   int _selectedPageIndex = 0;
//   // bool _isLoadingExpenses = true;
//   Stream<List<Expense>> _getUserExpensesStream() {
//     final user = AuthService.currentUser;
//     if (user == null) return const Stream.empty();

//     return FirebaseFirestore.instance
//         .collection('expenses')
//         .doc(user.uid)
//         .collection('user_expenses')
//         .orderBy('date', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) {
//               final data = doc.data();
//               return Expense.fromMap(data);
//             }).toList());
//   }

//   // List<Expense> get _todayExpenses {
//   //   final now = DateTime.now();
//   //   return _registeredExpenses
//   //       .where((expense) =>
//   //           expense.date.year == now.year &&
//   //           expense.date.month == now.month &&
//   //           expense.date.day == now.day)
//   //       .toList();
//   // }

//   @override
//   void initState() {
//     super.initState();
//     _fetchExpensesFromFirestore();
//     FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user != null) {
//         _fetchExpensesFromFirestore();
//       } else {
//         if (mounted) {
//           setState(() {
//             _registeredExpenses.clear();
//             _isLoadingExpenses = false;
//           });
//         }
//       }
//     });
//   }

//   Future<void> _fetchExpensesFromFirestore() async {
//     setState(() {
//       _isLoadingExpenses = true;
//     });
//     final user = AuthService.currentUser;
//     if (user != null) {
//       try {
//         final snapshot = await FirebaseFirestore.instance
//             .collection('expenses')
//             .doc(user.uid)
//             .collection('user_expenses')
//             .orderBy('date', descending: true)
//             .get();
//         final List<Expense> loadedExpenses = [];
//         for (final doc in snapshot.docs) {
//           loadedExpenses.add(Expense.fromMap(doc.data()));
//         }
//         if (mounted) {
//           setState(() {
//             _registeredExpenses.clear();
//             _registeredExpenses.addAll(loadedExpenses);
//             _isLoadingExpenses = false;
//           });
//         }
//       } catch (e) {
//         debugPrint('❌ Firestore fetch error: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to load expenses: ${e.toString()}'),
//             ),
//           );
//           setState(() {
//             _isLoadingExpenses = false;
//           });
//         }
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           _registeredExpenses.clear();
//           _isLoadingExpenses = false;
//         });
//       }
//     }
//   }

//   Future<void> _uploadExpenseToFirestore(Expense expense) async {
//     final user = AuthService.currentUser; // Use AuthService
//     if (user != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('expenses')
//             .doc(user.uid)
//             .collection('user_expenses')
//             .add(expense.toMap());
//         if (mounted) {
//           _fetchExpensesFromFirestore(); // Re-fetch all to update UI
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Expense added successfully!')),
//           );
//         }
//       } catch (e) {
//         debugPrint('❌ Upload error: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to add expense: ${e.toString()}')),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _removeExpenseFromFirestore(Expense expense) async {
//     final user = AuthService.currentUser; // Use AuthService
//     if (user != null) {
//       try {
//         final snapshot = await FirebaseFirestore.instance
//             .collection('expenses')
//             .doc(user.uid)
//             .collection('user_expenses')
//             .where('id', isEqualTo: expense.id)
//             .get();

//         if (snapshot.docs.isNotEmpty) {
//           // Assuming 'id' is unique, there should be only one document
//           await snapshot.docs.first.reference.delete();
//           if (mounted) {
//             _fetchExpensesFromFirestore(); // Re-fetch all to update UI
//           }
//         } else {
//           debugPrint('Expense with ID ${expense.id} not found in Firestore.');
//         }
//       } catch (e) {
//         debugPrint('❌ Delete error: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('Failed to delete expense: ${e.toString()}')),
//           );
//         }
//       }
//     }
//   }

//   void _addExpense(Expense expense) {
//     _uploadExpenseToFirestore(expense);
//   }

//   void _removeExpense(Expense expense, {bool showSnackBar = true}) {
//     _removeExpenseFromFirestore(expense);

//     if (showSnackBar && mounted) {
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Expense Deleted'),
//           duration: const Duration(seconds: 3),
//           action: SnackBarAction(
//             label: 'Undo',
//             onPressed: () =>
//                 _addExpense(expense), // This will re-add to Firestore
//           ),
//         ),
//       );
//     }
//   }

//   void _editExpense(Expense oldExpense) {
//     showModalBottomSheet(
//       useSafeArea: true, // Use safe area for bottom sheet
//       isScrollControlled: true,
//       context: context,
//       builder: (_) {
//         return NewExpense(
//           existingExpense: oldExpense,
//           onAddExpense: (updatedExpense) async {
//             // Remove the old one, then add the new one
//             await _removeExpenseFromFirestore(
//                 oldExpense); // Ensure old is removed
//             await _uploadExpenseToFirestore(updatedExpense); // Then upload new
//             if (mounted) Navigator.of(context).pop(); // Close bottom sheet
//           },
//         );
//       },
//     );
//   }

//   void _openAddExpenseOverlay() {
//     showModalBottomSheet(
//       useSafeArea: true, // Use safe area for bottom sheet
//       isScrollControlled: true,
//       context: context,
//       builder: (_) => NewExpense(onAddExpense: _addExpense),
//     );
//   }

//   Future<void> _handleRefresh() async {
//     await _fetchExpensesFromFirestore();
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Expenses refreshed from cloud!'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTodayScreen = _selectedPageIndex == 0;
//     final isSettingsScreen = _selectedPageIndex == 2;

//     Widget mainContent;

//     if (_isLoadingExpenses) {
//       mainContent = const Center(child: CircularProgressIndicator());
//     } else if (_registeredExpenses.isEmpty && isTodayScreen) {
//       mainContent = const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('No expenses added yet!'),
//             SizedBox(height: 10),
//             Text('Start adding some by tapping the "+" button.'),
//           ],
//         ),
//       );
//     } else if (isSettingsScreen) {
//       mainContent = SettingsScreen(
//           onColorChanged:
//               widget.onColorChanged); // Pass the callback to SettingsScreen
//     } else if (isTodayScreen) {
//       mainContent = Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const GreetingHeader(),
//             Totalsummarycard(expenses: _todayExpenses),
//             Chart(expenses: _todayExpenses),
//             const SizedBox(height: 12),
//             const Text(
//               'Today\'s Expenses',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 6),
//             Expanded(
//               child: ExpensesList(
//                 expenses: _todayExpenses,
//                 onRemoveExpense: _removeExpense,
//                 onEditExpense: _editExpense,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       // All Expenses Screen
//       mainContent = AllExpensesScreen(
//         allExpense: _registeredExpenses,
//         onRemoveExpense: _removeExpense,
//         onEditExpense: _editExpense,
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Expense Tracker'),
//         actions: isSettingsScreen
//             ? null // No actions on settings screen app bar
//             : [
//                 IconButton(
//                   onPressed: _handleRefresh,
//                   icon: const Icon(Icons.refresh),
//                 ),
//                 // Add your add expense button only for today/all expenses view
//                 if (_selectedPageIndex == 0 || _selectedPageIndex == 1)
//                   IconButton(
//                     onPressed: _openAddExpenseOverlay,
//                     icon: const Icon(Icons.add),
//                   ),
//               ],
//       ),
//       body: mainContent,
//       // FloatingActionButton logic moved into appBar actions for clarity if desired,
//       // but keeping it here is also fine if only on Today screen
//       floatingActionButton: isTodayScreen
//           ? FloatingActionButton(
//               onPressed: _openAddExpenseOverlay,
//               child: const Icon(Icons.add),
//             )
//           : null,
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedPageIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedPageIndex = index;
//             // If navigating to expenses screen, refresh data
//             if (index == 0 || index == 1) {
//               _fetchExpensesFromFirestore();
//             }
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.document_scanner),
//               label: 'All Expenses'), // Corrected label
//           BottomNavigationBarItem(
//               icon: Icon(Icons.settings), label: 'Settings'),
//         ],
//       ),
//     );
//   }
// }
import 'package:expensetracker/models/all_expenses.dart';
import 'package:expensetracker/screens/settings_screen.dart';
import 'package:expensetracker/services/auth_service.dart';
import 'package:expensetracker/widgets/chart/chart.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:expensetracker/widgets/expenses_list/expenses_list.dart';
import 'package:expensetracker/widgets/new_expense.dart';
import 'package:expensetracker/widgets/summary/totalSummaryCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/widgets/greeting_header.dart';

class Expenses extends StatefulWidget {
  final void Function(Color) onColorChanged;
  const Expenses({super.key, required this.onColorChanged});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  int _selectedPageIndex = 0;

  Stream<List<Expense>> _getUserExpensesStream() {
    final user = AuthService.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('expenses')
        .doc(user.uid)
        .collection('user_expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList());
  }

  Future<void> _uploadExpenseToFirestore(Expense expense) async {
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(user.uid)
            .collection('user_expenses')
            .add(expense.toMap());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully!')),
          );
        }
      } catch (e) {
        debugPrint('❌ Upload error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add expense: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _removeExpenseFromFirestore(Expense expense) async {
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .doc(user.uid)
            .collection('user_expenses')
            .where('id', isEqualTo: expense.id)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.delete();
        } else {
          debugPrint('Expense with ID ${expense.id} not found in Firestore.');
        }
      } catch (e) {
        debugPrint('❌ Delete error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete expense: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _addExpense(Expense expense) {
    _uploadExpenseToFirestore(expense);
  }

  void _removeExpense(Expense expense, {bool showSnackBar = true}) {
    _removeExpenseFromFirestore(expense);

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense Deleted'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _addExpense(expense),
          ),
        ),
      );
    }
  }

  void _editExpense(Expense oldExpense) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewExpense(
          existingExpense: oldExpense,
          onAddExpense: (updatedExpense) {
            Navigator.of(ctx).pop();
            Future.delayed(const Duration(milliseconds: 100), () async {
              try {
                await _removeExpenseFromFirestore(oldExpense);
              } catch (e) {
                debugPrint('❌ Error removing old expense: $e');
              }
              try {
                await _uploadExpenseToFirestore(updatedExpense);
              } catch (e) {
                debugPrint('❌ Error uploading updated expense: $e');
              }
            });
          },
        );
      },
    );
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (_) => NewExpense(onAddExpense: _addExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTodayScreen = _selectedPageIndex == 0;
    final isSettingsScreen = _selectedPageIndex == 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: isSettingsScreen
            ? null
            : [
                if (_selectedPageIndex == 0 || _selectedPageIndex == 1)
                  IconButton(
                    onPressed: _openAddExpenseOverlay,
                    icon: const Icon(Icons.add),
                  ),
              ],
      ),
      body: isSettingsScreen
          ? SettingsScreen(onColorChanged: widget.onColorChanged)
          : StreamBuilder<List<Expense>>(
              stream: _getUserExpensesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allExpenses = snapshot.data ?? [];

                final now = DateTime.now();
                final todayExpenses = allExpenses
                    .where((e) =>
                        e.date.year == now.year &&
                        e.date.month == now.month &&
                        e.date.day == now.day)
                    .toList();

                if (isTodayScreen) {
                  return todayExpenses.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No expenses added yet!'),
                              SizedBox(height: 10),
                              Text('Start adding some by tapping "+" button.'),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GreetingHeader(),
                              Totalsummarycard(expenses: todayExpenses),
                              Chart(expenses: todayExpenses),
                              const SizedBox(height: 12),
                              const Text(
                                'Today\'s Expenses',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: ExpensesList(
                                  expenses: todayExpenses,
                                  onRemoveExpense: _removeExpense,
                                  onEditExpense: _editExpense,
                                ),
                              ),
                            ],
                          ),
                        );
                } else {
                  return AllExpensesScreen(
                    allExpense: allExpenses,
                    onRemoveExpense: _removeExpense,
                    onEditExpense: _editExpense,
                  );
                }
              },
            ),
      floatingActionButton: isTodayScreen
          ? FloatingActionButton(
              onPressed: _openAddExpenseOverlay,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner), label: 'All Expenses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
