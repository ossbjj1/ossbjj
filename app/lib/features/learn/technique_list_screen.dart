import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/strings.dart';
import 'state/providers.dart';

/// Technique List Screen (Sprint 4 MVP).
class TechniqueListScreen extends ConsumerWidget {
  const TechniqueListScreen({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final techniquesAsync = ref.watch(techniquesByCategoryProvider(category));

    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryTitle(context, category)),
        backgroundColor: DsColors.bgSurface,
      ),
      body: techniquesAsync.when(
        data: (techniques) {
          if (techniques.isEmpty) {
            return Center(
              child: Text(
                'No techniques in this category yet.',
                style: DsTypography.bodyMedium.copyWith(
                  color: DsColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DsSpacing.md),
            itemCount: techniques.length,
            itemBuilder: (context, index) {
              final tech = techniques[index];
              final title = locale == 'de' ? tech.titleDe : tech.titleEn;
              return Card(
                color: DsColors.bgSurface,
                margin: const EdgeInsets.only(bottom: DsSpacing.sm),
                child: ListTile(
                  title: Text(
                    title,
                    style: DsTypography.bodyLarge.copyWith(
                      color: DsColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: DsColors.textSecondary,
                  ),
                  onTap: () {
                    // Future Sprint 5: Navigate to technique detail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Technique: $title (Sprint 5)')),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: DsTypography.bodyMedium.copyWith(
              color: DsColors.stateError,
            ),
          ),
        ),
      ),
    );
  }

  String _categoryTitle(BuildContext context, String cat) {
    final t = StringsScope.maybeOrDefault(context);
    switch (cat) {
      case 'takedown':
        return t.isDe ? 'Würfe' : 'Takedowns';
      case 'escape':
        return t.isDe ? 'Befreiungen' : 'Escapes';
      case 'sweep':
        return 'Sweeps';
      case 'guard_pass':
        return t.isDe ? 'Guard‑Pässe' : 'Guard Passes';
      case 'transition':
        return t.isDe ? 'Übergänge' : 'Transitions';
      case 'submission':
        return 'Submissions';
      default:
        return cat.toUpperCase();
    }
  }
}
