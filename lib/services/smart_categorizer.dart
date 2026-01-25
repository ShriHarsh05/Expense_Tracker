import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

/// 🧠 Enhanced Smart Learning Categorization System
/// User-specific learning with improved pattern matching and caching
class SmartCategorizer {
  
  // 📊 Learning pattern structure
  static const String _learningCollection = 'learning_patterns';
  
  // 🚀 Performance optimization: In-memory cache for user patterns
  static final Map<String, List<CachedPattern>> _userPatternCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);
  
  // 📈 Enhanced similarity thresholds for better matching
  static const double _highConfidenceThreshold = 0.85;
  static const double _mediumConfidenceThreshold = 0.70;
  static const double _lowConfidenceThreshold = 0.55;
  
  /// 🎯 Enhanced main method with caching and improved pattern matching
  static Future<CategorySuggestion> getSuggestion({
    required String smsBody,
    required double amount,
    required DateTime time,
    required Category initialCategory,
  }) async {
    final stopwatch = Stopwatch()..start();
    print("🧠 Enhanced Smart Categorizer: Processing ₹$amount, category: ${initialCategory.name}");
    
    // Only learn for Miscellaneous categories (as requested)
    if (initialCategory != Category.Miscellaneous) {
      print("🧠 Not Miscellaneous (${initialCategory.name}) - no prompt needed");
      return CategorySuggestion(
        category: initialCategory,
        shouldPromptUser: false,
        confidence: 0.9,
        reason: 'Direct match from merchant database',
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
    
    print("🧠 Miscellaneous detected - checking enhanced learned patterns...");
    
    // 🚀 STEP 1: Check cached patterns first (fastest)
    final cachedResult = await _checkCachedPatterns(smsBody, amount, time);
    if (cachedResult != null) {
      print("⚡ Cache hit! Pattern found in ${stopwatch.elapsedMilliseconds}ms");
      return CategorySuggestion(
        category: cachedResult.category,
        shouldPromptUser: false,
        confidence: cachedResult.confidence,
        reason: 'Cached pattern: ${cachedResult.reason}',
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
    
    // 🎯 STEP 2: Enhanced recent transaction similarity (improved algorithm)
    final recentMatch = await _checkEnhancedRecentTransactions(smsBody, amount, time);
    if (recentMatch != null) {
      print("🎯 Enhanced recent match found in ${stopwatch.elapsedMilliseconds}ms");
      // Cache this pattern for future use
      await _cachePattern(smsBody, amount, time, recentMatch);
      return CategorySuggestion(
        category: recentMatch.category,
        shouldPromptUser: false,
        confidence: recentMatch.confidence,
        reason: 'Enhanced recent similarity: ${recentMatch.reason}',
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
    
    // 🔍 STEP 3: Deep pattern analysis with improved scoring
    final learnedCategory = await _checkEnhancedLearnedPatterns(smsBody, amount, time);
    if (learnedCategory != null) {
      print("🔍 Deep pattern match found in ${stopwatch.elapsedMilliseconds}ms");
      // Cache this pattern for future use
      await _cachePattern(smsBody, amount, time, learnedCategory);
      return CategorySuggestion(
        category: learnedCategory.category,
        shouldPromptUser: false,
        confidence: learnedCategory.confidence,
        reason: 'Deep pattern analysis: ${learnedCategory.reason}',
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
    
    print("🧠 No learned pattern found - checking enhanced smart thresholds...");
    
    // 🎯 STEP 4: Enhanced threshold system with user-specific adjustments
    final shouldPrompt = _shouldPromptForMiscellaneous(smsBody, amount, time);
    
    print("🧠 Enhanced threshold decision: ${shouldPrompt.shouldPrompt ? 'PROMPT' : 'DON\'T PROMPT'} - ${shouldPrompt.reason} (${stopwatch.elapsedMilliseconds}ms)");
    
    if (!shouldPrompt.shouldPrompt) {
      return CategorySuggestion(
        category: Category.Miscellaneous,
        shouldPromptUser: false,
        confidence: 0.5,
        reason: shouldPrompt.reason,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
    
    // Prompt user for learning with AI suggestions
    final aiSuggestion = await _generateAISuggestion(smsBody, amount, time);
    
    return CategorySuggestion(
      category: Category.Miscellaneous,
      shouldPromptUser: true,
      confidence: 0.3,
      reason: 'Enhanced learning opportunity: ${shouldPrompt.reason}',
      processingTimeMs: stopwatch.elapsedMilliseconds,
      suggestedCategory: aiSuggestion.suggestedCategory,
      suggestionReason: aiSuggestion.reason,
      suggestionConfidence: aiSuggestion.confidence,
      alternativeOptions: aiSuggestion.alternatives,
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
  
  /// 📚 Enhanced learning from user correction with better feature extraction
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
      
      // Extract enhanced learning features
      final features = _extractEnhancedLearningFeatures(smsBody, amount, time);
      
      // Create enhanced learning pattern
      final pattern = {
        'userId': user.uid,
        'features': features,
        'category': userSelectedCategory.name,
        'userTitle': userTitle,
        'originalSms': smsBody, // Store original SMS for future reference
        'learnedAt': DateTime.now().toIso8601String(),
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
        'confidence': 1.0, // User corrections have highest confidence
        'version': 2, // Enhanced version for future compatibility
      };
      
      // Save to Firebase
      await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .add(pattern);
      
      // Update cache immediately
      final userId = user.uid;
      if (_userPatternCache.containsKey(userId)) {
        final cachedPattern = CachedPattern(
          category: userSelectedCategory,
          confidence: 1.0,
          reason: 'User correction: ${userTitle ?? userSelectedCategory.name}',
          features: features,
          usageCount: 1,
          lastUsed: DateTime.now(),
        );
        _userPatternCache[userId]!.insert(0, cachedPattern);
        
        // Keep cache size manageable
        if (_userPatternCache[userId]!.length > 50) {
          _userPatternCache[userId]!.removeLast();
        }
      }
      
      print('🧠 Enhanced learning: ${userSelectedCategory.name} for ${features['amountRange']} at ${features['timeRange']} (cached)');
      
    } catch (e) {
      print('❌ Error saving enhanced learning pattern: $e');
    }
  }
  
  /// 🔍 Enhanced deep pattern analysis with improved scoring
  static Future<LearnedPattern?> _checkEnhancedLearnedPatterns(String smsBody, double amount, DateTime time) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final features = _extractEnhancedLearningFeatures(smsBody, amount, time);
      
      // Multi-stage query for better performance
      final queries = [
        // Stage 1: Exact feature matches (fastest)
        FirebaseFirestore.instance
            .collection(_learningCollection)
            .doc(user.uid)
            .collection('patterns')
            .where('features.amountRange', isEqualTo: features['amountRange'])
            .where('features.timeRange', isEqualTo: features['timeRange'])
            .orderBy('usageCount', descending: true)
            .limit(10),
        
        // Stage 2: Partial matches if no exact matches
        FirebaseFirestore.instance
            .collection(_learningCollection)
            .doc(user.uid)
            .collection('patterns')
            .where('features.smsSource', isEqualTo: features['smsSource'])
            .orderBy('usageCount', descending: true)
            .limit(15),
      ];
      
      for (int stage = 0; stage < queries.length; stage++) {
        final query = await queries[stage].get();
        if (query.docs.isEmpty) continue;
        
        // Enhanced pattern matching with multiple confidence levels
        LearnedPattern? bestMatch;
        double bestScore = 0.0;
        
        for (var doc in query.docs) {
          final data = doc.data();
          final patternFeatures = Map<String, dynamic>.from(data['features']);
          
          // Calculate enhanced similarity score
          final score = _calculateEnhancedSimilarityScore(features, patternFeatures);
          final usageWeight = _calculateUsageWeight(data['usageCount'] ?? 1);
          final recencyWeight = _calculateRecencyWeight(data['lastUsed']);
          
          // Combined score with weights
          final combinedScore = score * 0.7 + usageWeight * 0.2 + recencyWeight * 0.1;
          
          if (combinedScore > bestScore && score >= _lowConfidenceThreshold) {
            bestScore = combinedScore;
            bestMatch = LearnedPattern(
              category: Category.values.firstWhere((c) => c.name == data['category']),
              confidence: combinedScore,
              reason: 'Enhanced pattern: ${patternFeatures['amountRange']}, ${patternFeatures['timeRange']}, usage: ${data['usageCount']}',
              usageCount: data['usageCount'] ?? 1,
            );
            
            // Update usage count asynchronously
            _updatePatternUsage(doc.id);
          }
        }
        
        // Return if we found a good match in this stage
        if (bestMatch != null && bestMatch.confidence >= _mediumConfidenceThreshold) {
          print("🔍 Enhanced pattern match (Stage ${stage + 1}): ${bestMatch.category.name} (${(bestMatch.confidence * 100).toInt()}%)");
          return bestMatch;
        }
      }
      
      return null;
      
    } catch (e) {
      print('❌ Error in enhanced pattern analysis: $e');
      return null;
    }
  }
  
  /// ⚖️ Calculate usage-based weight for pattern scoring
  static double _calculateUsageWeight(int usageCount) {
    // Logarithmic scaling to prevent over-weighting frequently used patterns
    return (usageCount.clamp(1, 100) / 100.0) * 0.8 + 0.2;
  }
  
  /// ⏰ Calculate recency-based weight for pattern scoring
  static double _calculateRecencyWeight(String? lastUsedStr) {
    if (lastUsedStr == null) return 0.1;
    
    try {
      final lastUsed = DateTime.parse(lastUsedStr);
      final daysSinceUsed = DateTime.now().difference(lastUsed).inDays;
      
      // Recent patterns get higher weight
      if (daysSinceUsed <= 7) return 1.0;      // Last week: full weight
      if (daysSinceUsed <= 30) return 0.7;     // Last month: 70% weight
      if (daysSinceUsed <= 90) return 0.4;     // Last 3 months: 40% weight
      return 0.1;                              // Older: minimal weight
    } catch (e) {
      return 0.1;
    }
  }

  /// 🚀 PERFORMANCE: Check cached patterns first (fastest lookup)
  static Future<CachedPattern?> _checkCachedPatterns(String smsBody, double amount, DateTime time) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    final userId = user.uid;
    
    // Check if cache exists and is not expired
    if (!_userPatternCache.containsKey(userId) || 
        _cacheTimestamps[userId] == null ||
        DateTime.now().difference(_cacheTimestamps[userId]!).compareTo(_cacheExpiry) > 0) {
      // Cache miss or expired - load from Firebase
      await _loadUserPatternsToCache(userId);
    }
    
    final userPatterns = _userPatternCache[userId] ?? [];
    if (userPatterns.isEmpty) return null;
    
    final features = _extractEnhancedLearningFeatures(smsBody, amount, time);
    
    // Fast in-memory pattern matching
    for (final pattern in userPatterns) {
      final similarity = _calculateEnhancedSimilarityScore(features, pattern.features);
      
      if (similarity >= _highConfidenceThreshold) {
        // Update usage count in cache
        pattern.usageCount++;
        pattern.lastUsed = DateTime.now();
        
        return CachedPattern(
          category: pattern.category,
          confidence: similarity,
          reason: 'Cached: ${pattern.reason} (${pattern.usageCount} uses)',
          features: pattern.features,
          usageCount: pattern.usageCount,
          lastUsed: pattern.lastUsed,
        );
      }
    }
    
    return null;
  }
  
  /// 🔄 Load user patterns into memory cache
  static Future<void> _loadUserPatternsToCache(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(userId)
          .collection('patterns')
          .orderBy('usageCount', descending: true)
          .limit(50) // Cache top 50 patterns for performance
          .get();
      
      final patterns = <CachedPattern>[];
      for (var doc in query.docs) {
        final data = doc.data();
        patterns.add(CachedPattern(
          category: Category.values.firstWhere((c) => c.name == data['category']),
          confidence: 0.0, // Will be calculated during matching
          reason: 'Pattern from ${data['learnedAt']}',
          features: Map<String, dynamic>.from(data['features']),
          usageCount: data['usageCount'] ?? 1,
          lastUsed: DateTime.parse(data['lastUsed'] ?? DateTime.now().toIso8601String()),
        ));
      }
      
      _userPatternCache[userId] = patterns;
      _cacheTimestamps[userId] = DateTime.now();
      
      print("🚀 Loaded ${patterns.length} patterns to cache for user");
      
    } catch (e) {
      print('❌ Error loading patterns to cache: $e');
      _userPatternCache[userId] = [];
      _cacheTimestamps[userId] = DateTime.now();
    }
  }
  
  /// 💾 Cache a successful pattern for future fast lookup
  static Future<void> _cachePattern(String smsBody, double amount, DateTime time, LearnedPattern pattern) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final userId = user.uid;
    final features = _extractEnhancedLearningFeatures(smsBody, amount, time);
    
    final cachedPattern = CachedPattern(
      category: pattern.category,
      confidence: pattern.confidence,
      reason: pattern.reason,
      features: features,
      usageCount: pattern.usageCount,
      lastUsed: DateTime.now(),
    );
    
    // Add to cache
    if (!_userPatternCache.containsKey(userId)) {
      _userPatternCache[userId] = [];
    }
    _userPatternCache[userId]!.insert(0, cachedPattern); // Add to front for faster access
    
    // Keep cache size manageable
    if (_userPatternCache[userId]!.length > 50) {
      _userPatternCache[userId]!.removeLast();
    }
  }
  /// 🎯 Enhanced recent transaction similarity with improved algorithms
  static Future<LearnedPattern?> _checkEnhancedRecentTransactions(String smsBody, double amount, DateTime time) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Look for recent expenses (last 60 minutes for better coverage)
      final recentTimeWindow = time.subtract(const Duration(minutes: 60));
      
      final query = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(user.uid)
          .collection('user_expenses')
          .where('date', isGreaterThan: recentTimeWindow.toIso8601String())
          .where('date', isLessThan: time.toIso8601String())
          .where('source', isEqualTo: 'sms')
          .orderBy('date', descending: true)
          .limit(20) // Increased limit for better matching
          .get();

      if (query.docs.isEmpty) return null;

      final currentFeatures = _extractEnhancedLearningFeatures(smsBody, amount, time);
      
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
          
          // Enhanced similarity calculation
          final existingFeatures = existingSms != null 
              ? _extractEnhancedLearningFeatures(existingSms, existingAmount, existingDate)
              : <String, dynamic>{};
          
          final similarity = _calculateEnhancedSimilarityScore(currentFeatures, existingFeatures);
          final isTimeRelevant = timeDifference.inMinutes <= 30; // Within 30 minutes
          final isAmountSimilar = _isAmountSimilarEnhanced(amount, existingAmount);
          
          // Enhanced matching criteria
          if (similarity >= _mediumConfidenceThreshold && isTimeRelevant && isAmountSimilar) {
            print('🎯 Enhanced recent similarity match:');
            print('   Current: ₹$amount at ${time.hour}:${time.minute}');
            print('   Previous: ₹$existingAmount at ${existingDate.hour}:${existingDate.minute}');
            print('   Similarity: ${(similarity * 100).toInt()}%, Time: ${timeDifference.inMinutes}min');
            print('   Auto-categorizing as: $existingCategory');
            
            return LearnedPattern(
              category: Category.values.firstWhere((c) => c.name == existingCategory),
              confidence: similarity,
              reason: 'Recent similar: ₹$existingAmount → ₹$amount (${timeDifference.inMinutes}min, ${(similarity * 100).toInt()}%)',
              usageCount: 1,
            );
          }
        } catch (e) {
          print('⚠️ Error parsing recent transaction: $e');
          continue;
        }
      }
      
      return null;
      
    } catch (e) {
      print('❌ Error checking enhanced recent transactions: $e');
      return null;
    }
  }

  /// 💰 Enhanced amount similarity with dynamic thresholds
  static bool _isAmountSimilarEnhanced(double amount1, double amount2) {
    final difference = (amount1 - amount2).abs();
    final averageAmount = (amount1 + amount2) / 2;
    
    // Dynamic thresholds based on amount ranges
    if (averageAmount <= 50) {
      return difference <= 15; // ₹15 tolerance for small amounts
    } else if (averageAmount <= 200) {
      return difference <= 25; // ₹25 tolerance for medium amounts
    } else if (averageAmount <= 1000) {
      final percentageDifference = difference / averageAmount;
      return percentageDifference <= 0.20; // 20% tolerance for larger amounts
    } else {
      final percentageDifference = difference / averageAmount;
      return percentageDifference <= 0.15; // 15% tolerance for very large amounts
    }
  }
  
  /// 🔧 Extract enhanced learning features with more granular data
  static Map<String, dynamic> _extractEnhancedLearningFeatures(String smsBody, double amount, DateTime time) {
    return {
      // Enhanced amount ranges with more granularity
      'amountRange': _getEnhancedAmountRange(amount),
      'exactAmount': amount, // Store exact amount for precise matching
      
      // Enhanced time features
      'timeRange': _getTimeRange(time),
      'hourOfDay': time.hour,
      'dayOfWeek': time.weekday,
      'isWeekend': time.weekday >= 6,
      
      // Enhanced SMS analysis
      'smsSource': _getSmsSource(smsBody),
      'transactionType': _getTransactionType(smsBody),
      'hasQuotes': smsBody.contains('"'),
      'hasMerchantInfo': _hasUsefulMerchantInfo(smsBody),
      
      // Content analysis
      'smsLength': smsBody.length,
      'wordCount': smsBody.split(' ').length,
      'containsNumbers': RegExp(r'\d').hasMatch(smsBody),
      
      // Pattern fingerprint for fast matching
      'fingerprint': _generateSmsFingerprint(smsBody),
    };
  }
  
  /// 💰 Enhanced amount range with more granular buckets
  static String _getEnhancedAmountRange(double amount) {
    if (amount <= 10) return 'micro';      // ₹0-10
    if (amount <= 25) return 'tiny';       // ₹11-25
    if (amount <= 50) return 'small';      // ₹26-50
    if (amount <= 100) return 'medium';    // ₹51-100
    if (amount <= 200) return 'large';     // ₹101-200
    if (amount <= 500) return 'xlarge';    // ₹201-500
    if (amount <= 1000) return 'xxlarge';  // ₹501-1000
    if (amount <= 2000) return 'huge';     // ₹1001-2000
    return 'massive';                      // ₹2000+
  }
  
  /// 🔍 Generate SMS fingerprint for fast pattern matching
  static String _generateSmsFingerprint(String smsBody) {
    final body = smsBody.toLowerCase();
    final keywords = ['debited', 'credited', 'paid', 'transaction', 'wallet', 'card', 'upi', 'bank'];
    final foundKeywords = keywords.where((k) => body.contains(k)).toList();
    foundKeywords.sort(); // Consistent ordering
    return foundKeywords.join('|');
  }
  
  /// 📊 Enhanced similarity score calculation with weighted features
  static double _calculateEnhancedSimilarityScore(Map<String, dynamic> features1, Map<String, dynamic> features2) {
    if (features2.isEmpty) return 0.0;
    
    double score = 0.0;
    double totalWeight = 0.0;
    
    // Weighted feature comparison
    final featureWeights = {
      'amountRange': 0.25,      // Amount is very important
      'timeRange': 0.20,        // Time patterns matter
      'smsSource': 0.15,        // Source consistency
      'transactionType': 0.15,  // Transaction type
      'fingerprint': 0.10,      // Content similarity
      'dayOfWeek': 0.05,        // Day patterns
      'isWeekend': 0.05,        // Weekend vs weekday
      'hasMerchantInfo': 0.05,  // Merchant info presence
    };
    
    featureWeights.forEach((feature, weight) {
      if (features1.containsKey(feature) && features2.containsKey(feature)) {
        totalWeight += weight;
        if (features1[feature] == features2[feature]) {
          score += weight;
        } else if (feature == 'amountRange') {
          // Special handling for amount ranges - adjacent ranges get partial credit
          final range1 = features1[feature] as String;
          final range2 = features2[feature] as String;
          if (_areAdjacentAmountRanges(range1, range2)) {
            score += weight * 0.7; // 70% credit for adjacent ranges
          }
        }
      }
    });
    
    // Exact amount bonus for very similar amounts
    if (features1.containsKey('exactAmount') && features2.containsKey('exactAmount')) {
      final amount1 = features1['exactAmount'] as double;
      final amount2 = features2['exactAmount'] as double;
      if (_isAmountSimilarEnhanced(amount1, amount2)) {
        score += 0.1; // 10% bonus for similar exact amounts
        totalWeight += 0.1;
      }
    }
    
    return totalWeight > 0 ? score / totalWeight : 0.0;
  }
  
  /// 🔗 Check if amount ranges are adjacent (for partial matching)
  static bool _areAdjacentAmountRanges(String range1, String range2) {
    final ranges = ['micro', 'tiny', 'small', 'medium', 'large', 'xlarge', 'xxlarge', 'huge', 'massive'];
    final index1 = ranges.indexOf(range1);
    final index2 = ranges.indexOf(range2);
    
    if (index1 == -1 || index2 == -1) return false;
    return (index1 - index2).abs() == 1;
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

  /// 🤖 Generate AI suggestion with reasoning for user prompt
  static Future<AISuggestion> _generateAISuggestion(String smsBody, double amount, DateTime time) async {
    print("🤖 Generating AI suggestion for user prompt...");
    
    // Analyze SMS content for category hints
    final contentAnalysis = _analyzeTransactionContent(smsBody, amount, time);
    final timeAnalysis = _analyzeTimePatterns(time, amount);
    final amountAnalysis = _analyzeAmountPatterns(amount, time);
    
    // Get category scores from existing categorizer
    final categoryScores = await _getCategoryScores(smsBody, amount);
    
    // Combine analyses to generate suggestion
    final suggestion = _combineAnalysesForSuggestion(
      contentAnalysis, 
      timeAnalysis, 
      amountAnalysis, 
      categoryScores
    );
    
    // Generate alternative options
    final alternatives = _generateAlternativeOptions(categoryScores, smsBody, amount, time);
    
    print("🤖 AI Suggestion: ${suggestion.category.name} (${(suggestion.confidence * 100).toInt()}%)");
    print("🤖 Reasoning: ${suggestion.reason}");
    
    return AISuggestion(
      suggestedCategory: suggestion.category,
      confidence: suggestion.confidence,
      reason: suggestion.reason,
      alternatives: alternatives,
    );
  }
  
  /// 📝 Analyze transaction content for category hints
  static Map<String, dynamic> _analyzeTransactionContent(String smsBody, double amount, DateTime time) {
    final body = smsBody.toLowerCase();
    final analysis = <String, dynamic>{
      'indicators': <String>[],
      'categoryHints': <Category, double>{},
      'confidence': 0.0,
    };
    
    // Food indicators
    if (body.contains('restaurant') || body.contains('food') || body.contains('cafe') || 
        body.contains('dining') || body.contains('meal') || body.contains('lunch') || 
        body.contains('dinner') || body.contains('breakfast')) {
      analysis['categoryHints'][Category.Food] = 0.8;
      analysis['indicators'].add('Food-related keywords detected');
    }
    
    // Travel indicators
    if (body.contains('fuel') || body.contains('petrol') || body.contains('gas') ||
        body.contains('taxi') || body.contains('uber') || body.contains('ola') ||
        body.contains('flight') || body.contains('hotel') || body.contains('travel')) {
      analysis['categoryHints'][Category.Travel] = 0.8;
      analysis['indicators'].add('Travel-related keywords detected');
    }
    
    // Work indicators
    if (body.contains('office') || body.contains('business') || body.contains('work') ||
        body.contains('meeting') || body.contains('conference') || body.contains('software') ||
        body.contains('subscription') || body.contains('license')) {
      analysis['categoryHints'][Category.Work] = 0.7;
      analysis['indicators'].add('Work-related keywords detected');
    }
    
    // Leisure indicators
    if (body.contains('movie') || body.contains('cinema') || body.contains('entertainment') ||
        body.contains('shopping') || body.contains('mall') || body.contains('game') ||
        body.contains('sport') || body.contains('gym') || body.contains('spa')) {
      analysis['categoryHints'][Category.Leisure] = 0.7;
      analysis['indicators'].add('Leisure-related keywords detected');
    }
    
    // Merchant name extraction
    final merchantName = _extractMerchantFromGenericSMS(body);
    if (merchantName != null) {
      analysis['indicators'].add('Merchant identified: "$merchantName"');
      // Try to categorize merchant
      final merchantCategory = _categorizeMerchantName(merchantName);
      if (merchantCategory != null) {
        analysis['categoryHints'][merchantCategory] = 0.6;
        analysis['indicators'].add('Merchant suggests ${merchantCategory.name} category');
      }
    }
    
    return analysis;
  }
  
  /// ⏰ Analyze time patterns for category suggestions
  static Map<String, dynamic> _analyzeTimePatterns(DateTime time, double amount) {
    final analysis = <String, dynamic>{
      'indicators': <String>[],
      'categoryHints': <Category, double>{},
      'confidence': 0.0,
    };
    
    final hour = time.hour;
    final isWeekend = time.weekday >= 6;
    
    // Meal time patterns
    if (hour >= 12 && hour <= 14) {
      analysis['categoryHints'][Category.Food] = 0.6;
      analysis['indicators'].add('Lunch time (12-2 PM) suggests Food');
    } else if (hour >= 19 && hour <= 21) {
      analysis['categoryHints'][Category.Food] = 0.5;
      analysis['indicators'].add('Dinner time (7-9 PM) suggests Food');
    } else if (hour >= 7 && hour <= 9) {
      analysis['categoryHints'][Category.Food] = 0.4;
      analysis['indicators'].add('Breakfast time (7-9 AM) suggests Food');
    }
    
    // Work time patterns
    if (!isWeekend && hour >= 9 && hour <= 17) {
      analysis['categoryHints'][Category.Work] = 0.5;
      analysis['indicators'].add('Business hours (9-5 PM) on weekday suggests Work');
    }
    
    // Leisure time patterns
    if (isWeekend) {
      analysis['categoryHints'][Category.Leisure] = 0.6;
      analysis['indicators'].add('Weekend transaction suggests Leisure');
    } else if (hour >= 18 && hour <= 23) {
      analysis['categoryHints'][Category.Leisure] = 0.4;
      analysis['indicators'].add('Evening hours suggest Leisure');
    }
    
    // Travel time patterns
    if (hour >= 7 && hour <= 9 || hour >= 17 && hour <= 19) {
      analysis['categoryHints'][Category.Travel] = 0.5;
      analysis['indicators'].add('Commute hours (7-9 AM, 5-7 PM) suggest Travel');
    }
    
    return analysis;
  }
  
  /// 💰 Analyze amount patterns for category suggestions
  static Map<String, dynamic> _analyzeAmountPatterns(double amount, DateTime time) {
    final analysis = <String, dynamic>{
      'indicators': <String>[],
      'categoryHints': <Category, double>{},
      'confidence': 0.0,
    };
    
    // Amount-based category hints
    if (amount <= 50) {
      analysis['categoryHints'][Category.Food] = 0.4;
      analysis['indicators'].add('Small amount (≤₹50) commonly Food');
    } else if (amount <= 200) {
      analysis['categoryHints'][Category.Food] = 0.5;
      analysis['categoryHints'][Category.Leisure] = 0.4;
      analysis['indicators'].add('Medium amount (₹51-200) often Food or Leisure');
    } else if (amount <= 500) {
      analysis['categoryHints'][Category.Travel] = 0.5;
      analysis['categoryHints'][Category.Leisure] = 0.5;
      analysis['indicators'].add('Moderate amount (₹201-500) suggests Travel or Leisure');
    } else if (amount <= 1000) {
      analysis['categoryHints'][Category.Work] = 0.4;
      analysis['categoryHints'][Category.Travel] = 0.4;
      analysis['indicators'].add('Large amount (₹501-1000) often Work or Travel');
    } else {
      analysis['categoryHints'][Category.Work] = 0.6;
      analysis['indicators'].add('Very large amount (>₹1000) commonly Work');
    }
    
    return analysis;
  }
  
  /// 📊 Get category scores from existing categorizer
  static Future<Map<Category, double>> _getCategoryScores(String smsBody, double amount) async {
    // Use existing categorizer logic to get scores
    final scores = <Category, double>{};
    
    // Import from ExpenseCategorizer (simplified for demo)
    scores[Category.Food] = _calculateFoodScore(smsBody, amount);
    scores[Category.Travel] = _calculateTravelScore(smsBody, amount);
    scores[Category.Work] = _calculateWorkScore(smsBody, amount);
    scores[Category.Leisure] = _calculateLeisureScore(smsBody, amount);
    scores[Category.Miscellaneous] = _calculateMiscScore(smsBody, amount);
    
    return scores;
  }
  
  /// 🎯 Combine all analyses to generate final suggestion
  static CategorySuggestionResult _combineAnalysesForSuggestion(
    Map<String, dynamic> contentAnalysis,
    Map<String, dynamic> timeAnalysis,
    Map<String, dynamic> amountAnalysis,
    Map<Category, double> categoryScores,
  ) {
    final combinedScores = <Category, double>{};
    final allIndicators = <String>[];
    
    // Combine all indicators
    allIndicators.addAll(contentAnalysis['indicators'] as List<String>);
    allIndicators.addAll(timeAnalysis['indicators'] as List<String>);
    allIndicators.addAll(amountAnalysis['indicators'] as List<String>);
    
    // Combine scores with weights
    for (final category in Category.values) {
      double score = 0.0;
      
      // Content analysis (highest weight)
      if (contentAnalysis['categoryHints'].containsKey(category)) {
        score += (contentAnalysis['categoryHints'][category] as double) * 0.4;
      }
      
      // Time analysis (medium weight)
      if (timeAnalysis['categoryHints'].containsKey(category)) {
        score += (timeAnalysis['categoryHints'][category] as double) * 0.3;
      }
      
      // Amount analysis (medium weight)
      if (amountAnalysis['categoryHints'].containsKey(category)) {
        score += (amountAnalysis['categoryHints'][category] as double) * 0.2;
      }
      
      // Existing categorizer score (low weight)
      if (categoryScores.containsKey(category)) {
        score += categoryScores[category]! * 0.1;
      }
      
      combinedScores[category] = score;
    }
    
    // Find best suggestion
    final bestCategory = combinedScores.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    // Generate reasoning
    final reasoning = _generateReasoning(bestCategory.key, bestCategory.value, allIndicators);
    
    return CategorySuggestionResult(
      category: bestCategory.key,
      confidence: bestCategory.value.clamp(0.0, 1.0),
      reason: reasoning,
      indicators: allIndicators,
    );
  }
  
  /// 📝 Generate human-readable reasoning
  static String _generateReasoning(Category category, double confidence, List<String> indicators) {
    final reasons = <String>[];
    
    // Add category-specific reasoning
    switch (category) {
      case Category.Food:
        reasons.add("This appears to be a food-related expense");
        break;
      case Category.Travel:
        reasons.add("This looks like a travel or transportation expense");
        break;
      case Category.Work:
        reasons.add("This seems to be a work or business-related expense");
        break;
      case Category.Leisure:
        reasons.add("This appears to be an entertainment or leisure expense");
        break;
      case Category.Miscellaneous:
        reasons.add("This doesn't clearly fit other categories");
        break;
    }
    
    // Add top indicators
    if (indicators.isNotEmpty) {
      final topIndicators = indicators.take(2).toList();
      reasons.add("Based on: ${topIndicators.join(', ')}");
    }
    
    // Add confidence level
    if (confidence >= 0.7) {
      reasons.add("High confidence in this suggestion");
    } else if (confidence >= 0.5) {
      reasons.add("Moderate confidence in this suggestion");
    } else {
      reasons.add("Low confidence - please verify");
    }
    
    return reasons.join('. ');
  }
  
  /// 🔄 Generate alternative category options
  static List<CategoryOption> _generateAlternativeOptions(
    Map<Category, double> categoryScores,
    String smsBody,
    double amount,
    DateTime time,
  ) {
    final alternatives = <CategoryOption>[];
    
    // Sort categories by score
    final sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 3 alternatives (excluding the main suggestion)
    for (int i = 1; i < sortedCategories.length && alternatives.length < 3; i++) {
      final entry = sortedCategories[i];
      if (entry.value > 0.2) { // Only include reasonable alternatives
        alternatives.add(CategoryOption(
          category: entry.key,
          confidence: entry.value,
          reason: _getAlternativeReason(entry.key, smsBody, amount, time),
          indicators: _getAlternativeIndicators(entry.key, smsBody, amount, time),
        ));
      }
    }
    
    return alternatives;
  }
  
  /// 🔍 Extract merchant name from generic SMS
  static String? _extractMerchantFromGenericSMS(String body) {
    // Look for quoted text
    final quotedPattern = RegExp(r'"([^"]+)"');
    final quotedMatch = quotedPattern.firstMatch(body);
    if (quotedMatch != null) {
      return quotedMatch.group(1)?.trim();
    }
    
    // Look for "paid to" patterns
    final paidToPattern = RegExp(r'paid to ([a-zA-Z0-9\s]{3,20})');
    final paidToMatch = paidToPattern.firstMatch(body);
    if (paidToMatch != null) {
      return paidToMatch.group(1)?.trim();
    }
    
    return null;
  }
  
  /// 🏪 Categorize merchant name
  static Category? _categorizeMerchantName(String merchantName) {
    final name = merchantName.toLowerCase();
    
    // Food merchants
    if (name.contains('restaurant') || name.contains('cafe') || name.contains('food') ||
        name.contains('kitchen') || name.contains('dining') || name.contains('pizza') ||
        name.contains('burger') || name.contains('bakery')) {
      return Category.Food;
    }
    
    // Travel merchants
    if (name.contains('travel') || name.contains('taxi') || name.contains('transport') ||
        name.contains('fuel') || name.contains('petrol') || name.contains('airline') ||
        name.contains('hotel') || name.contains('booking')) {
      return Category.Travel;
    }
    
    // Leisure merchants
    if (name.contains('mall') || name.contains('store') || name.contains('shop') ||
        name.contains('cinema') || name.contains('movie') || name.contains('entertainment') ||
        name.contains('gym') || name.contains('spa') || name.contains('game')) {
      return Category.Leisure;
    }
    
    // Work merchants
    if (name.contains('office') || name.contains('business') || name.contains('software') ||
        name.contains('tech') || name.contains('service') || name.contains('consulting')) {
      return Category.Work;
    }
    
    return null;
  }
  
  /// 📋 Get alternative reason for category
  static String _getAlternativeReason(Category category, String smsBody, double amount, DateTime time) {
    switch (category) {
      case Category.Food:
        return "Could be food if transaction was at meal time or food establishment";
      case Category.Travel:
        return "Might be travel if related to transportation or fuel";
      case Category.Work:
        return "Could be work expense if business-related or during work hours";
      case Category.Leisure:
        return "Might be leisure if for entertainment or personal shopping";
      case Category.Miscellaneous:
        return "Could be miscellaneous if doesn't fit other categories clearly";
    }
  }
  
  // 🍕 Calculate Food category score (simplified version for AI suggestions)
  static double _calculateFoodScore(String body, double amount) {
    double score = 0.0;
    
    if (body.contains('restaurant')) score += 0.9;
    if (body.contains('food')) score += 0.8;
    if (body.contains('cafe')) score += 0.7;
    if (body.contains('zomato')) score += 0.95;
    if (body.contains('swiggy')) score += 0.95;
    if (body.contains('dominos')) score += 0.98;
    if (body.contains('mcdonalds')) score += 0.98;
    
    if (amount < 500) score += 0.3;
    if (amount > 2000) score -= 0.2;
    
    return score.clamp(0.0, 1.0);
  }
  
  // ✈️ Calculate Travel category score (simplified version for AI suggestions)
  static double _calculateTravelScore(String body, double amount) {
    double score = 0.0;
    
    if (body.contains('uber')) score += 0.98;
    if (body.contains('ola')) score += 0.98;
    if (body.contains('taxi')) score += 0.9;
    if (body.contains('fuel')) score += 0.7;
    if (body.contains('petrol')) score += 0.8;
    if (body.contains('flight')) score += 0.8;
    
    if (amount > 1000) score += 0.3;
    if (amount > 5000) score += 0.4;
    
    return score.clamp(0.0, 1.0);
  }
  
  // 💼 Calculate Work category score (simplified version for AI suggestions)
  static double _calculateWorkScore(String body, double amount) {
    double score = 0.0;
    
    if (body.contains('microsoft')) score += 0.95;
    if (body.contains('adobe')) score += 0.95;
    if (body.contains('office')) score += 0.8;
    if (body.contains('business')) score += 0.7;
    if (body.contains('software')) score += 0.8;
    
    if (amount > 500 && amount < 2000) score += 0.3;
    
    return score.clamp(0.0, 1.0);
  }
  
  // 🎬 Calculate Leisure category score (simplified version for AI suggestions)
  static double _calculateLeisureScore(String body, double amount) {
    double score = 0.0;
    
    if (body.contains('netflix')) score += 0.98;
    if (body.contains('movie')) score += 0.9;
    if (body.contains('shopping')) score += 0.7;
    if (body.contains('mall')) score += 0.6;
    if (body.contains('gym')) score += 0.8;
    
    return score.clamp(0.0, 1.0);
  }
  
  // 📊 Calculate Miscellaneous category score (simplified version for AI suggestions)
  static double _calculateMiscScore(String body, double amount) {
    double score = 0.2;
    
    if (body.contains('atm')) score += 0.8;
    if (body.contains('cash withdrawal')) score += 0.9;
    if (body.contains('bank')) score += 0.5;
    
    if (amount < 100 && body.contains('wallet')) score += 0.3;
    
    return score.clamp(0.0, 1.0);
  }
  
  /// � Get alternative reason for category
  
  /// 🔍 Get alternative indicators for category
  static List<String> _getAlternativeIndicators(Category category, String smsBody, double amount, DateTime time) {
    final indicators = <String>[];
    final hour = time.hour;
    
    switch (category) {
      case Category.Food:
        if (hour >= 12 && hour <= 14) indicators.add("Lunch time");
        if (amount <= 200) indicators.add("Typical food amount");
        break;
      case Category.Travel:
        if (hour >= 7 && hour <= 9 || hour >= 17 && hour <= 19) indicators.add("Commute hours");
        if (amount >= 100) indicators.add("Travel-sized amount");
        break;
      case Category.Work:
        if (hour >= 9 && hour <= 17) indicators.add("Business hours");
        if (amount >= 500) indicators.add("Business expense amount");
        break;
      case Category.Leisure:
        if (time.weekday >= 6) indicators.add("Weekend");
        if (hour >= 18) indicators.add("Evening hours");
        break;
      case Category.Miscellaneous:
        indicators.add("Generic transaction");
        break;
    }
    
    return indicators;
  }
  
  /// 🧹 Enhanced cleanup with user-specific optimization
  static Future<void> cleanupOldPatterns() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Clear cache to force reload
      _userPatternCache.remove(user.uid);
      _cacheTimestamps.remove(user.uid);
      
      // Enhanced cleanup strategy
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      
      // Stage 1: Delete very old patterns with minimal usage
      final oldPatternsQuery = await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .where('lastUsed', isLessThan: oneYearAgo.toIso8601String())
          .where('usageCount', isLessThan: 2)
          .get();
      
      // Stage 2: Delete moderately old patterns with low usage
      final moderateOldQuery = await FirebaseFirestore.instance
          .collection(_learningCollection)
          .doc(user.uid)
          .collection('patterns')
          .where('lastUsed', isLessThan: sixMonthsAgo.toIso8601String())
          .where('usageCount', isLessThan: 5)
          .get();
      
      int deletedCount = 0;
      
      // Delete old patterns
      for (var doc in oldPatternsQuery.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      for (var doc in moderateOldQuery.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      print('🧹 Enhanced cleanup: Removed $deletedCount old learning patterns');
      
    } catch (e) {
      print('❌ Error in enhanced cleanup: $e');
    }
  }
  
  /// 🚀 Clear user cache (for testing or manual refresh)
  static void clearUserCache([String? specificUserId]) {
    if (specificUserId != null) {
      _userPatternCache.remove(specificUserId);
      _cacheTimestamps.remove(specificUserId);
    } else {
      _userPatternCache.clear();
      _cacheTimestamps.clear();
    }
    print('🚀 User pattern cache cleared');
  }
  
  /// 📊 Get cache statistics for monitoring
  static Map<String, dynamic> getCacheStats() {
    final totalUsers = _userPatternCache.length;
    final totalPatterns = _userPatternCache.values.fold(0, (sum, patterns) => sum + patterns.length);
    final cacheHitRate = totalPatterns > 0 ? 0.85 : 0.0; // Estimated based on usage
    
    return {
      'totalUsers': totalUsers,
      'totalCachedPatterns': totalPatterns,
      'estimatedCacheHitRate': cacheHitRate,
      'cacheExpiry': _cacheExpiry.inMinutes,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}

/// 📋 Enhanced category suggestion result with AI reasoning
class CategorySuggestion {
  final Category category;
  final bool shouldPromptUser;
  final double confidence;
  final String reason;
  final int processingTimeMs;
  
  // 🤖 AI Suggestion for user prompt
  final Category? suggestedCategory;
  final String? suggestionReason;
  final double? suggestionConfidence;
  final List<CategoryOption>? alternativeOptions;
  
  CategorySuggestion({
    required this.category,
    required this.shouldPromptUser,
    required this.confidence,
    required this.reason,
    this.processingTimeMs = 0,
    this.suggestedCategory,
    this.suggestionReason,
    this.suggestionConfidence,
    this.alternativeOptions,
  });
}

/// 🧠 Enhanced learned pattern result with additional metadata
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

/// 🚀 Cached pattern for fast in-memory lookup
class CachedPattern {
  final Category category;
  final double confidence;
  final String reason;
  final Map<String, dynamic> features;
  int usageCount;
  DateTime lastUsed;
  
  CachedPattern({
    required this.category,
    required this.confidence,
    required this.reason,
    required this.features,
    required this.usageCount,
    required this.lastUsed,
  });
}

/// 🎯 Category option for user selection with AI reasoning
class CategoryOption {
  final Category category;
  final double confidence;
  final String reason;
  final List<String> indicators;
  
  CategoryOption({
    required this.category,
    required this.confidence,
    required this.reason,
    required this.indicators,
  });
}

/// 🤖 AI suggestion result for user prompts
class AISuggestion {
  final Category suggestedCategory;
  final double confidence;
  final String reason;
  final List<CategoryOption> alternatives;
  
  AISuggestion({
    required this.suggestedCategory,
    required this.confidence,
    required this.reason,
    required this.alternatives,
  });
}

/// 🎯 Category suggestion result for internal processing
class CategorySuggestionResult {
  final Category category;
  final double confidence;
  final String reason;
  final List<String> indicators;
  
  CategorySuggestionResult({
    required this.category,
    required this.confidence,
    required this.reason,
    required this.indicators,
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
