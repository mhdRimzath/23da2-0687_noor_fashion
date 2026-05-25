import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('Sign-in timed out. Please check your network connection.'),
    );
    if (credential.user != null) {
      try {
        await FirestoreService()
            .migrateCurrentUserProfile(credential.user!)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        // Continue login even if migration fails/times out
      }
    }
    return credential;
  }

  // Sign up with email and password, and update display name
  Future<UserCredential> signUp(String email, String password, String name) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Sign-up timed out. Please check your network connection.'),
    );
    if (credential.user != null) {
      try {
        await credential.user!.updateDisplayName(name).timeout(const Duration(seconds: 2));
      } catch (_) {}
      try {
        await credential.user!.reload().timeout(const Duration(seconds: 2));
      } catch (_) {}
      final updatedUser = _auth.currentUser;
      try {
        if (updatedUser != null) {
          await FirestoreService()
              .migrateCurrentUserProfile(updatedUser)
              .timeout(const Duration(seconds: 4));
        } else {
          await FirestoreService()
              .migrateCurrentUserProfile(credential.user!)
              .timeout(const Duration(seconds: 4));
        }
      } catch (e) {
        // Continue signup even if migration fails/times out
      }
    }
    return credential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
