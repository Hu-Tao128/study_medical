import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class AuthUser {
  final String id;
  final String email;

  const AuthUser({required this.id, required this.email});
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
  final SupabaseClient _supabase = Supabase.instance.client;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  AuthUser? _user;
  bool _isInitialized = false;

  int _failedAttempts = 0;
  bool _isRateLimited = false;
  DateTime? _rateLimitUntil;

  static const int maxAttempts = 3;
  static const int lockoutSeconds = 30;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isRateLimited => _isRateLimited;
  int get failedAttempts => _failedAttempts;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _initAuthListener();
  }

  Future<void> _initAuthListener() async {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      developer.log(
        'Firebase auth state changed: ${firebaseUser != null}',
        name: 'FIREBASE_AUTH',
      );

      if (firebaseUser != null) {
        _user = AuthUser(id: firebaseUser.uid, email: firebaseUser.email ?? '');
        developer.log('User logged in: ${_user?.email}', name: 'FIREBASE_AUTH');
      } else {
        _user = null;
        developer.log('User logged out', name: 'FIREBASE_AUTH');
      }

      notifyListeners();
    });

    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        _user = AuthUser(id: currentUser.uid, email: currentUser.email ?? '');
        developer.log(
          'Restored session: ${_user?.email}',
          name: 'FIREBASE_AUTH',
        );
      }
    } catch (e) {
      developer.log('Error restoring session: $e', name: 'FIREBASE_AUTH');
    }

    _isInitialized = true;
    notifyListeners();
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
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = AuthUser(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
        );
        _failedAttempts = 0;

        AuthLogger.log(event: 'SIGN_IN_SUCCESS', email: email, success: true);

        await _syncWithSupabase();

        notifyListeners();
        return const AuthResult(success: true);
      }

      return const AuthResult(
        success: false,
        errorMessage: 'Credenciales inválidas',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      _failedAttempts++;

      if (_failedAttempts >= maxAttempts) {
        _isRateLimited = true;
        _rateLimitUntil = DateTime.now().add(
          const Duration(seconds: lockoutSeconds),
        );
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

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          message = 'Correo inválido';
          break;
        default:
          message = 'Credenciales inválidas';
      }

      return AuthResult(success: false, errorMessage: message);
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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = AuthUser(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
        );

        AuthLogger.log(event: 'SIGN_UP_SUCCESS', email: email, success: true);

        await _syncWithSupabase();

        notifyListeners();
        return const AuthResult(success: true);
      }

      return const AuthResult(
        success: false,
        errorMessage: 'Error al crear la cuenta',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
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

  // Sincroniza con Supabase usando el token de Firebase
  // Esto crea el usuario en auth.users de Supabase
  Future<void> _syncWithSupabase() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        developer.log('No hay usuario de Firebase para sync', name: 'AUTH');
        return;
      }

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        developer.log('No se pudo obtener el ID token', name: 'AUTH');
        return;
      }

      developer.log(
        'Intentando sincronizar con Supabase (Firebase Third-Party)...',
        name: 'AUTH',
      );

      // Usar signInWithIdToken con Google provider (para Firebase Third-Party Auth)
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user != null) {
        developer.log(
          '✅ Usuario creado en auth.users: ${response.user!.id}',
          name: 'AUTH',
        );
      } else {
        developer.log('⚠️ No se pudo crear usuario en Supabase', name: 'AUTH');
      }
    } catch (e, stack) {
      developer.log('⚠️ Error al sync con Supabase: $e\n$stack', name: 'AUTH');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);

      if (result.user != null) {
        _user = AuthUser(id: result.user!.uid, email: result.user!.email ?? '');

        await _syncWithSupabase();

        notifyListeners();
      }
    } catch (e) {
      developer.log('Google Sign In Error: $e', name: 'FIREBASE_AUTH');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      developer.log(
        'Google signOut error (non-critical): $e',
        name: 'FIREBASE_AUTH',
      );
    }

    await _firebaseAuth.signOut();

    try {
      await _supabase.auth.signOut();
    } catch (e) {
      developer.log('Supabase signOut error (non-critical): $e', name: 'AUTH');
    }

    _user = null;
    notifyListeners();
  }

  Future<String?> getToken() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return await firebaseUser.getIdToken();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
