import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models.dart';

/// Technique repository (Sprint 4 MVP).
///
/// Direct Supabase queries. RLS enforces access control.
class TechniqueRepository {
  TechniqueRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Fetch all unique categories (ordered by min display_order).
  Future<List<String>> fetchCategories() async {
    final response = await _supabase
        .from('technique')
        .select('category, display_order')
        .order('display_order', ascending: true);

    final rows = response as List<dynamic>;
    final categories = <String>{};
    for (final row in rows) {
      categories.add(row['category'] as String);
    }
    return categories.toList();
  }

  /// Fetch techniques by category (ordered by display_order).
  Future<List<TechniqueDto>> fetchByCategory(String category) async {
    final response = await _supabase
        .from('technique')
        .select('*')
        .eq('category', category)
        .order('display_order', ascending: true);

    final rows = response as List<dynamic>;
    return rows
        .map((row) => TechniqueDto.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Fetch steps for a technique (ordered by idx).
  Future<List<TechniqueStepDto>> fetchSteps(String techniqueId) async {
    final response = await _supabase
        .from('technique_step')
        .select('*')
        .eq('technique_id', techniqueId)
        .order('idx', ascending: true);

    final rows = response as List<dynamic>;
    return rows
        .map((row) => TechniqueStepDto.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
