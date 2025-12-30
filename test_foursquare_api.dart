import 'lib/services/expense_categorizer.dart';

void main() async {
  print('🧪 Testing Foursquare API Integration...\n');
  
  // Test cases that should trigger Foursquare API calls
  final testCases = [
    // These merchants are NOT in our Indian database, so should use Foursquare API
    {'sms': 'Rs.450 debited at OLIVE BAR KITCHEN for payment', 'amount': 450.0},
    {'sms': 'Rs.299 spent at TOIT BREWPUB bangalore', 'amount': 299.0},
    {'sms': 'Rs.150 debited at SOCIAL OFFLINE gurgaon', 'amount': 150.0},
    {'sms': 'Rs.800 paid to HARD ROCK CAFE mumbai', 'amount': 800.0},
    {'sms': 'Rs.200 debited at COSTA COFFEE delhi', 'amount': 200.0},
  ];
  
  for (var test in testCases) {
    final sms = test['sms'] as String;
    final amount = test['amount'] as double;
    
    print('📱 Testing SMS: "$sms"');
    print('💰 Amount: ₹$amount');
    
    // Test the full categorization process
    final result = await ExpenseCategorizer.categorizeHybrid(sms, amount);
    print('✅ Final Category: ${result.name}');
    print('---\n');
  }
  
  print('🎯 Foursquare API Test Complete!');
}