import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'expense_categorizer.dart';
import 'smart_categorizer.dart';
import '../models/expense.dart';

const uuid = Uuid();

// Initialize the SMS Query instance
final SmsQuery _query = SmsQuery();

/// Call this function when the app starts (e.g., in initState of your Home Screen)
Future<void> syncSmsMessages() async {
  try {
    // 1. Request Permissions safely using permission_handler
    var permission = await Permission.sms.status;
    if (!permission.isGranted) {
      await Permission.sms.request();
      permission = await Permission.sms.status;
    }

    if (permission.isGranted) {
      print("📡 Permission granted. Scanning inbox...");

      // 2. Fetch SMS messages (e.g., last 50 messages to save time)
      // We filter for INBOX only.
      List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50, // Fetch recent 50 to ensure we catch missed expenses
      );

      print("📡 Found ${messages.length} messages. Filtering for expenses...");

      // 3. Process each message with error handling
      for (var message in messages) {
        try {
          await _processSmsMessage(message);
        } catch (e) {
          print("❌ Error processing individual SMS: $e");
          // Continue processing other messages
        }
      }
      
      print("✅ SMS Sync Completed");
    } else {
      print("❌ SMS Permission denied");
    }
  } catch (e, stackTrace) {
    print("❌ Critical error in SMS sync: $e");
    print("📍 Stack trace: $stackTrace");
  }
}

Future<void> _processSmsMessage(SmsMessage message) async {
  try {
    final body = message.body?.toLowerCase() ?? '';
    final sender = message.address ?? '';
    
    // Use the actual message date, or fallback to now
    final time = message.date ?? DateTime.now();

    // 1. CHECK: Don't process very old messages (e.g., older than 7 days)
    if (time.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
      return; 
    }

    // ✅ Keywords to detect potential expenses
    final isExpense = body.contains('debited') ||
        body.contains('purchase') ||
        body.contains('spent') ||
        body.contains('withdrawn') ||
        body.contains('paid') ||
        body.contains('has been debited from your') || // For wallet notifications
        body.contains('wallet balance debited') ||
        body.contains('amount debited from wallet');

    if (!isExpense) {
      return; // Silent return to reduce log noise
    }

    // ✅ Regex to extract amount
    final amountRegex = RegExp(
      r'(rs[:\.]?)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final match = amountRegex.firstMatch(body);

    if (match == null) {
      // print("❌ No valid amount found in: $body");
      return;
    }

    final amountStr = match.group(2)?.replaceAll(',', '') ?? '0.0';
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      return;
    }

    // ✅ Create a unique SMS identifier for better duplicate detection
    final smsHash = _createSmsHash(body, sender, amount, time);

    // ✅ Check if this SMS was already processed (prevents re-adding after deletion)
    bool alreadyProcessed = await _checkIfSmsAlreadyProcessed(smsHash);
    if (alreadyProcessed) {
      print("⚠️ SMS already processed: ₹$amount from $sender at ${time.hour}:${time.minute}");
      return;
    }

    // ✅ Check for current duplicate expenses (in case of multiple similar SMS)
    bool exists = await _checkIfExpenseExists(amount, time, smsHash);
    if (exists) {
      print("⚠️ Skipped duplicate expense: ₹$amount from $sender at ${time.hour}:${time.minute}");
      return;
    }

    // 🤖 AI-Powered Categorization with Smart Learning
    Category category;
    String title;
    bool shouldPromptUser = false;
    
    try {
      // Use hybrid approach for initial categorization
      category = await ExpenseCategorizer.categorizeHybrid(body, amount);
      
      // Get smart suggestion (checks if we should prompt user or auto-categorize)
      final suggestion = await SmartCategorizer.getSuggestion(
        smsBody: body,
        amount: amount,
        time: time,
        initialCategory: category,
      );
      
      category = suggestion.category;
      shouldPromptUser = suggestion.shouldPromptUser;
      
      final confidence = ExpenseCategorizer.getConfidenceScore(body, category);
      print("🎯 Categorized as ${category.name} (confidence: ${(confidence * 100).toInt()}%)");
      print("🧠 Smart suggestion: ${suggestion.reason}");
      
    } catch (e) {
      print("⚠️ Categorization failed: $e, using Miscellaneous");
      category = Category.Miscellaneous;
      shouldPromptUser = true;
    }

    // 🏷️ Generate Smart Title with Category and Payment Method
    final paymentMethod = _detectPaymentMethod(body);
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    title = "${category.name}: $paymentMethod $timeStr";

    // ✅ Save to Firestore (with prompt flag if needed)
    await addExpenseToStorage(
      title: title,
      amount: amount,
      date: time,
      category: category.name,
      smsHash: smsHash,
      shouldPromptUser: shouldPromptUser,
      smsBody: body, // Store for user prompt
    );

    // ✅ Mark SMS as processed to prevent re-adding after deletion
    await _markSmsAsProcessed(smsHash);

    print("✅ New Expense Added: ₹$amount at $timeStr (${category.name}) - Prompt: $shouldPromptUser");
    
  } catch (e, stackTrace) {
    print("❌ Error processing SMS message: $e");
    print("📍 Stack trace: $stackTrace");
    // Don't rethrow - continue processing other messages
  }
}

// Detect payment method from SMS content
String _detectPaymentMethod(String body) {
  final bodyLower = body.toLowerCase();
  
  // UPI payments
  if (bodyLower.contains('upi') || 
      bodyLower.contains('gpay') || 
      bodyLower.contains('phonepe') || 
      bodyLower.contains('paytm') ||
      bodyLower.contains('bhim') ||
      bodyLower.contains('amazon pay')) {
    return 'UPI';
  }
  
  // Card payments
  if (bodyLower.contains('card') || 
      bodyLower.contains('visa') || 
      bodyLower.contains('mastercard') ||
      bodyLower.contains('rupay') ||
      bodyLower.contains('debit') ||
      bodyLower.contains('credit')) {
    return 'Card';
  }
  
  // Net banking
  if (bodyLower.contains('netbanking') || 
      bodyLower.contains('net banking') ||
      bodyLower.contains('online transfer') ||
      bodyLower.contains('neft') ||
      bodyLower.contains('rtgs') ||
      bodyLower.contains('imps')) {
    return 'Net Banking';
  }
  
  // ATM withdrawal
  if (bodyLower.contains('atm') || 
      bodyLower.contains('cash withdrawal') ||
      bodyLower.contains('withdrawn')) {
    return 'ATM';
  }
  
  // Default
  return 'Bank';
}

// Create a unique hash for SMS message to detect exact duplicates
String _createSmsHash(String body, String sender, double amount, DateTime date) {
  // Create a hash from key components of the SMS
  final key = '${sender}_${amount}_${date.day}_${date.hour}_${date.minute}';
  return key.hashCode.toString();
}

// Check if this SMS hash was already processed (permanent tracking)
Future<bool> _checkIfSmsAlreadyProcessed(String smsHash) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  try {
    // Check in a separate collection that tracks processed SMS
    final doc = await FirebaseFirestore.instance
        .collection('processed_sms')
        .doc(user.uid)
        .collection('sms_hashes')
        .doc(smsHash)
        .get();
    
    return doc.exists;
  } catch (e) {
    print("⚠️ Error checking processed SMS: $e");
    return false; // If check fails, allow processing to be safe
  }
}

// Mark SMS as processed (permanent tracking)
Future<void> _markSmsAsProcessed(String smsHash) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    await FirebaseFirestore.instance
        .collection('processed_sms')
        .doc(user.uid)
        .collection('sms_hashes')
        .doc(smsHash)
        .set({
          'processedAt': DateTime.now().toIso8601String(),
          'hash': smsHash,
        });
  } catch (e) {
    print("⚠️ Error marking SMS as processed: $e");
  }
}

// Helper: Prevent adding the same SMS twice using multiple duplicate detection methods
Future<bool> _checkIfExpenseExists(double amount, DateTime date, String smsHash) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  try {
    // Get expenses from the last 7 days (same as our SMS scan window)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final query = await FirebaseFirestore.instance
        .collection('expenses')
        .doc(user.uid)
        .collection('user_expenses')
        .where('date', isGreaterThan: sevenDaysAgo.toIso8601String())
        .get();

    // Check for duplicates using multiple methods
    for (var doc in query.docs) {
      final data = doc.data();
      final existingAmount = data['amount'];
      final existingDateStr = data['date'];
      final existingSmsHash = data['smsHash'];
      
      // Method 1: Check if SMS hash matches (most reliable)
      if (existingSmsHash != null && existingSmsHash == smsHash) {
        print("🔍 Exact duplicate found by SMS hash: ₹$amount");
        return true;
      }
      
      // Method 2: Check if amounts match AND time is close
      if (existingAmount == amount) {
        try {
          final existingDate = DateTime.parse(existingDateStr);
          final timeDifference = date.difference(existingDate).abs();
          
          // If same amount and within 5 minutes, it's likely a duplicate
          if (timeDifference.inMinutes <= 5) {
            print("🔍 Duplicate found by amount+time: ₹$amount at ${date.hour}:${date.minute} (existing: ${existingDate.hour}:${existingDate.minute})");
            return true;
          }
        } catch (e) {
          print("⚠️ Error parsing date for duplicate check: $e");
        }
      }
    }
    
    return false; // No duplicate found
  } catch (e) {
    print("⚠️ Duplicate check failed, allowing expense: $e");
    return false; // If check fails, allow the expense to be safe
  }
}

Future<void> addExpenseToStorage({
  required String title,
  required double amount,
  required DateTime date,
  required String category,
  String? smsHash,
  bool shouldPromptUser = false,
  String? smsBody,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No user logged in, cannot save expense");
      return;
    }
    
    print("💾 Saving expense to Firestore: $title - ₹$amount");
    
    final expenseData = {
      'id': uuid.v4(), // Generate unique ID
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category, // This should match Category.Miscellaneous.name
    };
    
    // Add SMS hash if provided (for SMS-based expenses)
    if (smsHash != null) {
      expenseData['smsHash'] = smsHash;
      expenseData['source'] = 'sms'; // Mark as SMS-generated expense
    }
    
    // Add learning flags if user prompt is needed
    if (shouldPromptUser && smsBody != null) {
      expenseData['needsUserInput'] = true;
      expenseData['originalSms'] = smsBody;
      expenseData['isLearning'] = true;
      print("🧠 Expense marked for user categorization learning");
    }
    
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(user.uid)
        .collection('user_expenses')
        .add(expenseData);
    
    print("✅ Successfully saved expense to Firestore");
  } catch (e) {
    print("❌ Failed to save expense: $e");
  }
}