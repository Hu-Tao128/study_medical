import 'package:flutter_test/flutter_test.dart';
import 'package:study_medical/features/auth/data/auth_service.dart';

void main() {
  group('AuthResult', () {
    test('should create AuthResult with success true', () {
      const result = AuthResult(success: true);
      expect(result.success, true);
      expect(result.errorMessage, null);
      expect(result.isRateLimited, false);
    });

    test('should create AuthResult with success false and error message', () {
      const result = AuthResult(success: false, errorMessage: 'Test error');
      expect(result.success, false);
      expect(result.errorMessage, 'Test error');
      expect(result.isRateLimited, false);
    });

    test('should create AuthResult with rate limit flag', () {
      const result = AuthResult(
        success: false,
        errorMessage: 'Rate limited',
        isRateLimited: true,
      );
      expect(result.isRateLimited, true);
    });
  });

  group('AuthLogger', () {
    test('should log with required parameters', () {
      AuthLogger.log(event: 'TEST_EVENT', success: true);
    });

    test('should log with email and IP', () {
      AuthLogger.log(
        event: 'TEST_EVENT',
        email: 'test@example.com',
        ip: '192.168.1.1',
        success: false,
      );
    });

    test('should log with failed attempts', () {
      AuthLogger.log(
        event: 'TEST_EVENT',
        failedAttempts: 3,
        errorCode: 'invalid credentials',
      );
    });
  });

  group('AuthService constants', () {
    test('should have correct maxAttempts', () {
      expect(AuthService.maxAttempts, 3);
    });

    test('should have correct lockoutSeconds', () {
      expect(AuthService.lockoutSeconds, 30);
    });
  });
}
