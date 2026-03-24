import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthResult {
  final bool success;
  final String? errorMessage;
  final String? token;

  const SupabaseAuthResult({
    required this.success,
    this.errorMessage,
    this.token,
  });
}

class SupabaseAuthUser {
  final String id;
  final String email;

  const SupabaseAuthUser({required this.id, required this.email});
}

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseAuthUser? _currentUser;

  SupabaseAuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<SupabaseAuthResult> signInWithPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = SupabaseAuthUser(
          id: response.user!.id,
          email: response.user!.email ?? email,
        );

        final token = response.session?.accessToken;

        developer.log(
          '✅ Supabase sign-in successful for: $email',
          name: 'SUPABASE_AUTH',
        );

        if (token != null) {
          developer.log('🎫 JWT Token: $token', name: 'SUPABASE_AUTH');
        }

        return SupabaseAuthResult(success: true, token: token);
      }

      return const SupabaseAuthResult(
        success: false,
        errorMessage: 'Sign-in failed: No user returned',
      );
    } on AuthException catch (e) {
      developer.log(
        '❌ Supabase AuthException: ${e.message}',
        name: 'SUPABASE_AUTH',
      );

      String message;
      switch (e.statusCode) {
        case '400':
          message = 'Credenciales inválidas';
          break;
        case '422':
          message = 'Formato de credenciales inválido';
          break;
        default:
          message = 'Error de autenticación: ${e.message}';
      }

      return SupabaseAuthResult(success: false, errorMessage: message);
    } catch (e) {
      developer.log('❌ Supabase sign-in error: $e', name: 'SUPABASE_AUTH');

      return const SupabaseAuthResult(
        success: false,
        errorMessage: 'Error de conexión. Intenta de nuevo.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      developer.log('👋 Supabase signed out', name: 'SUPABASE_AUTH');
    } catch (e) {
      developer.log('❌ Supabase sign-out error: $e', name: 'SUPABASE_AUTH');
    }
  }

  Future<String?> getToken() async {
    try {
      final session = _supabase.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      developer.log('❌ Get token error: $e', name: 'SUPABASE_AUTH');
      return null;
    }
  }

  SupabaseAuthUser? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return SupabaseAuthUser(id: user.id, email: user.email ?? '');
    }
    return null;
  }
}

/// Temporary test function to verify Supabase login works
Future<void> testSupabaseLogin(String email, String password) async {
  developer.log('🧪 Testing Supabase login for: $email', name: 'SUPABASE_AUTH');

  final authService = SupabaseAuthService();
  final result = await authService.signInWithPassword(email, password);

  if (result.success) {
    developer.log(
      '✅ TEST PASSED - Token received: ${result.token?.substring(0, 50)}...',
      name: 'SUPABASE_AUTH',
    );
  } else {
    developer.log(
      '❌ TEST FAILED - ${result.errorMessage}',
      name: 'SUPABASE_AUTH',
    );
  }
}
