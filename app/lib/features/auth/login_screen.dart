import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/strings/auth_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/navigation/routes.dart';

/// Login Screen (Sprint 2).
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _loading = true);

    final result = await widget.authService.signIn(
      email: email,
      password: password,
    );

    setState(() => _loading = false);

    if (result.isSuccess && mounted) {
      context.go(AppRoutes.homePath);
    } else if (result.isFailure && mounted) {
      _showError(result.error ?? AuthStrings.errGeneric);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                AuthStrings.loginHeadline,
                style: DsTypography.headlineLarge.copyWith(
                  color: DsColors.textPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.xs),
              Text(
                AuthStrings.loginSubhead,
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
              const SizedBox(height: DsSpacing.md),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: AuthStrings.passwordHint,
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: DsSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.resetPasswordPath),
                  child: const Text(AuthStrings.loginForgot),
                ),
              ),
              const SizedBox(height: DsSpacing.md),
              ElevatedButton(
                onPressed: _loading ? null : _handleLogin,
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
                    : const Text(AuthStrings.loginCta),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signupPath),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
