import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/strings/auth_strings.dart';
import '../../core/services/auth_service.dart';

/// Reset Password Screen (Sprint 2).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError(AppStrings.ctaContinue);
      return;
    }

    if (!_isValidEmail(email)) {
      _showError(AuthStrings.errEmailInvalid);
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.authService.resetPassword(email: email);
      setState(() => _loading = false);

      if (mounted) {
        _showSuccess(AuthStrings.successSubhead);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError(AppStrings.resetErrorGeneric);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DsColors.bgSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AuthStrings.forgotHeadline,
                style: DsTypography.headlineLarge.copyWith(
                  color: DsColors.textPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.xs),
              Text(
                AuthStrings.forgotSubhead,
                style: DsTypography.bodyMedium.copyWith(
                  color: DsColors.textSecondary,
                ),
              ),
              const SizedBox(height: DsSpacing.xl),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: AuthStrings.emailHint,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: DsSpacing.lg),
              ElevatedButton(
                onPressed: _loading ? null : _handleReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DsColors.brandRed,
                  foregroundColor: DsColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: DsSpacing.md,
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DsColors.textPrimary,
                        ),
                      )
                    : const Text(AuthStrings.forgotCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
