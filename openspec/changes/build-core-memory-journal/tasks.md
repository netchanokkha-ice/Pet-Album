# Tasks

## 1. Project Foundation

- [x] 1.1 Scaffold a new Flutter application in `pawlum_flutter/` for iOS and Android, preserve the prototype/reference files, and verify the generated smoke test plus `flutter analyze` pass.
- [x] 1.2 Add and pin GetX, Supabase Flutter, Drift/SQLite, media, path, UUID, connectivity, localization, and test dependencies; commit the lockfile and verify `flutter pub get` and dependency resolution complete without errors.
- [ ] 1.3 Create the feature-first `app/`, `core/`, and feature layer boundaries with environment-driven configuration and a fake repository bootstrap; verify a unit test can launch the app shell without Supabase credentials.
- [ ] 1.4 Configure linting, generated-file exclusions, test helpers, and CI-friendly Flutter commands in the README; verify every documented setup/check command runs as written.

## 2. Secure Supabase Data Foundation

- [ ] 2.1 Scaffold repository-local Supabase configuration and create migrations for profiles, user preferences, pets, pet memberships, memories, memory versions, pet-memory relations, and memory media; verify a fresh local database applies every migration in order.
- [ ] 2.2 Add state constraints, foreign keys, uniqueness rules, lifecycle timestamps, policy-filter indexes, and client-generated UUID support; verify SQL constraint tests reject invalid ownership, version, relationship, and lifecycle states.
- [ ] 2.3 Enable RLS, revoke default `anon`/`authenticated` privileges, add explicit least-privilege grants, and implement per-operation owner policies; verify pgTAP tests cover owner allow, anonymous deny, and non-owner deny paths for every exposed table.
- [ ] 2.4 Create private pet and memory media buckets plus Storage policies for account-scoped paths and required upload/replace operations; verify authorized uploads/reads succeed and cross-user access fails in Storage policy tests.
- [ ] 2.5 Implement narrowly scoped atomic pet-initialization and memory publish/promote functions with fixed search paths, internal `auth.uid()` checks, revoked public execution, and explicit authenticated grants; verify transaction and unauthorized-call tests pass.
- [ ] 2.6 Add deterministic seed fixtures for two isolated users and representative pet/memory states, document local Supabase startup/reset commands, and verify reset plus database tests produce the same result twice.

## 3. Flutter Design System and Navigation

- [ ] 3.1 Audit reusable visual assets and font licenses from `Graphic/` and the prototype bundle, copy only approved runtime assets into Flutter, and verify every declared asset loads without pubspec warnings.
- [ ] 3.2 Implement Pawlum color, typography, spacing, surface, shadow, and motion tokens with responsive themes; verify theme unit/widget tests cover Thai fallback fonts, text scaling, and light scrapbook surfaces.
- [ ] 3.3 Implement reusable paper background, washi tape, sticker label, pet placeholder, polaroid/media card, date stamp, ribbon, buttons, skeletons, and semantic status badges; verify focused widget tests and representative golden tests pass at phone and tablet constraints.
- [ ] 3.4 Build the app shell, bottom navigation, route guards, loading/error/empty patterns, and orientation-safe route state; verify navigation widget tests cover signed-out, onboarding-required, Home, authoring, Timeline, Recently Deleted, and Settings destinations.

## 4. Account Access

- [ ] 4.1 Define account/session domain entities, failures, use cases, and repository contract with an in-memory fake; verify unit tests cover unverified, verified, expired-session, and recovery outcomes.
- [ ] 4.2 Implement the Supabase account data source for email registration, verification resend, email/password sign-in, session restoration, sign-out, and password recovery; verify adapter tests map SDK results and sanitize errors.
- [ ] 4.3 Build localized sign-up, sign-in, verification-pending, forgot-password, and recovery-result screens matching the Pawlum visual system; verify widget tests cover validation, loading, success, and non-sensitive error states.
- [ ] 4.4 Add Google OAuth entry and redirect handling behind environment configuration, including existing-account resolution; verify mocked OAuth callback tests route one verified identity to one account without duplicate journal bootstrap.
- [ ] 4.5 Connect auth state to route guards and pending-draft protection; verify an expired session preserves local draft data, requests sign-in, and resumes the queued operation only after reauthentication.

## 5. Local Draft Store and Sync Outbox

- [ ] 5.1 Implement Drift tables and migrations for account-scoped onboarding drafts, memory/edit drafts, local media references, cached published summaries, and sync operations; verify migration and restart-persistence tests pass.
- [ ] 5.2 Implement deterministic idempotency keys, operation dependencies, retry/backoff, completed-operation cleanup, and conflict preservation; verify unit tests cover restart during partial upload, duplicate retry, transient failure, and remote revision conflict.
- [ ] 5.3 Implement app-private local media handling and account-scoped cleanup rules; verify sign-out removes private cache when safe and blocks for an explicit choice when unsynced work remains.
- [ ] 5.4 Expose sync state and retry actions through domain contracts without leaking Drift or Supabase types; verify fake and local implementations pass the same repository contract test suite.

## 6. Pet Onboarding and Multi-Pet Home

- [ ] 6.1 Implement pet/profile/membership domain models, onboarding validation, and repository use cases; verify unit tests cover required fields, Other type, future dates, immutable type, and multi-pet isolation.
- [ ] 6.2 Recreate the prototype's welcome, pet info, photo, and first-memory confirmation flow with recoverable local input; verify widget tests cover forward/back navigation, restart recovery, invalid fields, and cancellation.
- [ ] 6.3 Connect onboarding confirmation to the atomic remote initializer and local retry state; verify integration tests create exactly one pet, owner membership, pet-memory relation, and editable first-memory milestone after retries.
- [ ] 6.4 Implement Home pet cards, selected-pet navigation, add-pet entry, profile name/photo editing, placeholders, and loading/empty/error states; verify multiple pets remain visually and behaviorally isolated in widget/repository tests.
- [ ] 6.5 Implement pet soft delete, seven-day Recently Deleted presentation, and restore behavior; verify active Home exclusion, countdown display, restore, and expired-item handling tests pass.

## 7. Memory Authoring and Lifecycle

- [ ] 7.1 Implement memory aggregate, version, media, presentation, and lifecycle state machines plus validation; verify unit tests cover draft, publishing, published, edit-draft, failure, soft-delete, restore, and invalid transitions.
- [ ] 7.2 Implement image/video picking, three-image/one-video limits, cover/order selection, crop/zoom/position metadata, thumbnails, and configurable validation limits; verify media tests cover valid mixed media, excess selection, unsupported files, and publish-without-media denial.
- [ ] 7.3 Recreate the four prototype authoring steps for media, decoration, story details, and publish review with responsive accessible controls; verify widget tests retain values across steps and render default presentation when decoration is skipped.
- [ ] 7.4 Connect explicit Save Draft, autosave checkpoints, unsaved-exit choices, local recovery, and pending-sync badges; verify kill/relaunch simulation restores the correct draft step and values.
- [ ] 7.5 Implement private media upload orchestration with progress, retry, checksum/idempotency reuse, and orphan-safe failure handling; verify partial upload restart completes without duplicated objects or records.
- [ ] 7.6 Implement atomic publish, edit-draft creation/resume, and Publish Changes promotion through repositories; verify integration tests keep the old published version readable until promotion succeeds.
- [ ] 7.7 Implement memory soft delete, Undo, Recently Deleted restore, and first-memory-specific warning; verify active timelines exclude deleted records and restore returns the last valid lifecycle/version state.

## 8. Journal Timeline and Memory Detail

- [ ] 8.1 Implement paginated timeline queries and mapping that order by memory date, group by year/month, include authorized draft indicators, and exclude soft-deleted/private unauthorized versions; verify repository tests cover ordering, grouping, and visibility.
- [ ] 8.2 Recreate the portrait scrapbook timeline, pet header, date groups, published cards, labeled draft cards, and edit-draft indicators; verify widget/golden tests cover mixed years, long Thai/English copy, empty state, and media errors.
- [ ] 8.3 Implement the landscape horizontal timeline with equivalent item access and retained selected-pet/orientation state; verify rotation tests move between layouts without changing the active journal.
- [ ] 8.4 Implement Memory Detail for the published version and resume routing for drafts/edit drafts; verify tests show the correct version and prevent a working version from replacing published content.
- [ ] 8.5 Add lazy loading, skeletons, retryable page errors, and bounded summary cache behavior; verify a failed next page leaves existing memories visible and succeeds after retry.

## 9. Preferences and Localization

- [ ] 9.1 Create complete Thai and English ARB resources for all Phase 1 screens, validation, errors, accessibility labels, and emotional states; verify localization generation succeeds and a missing-key check reports no gaps.
- [ ] 9.2 Implement device-locale defaulting plus local-first and remote account preference persistence; verify launch, relaunch, and cross-device repository tests apply the expected language without flashing the wrong locale.
- [ ] 9.3 Implement basic Settings with account information, applicable password actions, language selection, Recently Deleted entry, and sign-out; verify deferred Phase 2 controls are not presented as functional and Google-only accounts omit password-change UI.

## 10. Integrated Phase 1 Verification

- [ ] 10.1 Run a fake-backend end-to-end Flutter test covering sign-in, onboarding, second pet creation, offline draft recovery, publish, timeline/detail, edit-draft promotion, delete, restore, language change, and sign-out; verify the full scenario passes deterministically.
- [ ] 10.2 Run the same critical account/pet/memory flow against a reset local Supabase stack, including RLS negative cases and private media access; verify database, Storage, and Flutter integration checks all pass.
- [ ] 10.3 Run formatting, code generation, `flutter analyze`, the full Flutter test suite, strict OpenSpec validation, and Android/web preview builds; record any iOS-only configuration still requiring Apple tooling or credentials.
- [ ] 10.4 Update project documentation with architecture, environment variables, local Supabase workflow, OAuth/deep-link setup, test commands, data privacy assumptions, and deferred Phase 2 boundaries; verify a clean-machine setup can follow the documented path without hidden secrets.

## Workflow follow-up

- Review the Phase 1 behavior and Supabase policy evidence before connecting production credentials.
- Archive the change only after implementation and verification requirements are satisfied.
