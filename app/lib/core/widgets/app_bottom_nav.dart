import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/routes.dart';
import '../design_tokens/colors.dart';
import '../l10n/strings.dart';

/// Bottom navigation bar for main app tabs.
///
/// Displays 4 tabs: Home, Learn, Stats, Settings.
/// Active state: visual highlight + bold text.
/// Touch targets: ≥ 44×44 pt (A11y requirement).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentLocation,
  });

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return Container(
      height: 64, // Sufficient for touch targets + padding
      decoration: const BoxDecoration(
        color: DsColors.bgSurface,
        border: Border(
          top: BorderSide(color: DsColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: t.tabHome,
            icon: Icons.home_outlined,
            route: AppRoutes.homePath,
            isActive: currentLocation == AppRoutes.homePath,
          ),
          _NavItem(
            label: t.tabLearn,
            icon: Icons.school_outlined,
            route: AppRoutes.learnPath,
            isActive: currentLocation == AppRoutes.learnPath,
          ),
          _NavItem(
            label: t.tabStats,
            icon: Icons.bar_chart_outlined,
            route: AppRoutes.statsPath,
            isActive: currentLocation == AppRoutes.statsPath,
          ),
          _NavItem(
            label: t.tabSettings,
            icon: Icons.settings_outlined,
            route: AppRoutes.settingsPath,
            isActive: currentLocation == AppRoutes.settingsPath,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.isActive,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: label,
        selected: isActive,
        button: true,
        child: InkWell(
          onTap: () => context.go(route),
          child: Container(
            constraints:
                const BoxConstraints(minHeight: 48), // Touch target ≥44
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? DsColors.brandPrimary : DsColors.textMuted,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? DsColors.textPrimary : DsColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
