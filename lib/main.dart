import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/theme/app_theme.dart';
import 'package:expensetracker/widgets/expenses.dart';
import 'package:expensetracker/controller/theme_controller.dart';
import 'package:expensetracker/services/auth_service.dart';
import 'package:expensetracker/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    print("Firebase already initialized: $e");
  }
  
  // Don't scan SMS here - user might not be authenticated yet
  // SMS scanning will happen after login in the Expenses widget
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists && doc.data()?.containsKey('accentColor') == true) {
      final colorValue = doc['accentColor'];
      ThemeController.updateAccentColor(Color(colorValue));
    }
  }
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  @override
  void initState() {
    super.initState();

    // Load accent color on auth state change
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists &&
            doc.data() != null &&
            doc.data()!.containsKey('accentColor')) {
          final colorValue = doc['accentColor'];
          ThemeController.updateAccentColor(Color(colorValue));
        }
      }
    });
  }

  void _handleColorChanged(Color newColor) {
    ThemeController.updateAccentColor(newColor);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeController.accentColorNotifier,
      builder: (context, accentColor, _) {
        return MaterialApp(
          scrollBehavior:
              const MaterialScrollBehavior().copyWith(overscroll: false),
          title: 'Expense Tracker',
          theme: AppTheme.lightTheme(accentColor),
          darkTheme: AppTheme.darkTheme(accentColor),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: AuthService.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('An error occurred.')),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                return Expenses(onColorChanged: _handleColorChanged);
              } else {
                return const Scaffold(body: LoginScreen());
              }
            },
          ),
        );
      },
    );
  }
}
