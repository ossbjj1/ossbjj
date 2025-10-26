import 'package:flutter_test/flutter_test.dart';
import 'package:oss/core/services/profile_service.dart';

void main() {
  group('UserProfile', () {
    test('isComplete returns true when all required fields set', () {
      const profile = UserProfile(
        belt: 'blue',
        expRange: 'intermediate',
        weeklyGoal: 3,
        goalType: 'technique',
        ageGroup: '18-30',
      );

      expect(profile.isComplete, true);
    });

    test('isComplete returns false when belt missing', () {
      const profile = UserProfile(
        expRange: 'intermediate',
        weeklyGoal: 3,
        goalType: 'technique',
      );

      expect(profile.isComplete, false);
    });

    test('isComplete returns false when expRange missing', () {
      const profile = UserProfile(
        belt: 'blue',
        weeklyGoal: 3,
        goalType: 'technique',
      );

      expect(profile.isComplete, false);
    });

    test('isComplete returns false when weeklyGoal missing', () {
      const profile = UserProfile(
        belt: 'blue',
        expRange: 'intermediate',
        goalType: 'technique',
      );

      expect(profile.isComplete, false);
    });

    test('ageGroup is optional', () {
      const profile = UserProfile(
        belt: 'blue',
        expRange: 'intermediate',
        weeklyGoal: 3,
        goalType: 'technique',
      );

      expect(profile.isComplete, true);
      expect(profile.ageGroup, null);
    });
  });
}
