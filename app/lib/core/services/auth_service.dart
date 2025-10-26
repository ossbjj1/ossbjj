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

  /// Initialize Supabase client.
  Future<void> init() async {
    if (!Env.hasSupabase) {
      _logger.w('Supabase not configured, auth will fail');
      return;
    }

    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      _logger.i('Supabase initialized');
    } catch (e, stackTrace) {
      _logger.e('Supabase init failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Current user (null if not logged in).
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  /// Sign up with email/password.
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
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
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent to $email');
    } on AuthException catch (e) {
      _logger.w('ResetPassword failed: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('ResetPassword error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Map Supabase AuthException to user-friendly error strings.
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

/// Auth operation result.
class AuthResult {
  const AuthResult._({this.user, this.error});

  factory AuthResult.success({required User? user}) => AuthResult._(user: user);

  factory AuthResult.failure(String error) => AuthResult._(error: error);

  final User? user;
  final String? error;

  bool get isSuccess => user != null;
  bool get isFailure => error != null;
}
