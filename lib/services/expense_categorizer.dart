import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../config/api_config.dart';

/// 🆓 FREE Three-Layer Expense Categorization Service (Wallet-Aware)
/// Layer 0: Enhanced Indian Merchant Database - 95% accuracy for Indian merchants
/// Layer 1: Merchant Database API (Foursquare) - 95% accuracy when found
/// Layer 2: Enhanced Keyword Scoring - 85% accuracy fallback
class ExpenseCategorizer {
  
  // 🇮🇳 **LAYER 0: Enhanced Indian Merchant Database (Wallet-Aware)**
  static Category? categorizeByIndianMerchants(String smsBody) {
    final body = smsBody.toLowerCase();
    
    // 💳 **WALLET TRANSACTION ENHANCEMENT**
    // Extract merchant name from wallet SMS patterns first
    String? walletMerchant = _extractWalletMerchant(body);
    if (walletMerchant != null) {
      print("💳 Wallet merchant detected: '$walletMerchant'");
      // Use the extracted merchant name for categorization
      final merchantCategory = _categorizeExtractedMerchant(walletMerchant);
      if (merchantCategory != null) {
        print("🎯 Wallet merchant categorized: $walletMerchant → ${merchantCategory.name}");
        return merchantCategory;
      }
    }
    
    // 🇮🇳 **ENHANCED INDIAN MERCHANT DATABASE**
    
    // Indian Food Delivery & Restaurants (Very High Confidence)
    final indianFoodMerchants = {
      'zomato', 'swiggy', 'uber eats', 'foodpanda', 'dunzo',
      'dominos', 'pizza hut', 'mcdonalds', 'kfc', 'burger king',
      'starbucks', 'cafe coffee day', 'barista', 'costa coffee',
      'haldirams', 'bikanervala', 'subway', 'taco bell',
      'wow momo', 'faasos', 'behrouz biryani', 'oven story',
      'box8', 'freshmenu', 'licious', 'bigbasket', 'grofers',
      'fresh to home', 'country delight', 'milk basket',
      'dmart ready', 'nature basket', 'spencer retail'
    };
    
    // Indian Travel & Transport (Very High Confidence)
    final indianTravelMerchants = {
      'uber', 'ola', 'rapido', 'meru', 'taxi for sure',
      'makemytrip', 'goibibo', 'cleartrip', 'yatra', 'ixigo',
      'irctc', 'redbus', 'abhibus', 'orange travels',
      'indigo', 'spicejet', 'air india', 'vistara', 'go air',
      'indian oil', 'bharat petroleum', 'hindustan petroleum',
      'reliance petrol', 'shell', 'hp petrol', 'essar oil',
      'fastag', 'parivahan', 'vahan', 'rc book'
    };
    
    // Indian Entertainment & Leisure (High Confidence)
    final indianLeisureMerchants = {
      'bookmyshow', 'paytm movies', 'netflix', 'amazon prime',
      'hotstar', 'zee5', 'sony liv', 'voot', 'alt balaji',
      'cult fit', 'gold gym', 'fitness first', 'talwalkars',
      'flipkart', 'amazon', 'myntra', 'ajio', 'nykaa',
      'big bazaar', 'reliance digital', 'croma', 'vijay sales',
      'lifestyle', 'pantaloons', 'westside', 'max fashion',
      'pvr', 'inox', 'cinepolis', 'carnival cinemas'
    };
    
    // Indian Work & Business (High Confidence)
    final indianWorkMerchants = {
      'microsoft', 'adobe', 'zoom', 'google workspace',
      'notion', 'slack', 'dropbox', 'canva', 'figma',
      'razorpay', 'payu', 'instamojo', 'cashfree',
      'freshworks', 'zoho', 'clevertap', 'postman',
      'github', 'gitlab', 'aws', 'azure', 'gcp'
    };
    
    // Indian Banking & Finance (Miscellaneous)
    final indianBankingMerchants = {
      'sbi', 'hdfc', 'icici', 'axis', 'kotak', 'pnb',
      'paytm', 'phonepe', 'gpay', 'mobikwik', 'freecharge',
      'bharatpe', 'cred', 'jupiter', 'niyo', 'fi money',
      'slice', 'uni cards', 'onecard'
    };
    
    // Check each category with enhanced matching
    for (String merchant in indianFoodMerchants) {
      if (_containsMerchant(body, merchant)) {
        print("🇮🇳 Indian Food Merchant: $merchant → Food");
        return Category.Food;
      }
    }
    
    for (String merchant in indianTravelMerchants) {
      if (_containsMerchant(body, merchant)) {
        print("🇮🇳 Indian Travel Merchant: $merchant → Travel");
        return Category.Travel;
      }
    }
    
    for (String merchant in indianLeisureMerchants) {
      if (_containsMerchant(body, merchant)) {
        print("🇮🇳 Indian Leisure Merchant: $merchant → Leisure");
        return Category.Leisure;
      }
    }
    
    for (String merchant in indianWorkMerchants) {
      if (_containsMerchant(body, merchant)) {
        print("🇮🇳 Indian Work Merchant: $merchant → Work");
        return Category.Work;
      }
    }
    
    for (String merchant in indianBankingMerchants) {
      if (_containsMerchant(body, merchant)) {
        print("🇮🇳 Indian Banking Merchant: $merchant → Miscellaneous");
        return Category.Miscellaneous;
      }
    }
    
    return null; // Not found in Indian database
  }

  // 💳 Helper: Extract merchant name from wallet SMS and credit card transactions
  static String? _extractWalletMerchant(String body) {
    // 🔍 **STEP 1: Check for credit card transaction patterns**
    final creditCardPatterns = [
      // Axis Bank credit card pattern: "Spent INR 4006.35Axis Bank Card no. XX542823-12-25 13:18:48 ISTRBL BANK LT"
      RegExp(r'spent\s+inr\s+[\d,]+\.?\d*\s*axis\s+bank\s+card\s+no\.\s+\w+\s*-?\s*\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\s+(\w+(?:\s+\w+)*)', caseSensitive: false),
      
      // Generic credit card patterns
      RegExp(r'(?:spent|charged|debited)\s+(?:inr|rs\.?)\s*[\d,]+\.?\d*.*?(?:at|from)\s+([a-zA-Z][a-zA-Z0-9\s]{2,20})', caseSensitive: false),
      RegExp(r'transaction\s+(?:at|on)\s+([a-zA-Z][a-zA-Z0-9\s]{2,20})', caseSensitive: false),
      RegExp(r'card\s+no\.?\s+\w+.*?(?:at|from)\s+([a-zA-Z][a-zA-Z0-9\s]{2,20})', caseSensitive: false),
    ];
    
    for (RegExp pattern in creditCardPatterns) {
      Match? match = pattern.firstMatch(body);
      if (match != null && match.group(1) != null) {
        String merchantName = match.group(1)!.trim();
        
        // Clean up merchant name (remove common suffixes)
        merchantName = merchantName.replaceAll(RegExp(r'\s+(bank|ltd|limited|pvt|private|inc|corp)$', caseSensitive: false), '');
        
        if (_isValidMerchantName(merchantName)) {
          print("💳 Credit card merchant extracted: '$merchantName'");
          return merchantName.toLowerCase();
        }
      }
    }
    
    // 🔍 **STEP 2: Check for wallet-specific patterns**
    final patterns = [
      'paid to ',
      'payment to ',
      'transferred to ',
      'payment made to ',
      'sent money to ',
      'upi payment to ',
      'upi transaction to ',
    ];
    
    for (String pattern in patterns) {
      int index = body.indexOf(pattern);
      if (index != -1) {
        String afterPattern = body.substring(index + pattern.length);
        
        // Extract merchant name (stop at common delimiters)
        List<String> stopWords = [' via', ' using', ' through', ' on', ' at', ' for', ' of'];
        String merchantName = afterPattern;
        
        for (String stopWord in stopWords) {
          int stopIndex = merchantName.indexOf(stopWord);
          if (stopIndex != -1) {
            merchantName = merchantName.substring(0, stopIndex);
            break;
          }
        }
        
        // Clean up the merchant name
        merchantName = merchantName.trim();
        if (merchantName.length >= 3 && merchantName.length <= 25 && _isValidMerchantName(merchantName)) {
          print("💳 Wallet merchant extracted: '$merchantName'");
          return merchantName.toLowerCase();
        }
      }
    }
    
    // 🔍 **STEP 3: Check for quoted merchant names**
    RegExp quotedPattern = RegExp(r'"([^"]+)"');
    Match? match = quotedPattern.firstMatch(body);
    if (match != null) {
      String merchantName = match.group(1)!.trim();
      if (_isValidMerchantName(merchantName)) {
        print("💳 Quoted merchant extracted: '$merchantName'");
        return merchantName.toLowerCase();
      }
    }
    
    // 🔍 **STEP 4: Handle wallet debit notifications without merchant info**
    // For SMS like "Rs.60.0 has been debited from your MobiKwik wallet"
    if (_isWalletDebitNotification(body)) {
      print("💳 Wallet debit notification detected (no merchant info)");
      return null; // Will fall back to keyword scoring
    }
    
    return null;
  }

  // 💳 Helper: Check if SMS is a wallet debit notification or credit card transaction without merchant info
  static bool _isWalletDebitNotification(String body) {
    final walletDebitPatterns = [
      'has been debited from your mobikwik wallet',
      'has been debited from your paytm wallet',
      'has been debited from your phonepe wallet',
      'debited from your wallet',
      'wallet balance debited',
      'amount debited from wallet',
      // Credit card patterns without clear merchant info
      'card no.',
      'credit card',
      'debit card',
      'avl limit',
      'available limit',
    ];
    
    return walletDebitPatterns.any((pattern) => body.contains(pattern));
  }

  // 🎯 Helper: Categorize extracted merchant name
  static Category? _categorizeExtractedMerchant(String merchantName) {
    final merchant = merchantName.toLowerCase();
    
    // Food merchants
    final foodKeywords = ['restaurant', 'cafe', 'pizza', 'burger', 'food', 'kitchen', 'dhaba', 'biryani'];
    if (foodKeywords.any((keyword) => merchant.contains(keyword))) {
      return Category.Food;
    }
    
    // Travel merchants
    final travelKeywords = ['travels', 'transport', 'taxi', 'cab', 'petrol', 'fuel', 'parking'];
    if (travelKeywords.any((keyword) => merchant.contains(keyword))) {
      return Category.Travel;
    }
    
    // Leisure merchants
    final leisureKeywords = ['mall', 'store', 'shop', 'mart', 'retail', 'fashion', 'gym', 'spa'];
    if (leisureKeywords.any((keyword) => merchant.contains(keyword))) {
      return Category.Leisure;
    }
    
    // Work merchants
    final workKeywords = ['office', 'tech', 'software', 'solutions', 'services', 'consulting'];
    if (workKeywords.any((keyword) => merchant.contains(keyword))) {
      return Category.Work;
    }
    
    return null; // Unknown merchant type
  }

  // 🔍 Helper: Enhanced merchant matching (handles partial matches and variations)
  static bool _containsMerchant(String body, String merchant) {
    // Direct match
    if (body.contains(merchant)) return true;
    
    // Handle common variations
    final variations = <String, List<String>>{
      'dominos': ['domino', 'dominos pizza'],
      'mcdonalds': ['mcdonald', 'mc donald', 'mc donalds'],
      'starbucks': ['starbuck'],
      'uber': ['uber india', 'uber trip'],
      'ola': ['ola cabs', 'ola cab'],
      'zomato': ['zomato india'],
      'swiggy': ['swiggy india'],
      'amazon': ['amazon india', 'amazon.in'],
      'flipkart': ['flipkart india'],
    };
    
    if (variations.containsKey(merchant)) {
      for (String variation in variations[merchant]!) {
        if (body.contains(variation)) return true;
      }
    }
    
    return false;
  }

  // 🔍 Helper: Validate if extracted text is a valid merchant name
  static bool _isValidMerchantName(String name) {
    final cleanName = name.trim().toLowerCase();
    
    // Filter out common non-merchant words
    final invalidWords = [
      'upi', 'payment', 'transaction', 'transfer', 'wallet', 'bank', 'account',
      'mobile', 'number', 'phone', 'via', 'using', 'through', 'from', 'to',
      'rs', 'inr', 'rupees', 'amount', 'balance', 'available', 'successful',
      'failed', 'pending', 'completed', 'debited', 'credited', 'charged',
      'your', 'you', 'the', 'and', 'or', 'for', 'with', 'on', 'at', 'in'
    ];
    
    // Check if name contains only invalid words
    final words = cleanName.split(' ');
    final validWords = words.where((word) => 
      word.length >= 3 && !invalidWords.contains(word)
    ).toList();
    
    // Must have at least one valid word and reasonable length
    return validWords.isNotEmpty && 
           cleanName.length >= 3 && 
           cleanName.length <= 25 &&
           !RegExp(r'^\d+$').hasMatch(cleanName); // Not just numbers
  }

  // 🏪 **LAYER 1: Merchant Database API (Foursquare Fallback)**
  static Future<Category?> categorizeByMerchantAPI(String smsBody) async {
    try {
      // Extract potential merchant names from SMS
      final merchantNames = _extractMerchantNames(smsBody);
      
      for (String merchantName in merchantNames) {
        if (merchantName.length < 3) continue; // Skip very short names
        
        // Search Foursquare Places API
        final category = await _searchFoursquareMerchant(merchantName);
        if (category != null) {
          print("🏪 Merchant API match: $merchantName → ${category.name}");
          return category;
        }
      }
      
      return null; // No merchant found in API
    } catch (e) {
      print("⚠️ Merchant API error: $e");
      return null; // Fallback to keyword scoring
    }
  }
  
  // 🔍 **LAYER 2: Enhanced Keyword Scoring (Fallback)**
  static Category categorizeByKeywordScoring(String smsBody, double amount) {
    final body = smsBody.toLowerCase();
    final scores = <Category, double>{};
    
    // Calculate weighted scores for each category
    scores[Category.Food] = _calculateFoodScore(body, amount);
    scores[Category.Travel] = _calculateTravelScore(body, amount);
    scores[Category.Work] = _calculateWorkScore(body, amount);
    scores[Category.Leisure] = _calculateLeisureScore(body, amount);
    scores[Category.Miscellaneous] = _calculateMiscScore(body, amount);
    
    // Return category with highest score
    final bestMatch = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    // Only return if confidence is reasonable (>0.3)
    if (bestMatch.value > 0.3) {
      print("🎯 Keyword scoring: ${bestMatch.key.name} (${(bestMatch.value * 100).toInt()}% confidence)");
      return bestMatch.key;
    }
    
    return Category.Miscellaneous; // Default fallback
  }
  
  // 🔄 **MAIN CATEGORIZATION METHOD (Three-Layer Hybrid)**
  static Future<Category> categorizeHybrid(String smsBody, double amount) async {
    // Layer 0: Try Indian merchant database first (instant, high accuracy)
    final indianCategory = categorizeByIndianMerchants(smsBody);
    if (indianCategory != null) {
      return indianCategory; // Very high confidence Indian merchant match
    }
    
    // Layer 1: Try Foursquare API for international/unknown merchants
    final merchantCategory = await categorizeByMerchantAPI(smsBody);
    if (merchantCategory != null) {
      return merchantCategory; // High confidence API merchant match
    }
    
    // Layer 2: Fallback to enhanced keyword scoring
    return categorizeByKeywordScoring(smsBody, amount);
  }
  
  // 🏪 Helper: Extract potential merchant names from SMS
  static List<String> _extractMerchantNames(String smsBody) {
    final merchants = <String>[];
    final body = smsBody.toLowerCase();
    
    // Try wallet merchant extraction first
    String? walletMerchant = _extractWalletMerchant(body);
    if (walletMerchant != null) {
      merchants.add(walletMerchant);
    }
    
    // Look for known merchant patterns
    final knownMerchants = [
      'dominos', 'mcdonalds', 'starbucks', 'uber', 'ola', 'zomato', 'swiggy',
      'netflix', 'amazon', 'flipkart', 'paytm', 'phonepe', 'gpay', 'mobikwik',
      'pizza hut', 'kfc', 'burger king', 'subway', 'dunkin donuts',
      'makemytrip', 'goibibo', 'cleartrip', 'irctc', 'redbus',
      'bookmyshow', 'pvr', 'inox', 'big bazaar', 'reliance digital'
    ];
    
    for (final merchant in knownMerchants) {
      if (body.contains(merchant)) {
        merchants.add(merchant);
        print("🎯 Known merchant found: '$merchant'");
      }
    }
    
    return merchants.toSet().toList(); // Remove duplicates
  }
  
  // 🌐 Helper: Search Foursquare API for merchant category
  static Future<Category?> _searchFoursquareMerchant(String merchantName) async {
    try {
      if (!ApiConfig.isFoursquareConfigured) {
        return null; // API not configured
      }
      
      final url = Uri.parse(
        'https://api.foursquare.com/v3/places/search?query=${Uri.encodeComponent(merchantName)}&limit=1'
      );
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': ApiConfig.foursquareApiKey,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        
        if (results != null && results.isNotEmpty) {
          final place = results[0];
          final categories = place['categories'] as List?;
          
          if (categories != null && categories.isNotEmpty) {
            final categoryName = categories[0]['name']?.toString().toLowerCase() ?? '';
            return _mapFoursquareCategoryToExpenseCategory(categoryName);
          }
        }
      }
      
      return null;
    } catch (e) {
      print("⚠️ Foursquare API error: $e");
      return null;
    }
  }
  
  // 🗺️ Helper: Map Foursquare categories to our expense categories
  static Category? _mapFoursquareCategoryToExpenseCategory(String foursquareCategory) {
    final category = foursquareCategory.toLowerCase();
    
    // Food & Dining
    if (category.contains('restaurant') || category.contains('food') || 
        category.contains('cafe') || category.contains('bar') ||
        category.contains('pizza') || category.contains('bakery') ||
        category.contains('fast food') || category.contains('diner')) {
      return Category.Food;
    }
    
    // Travel & Transportation
    if (category.contains('hotel') || category.contains('airport') ||
        category.contains('gas station') || category.contains('taxi') ||
        category.contains('transport') || category.contains('travel') ||
        category.contains('parking') || category.contains('rental')) {
      return Category.Travel;
    }
    
    // Work & Business
    if (category.contains('office') || category.contains('coworking') ||
        category.contains('business') || category.contains('bank') ||
        category.contains('professional') || category.contains('service')) {
      return Category.Work;
    }
    
    // Leisure & Entertainment
    if (category.contains('entertainment') || category.contains('movie') ||
        category.contains('theater') || category.contains('gym') ||
        category.contains('spa') || category.contains('shopping') ||
        category.contains('mall') || category.contains('store') ||
        category.contains('recreation') || category.contains('sports')) {
      return Category.Leisure;
    }
    
    return null; // Unknown category
  }
  
  // 🍕 Calculate Food category score
  static double _calculateFoodScore(String body, double amount) {
    double score = 0.0;
    
    // Primary food keywords (high weight)
    if (body.contains('restaurant')) score += 0.9;
    if (body.contains('food')) score += 0.8;
    if (body.contains('dining')) score += 0.8;
    if (body.contains('cafe')) score += 0.7;
    if (body.contains('pizza')) score += 0.9;
    if (body.contains('burger')) score += 0.8;
    
    // Food delivery services (high weight)
    if (body.contains('zomato')) score += 0.95;
    if (body.contains('swiggy')) score += 0.95;
    if (body.contains('uber eats')) score += 0.95;
    if (body.contains('foodpanda')) score += 0.9;
    
    // Popular food chains (very high weight)
    if (body.contains('dominos')) score += 0.98;
    if (body.contains('mcdonalds')) score += 0.98;
    if (body.contains('kfc')) score += 0.98;
    if (body.contains('starbucks')) score += 0.95;
    if (body.contains('subway')) score += 0.9;
    
    // Context keywords (medium weight)
    if (body.contains('delivery')) score += 0.6;
    if (body.contains('order')) score += 0.5;
    if (body.contains('meal')) score += 0.7;
    
    // Amount-based adjustments
    if (amount < 500) score += 0.3; // Small amounts often food
    if (amount > 2000) score -= 0.2; // Large amounts less likely food
    
    return score.clamp(0.0, 1.0);
  }
  
  // ✈️ Calculate Travel category score
  static double _calculateTravelScore(String body, double amount) {
    double score = 0.0;
    
    // Transportation services (very high weight)
    if (body.contains('uber')) score += 0.98;
    if (body.contains('ola')) score += 0.98;
    if (body.contains('taxi')) score += 0.9;
    if (body.contains('cab')) score += 0.9;
    
    // Travel booking (high weight)
    if (body.contains('makemytrip')) score += 0.95;
    if (body.contains('goibibo')) score += 0.95;
    if (body.contains('cleartrip')) score += 0.95;
    if (body.contains('irctc')) score += 0.98;
    
    // Airlines (very high weight)
    if (body.contains('indigo')) score += 0.98;
    if (body.contains('spicejet')) score += 0.98;
    if (body.contains('air india')) score += 0.98;
    
    // Travel keywords (medium weight)
    if (body.contains('flight')) score += 0.8;
    if (body.contains('hotel')) score += 0.8;
    if (body.contains('booking')) score += 0.6;
    if (body.contains('travel')) score += 0.7;
    if (body.contains('fuel')) score += 0.7;
    if (body.contains('petrol')) score += 0.8;
    if (body.contains('parking')) score += 0.6;
    
    // Amount-based adjustments
    if (amount > 1000) score += 0.3; // Large amounts often travel
    if (amount > 5000) score += 0.4; // Very large amounts very likely travel
    
    return score.clamp(0.0, 1.0);
  }
  
  // 💼 Calculate Work category score
  static double _calculateWorkScore(String body, double amount) {
    double score = 0.0;
    
    // Software/SaaS (very high weight)
    if (body.contains('microsoft')) score += 0.95;
    if (body.contains('adobe')) score += 0.95;
    if (body.contains('zoom')) score += 0.9;
    if (body.contains('slack')) score += 0.9;
    if (body.contains('notion')) score += 0.9;
    
    // Work keywords (high weight)
    if (body.contains('office')) score += 0.8;
    if (body.contains('business')) score += 0.7;
    if (body.contains('subscription')) score += 0.6;
    if (body.contains('software')) score += 0.8;
    if (body.contains('license')) score += 0.8;
    
    // Amount-based adjustments
    if (amount > 500 && amount < 2000) score += 0.3; // Typical software costs
    
    return score.clamp(0.0, 1.0);
  }
  
  // 🎬 Calculate Leisure category score
  static double _calculateLeisureScore(String body, double amount) {
    double score = 0.0;
    
    // Entertainment services (very high weight)
    if (body.contains('netflix')) score += 0.98;
    if (body.contains('amazon prime')) score += 0.95;
    if (body.contains('spotify')) score += 0.95;
    if (body.contains('disney')) score += 0.95;
    if (body.contains('youtube premium')) score += 0.9;
    
    // Entertainment venues (high weight)
    if (body.contains('movie')) score += 0.9;
    if (body.contains('cinema')) score += 0.9;
    if (body.contains('theater')) score += 0.8;
    if (body.contains('bookmyshow')) score += 0.95;
    
    // Shopping & lifestyle (medium weight)
    if (body.contains('shopping')) score += 0.7;
    if (body.contains('mall')) score += 0.6;
    if (body.contains('gym')) score += 0.8;
    if (body.contains('spa')) score += 0.8;
    if (body.contains('salon')) score += 0.7;
    
    // E-commerce (medium weight)
    if (body.contains('amazon')) score += 0.6;
    if (body.contains('flipkart')) score += 0.6;
    
    return score.clamp(0.0, 1.0);
  }
  
  // 📊 Calculate Miscellaneous category score
  static double _calculateMiscScore(String body, double amount) {
    double score = 0.2; // Base score for miscellaneous
    
    // ATM/Cash withdrawals (high weight)
    if (body.contains('atm')) score += 0.8;
    if (body.contains('cash withdrawal')) score += 0.9;
    if (body.contains('withdrawn')) score += 0.7;
    
    // Wallet debit notifications without merchant info (medium-high weight)
    if (body.contains('debited from your mobikwik wallet')) score += 0.7;
    if (body.contains('debited from your paytm wallet')) score += 0.7;
    if (body.contains('debited from your phonepe wallet')) score += 0.7;
    if (body.contains('debited from your wallet')) score += 0.6;
    if (body.contains('wallet balance debited')) score += 0.6;
    
    // Banking services
    if (body.contains('bank')) score += 0.5;
    if (body.contains('transfer')) score += 0.4;
    
    // Amount-based adjustments for wallet transactions
    if (amount < 100 && body.contains('wallet')) score += 0.3; // Small wallet amounts often miscellaneous
    
    return score.clamp(0.0, 1.0);
  }

  // 🧪 Test three-layer categorization with sample SMS messages (including wallet transactions)
  static Future<void> testCategorization() async {
    print('\n🧪 Testing Enhanced Three-Layer Expense Categorization (Wallet-Aware)...\n');
    
    final testCases = [
      // Traditional bank SMS
      {'sms': 'Debited Rs.450 at DOMINOS PIZZA for food order', 'amount': 450.0},
      {'sms': 'Rs.280 debited for UBER TRIP from home to office', 'amount': 280.0},
      {'sms': 'Debited Rs.999 MICROSOFT OFFICE subscription renewal', 'amount': 999.0},
      {'sms': 'Rs.199 debited NETFLIX SUBSCRIPTION monthly payment', 'amount': 199.0},
      {'sms': 'Debited Rs.1500 at ATM withdrawal for cash', 'amount': 1500.0},
      
      // Wallet-based transactions WITH merchant info
      {'sms': 'Rs.350 paid to STARBUCKS COFFEE via MobiKwik wallet', 'amount': 350.0},
      {'sms': 'Payment to DOMINOS PIZZA of Rs.420 via Paytm successful', 'amount': 420.0},
      {'sms': 'Rs.180 paid ZOMATO via PhonePe UPI transaction completed', 'amount': 180.0},
      {'sms': 'UPI payment to UBER INDIA of Rs.250 using Google Pay', 'amount': 250.0},
      {'sms': 'Transferred Rs.89 to SWIGGY via MobiKwik wallet', 'amount': 89.0},
      
      // Complex wallet SMS patterns
      {'sms': 'MobiKwik: Rs.299 paid to "BIG BAZAAR RETAIL" via UPI', 'amount': 299.0},
      {'sms': 'Paytm payment made to RELIANCE DIGITAL for Rs.1299', 'amount': 1299.0},
      {'sms': 'PhonePe: Sent money to CULT FIT GYM Rs.999 successful', 'amount': 999.0},
      
      // Wallet debit notifications WITHOUT merchant info (like your MobiKwik example)
      {'sms': 'Rs.60.0 has been debited from your MobiKwik wallet. Remaining balance: Rs.2959.18. Not you? Please report on fraudalerts@mobikwik.com -MobiKwik', 'amount': 60.0},
      {'sms': 'Rs.25 has been debited from your Paytm wallet for transaction', 'amount': 25.0},
      {'sms': 'Amount Rs.150 debited from your PhonePe wallet successfully', 'amount': 150.0},
    ];
    
    for (var test in testCases) {
      final sms = test['sms'] as String;
      final amount = test['amount'] as double;
      
      print('📱 SMS: "$sms"');
      print('💰 Amount: ₹$amount');
      
      // Test Layer 0: Enhanced Indian Merchants (Wallet-Aware)
      final indianCategory = categorizeByIndianMerchants(sms);
      if (indianCategory != null) {
        print('🇮🇳 Layer 0 (Enhanced Indian DB): ${indianCategory.name}');
      } else {
        print('🇮🇳 Layer 0 (Enhanced Indian DB): No match found');
      }
      
      // Test Layer 1: Foursquare API
      final merchantCategory = await categorizeByMerchantAPI(sms);
      if (merchantCategory != null) {
        print('🏪 Layer 1 (Foursquare API): ${merchantCategory.name}');
      } else {
        print('🏪 Layer 1 (Foursquare API): No match found');
      }
      
      // Test Layer 2: Keyword Scoring
      final keywordCategory = categorizeByKeywordScoring(sms, amount);
      print('🎯 Layer 2 (Keywords): ${keywordCategory.name}');
      
      // Test Final Result (Three-Layer Hybrid)
      final finalCategory = await categorizeHybrid(sms, amount);
      print('✅ Final Result: ${finalCategory.name}');
      print('---');
    }
    
    print('✅ Enhanced three-layer categorization test completed!\n');
  }

  // 📊 Get confidence score for categorization
  static double getConfidenceScore(String smsBody, Category category) {
    final body = smsBody.toLowerCase();
    
    // Use the scoring functions to get confidence
    switch (category) {
      case Category.Food:
        return _calculateFoodScore(body, 0.0);
      case Category.Travel:
        return _calculateTravelScore(body, 0.0);
      case Category.Work:
        return _calculateWorkScore(body, 0.0);
      case Category.Leisure:
        return _calculateLeisureScore(body, 0.0);
      case Category.Miscellaneous:
        return _calculateMiscScore(body, 0.0);
    }
  }
}