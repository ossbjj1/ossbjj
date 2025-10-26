import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<void> upsert(UserProfile profile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Cannot upsert profile: user not logged in');
      }

      final payload = profile.toUpsertJson(user.id);
      await Supabase.instance.client.from('user_profile').upsert(payload);

      _logger.i('Profile upserted');
    } catch (e, stackTrace) {
      _logger.e('Profile upsert failed', error: e, stackTrace: stackTrace);
      rethrow;
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
