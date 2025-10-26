import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:oss/core/services/gating_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
void main() {
  group('GatingService', () {
    test('creates instance', () {
      final service = GatingService();
      expect(service, isNotNull);
    });

    // Note: Full integration tests require complex Supabase mocking
    // (SupabaseClient → from() → select() → eq() → single())
    // For MVP, we test class instantiation + models.
    // TODO Sprint 4.1: Add full mock chain for checkStepAccess/completeStep
  });

  group('GatingAccess', () {
    test('creates valid access object', () {
      const access = GatingAccess(
        allowed: true,
        reason: GatingReason.free,
      );
      expect(access.allowed, isTrue);
      expect(access.reason, GatingReason.free);
    });
  });

  group('CompleteResult', () {
    test('creates valid result object', () {
      const result = CompleteResult(
        success: true,
        idempotent: false,
        message: 'Step completed',
      );
      expect(result.success, isTrue);
      expect(result.idempotent, isFalse);
      expect(result.message, 'Step completed');
    });
  });
}
