import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../data/technique_repository.dart';
import '../data/models.dart';

/// Technique repository provider (Sprint 4 MVP).
final techniqueRepositoryProvider = Provider<TechniqueRepository>((ref) {
  return TechniqueRepository(Supabase.instance.client);
});

/// Categories provider (Sprint 4 MVP).
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(techniqueRepositoryProvider);
  return repo.fetchCategories();
});

/// Techniques by category provider (Sprint 4 MVP).
final techniquesByCategoryProvider =
    FutureProvider.family<List<TechniqueDto>, String>((ref, category) async {
  final repo = ref.watch(techniqueRepositoryProvider);
  return repo.fetchByCategory(category);
});
