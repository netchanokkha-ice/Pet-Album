# Design

## Context

See `proposal.md` for motivation and the capability specs for behavior contracts. The workspace contains a PRD/SRS, design assets, a standalone React clickable prototype, and prototype JSX inside `Pawlum.zip`; there is no current unpacked application source to preserve. Implementation therefore starts a new Flutter project and treats the prototype as a read-only interaction and visual reference.

The design must support a useful offline-tolerant Phase 1 while avoiding data-model replacement when collaboration, bearer-link sharing, recap generation, administration, or ownership transfer is added. Pet photos and stories are private user content, so authorization must be enforced below the Flutter UI.

## Goals / Non-Goals

**Goals:**

- Keep Flutter presentation replaceable and testable by depending on domain contracts rather than backend SDK calls.
- Make Postgres the durable source of truth while preserving unfinished local work through restarts and transient failures.
- Establish secure ownership, membership, versioning, many-to-many pet relationships, and private media paths needed by later phases.
- Reproduce the prototype's warm scrapbook language, core routes, four-step authoring flow, and portrait/landscape journal experience with responsive Flutter widgets.
- Make schema, policies, Storage configuration, and seeds reproducible and testable from repository files.

**Non-Goals:**

- Offline editing by multiple devices with automatic conflict merging; Phase 1 preserves conflicts for explicit resolution.
- Public or bearer-link data access, contributor UI, recap jobs, push notifications, ownership transfer, admin tooling, or payments.
- Pixel-for-pixel reuse of prototype JSX; Flutter reimplements the behavior and visual system.
- Provisioning or storing hosted Supabase secrets in source control.

## Decisions

### 1. Use a feature-first Flutter architecture with explicit layers

Create `pawlum_flutter/` with `app/`, `core/`, and feature folders for auth, onboarding/pets, memories, timeline, recently-deleted, and settings. Each feature separates presentation, domain, and data responsibilities. GetX owns navigation, dependency bindings, and screen controllers because it matches the project context, but controllers call use cases/repositories and never query Supabase directly.

Domain entities and repository interfaces remain plain Dart. Data implementations map between domain objects, local Drift rows, and Supabase DTOs. This makes unit tests independent of plugins and lets a future REST/Edge Function gateway replace direct Data API access without changing screens.

Alternatives considered:

- A screen-first app with Supabase calls in controllers is faster initially but makes policy, retry, and later API changes leak through every screen.
- Riverpod or BLoC could provide similar boundaries, but adding a second state-management convention offers no Phase 1 benefit.

### 2. Use Supabase as the hosted platform, with explicit exposure and least privilege

Supabase provides Auth, Postgres, generated Data API, and private Storage behind one user session. Flutter uses the current `supabase_flutter` client through data-source adapters. New tables do not rely on automatic Data API exposure: every migration enables RLS, revokes broad grants, and grants only required operations to `authenticated`; `anon` receives no journal-table access.

Every table receives separate SELECT/INSERT/UPDATE/DELETE policies as applicable, with both `USING` and `WITH CHECK` for updates. Policy filter columns are indexed. Authorization uses `auth.uid()` and database relationships, never user-editable metadata. RLS tests assert allowed owner actions and denied non-owner/anonymous actions.

Alternatives considered:

- Firebase is strong for mobile and push notifications, but the relational permission graph, versioned memories, many-to-many pets, auditability, and future admin reporting map more directly to Postgres.
- A custom API server provides maximum control but adds deployment and authentication work before core product validation. Privileged workflows can be introduced later as Edge Functions or a dedicated service behind the same repository contracts.

### 3. Establish a future-compatible relational model now

Core tables:

- `profiles`: application profile keyed to the authenticated user.
- `user_preferences`: language and future preference columns/JSON, one row per user.
- `pets`: stable pet identity, current `owner_user_id`, profile fields, lifecycle timestamps.
- `pet_memberships`: `(pet_id, user_id)`, role, capability flags, status, and timestamps. Phase 1 creates only the active owner row; later phases add contributor/view-only behavior.
- `memories`: stable memory identity, creator, lifecycle status, privacy, current published/working version references, and deletion timestamps.
- `memory_versions`: immutable-or-promotable content snapshots containing title, caption, memory date, mood, location, occasion, decoration/layout JSON, and version state.
- `pet_memories`: many-to-many relation between memories and pets.
- `memory_media`: media identity, owning version, private object path, type, order, thumbnail path, crop/zoom/position JSON, upload state, and checksums.
- `sync_operations`: local-only Drift queue, not a remote table, containing idempotency keys and retry metadata.

Use UUIDs generated client-side for draftable aggregates so local and remote identity is stable across retries. Use database constraints for allowed states, one active owner membership, valid version references, and media limits where practical. Store presentation geometry as versioned JSON with a schema version; keep queryable authorization and lifecycle fields relational.

`privacy` includes future values but Phase 1 defaults newly authored memories to `only_me`. The later sharing phase must explicitly decide whether the PRD's `anyone_with_link` default is compatible with the product's private-first promise before enabling link creation.

Alternatives considered:

- One large `memories` row with draft fields is simpler but cannot keep a stable published view during edits.
- Pre-creating shared-link, transfer, recap, notification, and admin tables now would encode unresolved behavior. Only the relationships that protect Phase 1 migration paths are created.

### 4. Use controlled database functions only for atomic aggregate transitions

Pet initialization and publish/promote operations span multiple rows and must be atomic. Implement narrowly scoped Postgres functions in a non-exposed schema only where a single Data API mutation cannot preserve invariants. If `SECURITY DEFINER` is required, each function uses a fixed safe `search_path`, checks `auth.uid()` internally, revokes execution from `PUBLIC`/`anon`, and grants only the named operation to `authenticated`.

Ordinary CRUD stays under RLS through the Data API. No service-role or secret key is shipped to Flutter.

Alternatives considered:

- Client-side multi-call orchestration can leave partial pets or publications after interruption.
- Making all operations privileged functions would create an unnecessary custom API surface and concentrate authorization risk.

### 5. Keep media private and separate logical state from upload state

Use private Storage buckets for pet profile and memory media. Object paths include the authenticated owner scope and stable aggregate/version identifiers. The app requests short-lived authorized URLs for display and stores object paths, never permanent public URLs, in domain records.

The authoring state machine tracks local-selected, queued, uploading, uploaded, failed, and removed media. A memory version is promoted only when required media is uploaded and validated. File type, count, and configurable size/duration limits are checked before upload; server-side policies remain the final authority.

### 6. Use Drift for local draft recovery and an idempotent outbox

Drift stores account-scoped onboarding state, memory/edit drafts, local media references, and pending operations in the app-private directory. Repository writes update local working state first, then enqueue a deterministic remote operation. Successful sync records remote revision/timestamp and clears completed queue entries; failed operations retain actionable error and retry state.

The outbox is intentionally narrow: it protects drafts and uploads rather than mirroring the entire remote journal. Published reads remain remote-first with bounded cached display data. A server revision mismatch preserves the local working copy and surfaces a conflict instead of overwriting.

Alternatives considered:

- Shared preferences/JSON is insufficient for related media, retries, migrations, and conflict metadata.
- Full offline-first replication adds conflict and cache invalidation complexity beyond Phase 1.

### 7. Model authoring and publication as explicit state machines

Memory aggregate states are `draft`, `publishing`, `published`, `publish_failed`, `soft_deleted`, and `purged`; a published memory may reference a separate `edit_draft` version. UI controllers derive allowed actions from domain state rather than scattered booleans. Publish and promote commands are idempotent and return the authoritative aggregate.

Pet creation likewise moves from local onboarding draft to one atomic initialized remote aggregate containing the owner membership and first-memory milestone.

### 8. Rebuild the prototype as a reusable Flutter design system

Extract tokens for cream/pink/purple/yellow/mint colors, paper surfaces, ink colors, radii, spacing, shadows, and typography. Use bundled/local font assets where licensing permits; retain the prototype's Thai-friendly handwritten hierarchy and provide system-font fallback. Reusable widgets include paper background, washi tape, sticker label, pet placeholder, polaroid/media card, date stamp, ribbon, primary/ghost buttons, bottom navigation, loading skeletons, and semantic state badges.

The route map covers account access, four onboarding steps, Home, Timeline, landscape Timeline, Memory Detail, four authoring steps, Recently Deleted, and Settings. Responsive widgets use available constraints rather than fixed 390x844 coordinates. Accessibility semantics, minimum touch targets, text scaling, and non-color state indicators are part of each component.

### 9. Use Flutter localization generation and environment-defined configuration

Store Thai and English strings in ARB resources and generate typed localization accessors. Device locale selects the first default; the account preference overrides it after authentication.

Supabase URL and publishable key enter builds through environment/dart defines and documented example configuration. Secrets and service-role keys never enter the mobile project. Package identifiers, signing, hosted URLs, and OAuth redirect values remain deployment configuration.

### 10. Test behavior at each boundary

- Plain Dart unit tests cover state transitions, validation, date ordering, idempotency decisions, and repository contracts.
- Widget tests cover prototype-derived screens, Thai/English rendering, accessibility semantics, navigation, draft warnings, and loading/error states.
- Integration tests cover local recovery and repository behavior against fakes, then an opt-in local Supabase environment.
- SQL migrations include pgTAP policy/constraint tests for anonymous denial, owner allow paths, non-owner denial, and atomic functions.
- Golden tests protect a small set of stable core screens rather than every dynamic layout.

## Risks / Trade-offs

- [Phase 1 is still large] -> Deliver in vertical slices that end in tested user value: shell/design system, auth, pet onboarding, authoring, timeline, recovery/settings.
- [Direct Data API usage can expose tables when grants or RLS are wrong] -> Enable RLS and explicit grants in the same migration, add deny tests, and run database advisors before hosted deployment.
- [Membership-aware policies can become recursive] -> Keep Phase 1 owner checks direct and introduce reviewed helper functions for later membership rules instead of policies that read each other.
- [Client-generated UUIDs and retries can leave orphaned uploads] -> Use idempotency keys, checksums, aggregate ownership paths, and a cleanup job/interface for unattached expired objects.
- [Local draft database contains private content] -> Use app-private storage, account scoping, platform protection, controlled sign-out cleanup, and no service credentials.
- [Prototype uses fixed phone dimensions and illustrative assets] -> Preserve visual intent through responsive components and verify representative device sizes rather than copying coordinates.
- [Supabase hosted configuration is not yet available] -> Build against fakes/local configuration first; keep hosted connection values external and document the exact handoff needed.
- [Video limits and processing cost are unresolved] -> Make limits configuration-driven; Phase 1 supports upload/playback metadata but does not perform server-generated slideshow or advanced transcoding.

## Migration Plan

1. Scaffold the Flutter and Supabase directories without modifying the reference prototype.
2. Add migrations, grants, RLS, Storage policies, seeds, and database tests; verify against a local Supabase stack when available.
3. Build the Flutter shell, design system, localization, domain contracts, fake repositories, and local Drift store.
4. Implement and verify vertical slices in dependency order, then connect production repositories to Supabase.
5. Configure a hosted development project through environment values and OAuth redirect settings; run policy tests and end-to-end smoke flows before release configuration.
6. Rollback application releases by redeploying the last compatible build. Database migrations are forward-corrected; destructive schema removal is avoided until a later migration confirms no supported client depends on it.

## Open Questions

- Final iOS/Android application identifiers, signing teams, and store metadata can be supplied before release builds.
- Hosted Supabase organization/project and OAuth credentials can be connected after local/fake flows pass.
- Initial configurable video size and duration defaults can be tightened after device and cost testing without changing the data model.
