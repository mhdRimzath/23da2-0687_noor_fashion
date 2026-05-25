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
    );
    if (credential.user != null) {
      await FirestoreService().migrateCurrentUserProfile(credential.user!);
    }
    return credential;
  }

  // Sign up with email and password, and update display name
  Future<UserCredential> signUp(String email, String password, String name) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      final updatedUser = _auth.currentUser;
      if (updatedUser != null) {
        await FirestoreService().migrateCurrentUserProfile(updatedUser);
      } else {
        await FirestoreService().migrateCurrentUserProfile(credential.user!);
      }
    }
    return credential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
