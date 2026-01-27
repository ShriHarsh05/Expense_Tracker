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

    // 🔒 **SECURITY CHECK: Validate sender is legitimate bank/financial institution**
    if (!_isLegitimateFinancialSender(sender, body)) {
      // print("🚫 Skipped non-financial sender: $sender");
      return;
    }

    // ❌ **EXPLICIT CREDIT/INCOME EXCLUSION** - Never process income transactions as expenses
    if (body.contains('credited to your') || 
        body.contains('amount credited') ||
        body.contains('rs') && body.contains('credited') && !body.contains('debited') ||
        body.contains('cashback') && body.contains('credited') ||
        body.contains('refund') && body.contains('credited') ||
        body.contains('salary') && body.contains('credited') ||
        body.contains('interest') && body.contains('credited') ||
        body.contains('withdrawn to your') ||
        body.contains('amount withdrawn to') ||
        body.contains('withdrawal to your') ||
        body.contains('cash withdrawn to') ||
        body.contains('money withdrawn to') ||
        body.contains('deposited to your') ||
        body.contains('amount deposited') ||
        body.contains('transfer to your account') ||
        body.contains('received in your account')) {
      // print("🚫 Skipped credit/income transaction: $body");
      return; // Skip all credit/income transactions
    }

    // ✅ Keywords to detect potential expenses (DEBIT/EXPENSE ONLY)
    // First check for promotional/non-expense patterns to exclude
    final isPromoOrNonExpense = body.contains('get cashback') ||
        body.contains('download the app') ||
        body.contains('limited time offer') ||
        body.contains('congratulations') ||
        body.contains('you have won') ||
        body.contains('click here') ||
        body.contains('visit our website') ||
        body.contains('terms and conditions') ||
        body.contains('offer valid till') ||
        body.contains('verification is pending') ||
        body.contains('complete kyc') ||
        body.contains('update your') ||
        body.contains('activate your') ||
        (body.contains('cashback') && !body.contains('cashback received')) ||
        (body.contains('offer') && !body.contains('transaction'));
    
    if (isPromoOrNonExpense) {
      return; // Skip promotional/service messages
    }
    
    final isExpense = body.contains('debited') ||
        body.contains('purchase') ||
        body.contains('spent') ||
        body.contains('withdrawn') ||
        body.contains('paid') ||
        body.contains('has been debited from your') || // For wallet notifications
        body.contains('wallet balance debited') ||
        body.contains('amount debited from wallet') ||
        // Credit card transaction patterns
        body.contains('card no.') ||
        body.contains('credit card') ||
        body.contains('debit card') ||
        body.contains('avl limit') ||
        body.contains('available limit') ||
        body.contains('transaction on') ||
        body.contains('charged to') ||
        // Bank-specific patterns
        body.contains('axis bank') ||
        body.contains('hdfc bank') ||
        body.contains('icici bank') ||
        body.contains('sbi card') ||
        body.contains('kotak bank') ||
        body.contains('union bank') ||
        body.contains('unionbank') ||
        body.contains('ubi') ||
        // Additional expense keywords
        body.contains('withdraw') ||
        body.contains('payment') ||
        body.contains('transfer') ||
        body.contains('pos') ||
        body.contains('atm') ||
        body.contains('online') ||
        body.contains('mobile banking') ||
        body.contains('net banking') ||
        // Wallet-specific expense patterns
        body.contains('paytm wallet') ||
        body.contains('phonepe wallet') ||
        body.contains('gpay wallet') ||
        body.contains('amazon pay wallet') ||
        body.contains('mobikwik wallet') ||
        body.contains('freecharge wallet') ||
        body.contains('ola money') ||
        body.contains('jio money') ||
        body.contains('airtel money') ||
        body.contains('wallet payment') ||
        body.contains('paid using') ||
        body.contains('payment from wallet') ||
        body.contains('wallet to bank') ||
        body.contains('money debited') ||
        body.contains('amount paid') ||
        body.contains('transaction successful') ||
        body.contains('payment successful') ||
        // UPI and digital payment patterns
        body.contains('upi transaction') ||
        body.contains('upi payment') ||
        body.contains('paid via upi') ||
        body.contains('bhim upi') ||
        // Amount patterns for credit cards and wallets
        (body.contains('inr') && (body.contains('limit') || body.contains('card') || body.contains('wallet'))) ||
        // Generic transaction patterns (ONLY debit/expense patterns)
        (body.contains('rs') && (body.contains('debited') || body.contains('paid'))) ||
        (body.contains('transaction') && (body.contains('successful') || body.contains('completed')));

    if (!isExpense) {
      return; // Silent return to reduce log noise
    }

    // ✅ Enhanced regex to extract amount (supports INR format and credit card patterns)
    final amountRegex = RegExp(
      r'(?:rs[:\.]?\s*|inr\s*|₹\s*)([\d,]+(?:\.\d{1,2})?)|(?:spent|charged|debited|withdrawn|paid)\s*(?:rs[:\.]?\s*|inr\s*|₹\s*)?([\d,]+(?:\.\d{1,2})?)|(?:amount|amt)\s*(?:rs[:\.]?\s*|inr\s*|₹\s*)?([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final match = amountRegex.firstMatch(body);

    if (match == null) {
      // Try alternative patterns for credit card SMS and Union Bank formats
      final altRegex = RegExp(
        r'([\d,]+\.\d{2})\s*(?:inr|rs|₹)?|(?:balance|bal)\s*(?:rs|inr|₹)?\s*([\d,]+(?:\.\d{2})?)|(?:your\s+account|a\/c)\s*.*?([\d,]+(?:\.\d{2})?)',
        caseSensitive: false,
      );
      final altMatch = altRegex.firstMatch(body);
      
      if (altMatch == null) {
        // print("❌ No valid amount found in: $body");
        return;
      }
      
      final amountStr = (altMatch.group(1) ?? altMatch.group(2) ?? altMatch.group(3))?.replaceAll(',', '') ?? '0.0';
      final amount = double.tryParse(amountStr);

      if (amount == null || amount <= 0) {
        return;
      }
      
      await _processExpenseTransaction(body, sender, time, amount);
      return;
    }

    // Process the matched amount
    final amountStr = (match.group(1) ?? match.group(2) ?? match.group(3))?.replaceAll(',', '') ?? '0.0';
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      return;
    }

    await _processExpenseTransaction(body, sender, time, amount);
  } catch (e, stackTrace) {
    print("❌ Error processing SMS message: $e");
    print("📍 Stack trace: $stackTrace");
    // Don't rethrow - continue processing other messages
  }
}

// Separate function to process the expense transaction
Future<void> _processExpenseTransaction(String body, String sender, DateTime time, double amount) async {
  try {

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
    print("❌ Error processing expense transaction: $e");
    print("📍 Stack trace: $stackTrace");
  }
}

// Detect payment method from SMS content (enhanced for credit cards)
String _detectPaymentMethod(String body) {
  final bodyLower = body.toLowerCase();
  
  // Credit Card payments (specific detection)
  if (bodyLower.contains('credit card') || 
      bodyLower.contains('card no.') ||
      bodyLower.contains('avl limit') ||
      bodyLower.contains('available limit') ||
      (bodyLower.contains('card') && bodyLower.contains('limit'))) {
    return 'Credit Card';
  }
  
  // Debit Card payments
  if (bodyLower.contains('debit card') ||
      bodyLower.contains('debit from') ||
      (bodyLower.contains('card') && bodyLower.contains('debited'))) {
    return 'Debit Card';
  }
  
  // UPI payments
  if (bodyLower.contains('upi') || 
      bodyLower.contains('gpay') || 
      bodyLower.contains('phonepe') || 
      bodyLower.contains('paytm') ||
      bodyLower.contains('bhim') ||
      bodyLower.contains('amazon pay')) {
    return 'UPI';
  }
  
  // Generic card payments
  if (bodyLower.contains('card') || 
      bodyLower.contains('visa') || 
      bodyLower.contains('mastercard') ||
      bodyLower.contains('rupay')) {
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

// 🔒 **SECURITY: Reject non-authentic senders (Banking Industry Standard)**
bool _isLegitimateFinancialSender(String sender, String body) {
  final senderLower = sender.toLowerCase();
  final bodyLower = body.toLowerCase();
  final senderUpper = sender.toUpperCase();
  
  // 🚫 **PRIMARY REJECTION RULES (Banking Industry Standards)**
  
  // ❌ REJECT: Standard 10-digit phone numbers (personal/fraudulent)
  if (RegExp(r'^\+?[1-9]\d{9}$').hasMatch(sender)) {
    print("🚫 REJECTED: Standard 10-digit phone number (fraudulent): $sender");
    return false;
  }
  
  // ❌ REJECT: 11-digit numbers starting with +91 (Indian personal numbers)
  if (RegExp(r'^\+91[6-9]\d{9}$').hasMatch(sender)) {
    print("🚫 REJECTED: Indian personal mobile number: $sender");
    return false;
  }
  
  // ❌ REJECT: 800 numbers (toll-free, often fraudulent for banking)
  if (RegExp(r'^1?800\d{7}$').hasMatch(sender)) {
    print("🚫 REJECTED: 800 toll-free number (non-banking): $sender");
    return false;
  }
  
  // ❌ REJECT: International numbers (banks use local short codes)
  if (RegExp(r'^\+(?!91)\d{10,15}$').hasMatch(sender)) {
    print("🚫 REJECTED: International number (non-Indian bank): $sender");
    return false;
  }
  
  // ❌ REJECT: Very long numbers (15+ digits, suspicious)
  if (RegExp(r'^\d{15,}$').hasMatch(sender)) {
    print("🚫 REJECTED: Suspiciously long number: $sender");
    return false;
  }
  
  // ❌ REJECT: Single digit or very short (1-3 digits, system messages)
  if (RegExp(r'^\d{1,3}$').hasMatch(sender)) {
    print("🚫 REJECTED: Too short, likely system message: $sender");
    return false;
  }
  
  // ❌ REJECT: Contains special characters (except hyphens for legitimate codes)
  if (RegExp(r'[^A-Z0-9\-]').hasMatch(sender.toUpperCase())) {
    print("🚫 REJECTED: Contains invalid special characters: $sender");
    return false;
  }
  
  // ❌ REJECT: All lowercase (banks use uppercase codes)
  if (sender.length > 3 && sender == sender.toLowerCase() && RegExp(r'^[a-z]+$').hasMatch(sender)) {
    print("🚫 REJECTED: All lowercase sender (non-banking): $sender");
    return false;
  }
  
  // ❌ REJECT: Personal names or common words (not bank codes)
  final personalNames = [
    'john', 'mary', 'david', 'sarah', 'mike', 'anna', 'raj', 'priya',
    'amit', 'neha', 'rohit', 'kavya', 'admin', 'user', 'test', 'demo',
    'info', 'hello', 'hi', 'message', 'sms', 'text', 'notification'
  ];
  
  for (String name in personalNames) {
    if (senderLower == name) {
      print("🚫 REJECTED: Personal name or common word: $sender");
      return false;
    }
  }
  
  // ✅ **TRAI 2025 SUFFIX-BASED VALIDATION (Primary Method)**
  // Check for TRAI compliant suffixes: -S (Service), -T (Transactional), -P (Promotional), -G (Government)
  if (RegExp(r'-[STPG]$').hasMatch(senderUpper)) {
    if (_hasAuthenticBankingContent(bodyLower)) {
      final suffix = senderUpper.substring(senderUpper.length - 1);
      final suffixType = suffix == 'S' ? 'Service' : 
                       suffix == 'T' ? 'Transactional' : 
                       suffix == 'P' ? 'Promotional' : 'Government';
      print("✅ ACCEPTED: TRAI compliant sender ($suffixType): $sender");
      return true;
    } else {
      print("🚫 REJECTED: TRAI compliant sender but no banking content: $sender");
      return false;
    }
  }
  
  // ✅ **LEGACY FORMAT SUPPORT (Pre-May 2025)**
  // For backward compatibility with older SMS formats
  
  // ✅ ACCEPT: 4-6 digit short codes (standard banking practice)
  if (RegExp(r'^\d{4,6}$').hasMatch(sender)) {
    if (_hasAuthenticBankingContent(bodyLower)) {
      print("✅ ACCEPTED: Bank short code with financial content: $sender");
      return true;
    } else {
      print("🚫 REJECTED: Short code but no banking content: $sender");
      return false;
    }
  }
  
  // ✅ ACCEPT: 5-6 character alphanumeric codes (Indian bank standard)
  if (RegExp(r'^[A-Z0-9]{5,6}$').hasMatch(senderUpper)) {
    if (_hasAuthenticBankingContent(bodyLower)) {
      print("✅ ACCEPTED: Legacy bank code with financial content: $sender");
      return true;
    } else {
      print("🚫 REJECTED: Bank code but no banking content: $sender");
      return false;
    }
  }
  
  // ✅ ACCEPT: Extended bank codes with hyphens (legacy format like JK-UNIONB)
  if (RegExp(r'^[A-Z0-9\-]{7,25}$').hasMatch(senderUpper)) {
    // Check if it contains known banking patterns
    final bankingPatterns = [
      'BANK', 'BNK', 'CARD', 'UNION', 'HDFC', 'ICICI', 'AXIS', 'SBI',
      'KOTAK', 'YES', 'PNB', 'CAN', 'IOB', 'SYND', 'AND', 'BOB',
      'UBI', 'MAHA', 'VIJ', 'AMEX', 'CITI', 'STAN', 'RBL', 'IND',
      'MOBIKW', 'PAYTM', 'PHONEPE', 'GPAY', 'AMAZONP', 'FREECHARGE'
    ];
    
    for (String pattern in bankingPatterns) {
      if (senderUpper.contains(pattern)) {
        if (_hasAuthenticBankingContent(bodyLower)) {
          print("✅ ACCEPTED: Legacy extended bank code with financial content: $sender");
          return true;
        } else {
          print("🚫 REJECTED: Bank code but no banking content: $sender");
          return false;
        }
      }
    }
  }
  
  // ✅ ACCEPT: Extended wallet/merchant codes (legacy format)
  if (RegExp(r'^[A-Z0-9\-]{10,30}$').hasMatch(senderUpper)) {
    // Check if it contains known wallet/payment patterns
    final walletPatterns = ['MOBIKW', 'PAYTM', 'PHONEPE', 'GPAY', 'AMAZONP', 'FREECHARGE'];
    
    for (String pattern in walletPatterns) {
      if (senderUpper.contains(pattern)) {
        if (_hasAuthenticBankingContent(bodyLower)) {
          print("✅ ACCEPTED: Legacy wallet code with financial content: $sender");
          return true;
        } else {
          print("🚫 REJECTED: Wallet code but no banking content: $sender");
          return false;
        }
      }
    }
  }
  
  // ✅ ACCEPT: Hyphenated bank/merchant codes (legacy format)
  if (RegExp(r'^[A-Z0-9]+(-[A-Z0-9]+)+$').hasMatch(senderUpper)) {
    if (_hasAuthenticBankingContent(bodyLower)) {
      print("✅ ACCEPTED: Legacy hyphenated code with financial content: $sender");
      return true;
    } else {
      print("🚫 REJECTED: Hyphenated code but no banking content: $sender");
      return false;
    }
  }
  
  // 🚫 **DEFAULT REJECTION**
  // If sender doesn't match any authentic banking pattern, reject
  print("🚫 REJECTED: Does not match authentic banking sender patterns: $sender");
  return false;
}

// Enhanced banking content validation (includes wallet transactions)
bool _hasAuthenticBankingContent(String body) {
  // 🏦 **STRONG BANKING INDICATORS** (must have at least one)
  final strongBankingIndicators = [
    'avl limit', 'available limit', 'card no.', 'account no',
    'transaction id', 'reference no', 'utr no', 'utr number',
    'ifsc code', 'branch code', 'customer id', 'debit card',
    'credit card', 'net banking', 'mobile banking',
    'not you? sms block', 'call customer care', 'visit branch',
    'terms and conditions apply', 'charges applicable',
    // Union Bank specific patterns
    'union bank', 'unionbank', 'ubi', 'union bank of india',
    // Common banking transaction phrases
    'debited from your', 'credited to your', 'balance is',
    'transaction successful', 'transaction failed', 'otp',
    'mini statement', 'account statement', 'cheque book',
    'atm withdrawal', 'pos transaction', 'online transfer',
    'neft', 'rtgs', 'imps', 'upi transaction',
    
    // 💳 **WALLET-SPECIFIC INDICATORS**
    'wallet balance', 'wallet debited', 'wallet credited',
    'paytm wallet', 'phonepe wallet', 'gpay wallet', 'amazon pay wallet',
    'mobikwik wallet', 'freecharge wallet', 'ola money', 'jio money',
    'airtel money', 'bharti wallet', 'wallet to bank', 'bank to wallet',
    'wallet recharge', 'wallet payment', 'wallet transfer',
    'add money to wallet', 'money added to wallet',
    'wallet balance low', 'wallet transaction',
    'paid using wallet', 'payment from wallet',
    'wallet cashback', 'wallet refund'
  ];
  
  for (String indicator in strongBankingIndicators) {
    if (body.contains(indicator)) {
      return true; // Strong banking/wallet indicator found
    }
  }
  
  // 💰 **FINANCIAL TRANSACTION PATTERNS** (must match specific format)
  // Pattern: Amount + Banking/Wallet action + Account/Card/Wallet reference
  final transactionPatterns = [
    RegExp(r'(rs|inr)\s*[\d,]+\.?\d*\s*(debited|credited|spent|charged).*?(account|card|wallet)', caseSensitive: false),
    RegExp(r'(debited|credited|spent|charged)\s*(rs|inr)\s*[\d,]+\.?\d*.*?(from|to).*?(account|card|wallet)', caseSensitive: false),
    RegExp(r'transaction.*?(rs|inr)\s*[\d,]+\.?\d*.*?(successful|completed|failed)', caseSensitive: false),
    // Union Bank specific transaction patterns
    RegExp(r'(rs|inr)\s*[\d,]+\.?\d*.*?(debited|credited).*?(union|ubi)', caseSensitive: false),
    RegExp(r'your.*?(account|card|wallet).*?(rs|inr)\s*[\d,]+\.?\d*', caseSensitive: false),
    // Wallet-specific patterns
    RegExp(r'(rs|inr)\s*[\d,]+\.?\d*.*?(debited|credited|added|paid).*?wallet', caseSensitive: false),
    RegExp(r'wallet.*?(rs|inr)\s*[\d,]+\.?\d*.*?(debited|credited|balance)', caseSensitive: false),
    RegExp(r'paid.*?(rs|inr)\s*[\d,]+\.?\d*.*?(using|via|through).*?(paytm|phonepe|gpay|wallet)', caseSensitive: false),
  ];
  
  for (RegExp pattern in transactionPatterns) {
    if (pattern.hasMatch(body)) {
      return true; // Authentic transaction pattern found
    }
  }
  
  // 🔢 **BANKING/WALLET KEYWORDS COUNT** (fallback - need multiple keywords)
  final bankingKeywords = [
    'account', 'balance', 'transaction', 'debited', 'credited',
    'bank', 'card', 'upi', 'wallet', 'payment', 'transfer',
    'limit', 'statement', 'otp', 'pin', 'atm', 'pos',
    // Additional banking terms
    'withdraw', 'deposit', 'cheque', 'draft', 'loan',
    'emi', 'interest', 'charges', 'fee', 'branch',
    'customer', 'service', 'helpline', 'support',
    // Wallet-specific keywords
    'paytm', 'phonepe', 'gpay', 'amazon pay', 'mobikwik',
    'freecharge', 'ola money', 'jio money', 'airtel money',
    'recharge', 'cashback', 'refund', 'topup', 'add money'
  ];
  
  int keywordCount = 0;
  for (String keyword in bankingKeywords) {
    if (body.contains(keyword)) {
      keywordCount++;
    }
  }
  
  // Need at least 2 banking/wallet keywords for unknown patterns
  if (keywordCount >= 2) {
    return true;
  }
  
  return false; // Not enough banking/wallet indicators
}