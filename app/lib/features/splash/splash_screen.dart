import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/consent_service.dart';
import '../../core/services/auth_service.dart';

/// Simple Splash Screen (2s) showing logo then routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.consentService,
    required this.authService,
    required this.forceOnboarding,
  });

  final ConsentService consentService;
  final AuthService authService;
  final bool forceOnboarding;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    // Navigate after a short delay to allow splash to be visible
    Timer(const Duration(milliseconds: 1500), _navigateNext);
  }

  void _navigateNext() {
    final user = widget.authService.currentUser;
    if (user == null) {
      context.go(AppRoutes.loginPath);
      return;
    }
    if (!widget.consentService.shown) {
      context.go(AppRoutes.consentPath);
      return;
    }
    if (widget.forceOnboarding) {
      context.go(AppRoutes.onboardingPath);
      return;
    }
    context.go(AppRoutes.homePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.bgSurface,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: SizedBox(
            width: 180,
            height: 180,
            child: Image.asset(
              'assets/images/splash_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.sports_martial_arts,
                  size: 96, color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
