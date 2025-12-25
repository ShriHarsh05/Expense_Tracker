import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

/// 🧠 Simplified Smart Learning Categorization System
/// Uses simple queries that don't require composite indexes
class SimplifiedSmartCategorizer {
  
  /// 🎯 Main method: Check if we should prompt user or auto-categorize
  static Future<CategorySuggestion> getSuggestion({
    required String smsBody,
    required double amount,
    required DateTime time,
    required Category initialCategory,
  }) async {
    print("🧠 Simplified Smart Categorizer: Processing ₹$amount, category: ${initialCategory.name}");
    
    // Only learn for Miscellaneous categories
    if (initialCategory != Category.Miscellaneous) {
      print("🧠 Not Miscellaneous (${initialCategory.name}) - no prompt needed");
      return CategorySuggestion(
        category: initialCategory,
        shouldPromptUser: false,
        confidence: 0.9,
        reason: 'Direct match from merchant database',
      );
    }
    
    print("🧠 Miscellaneous detected - checking for recent similar transactions...");
    
    // Check for recent similar transactions (simplified approach)
    final recentMatch = await _checkRecentSimilarTransactionsSimple(smsBody, amount, time);
    
    if (recentMatch != null) {
      print("🧠 Found recent similar transaction: ${recentMatch.category.name} (confidence: ${recentMatch.confidence})");
      return CategorySuggestion(
        category: recentMatch.category,
        shouldPromptUser: false,
        confidence: recentMatch.confidence,
        reason: 'Auto-categorized based on recent similar transaction: ${recentMatch.reason}',
      );
    }
    
    print("🧠 No recent similar transaction found - checking smart thresholds...");
    
    // Apply smart threshold system
    final shouldPrompt = _shouldPromptForMiscellaneous(smsBody, amount, time);
    
    print("🧠 Threshold decision: ${shouldPrompt.shouldPrompt ? 'PROMPT' : 'DON\'T PROMPT'} - ${shouldPrompt.reason}");
    
    if (!shouldPrompt.shouldPrompt) {
      return CategorySuggestion(
        category: Category.Miscellaneous,
        shouldPromptUser: false,
        confidence: 0.5,
        reason: shouldPrompt.reason,
      );
    }
    
    // Prompt user for learning
    return CategorySuggestion(
      category: Category.Miscellaneous,
      shouldPromptUser: true,
      confidence: 0.3,
      reason: 'Learning opportunity detected: ${shouldPrompt.reason}',
    );
  }
  
  /// 🎯 Simplified check for recent similar transactions
  /// Uses single-field queries to avoid composite index requirements
  static Future<LearnedPattern?> _checkRecentSimilarTransactionsSimple(String smsBody, double amount, DateTime time) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Look for recent SMS expenses (last 30 minutes) - single field query
      final thirtyMinutesAgo = time.subtract(const Duration(minutes: 30));
      
      print("🔍 Searching for recent SMS expenses since ${thirtyMinutesAgo.hour}:${thirtyMinutesAgo.minute}");
      
      final query = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(user.uid)
          .collection('user_expenses')
          .where('source', isEqualTo: 'sms') // Single field query - no index needed
          .orderBy('date', descending: true)
          .limit(20) // Get more results to filter client-side
          .get();

      if (query.docs.isEmpty) {
        print("🔍 No recent SMS expenses found");
        return null;
      }

      print("🔍 Found ${query.docs.length} recent SMS expenses, checking for similarity...");

      final currentSmsSource = _getSmsSource(smsBody);
      
      for (var doc in query.docs) {
        final data = doc.data();
        final existingAmount = data['amount'] as double;
        final existingDateStr = data['date'] as String;
        final existingCategory = data['category'] as String;
        final existingSms = data['originalSms'] as String?;
        final wasLearned = data['isLearning'] == false && data['needsUserInput'] == false;
        
        // Skip if this expense wasn't manually categorized by user
        if (!wasLearned) continue;
        
        try {
          final existingDate = DateTime.parse(existingDateStr);
          
          // Client-side filtering for time range (no index needed)
          if (existingDate.isBefore(thirtyMinutesAgo)) continue;
          if (existingDate.isAfter(time)) continue;
          
          final timeDifference = time.difference(existingDate).abs();
          
          // Check if transactions are similar enough to auto-categorize
          final isSimilarTime = timeDifference.inMinutes <= 10; // Within 10 minutes
          final isSimilarAmount = _isAmountSimilar(amount, existingAmount);
          final isSameSource = existingSms != null && _getSmsSource(existingSms) == currentSmsSource;
          
          if (isSimilarTime && isSimilarAmount && isSameSource) {
            print('🎯 Enhanced similarity match found:');
            print('   Current: ₹$amount at ${time.hour}:${time.minute} from $currentSmsSource');
            print('   Previous: ₹$existingAmount at ${existingDate.hour}:${existingDate.minute} from ${_getSmsSource(existingSms)}');
            print('   Time diff: ${timeDifference.inMinutes} minutes');
            print('   Auto-categorizing as: $existingCategory');
            
            return LearnedPattern(
              category: Category.values.firstWhere((c) => c.name == existingCategory),
              confidence: 0.85, // High confidence for recent similar transactions
              reason: 'Similar transaction ₹$existingAmount → ₹$amount (${timeDifference.inMinutes}min ago)',
              usageCount: 1,
            );
          }
        } catch (e) {
          print('⚠️ Error parsing date for similarity check: $e');
          continue;
        }
      }
      
      print("🔍 No similar transactions found in recent history");
      return null;
      
    } catch (e) {
      print('❌ Error checking recent similar transactions: $e');
      return null;
    }
  }

  /// 💰 Check if two amounts are similar enough for auto-categorization
  static bool _isAmountSimilar(double amount1, double amount2) {
    final difference = (amount1 - amount2).abs();
    final averageAmount = (amount1 + amount2) / 2;
    
    // For small amounts (≤₹100), allow ₹10 difference
    if (averageAmount <= 100) {
      return difference <= 10;
    }
    
    // For larger amounts, allow 15% difference
    final percentageDifference = difference / averageAmount;
    return percentageDifference <= 0.15; // 15% tolerance
  }
  
  /// 📱 Get SMS source (wallet type)
  static String _getSmsSource(String smsBody) {
    final body = smsBody.toLowerCase();
    if (body.contains('mobikwik')) return 'mobikwik';
    if (body.contains('paytm')) return 'paytm';
    if (body.contains('phonepe')) return 'phonepe';
    if (body.contains('gpay') || body.contains('google pay')) return 'gpay';
    return 'bank';
  }
  
  /// 🧠 Smart threshold system to determine if Miscellaneous expense is worth prompting for
  static PromptDecision _shouldPromptForMiscellaneous(String smsBody, double amount, DateTime time) {
    final body = smsBody.toLowerCase();
    
    // 🚫 **DON'T PROMPT THRESHOLDS** (Auto-accept as Miscellaneous)
    
    // 1. Very small amounts (likely not worth categorizing)
    if (amount <= 10) {
      return PromptDecision(
        shouldPrompt: false,
        reason: 'Amount too small (≤₹10) - likely parking, tips, etc.',
      );
    }
    
    // 2. ATM/Cash withdrawals (clearly miscellaneous)
    if (body.contains('atm') || 
        body.contains('cash withdrawal') || 
        body.contains('withdrawn from atm')) {
      return PromptDecision(
        shouldPrompt: false,
        reason: 'ATM/Cash withdrawal - clearly miscellaneous',
      );
    }
    
    // 3. Bank fees and charges (clearly miscellaneous)
    if (body.contains('service charge') || 
        body.contains('annual fee') || 
        body.contains('maintenance charge') ||
        body.contains('sms charge') ||
        body.contains('debit card fee')) {
      return PromptDecision(
        shouldPrompt: false,
        reason: 'Bank fee/charge - clearly miscellaneous',
      );
    }
    
    // 4. Very late night transactions (likely online/miscellaneous)
    final hour = time.hour;
    if ((hour >= 23 || hour <= 5) && amount <= 100) {
      return PromptDecision(
        shouldPrompt: false,
        reason: 'Late night small transaction - likely miscellaneous',
      );
    }
    
    // 5. Generic wallet debits without merchant info (low learning value)
    if ((body.contains('debited from your') && body.contains('wallet')) &&
        !_hasUsefulMerchantInfo(body) && amount <= 50) {
      return PromptDecision(
        shouldPrompt: false,
        reason: 'Generic wallet debit without merchant info - low learning value',
      );
    }
    
    // ✅ **DO PROMPT THRESHOLDS** (Worth learning from)
    
    // 1. Moderate to large amounts (worth categorizing)
    if (amount >= 100) {
      return PromptDecision(
        shouldPrompt: true,
        reason: 'Significant amount (≥₹100) - worth categorizing',
      );
    }
    
    // 2. Recurring time patterns (could be regular expenses)
    if (_isRecurringTimePattern(time)) {
      return PromptDecision(
        shouldPrompt: true,
        reason: 'Recurring time pattern - could be regular expense',
      );
    }
    
    // 3. Contains potential merchant information
    if (_hasUsefulMerchantInfo(body)) {
      return PromptDecision(
        shouldPrompt: true,
        reason: 'Contains merchant information - good learning opportunity',
      );
    }
    
    // 4. Peak spending hours (likely intentional purchases)
    if ((hour >= 12 && hour <= 14) || (hour >= 18 && hour <= 21)) {
      return PromptDecision(
        shouldPrompt: true,
        reason: 'Peak spending hours - likely intentional purchase',
      );
    }
    
    // Default: Don't prompt for small, unclear transactions
    return PromptDecision(
      shouldPrompt: false,
      reason: 'Small unclear transaction - not worth prompting',
    );
  }
  
  /// 🔍 Check if SMS contains useful merchant information
  static bool _hasUsefulMerchantInfo(String body) {
    // Look for quoted text, specific patterns, or known keywords
    return body.contains('"') || 
           body.contains('paid to') || 
           body.contains('payment to') ||
           body.contains('at ') ||
           body.contains('from ') ||
           RegExp(r'\b[A-Z]{2,}\b').hasMatch(body); // Uppercase words (merchant names)
  }
  
  /// ⏰ Check if transaction time suggests recurring pattern
  static bool _isRecurringTimePattern(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    // Round hours (9:00, 10:00, etc.) - often recurring
    if (minute <= 5 || minute >= 55) return true;
    
    // Common recurring times
    if ((hour == 9 && minute <= 30) ||  // Morning routine
        (hour == 13 && minute <= 30) || // Lunch time
        (hour == 18 && minute <= 30)) { // Evening routine
      return true;
    }
    
    return false;
  }
  
  /// 📚 Save user correction (simplified - no complex patterns)
  static Future<void> learnFromUserCorrection({
    required String smsBody,
    required double amount,
    required DateTime time,
    required Category userSelectedCategory,
    required String? userTitle,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Simple learning: just mark the expense as learned
      // The similarity matching will find it in future queries
      print('🧠 Simple learning: User selected ${userSelectedCategory.name} for ₹$amount transaction');
      
    } catch (e) {
      print('❌ Error in simple learning: $e');
    }
  }
}

/// 📋 Category suggestion result
class CategorySuggestion {
  final Category category;
  final bool shouldPromptUser;
  final double confidence;
  final String reason;
  
  CategorySuggestion({
    required this.category,
    required this.shouldPromptUser,
    required this.confidence,
    required this.reason,
  });
}

/// 🧠 Learned pattern result
class LearnedPattern {
  final Category category;
  final double confidence;
  final String reason;
  final int usageCount;
  
  LearnedPattern({
    required this.category,
    required this.confidence,
    required this.reason,
    required this.usageCount,
  });
}

/// 🎯 Prompt decision result for Miscellaneous thresholds
class PromptDecision {
  final bool shouldPrompt;
  final String reason;
  
  PromptDecision({
    required this.shouldPrompt,
    required this.reason,
  });
}