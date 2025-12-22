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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expensetracker/widgets/greeting_header.dart';
import 'package:expensetracker/services/sms_listener.dart';
import 'package:expensetracker/services/expense_categorizer.dart';
import 'package:expensetracker/services/smart_categorizer.dart';
import 'package:expensetracker/widgets/category_prompt_dialog.dart';
import 'package:expensetracker/widgets/learning_prompt_banner.dart';

class Expenses extends StatefulWidget {
  final void Function(Color) onColorChanged;
  const Expenses({super.key, required this.onColorChanged});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  int _selectedPageIndex = 0;
  bool _hasRunInitialSmsSync = false;
  Expense? _currentLearningExpense; // 🧠 Current expense needing categorization
  bool _showLearningBanner = false; // 🎯 Banner visibility flag

  Stream<List<Expense>> _getUserExpensesStream() {
    final user = AuthService.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('expenses')
        .doc(user.uid)
        .collection('user_expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final expenses = snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
          
          // Check for expenses that need user input (learning system)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkForLearningPrompts(expenses);
          });
          
          return expenses;
        });
  }

  // 🧠 Check for expenses that need user categorization input
  void _checkForLearningPrompts(List<Expense> expenses) {
    final needsInput = expenses.where((e) => e.needsUserInput && e.isLearning).toList();
    
    if (needsInput.isNotEmpty && mounted) {
      // Show banner for the first expense that needs input (non-intrusive)
      final expense = needsInput.first;
      if (_currentLearningExpense?.id != expense.id) {
        setState(() {
          _currentLearningExpense = expense;
          _showLearningBanner = true;
        });
      }
    } else {
      // Hide banner if no expenses need input
      if (_showLearningBanner) {
        setState(() {
          _showLearningBanner = false;
          _currentLearningExpense = null;
        });
      }
    }
  }

  // 🎯 Show category selection dialog for learning
  void _showCategoryPrompt(Expense expense) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to make a choice
      builder: (context) => CategoryPromptDialog(
        amount: expense.amount,
        date: expense.date,
        smsBody: expense.originalSms ?? 'Transaction details not available',
        suggestedCategory: expense.category,
        onCategorySelected: (selectedCategory, customTitle) async {
          await _handleUserCategorySelection(expense, selectedCategory, customTitle);
        },
      ),
    );
  }

  // 📚 Handle user's category selection and learn from it
  Future<void> _handleUserCategorySelection(
    Expense expense, 
    Category selectedCategory, 
    String customTitle
  ) async {
    try {
      // Hide the learning banner immediately
      setState(() {
        _showLearningBanner = false;
        _currentLearningExpense = null;
      });

      // Learn from user's selection
      await SmartCategorizer.learnFromUserCorrection(
        smsBody: expense.originalSms ?? '',
        amount: expense.amount,
        time: expense.date,
        userSelectedCategory: selectedCategory,
        userTitle: customTitle.isNotEmpty ? customTitle : null,
      );

      // Update the expense in Firebase
      await _updateExpenseAfterLearning(expense, selectedCategory, customTitle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Learned! Similar transactions will be auto-categorized as ${selectedCategory.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      print('❌ Error handling user category selection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error saving your selection'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔄 Update expense after user learning
  Future<void> _updateExpenseAfterLearning(
    Expense expense, 
    Category selectedCategory, 
    String customTitle
  ) async {
    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      // Find the document to update
      final query = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(user.uid)
          .collection('user_expenses')
          .where('id', isEqualTo: expense.id)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        
        // Generate new title if custom title is provided
        final timeStr = "${expense.date.hour.toString().padLeft(2, '0')}:${expense.date.minute.toString().padLeft(2, '0')}";
        final finalTitle = customTitle.isNotEmpty ? customTitle : "${selectedCategory.name}: UPI $timeStr";
        
        await doc.reference.update({
          'category': selectedCategory.name,
          'title': finalTitle,
          'needsUserInput': false,
          'isLearning': false,
        });
      }
    } catch (e) {
      print('❌ Error updating expense after learning: $e');
    }
  }

  // ⏭️ Handle skip action (mark as processed without learning)
  Future<void> _handleSkipLearning(Expense expense) async {
    // Hide the learning banner immediately
    setState(() {
      _showLearningBanner = false;
      _currentLearningExpense = null;
    });

    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      // Find the document to update
      final query = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(user.uid)
          .collection('user_expenses')
          .where('id', isEqualTo: expense.id)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        
        await doc.reference.update({
          'needsUserInput': false,
          'isLearning': false,
          // Keep original category and title
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏭️ Skipped learning for this transaction'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error skipping learning: $e');
    }
  }

  // 🚫 Dismiss learning banner
  void _dismissLearningBanner() {
    setState(() {
      _showLearningBanner = false;
    });
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

  Future<void> _handleRefreshAll() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing: Scanning SMS and testing categorization...'),
          duration: Duration(seconds: 2),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No user logged in for refresh");
        return;
      }
      
      print("🔄 Starting comprehensive refresh...");
      print("🔍 Current user: ${user.uid}");
      
      // First: Scan SMS for new expenses
      print("📱 Step 1: Scanning SMS messages...");
      await syncSmsMessages();
      
      // Second: Test categorization system
      print("🧪 Step 2: Testing categorization system...");
      await ExpenseCategorizer.testCategorization();

      // Third: Clean up old learning patterns (keep app lightweight)
      print("🧹 Step 3: Cleaning up old learning patterns...");
      await SmartCategorizer.cleanupOldPatterns();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Refresh completed! SMS scanned, categorization tested, and patterns cleaned.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      print("✅ Comprehensive refresh completed successfully");
    } catch (e) {
      print("❌ Refresh error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Refresh failed: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _runInitialSmsSync() async {
    if (!_hasRunInitialSmsSync) {
      _hasRunInitialSmsSync = true;
      print("🔄 Running initial SMS sync after authentication...");
      try {
        await syncSmsMessages();
        print("✅ Initial SMS sync completed");
      } catch (e) {
        print("❌ Initial SMS sync failed: $e");
      }
    }
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
                    onPressed: _handleRefreshAll,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh: Scan SMS & Test Categorization',
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

                // Run initial SMS sync once user is authenticated and data is loaded
                if (snapshot.hasData && !_hasRunInitialSmsSync) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _runInitialSmsSync();
                  });
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
                  return Column(
                    children: [
                      // 🧠 Learning prompt banner (non-intrusive)
                      if (_showLearningBanner && _currentLearningExpense != null)
                        LearningPromptBanner(
                          expense: _currentLearningExpense!,
                          onFixPressed: () async {
                            // Small delay to ensure banner animation completes
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (mounted) {
                              _showCategoryPrompt(_currentLearningExpense!);
                            }
                          },
                          onSkipPressed: () {
                            _handleSkipLearning(_currentLearningExpense!);
                          },
                          onDismiss: _dismissLearningBanner,
                        ),
                      
                      // Main content
                      Expanded(
                        child: todayExpenses.isEmpty
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
                            : SingleChildScrollView(
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
                                    // Use a fixed height container for the expenses list
                                    SizedBox(
                                      height: 300, // Fixed height to prevent overflow
                                      child: ExpensesList(
                                        expenses: todayExpenses,
                                        onRemoveExpense: _removeExpense,
                                        onEditExpense: _editExpense,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      // 🧠 Learning prompt banner (non-intrusive)
                      if (_showLearningBanner && _currentLearningExpense != null)
                        LearningPromptBanner(
                          expense: _currentLearningExpense!,
                          onFixPressed: () async {
                            // Small delay to ensure banner animation completes
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (mounted) {
                              _showCategoryPrompt(_currentLearningExpense!);
                            }
                          },
                          onSkipPressed: () {
                            _handleSkipLearning(_currentLearningExpense!);
                          },
                          onDismiss: _dismissLearningBanner,
                        ),
                      
                      // All expenses content
                      Expanded(
                        child: AllExpensesScreen(
                          allExpense: allExpenses,
                          onRemoveExpense: _removeExpense,
                          onEditExpense: _editExpense,
                        ),
                      ),
                    ],
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
