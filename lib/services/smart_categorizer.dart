import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

/// 🧠 Smart Learning Categorization System
/// Learns from user corrections and auto-categorizes similar transactions
class SmartCategorizer {
  
  // 📊 Learning pattern structure
  static const String _learningCollection = 'learning_patterns';
  
  /// 🎯 Main method: Check if we should prompt user or auto-categorize
  static Future<CategorySuggestion> getSuggestion({
    required String smsBody,
    required double amount,
    required DateTime time,
    required Category initialCategory,
  }) async {
    print("🧠 Smart Categorizer: Processing ₹$amount, category: ${initialCategory.name}");
    
    // Only learn for Miscellaneous categories (as requested)
    if (initialCategory != Category.Miscellaneous) {
      print("🧠 Not Miscellaneous (${initialCategory.name}) - no prompt needed");
      return CategorySuggestion(
        category: initialCategory,
        shouldPromptUser: false,
        confidence: 0.9,
        reason: 'Direct match from merchant database',
      );
    }
    
    print("🧠 Miscellaneous detected - checking learned patterns...");
    
    // Check if we have learned patterns for this type of transaction
    final learnedCategory = await _checkLearnedPatterns(smsBody, amount, time);
    
    if (learnedCategory != null) {
      print("🧠 Found learned pattern: ${learnedCategory.category.name} (confidence: ${learnedCategory.confidence})");
      return CategorySuggestion(
        category: learnedCategory.category,
        shouldPromptUser: false,
        confidence: learnedCategory.confidence,
        reason: 'Auto-categorized based on learned pattern: ${learnedCategory.reason}',
      );
    }
    
    print("🧠 No learned pattern found - checking smart thresholds...");
    
    // 🎯 **SMART THRESHOLD SYSTEM FOR MISCELLANEOUS PROMPTING**
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
  
  /// 📚 Save user correction as a learning pattern
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
      
      // Extract learning features
      final features = _extractLearningFeatures(smsBody, amount, time);
      
      // Create learning pattern
      final pattern = {
        'userId': user.uid,
        'features': features,
        'category': userSelectedCategory.name,
        'userTitle': userTitle,
        'learnedAt': DateTime.now().toIso8601String(),
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      };
      
      // Save to Firebase
      await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .add(pattern);
      
      print('🧠 Learned new pattern: ${userSelectedCategory.name} for ${features['amountRange']} at ${features['timeRange']}');
      
    } catch (e) {
      print('❌ Error saving learning pattern: $e');
    }
  }
  
  /// 🔍 Check existing learned patterns for similar transactions
  static Future<LearnedPattern?> _checkLearnedPatterns(String smsBody, double amount, DateTime time) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      // First, check for recent similar transactions (enhanced similarity matching)
      final recentMatch = await _checkRecentSimilarTransactions(smsBody, amount, time);
      if (recentMatch != null) {
        print('🎯 Found recent similar transaction match: ${recentMatch.category.name}');
        return recentMatch;
      }
      
      final features = _extractLearningFeatures(smsBody, amount, time);
      
      // Query Firebase for matching patterns
      final query = await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .where('features.amountRange', isEqualTo: features['amountRange'])
          .where('features.timeRange', isEqualTo: features['timeRange'])
          .orderBy('usageCount', descending: true)
          .limit(5)
          .get();
      
      if (query.docs.isEmpty) return null;
      
      // Find best matching pattern
      LearnedPattern? bestMatch;
      double bestScore = 0.0;
      
      for (var doc in query.docs) {
        final data = doc.data();
        final patternFeatures = data['features'] as Map<String, dynamic>;
        
        // Calculate similarity score
        final score = _calculateSimilarityScore(features, patternFeatures);
        
        if (score > bestScore && score >= 0.7) { // 70% similarity threshold
          bestScore = score;
          bestMatch = LearnedPattern(
            category: Category.values.firstWhere((c) => c.name == data['category']),
            confidence: score,
            reason: 'Amount: ${patternFeatures['amountRange']}, Time: ${patternFeatures['timeRange']}',
            usageCount: data['usageCount'] ?? 1,
          );
          
          // Update usage count
          _updatePatternUsage(doc.id);
        }
      }
      
      return bestMatch;
      
    } catch (e) {
      print('❌ Error checking learned patterns: $e');
      return null;
    }
  }

  /// 🎯 Check for recent similar transactions (enhanced similarity matching)
  /// Handles cases like ₹60 and ₹65 transactions 2 minutes apart from same wallet
  static Future<LearnedPattern?> _checkRecentSimilarTransactions(String smsBody, double amount, DateTime time) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Look for recent expenses (last 30 minutes) that were manually categorized
      final thirtyMinutesAgo = time.subtract(const Duration(minutes: 30));
      
      final query = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(user.uid)
          .collection('user_expenses')
          .where('date', isGreaterThan: thirtyMinutesAgo.toIso8601String())
          .where('date', isLessThan: time.toIso8601String())
          .where('source', isEqualTo: 'sms') // Only SMS-generated expenses
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      if (query.docs.isEmpty) return null;

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
  
  /// 🔧 Extract lightweight learning features from transaction
  static Map<String, dynamic> _extractLearningFeatures(String smsBody, double amount, DateTime time) {
    return {
      // Amount ranges (lightweight bucketing)
      'amountRange': _getAmountRange(amount),
      
      // Time ranges (hour of day)
      'timeRange': _getTimeRange(time),
      
      // SMS source (wallet type)
      'smsSource': _getSmsSource(smsBody),
      
      // Transaction type
      'transactionType': _getTransactionType(smsBody),
    };
  }
  
  /// 💰 Get amount range bucket (lightweight)
  static String _getAmountRange(double amount) {
    if (amount <= 50) return 'micro'; // ₹0-50
    if (amount <= 200) return 'small'; // ₹51-200
    if (amount <= 500) return 'medium'; // ₹201-500
    if (amount <= 1000) return 'large'; // ₹501-1000
    return 'xlarge'; // ₹1000+
  }
  
  /// ⏰ Get time range bucket (hour of day)
  static String _getTimeRange(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 12) return 'morning'; // 6 AM - 12 PM
    if (hour >= 12 && hour < 17) return 'afternoon'; // 12 PM - 5 PM
    if (hour >= 17 && hour < 21) return 'evening'; // 5 PM - 9 PM
    return 'night'; // 9 PM - 6 AM
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
  
  /// 💳 Get transaction type
  static String _getTransactionType(String smsBody) {
    final body = smsBody.toLowerCase();
    if (body.contains('wallet')) return 'wallet';
    if (body.contains('upi')) return 'upi';
    if (body.contains('card')) return 'card';
    if (body.contains('atm')) return 'atm';
    return 'bank';
  }
  
  /// 📊 Calculate similarity score between feature sets
  static double _calculateSimilarityScore(Map<String, dynamic> features1, Map<String, dynamic> features2) {
    double score = 0.0;
    int totalFeatures = 0;
    
    // Compare each feature
    features1.forEach((key, value) {
      if (features2.containsKey(key)) {
        totalFeatures++;
        if (features2[key] == value) {
          score += 1.0;
        }
      }
    });
    
    return totalFeatures > 0 ? score / totalFeatures : 0.0;
  }
  
  /// 📈 Update pattern usage count (for learning improvement)
  static Future<void> _updatePatternUsage(String patternId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .doc(patternId)
          .update({
        'usageCount': FieldValue.increment(1),
        'lastUsed': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      print('❌ Error updating pattern usage: $e');
    }
  }
  
  /// 🧹 Clean up old patterns (keep app lightweight)
  static Future<void> cleanupOldPatterns() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Delete patterns older than 6 months with low usage
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      
      final query = await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .where('lastUsed', isLessThan: sixMonthsAgo.toIso8601String())
          .where('usageCount', isLessThan: 3)
          .get();
      
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      
      print('🧹 Cleaned up ${query.docs.length} old learning patterns');
      
    } catch (e) {
      print('❌ Error cleaning up patterns: $e');
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