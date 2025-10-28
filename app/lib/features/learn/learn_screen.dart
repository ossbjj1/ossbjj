import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/strings.dart';
import 'state/providers.dart';

/// Learn Screen (Sprint 4): Categories grid.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StringsScope.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navTitleLearn),
        backgroundColor: DsColors.bgSurface,
      ),
      body: categoriesAsync.when(
        data: (categories) => GridView.builder(
          padding: const EdgeInsets.all(DsSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: DsSpacing.md,
            mainAxisSpacing: DsSpacing.md,
            childAspectRatio: 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(
              category: category,
              onTap: () => context.go('/learn/category/$category'),
            );
          },
        ),
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
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DsColors.bgSurface,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            _categoryLabel(context, category),
            style: DsTypography.headlineSmall.copyWith(
              color: DsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _categoryLabel(BuildContext context, String cat) {
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
