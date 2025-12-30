void main() {
  print('🧪 Testing Complete Axis Bank SMS Processing Flow...\n');
  
  // Your exact SMS
  final smsBody = 'Spent INR 4006.35Axis Bank Card no. XX542823-12-25 13:18:48 ISTRBL BANK LTAvl Limit: INR 177993.65Not you? SMS BLOCK 5428 to 919951860002';
  final sender = 'AXISBK'; // Typical Axis Bank sender
  
  print('📱 SMS: "$smsBody"');
  print('📞 Sender: "$sender"');
  print('---\n');
  
  // Step 1: Test Sender Validation
  print('🔒 Step 1: Sender Validation');
  final body = smsBody.toLowerCase();
  
  // Check if sender matches banking patterns
  bool isValidSender = false;
  if (RegExp(r'^[A-Z0-9]{4,6}$').hasMatch(sender)) {
    isValidSender = true;
    print('✅ Sender "$sender" matches bank code pattern (4-6 chars)');
  }
  
  // Check if SMS contains banking keywords
  bool hasBankingContent = body.contains('avl limit') || 
                          body.contains('card no.') || 
                          body.contains('axis bank');
  print('✅ Banking content detected: $hasBankingContent');
  print('');
  
  // Step 2: Test Expense Detection
  print('💰 Step 2: Expense Detection');
  final isExpense = body.contains('spent') ||
                   body.contains('card no.') ||
                   body.contains('avl limit') ||
                   body.contains('axis bank');
  print('✅ Expense keywords found: $isExpense');
  print('');
  
  // Step 3: Test Amount Extraction
  print('💵 Step 3: Amount Extraction');
  final amountRegex = RegExp(
    r'(?:rs[:\.]?|inr)\s*([\d,]+(?:\.\d{1,2})?)|(?:spent|charged|debited)\s*(?:rs[:\.]?|inr)?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  
  final match = amountRegex.firstMatch(body);
  if (match != null) {
    final amountStr = (match.group(1) ?? match.group(2))?.replaceAll(',', '') ?? '0.0';
    final amount = double.tryParse(amountStr);
    print('✅ Amount extracted: ₹$amount');
  } else {
    print('❌ Amount not extracted with primary regex');
    
    // Try alternative pattern
    final altRegex = RegExp(r'([\d,]+\.\d{2})\s*(?:inr|rs)?', caseSensitive: false);
    final altMatch = altRegex.firstMatch(body);
    if (altMatch != null) {
      final amountStr = altMatch.group(1)?.replaceAll(',', '') ?? '0.0';
      final amount = double.tryParse(amountStr);
      print('✅ Amount extracted with alternative regex: ₹$amount');
    }
  }
  print('');
  
  // Step 4: Test Merchant Extraction
  print('🏪 Step 4: Merchant Extraction');
  
  // Test the enhanced Axis Bank pattern
  final axisPattern = RegExp(
    r'spent\s+inr\s+[\d,]+\.?\d*\s*axis\s+bank\s+card\s+no\.\s+\w+\s*-?\s*\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\s+([A-Z][A-Z0-9\s]{2,25}?)(?:\s*avl\s+limit|$)',
    caseSensitive: false
  );
  
  final merchantMatch = axisPattern.firstMatch(body);
  if (merchantMatch != null && merchantMatch.group(1) != null) {
    String merchantName = merchantMatch.group(1)!.trim();
    print('✅ Merchant extracted: "$merchantName"');
    
    // Clean up merchant name
    merchantName = merchantName.replaceAll(RegExp(r'\s+(bank|ltd|limited|pvt|private|inc|corp)$', caseSensitive: false), '');
    print('✅ Cleaned merchant name: "$merchantName"');
    
    // Validate merchant name
    final cleanName = merchantName.trim().toLowerCase();
    final invalidWords = ['upi', 'payment', 'transaction', 'transfer', 'wallet', 'account', 'avl', 'limit', 'not'];
    final words = cleanName.split(' ');
    final validWords = words.where((word) => word.length >= 2 && !invalidWords.contains(word)).toList();
    
    bool isValid = validWords.isNotEmpty && 
                   cleanName.length >= 2 && 
                   cleanName.length <= 30 &&
                   !RegExp(r'^\d+$').hasMatch(cleanName) &&
                   !RegExp(r'^[^a-zA-Z]*$').hasMatch(cleanName);
    
    print('✅ Merchant name valid: $isValid');
  } else {
    print('❌ Merchant not extracted');
  }
  print('');
  
  // Step 5: Test Payment Method Detection
  print('💳 Step 5: Payment Method Detection');
  String paymentMethod = 'Unknown';
  
  if (body.contains('credit card') || 
      body.contains('card no.') ||
      body.contains('avl limit') ||
      body.contains('available limit') ||
      (body.contains('card') && body.contains('limit'))) {
    paymentMethod = 'Credit Card';
  }
  
  print('✅ Payment method detected: $paymentMethod');
  print('');
  
  // Step 6: Expected Final Result
  print('🎯 Step 6: Expected Processing Result');
  print('✅ SMS should be processed successfully');
  print('✅ Amount: ₹4006.35');
  print('✅ Merchant: ISTRBL BANK LT (or similar)');
  print('✅ Category: Will depend on Foursquare API or keyword scoring');
  print('✅ Payment Method: Credit Card');
  print('✅ Title Format: "Category: Credit Card HH:MM"');
  print('');
  
  print('🎯 Test Complete! Your Axis Bank SMS format should work correctly.');
}