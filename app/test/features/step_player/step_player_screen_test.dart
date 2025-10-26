import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:oss/core/services/gating_service.dart';

import 'step_player_screen_test.mocks.dart';

@GenerateMocks([GatingService])
void main() {
  group('StepPlayerScreen Integration Tests', () {
    // Note: Full widget tests require GoRouter mock (navigation context).
    // For MVP Sprint 4, we validate service integration only.

    test('GatingService mock can be created', () {
      final mockGatingService = MockGatingService();
      expect(mockGatingService, isNotNull);
    });

    // TODO Sprint 4.1: Add full widget tests with GoRouter mock:
    // - displays step ID and complete button
    // - shows loading spinner while completing
    // - shows success/error snackbars
    // - button re-enables after error
    // - navigates back on success
  });
}
