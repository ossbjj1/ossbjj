import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/strings/auth_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/navigation/routes.dart';

/// Signup Screen (Sprint 2).
class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _hasPasswordComplexity(String password) {
    // Require at least 8 chars and 3 of: uppercase, lowercase, digit, special
    if (password.length < 8) return false;
    int classCount = 0;
    if (RegExp(r'[A-Z]').hasMatch(password)) classCount++;
    if (RegExp(r'[a-z]').hasMatch(password)) classCount++;
    if (RegExp(r'[0-9]').hasMatch(password)) classCount++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) classCount++;
    return classCount >= 3;
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError(AuthStrings.errEmailInvalid);
      return;
    }

    if (!_hasPasswordComplexity(password)) {
      _showError(
          'Password must be 8+ chars with uppercase, lowercase, digit, and special character');
      return;
    }

    setState(() => _loading = true);

    final result = await widget.authService.signUp(
      email: email,
      password: password,
    );

    setState(() => _loading = false);

    if (result.isSuccess && mounted) {
      _showSuccess('Account created! Check your email to verify.');
      context.go(AppRoutes.onboardingPath);
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

  void _showSuccess(String message) {
    if (!mounted) return;
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
                AuthStrings.signupHeadline,
                style: DsTypography.headlineLarge.copyWith(
                  color: DsColors.textPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.xs),
              Text(
                AuthStrings.signupSubhead,
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
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: DsSpacing.lg),
              ElevatedButton(
                onPressed: _loading ? null : _handleSignup,
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
                    : const Text(AuthStrings.signupCta),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.loginPath),
                    child: const Text('Log In'),
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
