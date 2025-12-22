import 'package:flutter/material.dart';
import 'package:expensetracker/services/auth_service.dart';
// If you need GoogleSignIn directly for the button or state, keep it.
// import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  // Changed from LoginDialog to LoginScreen
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  String _statusMessage =
      'Please sign in with your Google account to continue.';

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    setState(() {
      _isSigningIn = true;
      _statusMessage = 'Signing in...';
    });

    try {
      final user = await AuthService.signInWithGoogle();

      if (user == null) {
        // User cancelled the login or an issue occurred within the Google sign-in flow.
        // No need to pop here, main.dart will handle the route change.
        if (mounted) {
          setState(() {
            _statusMessage = 'Sign-in cancelled. Please try again.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In cancelled.')),
          );
        }
      } else {
        // Successful sign-in. main.dart's StreamBuilder will detect this and navigate.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully!')),
          );
          // No explicit navigation needed here. The StreamBuilder in main.dart
          // will automatically switch the `home` widget.
        }
      }
    } catch (e) {
      debugPrint('Error during Google Sign-In in LoginScreen: $e');
      if (mounted) {
        String errorMessage = 'An unexpected error occurred. Please try again.';
        if (e is Exception) {
          errorMessage =
              'Sign-in failed: ${e.toString().replaceAll('Exception: ', '')}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        setState(() {
          _statusMessage = 'Sign-in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false; // Always stop signing in state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Now it's a full Scaffold
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Keep column compact
            children: [
              const Icon(Icons.lock_open, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Expense Tracker!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _isSigningIn ? Colors.blue : Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isSigningIn ? null : _signInWithGoogle,
                icon: _isSigningIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Image.network(
                        'https://www.gstatic.com/marketing-cms/assets/images/d5/dc/cfe9ce8b4425b410b49b7f2dd3f3/g.webp=s96-fcrop64=1,00000000ffffffff-rw', // Make sure you have a Google logo asset
                        height: 24.0,
                        width: 24.0,
                      ),
                label: Text(
                  _isSigningIn ? 'Signing In...' : 'Sign in with Google',
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              // You can add other login options or information here
            ],
          ),
        ),
      ),
    );
  }
}
