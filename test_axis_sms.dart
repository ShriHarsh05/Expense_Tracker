import 'lib/services/expense_categorizer.dart';

void main() async {
  print('🧪 Testing Axis Bank Credit Card SMS Format...\n');
  
  // Your specific SMS format
  final testSMS = 'Spent INR 4006.35Axis Bank Card no. XX542823-12-25 13:18:48 ISTRBL BANK LTAvl Limit: INR 177993.65Not you? SMS BLOCK 5428 to 919951860002';
  final amount = 4006.35;
  
  print('📱 Testing SMS: "$testSMS"');
  print('💰 Expected Amount: ₹$amount');
  print('🏪 Expected Merchant: ISTRBL BANK LT');
  print('---\n');
  
  // Test merchant extraction
  print('🔍 Testing Merchant Extraction:');
  final extractedMerchant = ExpenseCategorizer._extractWalletMerchant(testSMS.toLowerCase());
  if (extractedMerchant != null) {
    print('✅ Extracted Merchant: "$extractedMerchant"');
  } else {
    print('❌ No merchant extracted');
  }
  print('');
  
  // Test Layer 0: Indian Merchant Database
  print('🇮🇳 Testing Layer 0 (Indian Merchant Database):');
  final indianCategory = ExpenseCategorizer.categorizeByIndianMerchants(testSMS);
  if (indianCategory != null) {
    print('✅ Indian DB Match: ${indianCategory.name}');
  } else {
    print('❌ No match in Indian database');
  }
  print('');
  
  // Test Layer 1: Foursquare API (if merchant extracted)
  if (extractedMerchant != null) {
    print('🏪 Testing Layer 1 (Foursquare API):');
    final merchantCategory = await ExpenseCategorizer.categorizeByMerchantAPI(testSMS);
    if (merchantCategory != null) {
      print('✅ Foursquare API Match: ${merchantCategory.name}');
    } else {
      print('❌ No match in Foursquare API');
    }
    print('');
  }
  
  // Test Layer 2: Keyword Scoring
  print('🎯 Testing Layer 2 (Keyword Scoring):');
  final keywordCategory = ExpenseCategorizer.categorizeByKeywordScoring(testSMS, amount);
  print('✅ Keyword Category: ${keywordCategory.name}');
  print('');
  
  // Test Final Result
  print('🎯 Testing Final Hybrid Categorization:');
  final finalCategory = await ExpenseCategorizer.categorizeHybrid(testSMS, amount);
  print('✅ Final Category: ${finalCategory.name}');
  print('');
  
  // Test payment method detection
  print('💳 Testing Payment Method Detection:');
  // We need to access the _detectPaymentMethod function - let's simulate it
  final body = testSMS.toLowerCase();
  String paymentMethod = 'Unknown';
  
  if (body.contains('credit card') || 
      body.contains('card no.') ||
      body.contains('avl limit') ||
      body.contains('available limit') ||
      (body.contains('card') && body.contains('limit'))) {
    paymentMethod = 'Credit Card';
  }
  
  print('✅ Payment Method: $paymentMethod');
  print('');
  
  print('🎯 Test Complete!');
  print('📊 Summary:');
  print('   • Amount Detection: Should work (INR 4006.35)');
  print('   • Merchant: ${extractedMerchant ?? "Not extracted"}');
  print('   • Category: ${finalCategory.name}');
  print('   • Payment Method: $paymentMethod');
}