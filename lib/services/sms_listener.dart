import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final Telephony telephony = Telephony.instance;

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  await _processSmsMessage(message, isBackground: true);
}

Future<void> initializeSmsListener() async {
  final bool? permissionGranted = await telephony.requestPhoneAndSmsPermissions;
  print("Permission granted: $permissionGranted");

  if (permissionGranted ?? false) {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        _processSmsMessage(message, isBackground: false);
      },
      onBackgroundMessage: backgroundMessageHandler,
    );

    print("📡 SMS Listener registered");
  }
}

Future<void> _processSmsMessage(SmsMessage message,
    {bool isBackground = false}) async {
  final body = message.body?.toLowerCase() ?? '';
  final sender = message.address ?? '';
  final time =
      DateTime.now(); // You can change this to use message.date if needed

  print(
      "📩 ${isBackground ? 'BG' : 'FG'} Received SMS from $sender: ${message.body}");

  // ✅ Keywords to detect potential expenses
  final isExpense = body.contains('debited') ||
      body.contains('Debited') ||
      body.contains('purchase') ||
      body.contains('spent') ||
      body.contains('withdrawn') ||
      body.contains('paid');

  if (!isExpense) {
    print("❌ No valid expense keywords.");
    return;
  }

  // ✅ Regex to extract amount
  final amountRegex = RegExp(
    r'(rs[:\.]?)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  final match = amountRegex.firstMatch(body);

  if (match == null) {
    print("❌ No valid amount found.");
    return;
  }

  final amountStr = match.group(2)?.replaceAll(',', '') ?? '0.0';
  final amount = double.tryParse(amountStr);

  if (amount == null || amount <= 0) {
    print("❌ Invalid or zero amount.");
    return;
  }

  // ✅ Format title
  final timeStr =
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  final title = "${isBackground ? 'BG' : 'FG'} msg: $timeStr";

  // ✅ Save to Firestore
  await addExpenseToStorage(
    title: title,
    amount: amount,
    date: time,
    category: "Miscellaneous",
  );

  print("✅ Expense added: ₹$amount at $timeStr");
}

Future<void> addExpenseToStorage({
  required String title,
  required double amount,
  required DateTime date,
  required String category,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ No authenticated user.');
      return;
    }
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(user.uid)
        .collection('user_expenses')
        .add({
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    });
    print("✅ Firestore entry complete to top-level 'expenses'");
  } catch (e) {
    print("❌ Failed to save expense: $e");
  }
}
