# SPRINT 1 – HANDOFF

Scope
- Navigation Shell + BottomNav + Stubs, Hide‑Rules for modal/detail routes
- Hardening: CI format/analyze/test, CodeRabbit findings fixed across Android/Linux/Windows/tests

Branch & Head
- Branch: sprint-1/navigation-shell
- Head: ed5cee3

Deliverables
- Router shell with 4 tabs: /, /learn, /stats, /settings
- Modal stubs: /consent, /paywall; Hide bottom nav on modal/detail
- Widget tests: 11 tests covering start route, tab navigation, hide‑rules

CodeRabbit Fixes (applied)
1) .coderabbit.yaml
   - commit_status: true (boolean) instead of nested object
   - Path filters retained
2) Android Kotlin package
   - app/android/app/src/main/kotlin/com/example/oss/MainActivity.kt → package com.example.oss
3) Android Gradle build dir Providers
   - app/android/build.gradle.kts → use Provider-based set(...) rooted at projectDirectory
4) Linux CMake native assets copy guard
   - app/linux/CMakeLists.txt → NATIVE_ASSETS_DIR path join with '/'; guard install with if(EXISTS)
5) Router tests isolation and robustness
   - app/test/router_test.dart → per-test GoRouter instance with setUp/tearDown; import go_router; robust assertions; bottom nav onTap wired to GoRouter.of(context).go
6) Windows generated plugins
   - app/windows/flutter/generated_plugins.cmake → remove app_links, url_launcher_windows; keep sentry_flutter
7) Windows runner header safety
   - app/windows/runner/flutter_window.h → destructor "~FlutterWindow() override;"; delete copy/move ctors/assignments
8) Windows COM init lifecycle
   - app/windows/runner/main.cpp → store HRESULT from CoInitializeEx; call CoUninitialize only if SUCCEEDED(hr)

CI/QA Status
- flutter format: clean (pre-commit hook runs dart-format)
- flutter analyze: No issues found
- flutter test: All tests passed (11)
- No secrets in code; Client does not perform entitlement checks

Changed Files
- .coderabbit.yaml
- app/android/app/src/main/kotlin/com/example/oss/MainActivity.kt
- app/android/build.gradle.kts
- app/linux/CMakeLists.txt
- app/test/router_test.dart
- app/windows/flutter/generated_plugins.cmake
- app/windows/runner/flutter_window.h
- app/windows/runner/main.cpp

How to run locally
```bash path=null start=null
cd app
flutter pub get
flutter analyze
flutter test -r expanded
flutter format --set-exit-if-changed lib/ test/
```

Notes / Caveats
- zsh + paths with '!': quote the path (e.g., cd '/Volumes/…/OSS!/oss')
- Pre-commit hooks (lefthook) run dart-format; ensure staged files are formatted

Sprint 2 Kickoff (Consent + Legal + Auth)
- Create branch: sprint-2/consent-auth
- Implement consent modal + DSGVO gates for analytics; add legal links
- Setup Supabase email/password auth screens; ensure no telemetry without consent
- Update tests: consent flow; analytics gating checks

DoD References
- BMAD present in PRs; Prove: analyze/test/format green; Health endpoint unaffected
