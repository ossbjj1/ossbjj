import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when user profile validation fails.
class ProfileValidationException implements Exception {
  ProfileValidationException(this.message);
  final String message;
  @override
  String toString() => 'ProfileValidationException: $message';
}

/// Thrown when user is not authenticated for profile operations.
class UserNotAuthenticatedException implements Exception {
  UserNotAuthenticatedException(this.message);
  final String message;
  @override
  String toString() => 'UserNotAuthenticatedException: $message';
}

/// User profile service for onboarding data (Sprint 3).
class ProfileService {
  ProfileService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Fetch current user's profile.
  Future<UserProfile?> fetch() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot fetch profile: user not logged in');
    }

    try {
      final response = await Supabase.instance.client
          .from('user_profile')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Profile fetch failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Upsert user profile (create or update).
  /// Validates required fields and ranges before persisting.
  /// Throws ProfileValidationException if validation fails.
  /// Throws UserNotAuthenticatedException if user not logged in.
  ///
  /// [draft] flag allows saving incomplete profiles (e.g. autosave during onboarding).
  /// When true, skips validation. Default: false.
  Future<void> upsert(UserProfile profile, {bool draft = false}) async {
    try {
      // Validate profile before any DB operations (skip for drafts)
      if (!draft) {
        _validateProfile(profile);
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw UserNotAuthenticatedException(
          'Cannot upsert profile: user not logged in',
        );
      }

      final payload = profile.toUpsertJson(user.id);
      await Supabase.instance.client.from('user_profile').upsert(payload);

      _logger.i('Profile upserted');
    } catch (e, stackTrace) {
      _logger.e('Profile upsert failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Validate user profile fields and ranges.
  /// Throws ProfileValidationException on validation failure.
  void _validateProfile(UserProfile profile) {
    // Check required fields
    if (profile.belt == null) {
      const msg = 'Profile validation failed: belt is required';
      _logger.e(msg);
      throw ProfileValidationException(msg);
    }
    if (profile.expRange == null) {
      const msg = 'Profile validation failed: expRange is required';
      _logger.e(msg);
      throw ProfileValidationException(msg);
    }
    if (profile.goalType == null) {
      const msg = 'Profile validation failed: goalType is required';
      _logger.e(msg);
      throw ProfileValidationException(msg);
    }

    // Validate ranges
    if (profile.weeklyGoal != null) {
      if (profile.weeklyGoal! < 1 || profile.weeklyGoal! > 7) {
        final msg =
            'Profile validation failed: weeklyGoal must be between 1 and 7, got ${profile.weeklyGoal}';
        _logger.e(msg);
        throw ProfileValidationException(msg);
      }
    }

    // Validate enum values
    const validBelts = {'white', 'blue', 'purple', 'brown', 'black'};
    if (!validBelts.contains(profile.belt)) {
      final msg =
          'Profile validation failed: invalid belt value "${profile.belt}"';
      _logger.e(msg);
      throw ProfileValidationException(msg);
    }

    const validExpRanges = {'beginner', 'intermediate', 'advanced'};
    if (!validExpRanges.contains(profile.expRange)) {
      final msg =
          'Profile validation failed: invalid expRange value "${profile.expRange}"';
      _logger.e(msg);
      throw ProfileValidationException(msg);
    }

    const validGoalTypes = {
      'fundamentals',
      'technique',
      'strength',
      'flexibility'
    };
    if (!validGoalTypes.contains(profile.goalType)) {
      final msg =
          'Profile validation failed: invalid goalType value "${profile.goalType}"';
      _logger.e(msg);
      throw ProfileValidationException(msg);
    }
  }
}

/// User profile data model.
class UserProfile {
  const UserProfile({
    this.belt,
    this.expRange,
    this.weeklyGoal,
    this.goalType,
    this.ageGroup,
  });

  final String? belt;
  final String? expRange;
  final int? weeklyGoal;
  final String? goalType;
  final String? ageGroup;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      belt: json['belt'] as String?,
      expRange: json['exp_range'] as String?,
      weeklyGoal: json['weekly_goal'] as int?,
      goalType: json['goal_type'] as String?,
      ageGroup: json['age_group'] as String?,
    );
  }

  /// Convert profile to JSON for toJson() serialization.
  Map<String, dynamic> toJson() {
    return {
      'belt': belt,
      'exp_range': expRange,
      'weekly_goal': weeklyGoal,
      'goal_type': goalType,
      'age_group': ageGroup,
    };
  }

  /// Convert profile to JSON with user_id for Supabase upsert.
  Map<String, dynamic> toUpsertJson(String userId) {
    return {
      ...toJson(),
      'user_id': userId,
    };
  }

  /// Check if profile is complete (required fields filled including goalType).
  /// ageGroup is optional as per product design.
  bool get isComplete =>
      belt != null &&
      expRange != null &&
      weeklyGoal != null &&
      goalType != null;
}
