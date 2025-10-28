import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models.dart';

/// Technique repository (Sprint 4 MVP).
///
/// Direct Supabase queries. RLS enforces access control.
class TechniqueRepository {
  TechniqueRepository(this._supabase);

  final SupabaseClient _supabase;
  static const _queryTimeout = Duration(seconds: 10);

  /// Fetch all unique categories (ordered by min display_order).
  Future<List<String>> fetchCategories() async {
    try {
      final response = await _supabase
          .from('technique')
          .select('category, display_order')
          .order('display_order', ascending: true)
          .timeout(_queryTimeout);

      if (response is! List) {
        throw TechniqueLoadFailure('categories',
            Exception('Unexpected response type: ${response.runtimeType}'));
      }

      final categories = <String>{};
      for (final row in response) {
        if (row is Map<String, dynamic>) {
          final category = row['category'];
          if (category != null) {
            categories.add(category.toString());
          }
        }
      }
      return categories.toList();
    } on TimeoutException catch (e) {
      throw TechniqueLoadFailure('categories', e);
    } on PostgrestException catch (e) {
      throw TechniqueLoadFailure('categories', e);
    } catch (e) {
      throw TechniqueLoadFailure('categories', e);
    }
  }

  /// Fetch techniques by category (ordered by display_order).
  Future<List<TechniqueDto>> fetchByCategory(String category) async {
    try {
      final response = await _supabase
          .from('technique')
          .select('*')
          .eq('category', category)
          .order('display_order', ascending: true)
          .timeout(_queryTimeout);

      if (response is! List) {
        throw TechniqueLoadFailure('fetchByCategory',
            Exception('Unexpected response type: ${response.runtimeType}'));
      }

      return response
          .whereType<Map<String, dynamic>>()
          .map((row) => TechniqueDto.fromJson(row))
          .toList();
    } on TimeoutException catch (e) {
      throw TechniqueLoadFailure('fetchByCategory($category)', e);
    } on PostgrestException catch (e) {
      throw TechniqueLoadFailure('fetchByCategory($category)', e);
    } catch (e) {
      throw TechniqueLoadFailure('fetchByCategory($category)', e);
    }
  }

  /// Fetch steps for a technique (ordered by idx).
  Future<List<TechniqueStepDto>> fetchSteps(String techniqueId) async {
    try {
      final response = await _supabase
          .from('technique_step')
          .select('*')
          .eq('technique_id', techniqueId)
          .order('idx', ascending: true)
          .timeout(_queryTimeout);

      if (response is! List) {
        throw TechniqueLoadFailure('fetchSteps',
            Exception('Unexpected response type: ${response.runtimeType}'));
      }

      return response
          .whereType<Map<String, dynamic>>()
          .map((row) => TechniqueStepDto.fromJson(row))
          .toList();
    } on TimeoutException catch (e) {
      throw TechniqueLoadFailure('fetchSteps($techniqueId)', e);
    } on PostgrestException catch (e) {
      throw TechniqueLoadFailure('fetchSteps($techniqueId)', e);
    } catch (e) {
      throw TechniqueLoadFailure('fetchSteps($techniqueId)', e);
    }
  }
}

/// Exception for technique load failures (Sprint 4).
class TechniqueLoadFailure implements Exception {
  const TechniqueLoadFailure(this.operation, this.cause);

  final String operation;
  final Object cause;

  @override
  String toString() => 'TechniqueLoadFailure($operation): ${cause.toString()}';
}
