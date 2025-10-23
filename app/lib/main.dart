import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'router.dart';

void main() {
  runApp(const OssApp());
}

/// OSS App entry point.
class OssApp extends StatelessWidget {
  const OssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OSS',
      theme: AppTheme.buildDarkTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
