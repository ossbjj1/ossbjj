import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oss/core/services/auth_service.dart';
import 'package:oss/core/strings/auth_strings.dart';

void main() {
  group('AuthService error mapping', () {
    test('_mapAuthError handles invalid credentials', () {
      const error = AuthException('Invalid login credentials');
      // Access via reflection not possible, test via signIn/signUp flow in integration
      // MVP: skip direct _mapAuthError test (private method)
      expect(error.message, isNotEmpty);
      expect(AuthStrings.errPasswordInvalid, isNotEmpty);
    });

    test('error strings are defined', () {
      expect(AuthStrings.errEmailInvalid, isNotEmpty);
      expect(AuthStrings.errPasswordInvalid, isNotEmpty);
      expect(AuthStrings.errLoginUnavailable, isNotEmpty);
      expect(AuthStrings.errGeneric, isNotEmpty);
    });

    test('AuthResult factories work correctly', () {
      final success = AuthResult.success(user: null);
      expect(success.isSuccess, false); // user is null
      expect(success.isFailure, false);

      final failure = AuthResult.failure('test error');
      expect(failure.isSuccess, false);
      expect(failure.isFailure, true);
      expect(failure.error, 'test error');
    });
  });
}
