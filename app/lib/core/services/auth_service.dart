import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import '../strings/auth_strings.dart';

/// Auth service wrapper for Supabase (Sprint 2).
///
/// Handles email/password signup, login, logout, password reset.
class AuthService {
  AuthService();

  final _logger = Logger();
  bool _initialized = false;

  /// Initialize Supabase client (idempotent).
  Future<void> init() async {
    if (_initialized) {
      _logger.d('Supabase already initialized');
      return;
    }

    if (!Env.hasSupabase) {
      _logger.w('Supabase not configured, auth will fail');
      return;
    }

    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      _initialized = true;
      _logger.i('Supabase initialized');
    } catch (e, stackTrace) {
      _logger.e('Supabase init failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Current user (null if not logged in or not initialized).
  User? get currentUser {
    if (!_initialized) {
      return null;
    }
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Sign up with email/password.
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
      return AuthResult.failure(
          'Auth service not initialized. Call init() first.');
    }
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure(AuthStrings.errGeneric);
      }

      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      _logger.w('SignUp failed: ${e.message}');
      return AuthResult.failure(_mapAuthError(e));
    } catch (e, stackTrace) {
      _logger.e('SignUp error', error: e, stackTrace: stackTrace);
      return AuthResult.failure(AuthStrings.errGeneric);
    }
  }

  /// Sign in with email/password.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
      return AuthResult.failure(
          'Auth service not initialized. Call init() first.');
    }
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure(AuthStrings.errGeneric);
      }

      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      _logger.w('SignIn failed: ${e.message}');
      return AuthResult.failure(_mapAuthError(e));
    } catch (e, stackTrace) {
      _logger.e('SignIn error', error: e, stackTrace: stackTrace);
      return AuthResult.failure(AuthStrings.errGeneric);
    }
  }

  /// Sign out current user.
  Future<void> signOut() async {
    if (!_initialized) {
      _logger.w('Auth service not initialized, cannot sign out');
      return;
    }
    try {
      await Supabase.instance.client.auth.signOut();
      _logger.i('User signed out');
    } catch (e, stackTrace) {
      _logger.e('SignOut error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Send password reset email.
  Future<void> resetPassword({required String email}) async {
    if (!_initialized) {
      _logger.w('Auth service not initialized, cannot reset password');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent');
    } on AuthException catch (e) {
      _logger.w('ResetPassword failed: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('ResetPassword error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Map Supabase AuthException to user-friendly error strings.
  /// Note: Relies on substring matching of Supabase error messages.
  /// TODO: Update to use structured error codes when Supabase provides them.
  String _mapAuthError(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return AuthStrings.errPasswordInvalid;
    }
    if (message.contains('email') && message.contains('invalid')) {
      return AuthStrings.errEmailInvalid;
    }
    if (message.contains('unavailable') || message.contains('timeout')) {
      return AuthStrings.errLoginUnavailable;
    }
    return AuthStrings.errGeneric;
  }
}

/// Auth operation result with explicit success flag for consistency.
class AuthResult {
  const AuthResult._({required this.success, this.user, this.error});

  factory AuthResult.success({required User? user}) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }

  final bool success;
  final User? user;
  final String? error;

  bool get isSuccess => success;
  bool get isFailure => !success;
}
