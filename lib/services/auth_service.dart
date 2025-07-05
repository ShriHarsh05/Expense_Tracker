import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer'; // For logging errors, useful for debugging

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // A getter for the current user, useful for immediate checks
  static User? get currentUser => _auth.currentUser;

  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in flow
      if (googleUser == null) {
        log('Google Sign-In cancelled by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      log('Google Sign-In successful for user: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Firebase specific errors
      log('FirebaseAuthException during Google Sign-In: code=${e.code}, message=${e.message}');
      // You might want to throw a custom exception or return null based on error type
      // For instance, if 'account-exists-with-different-credential', you might guide the user
      // to link accounts.
      // Example:
      // if (e.code == 'account-exists-with-different-credential') {
      //   // Handle linking accounts logic in the UI
      // }
      rethrow; // Re-throw the exception so the UI can catch and display it
    } catch (e) {
      // General errors (e.g., network issues, Google Sign-In specific errors)
      log('General error during Google Sign-In: $e');
      rethrow; // Re-throw the exception
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      log('Signed out from Google.');

      await _auth.signOut();
      log('Signed out from Firebase.');
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException during sign out: code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      log('General error during sign out: $e');
      rethrow;
    }
  }

  static Stream<User?> get userChanges => _auth.userChanges();
  static Stream<User?> get authStateChanges =>
      _auth.authStateChanges(); // A more commonly used stream

  // You could also add a stream for ID token changes if needed
  // static Stream<User?> get idTokenChanges => _auth.idTokenChanges();
}
