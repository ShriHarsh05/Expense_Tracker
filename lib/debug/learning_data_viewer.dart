import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔍 Debug utility to view stored learning patterns
class LearningDataViewer {
  
  /// View all learned patterns for current user
  static Future<void> printAllLearningPatterns() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }
      
      print('🔍 Fetching learning patterns for user: ${user.uid}');
      
      final query = await FirebaseFirestore.instance
          .collection('learning_patterns')
          .doc(user.uid)
          .collection('patterns')
          .orderBy('learnedAt', descending: true)
          .get();
      
      if (query.docs.isEmpty) {
        print('📭 No learning patterns found yet');
        return;
      }
      
      print('📊 Found ${query.docs.length} learning patterns:');
      print('=' * 60);
      
      for (int i = 0; i < query.docs.length; i++) {
        final doc = query.docs[i];
        final data = doc.data();
        
        print('Pattern ${i + 1}:');
        print('  📁 Document ID: ${doc.id}');
        print('  🏷️  Category: ${data['category']}');
        print('  💰 Amount Range: ${data['features']['amountRange']}');
        print('  ⏰ Time Range: ${data['features']['timeRange']}');
        print('  📱 SMS Source: ${data['features']['smsSource']}');
        print('  💳 Transaction Type: ${data['features']['transactionType']}');
        print('  📝 Custom Title: ${data['userTitle'] ?? 'None'}');
        print('  📅 Learned At: ${data['learnedAt']}');
        print('  🔢 Usage Count: ${data['usageCount']}');
        print('  🕐 Last Used: ${data['lastUsed']}');
        print('  ' + '-' * 40);
      }
      
      print('✅ Learning data review complete');
      
    } catch (e) {
      print('❌ Error fetching learning patterns: $e');
    }
  }
  
  /// Get learning statistics
  static Future<void> printLearningStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final query = await FirebaseFirestore.instance
          .collection('learning_patterns')
          .doc(user.uid)
          .collection('patterns')
          .get();
      
      if (query.docs.isEmpty) {
        print('📊 Learning Stats: No data yet');
        return;
      }
      
      // Analyze patterns
      Map<String, int> categoryCount = {};
      Map<String, int> sourceCount = {};
      Map<String, int> amountRangeCount = {};
      int totalUsage = 0;
      
      for (var doc in query.docs) {
        final data = doc.data();
        final category = data['category'] as String;
        final source = data['features']['smsSource'] as String;
        final amountRange = data['features']['amountRange'] as String;
        final usage = data['usageCount'] as int;
        
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        sourceCount[source] = (sourceCount[source] ?? 0) + 1;
        amountRangeCount[amountRange] = (amountRangeCount[amountRange] ?? 0) + 1;
        totalUsage += usage;
      }
      
      print('📊 Learning Statistics:');
      print('=' * 40);
      print('📈 Total Patterns: ${query.docs.length}');
      print('🔄 Total Auto-Categorizations: $totalUsage');
      print('');
      print('📂 Categories Learned:');
      categoryCount.forEach((category, count) {
        print('  • $category: $count patterns');
      });
      print('');
      print('📱 SMS Sources:');
      sourceCount.forEach((source, count) {
        print('  • $source: $count patterns');
      });
      print('');
      print('💰 Amount Ranges:');
      amountRangeCount.forEach((range, count) {
        print('  • $range: $count patterns');
      });
      
    } catch (e) {
      print('❌ Error getting learning stats: $e');
    }
  }
}