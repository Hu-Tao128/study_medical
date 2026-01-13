import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      final bool shouldNotify = _user?.uid != user?.uid;
      _user = user;
      if (shouldNotify) {
        notifyListeners();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _firebaseAuth.signInWithPopup(googleProvider);
    } else {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
      } catch (e) {
        debugPrint('Google Sign In Error: $e');
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }
}
