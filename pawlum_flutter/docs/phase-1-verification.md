# Phase 1 verification record

Verified on 2026-11-01 from Windows 11 with Flutter 3.44.8, Dart 3.12.2,
Microsoft OpenJDK 17.0.21, Android SDK 36.0.0, and a reset local Supabase stack.

| Check | Command | Result |
| --- | --- | --- |
| Formatting | `dart format --output=none --set-exit-if-changed lib test` | Passed |
| Localization generation | `flutter gen-l10n` | Passed |
| Drift/code generation | `dart run build_runner build` | Passed |
| Static analysis | `flutter analyze` | Passed with no issues |
| Full Flutter suite | `flutter test` | Passed: 122 tests, 1 opt-in test skipped |
| Fake end-to-end | `flutter test test/core_memory_journal_fake_e2e_test.dart` | Passed |
| Local Supabase integration | Local integration test with local defines | Passed |
| Database/RLS/Storage | `supabase test db --local` | Passed: 116 pgTAP assertions |
| OpenSpec | `openspec validate build-core-memory-journal --strict` | Passed |
| Web preview | `flutter build web` | Passed |
| Android preview | `flutter build apk --debug` | Passed; `build/app/outputs/flutter-apk/app-debug.apk` |

On Windows the Android build used an ASCII `P:` drive mapping because the
repository path contains an emoji. Kotlin incremental compilation is disabled
in `android/gradle.properties` so plugin sources on `C:` can compile while the
repository is mapped to another drive.

## iOS-only follow-up

An iOS archive was not produced because Apple tooling is unavailable on
Windows. Before TestFlight/App Store delivery:

1. Use macOS with a Flutter-compatible Xcode, accept its license, and install
   CocoaPods if `flutter doctor` requests it.
2. Open `ios/Runner.xcworkspace`, choose the Apple Developer Team, and confirm
   certificates/provisioning for `com.pawlum.pawlum` or the final bundle ID.
3. Keep `pawlum` in `CFBundleURLSchemes` and allow-list
   `pawlum://login-callback` in Supabase Auth.
4. Add the iOS Google OAuth client/reversed scheme only if the selected provider
   integration requires it; never store a Google client secret in source.
5. Add Associated Domains only if a later change adopts HTTPS universal links.
   Phase 1 does not require APNs.
6. Run `flutter build ios --debug --no-codesign`, then a signed archive/device
   smoke test with real Apple credentials.

No Apple certificate, provisioning profile, Google client secret, hosted
Supabase secret, or `service_role` credential belongs in this repository.
