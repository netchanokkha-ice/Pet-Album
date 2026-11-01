# Pawlum Flutter

Pawlum is a private Thai/English pet-memory journal for iOS and Android. The
Flutter application is isolated from Supabase and Drift behind domain
repositories so fake data can drive local development and tests.

## Requirements

- Flutter 3.44.8 or a compatible stable release
- Dart 3.12.2 or a compatible Dart 3 release
- Xcode for iOS builds
- Android Studio or the Android command-line tools for Android builds

## Environment

The app defaults to fake repositories and can launch without credentials. The
hosted project URL defaults to `https://projowodlrydgzexcald.supabase.co`;
provide its publishable key only at build time.

```text
--dart-define=APP_ENV=development
--dart-define=USE_FAKE_REPOSITORIES=true
--dart-define=SUPABASE_URL=https://projowodlrydgzexcald.supabase.co
--dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Never use a Supabase secret or `service_role` key in a mobile build.

## Setup

Run from `pawlum_flutter/`:

```powershell
flutter pub get
dart run build_runner build
```

## Checks

These commands are non-interactive and suitable for CI:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Local Supabase

Run these commands from the workspace root. Docker Desktop must be running.
The local stack is development-only and must not be exposed to external
traffic.

```powershell
npx --yes supabase@latest start
npx --yes supabase@latest db reset --local
npx --yes supabase@latest test db --local
npx --yes supabase@latest db advisors --local --type all --level info --fail-on none
```

`db reset` recreates the local database, applies every migration in order, and
loads `supabase/seed.sql`. The seed contains two deterministic placeholder Auth
users with isolated journals: Alice has a published memory plus an edit draft,
while Bob has a draft with queued media. The accounts have no passwords and
cannot sign in; create login-capable local users through Auth when interactive
testing requires them.

Local service URLs use the ports in `supabase/config.toml`: API `54321`,
database `54322`, Studio `54323`, and local mail UI `54324`. To stop the stack
without deleting local data:

```powershell
npx --yes supabase@latest stop
```

When the workspace path contains non-ASCII emoji and a Windows Flutter analysis
server cannot parse it, map the workspace to an ASCII drive letter and run the
same commands from that drive. This is a tooling-path workaround; it does not
change source files.

## Structure

- `lib/app/`: composition, GetX bindings, and routes
- `lib/core/`: cross-feature configuration and infrastructure
- `lib/features/`: feature-owned data, domain, and presentation layers
- `test/helpers/`: reusable app and repository test harnesses

Supabase Auth, Postgres/RPC, and private Storage are accessed through adapters;
RLS is the authorization boundary. Drift stores account-scoped drafts, local
media references, preferences, bounded caches, and an idempotent sync outbox.
The default executable is intentionally fake-first; the opt-in local-stack test
exercises the real Supabase adapters without requiring hosted credentials.

## Clean-machine setup

Install Git, Flutter 3.44.8 (Dart 3.12.2), Node.js/npm, Docker Desktop, and
Chrome. Android builds additionally need JDK 17, accepted Android licenses,
platforms 35/36, Build Tools 36.0.0, NDK 28.2.13676358, and CMake 3.22.1. iOS
builds require macOS with Xcode and any CocoaPods version requested by
`flutter doctor`.

```powershell
cd pawlum_flutter
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run --dart-define=USE_FAKE_REPOSITORIES=true
```

No secret is needed for that path. Configuration comes only from documented
`--dart-define` values; the repository does not depend on a hidden `.env` file.

| Define | Default | Meaning |
| --- | --- | --- |
| `APP_ENV` | `development` | `development`, `staging`, or `production` |
| `USE_FAKE_REPOSITORIES` | `true` | Declares deterministic fake-mode intent |
| `SUPABASE_URL` | hosted Pawlum URL | Hosted or local Data API base URL |
| `SUPABASE_PUBLISHABLE_KEY` | empty | Client-safe publishable/anon key only |
| `GOOGLE_OAUTH_ENABLED` | `false` | Enables the Google OAuth entry |
| `OAUTH_REDIRECT_URL` | `pawlum://login-callback` | Mobile OAuth return URL |

Use the publishable key printed by `supabase status` or a deployment secret
store. Never commit hosted credentials or place a `service_role` key in a
Flutter build.

To run the real local boundary test after `supabase start`/`status`:

```powershell
cd pawlum_flutter
flutter test test/local_supabase_stack_integration_test.dart `
  --dart-define=LOCAL_SUPABASE_URL=http://127.0.0.1:54321 `
  --dart-define=LOCAL_SUPABASE_KEY=<key-from-supabase-status>
```

Without both defines the test is intentionally skipped. `db reset --local` is
destructive to local-only data: it reapplies every migration and seed.

## OAuth and deep links

1. Create Google OAuth credentials and add the Supabase provider callback
   `https://<project-ref>.supabase.co/auth/v1/callback` in Google Cloud.
2. Enable Google under Supabase Authentication > Providers and keep the Google
   client secret in the provider dashboard, not this repository.
3. Allow-list `pawlum://login-callback` in Supabase Authentication redirects.
4. Build with `GOOGLE_OAUTH_ENABLED=true` and the matching
   `OAUTH_REDIRECT_URL=pawlum://login-callback`.

Android already has a browsable `pawlum` / `login-callback` intent filter and
iOS already declares the `pawlum` URL scheme. Production web OAuth should use
an allow-listed HTTPS origin instead of this mobile custom scheme.

## Privacy and Phase 2 boundary

- Anonymous journal access is denied; account/pet membership RLS protects data.
- Media buckets are private and use short-lived authorized URLs, not permanent
  public URLs.
- New memories default to `only_me`; working versions remain private until
  explicitly promoted.
- Pets and memories are soft-deleted and recoverable for seven days.
- Local drafts are app-private and account-scoped; sign-out retains only
  explicitly recoverable unsynced work.

Public/bearer links, non-owner contributors, comments, recaps, notifications,
ownership transfer, admin/support tooling, monetization, and physical products
remain deferred. Sharing/collaboration belongs to the separate
`build-private-sharing-collaboration` change.

The complete verification matrix and Apple-only follow-up are recorded in
[`docs/phase-1-verification.md`](docs/phase-1-verification.md).
