import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final bool isRateLimited;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.isRateLimited = false,
  });
}

class AuthLogger {
  static void log({
    required String event,
    String? email,
    String? ip,
    bool success = false,
    int? failedAttempts,
    String? errorCode,
  }) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final logEntry =
        '''
[$timestamp] EVENT: $event
  Email: ${email ?? 'N/A'}
  IP: ${ip ?? 'client-side'}
  Success: $success
  FailedAttempts: ${failedAttempts ?? 'N/A'}
  ErrorCode: ${errorCode ?? 'N/A'}
''';
    developer.log(logEntry, name: 'AUTH_SECURITY');
  }
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  int _failedAttempts = 0;
  bool _isRateLimited = false;
  DateTime? _rateLimitUntil;

  static const int maxAttempts = 3;
  static const int lockoutSeconds = 30;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isRateLimited => _isRateLimited;
  int get failedAttempts => _failedAttempts;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      final bool shouldNotify = _user?.uid != user?.uid;
      _user = user;
      if (shouldNotify) {
        notifyListeners();
      }
    });
  }

  void _checkRateLimit() {
    if (_isRateLimited && _rateLimitUntil != null) {
      if (DateTime.now().isAfter(_rateLimitUntil!)) {
        _isRateLimited = false;
        _failedAttempts = 0;
        _rateLimitUntil = null;
        notifyListeners();
      }
    }
  }

  Future<AuthResult> signIn(String email, String password) async {
    _checkRateLimit();

    if (_isRateLimited) {
      AuthLogger.log(
        event: 'SIGN_IN_BLOCKED_RATE_LIMIT',
        email: email,
        failedAttempts: _failedAttempts,
      );
      return const AuthResult(
        success: false,
        errorMessage: 'Demasiados intentos. Intenta más tarde.',
        isRateLimited: true,
      );
    }

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _failedAttempts = 0;
      AuthLogger.log(event: 'SIGN_IN_SUCCESS', email: email, success: true);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      _failedAttempts++;

      if (_failedAttempts >= maxAttempts) {
        _isRateLimited = true;
        _rateLimitUntil = DateTime.now().add(Duration(seconds: lockoutSeconds));
        notifyListeners();

        AuthLogger.log(
          event: 'RATE_LIMIT_TRIGGERED',
          email: email,
          failedAttempts: _failedAttempts,
          errorCode: e.code,
        );

        return AuthResult(
          success: false,
          errorMessage:
              'Demasiados intentos fallidos. Intenta en $lockoutSeconds segundos.',
          isRateLimited: true,
        );
      }

      AuthLogger.log(
        event: 'SIGN_IN_FAILED',
        email: email,
        failedAttempts: _failedAttempts,
        errorCode: e.code,
      );

      return const AuthResult(
        success: false,
        errorMessage: 'Credenciales inválidas',
      );
    } catch (e) {
      AuthLogger.log(
        event: 'SIGN_IN_ERROR',
        email: email,
        errorCode: 'unknown',
      );
      return const AuthResult(
        success: false,
        errorMessage: 'Error de conexión. Intenta de nuevo.',
      );
    }
  }

  Future<AuthResult> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      AuthLogger.log(event: 'SIGN_UP_SUCCESS', email: email, success: true);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      AuthLogger.log(event: 'SIGN_UP_FAILED', email: email, errorCode: e.code);

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          message = 'Correo inválido';
          break;
        case 'weak-password':
          message = 'La contraseña debe tener al menos 6 caracteres';
          break;
        default:
          message = 'Error al crear la cuenta';
      }

      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return const AuthResult(
        success: false,
        errorMessage: 'Error de conexión. Intenta de nuevo.',
      );
    }
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
