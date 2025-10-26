import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/strings.dart';

/// Paywall Modal (Sprint 1 stub).
///
/// Future (Sprint 8): RevenueCat products, prices, restore purchases.
class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.paywallTitle),
        backgroundColor: DsColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Paywall Modal\n(Sprint 1 stub)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: DsColors.textSecondary),
        ),
      ),
    );
  }
}
