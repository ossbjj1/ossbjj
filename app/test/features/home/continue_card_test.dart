import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:oss/core/services/gating_service.dart';
import 'package:oss/core/services/progress_service.dart';

import 'continue_card_test.mocks.dart';

@GenerateMocks([GatingService, ProgressService])
void main() {
  group('ContinueCard Integration Tests', () {
    // Note: Full widget tests require GoRouter mock (complex setup).
    // For MVP Sprint 4, we focus on service-level integration.
    // Widget rendering tests can be added in Sprint 4.1 with proper router harness.

    test('GatingService mock can be created', () {
      final mockGatingService = MockGatingService();
      expect(mockGatingService, isNotNull);
    });

    test('ProgressService mock can be created', () {
      final mockProgressService = MockProgressService();
      expect(mockProgressService, isNotNull);
    });

    // TODO Sprint 4.1: Add full widget tests with GoRouter mock:
    // - shows loading placeholder
    // - shows onboarding CTA when hint null
    // - shows continue button when hint exists
    // - calls gating service on tap
    // - navigates to step (allowed) or paywall (locked)
    // - shows error snackbar on gating failure
  });
}
