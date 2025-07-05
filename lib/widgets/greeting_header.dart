import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print("User Photo URL: ${user?.photoURL}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Greeting + Name in Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getGreeting(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Right Side: User Photo
          user?.photoURL != null
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user!.photoURL!),
                )
              : const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
        ],
      ),
    );
  }
}
