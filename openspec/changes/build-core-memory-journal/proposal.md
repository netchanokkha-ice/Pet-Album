# Proposal

## Why

Pawlum currently exists as a product requirements draft and a clickable React prototype, but not as a maintainable production application. Phase 1 establishes the core pet-memory journal as a new Flutter application while creating a secure data and API foundation that later sharing, contributor, recap, administration, and ownership-transfer features can extend without replacing the core model.

## What Changes

- Create a new Flutter mobile application for iOS and Android, using the supplied prototype as the visual and interaction reference.
- Add email/password and Google account access, email verification, session restoration, and password-reset entry points.
- Implement emotional onboarding and multi-pet profile management, including the automatic first-memory milestone.
- Implement the four-step memory creation flow with image/video selection, metadata, presentation choices, draft saving, publishing, editing, soft deletion, restoration, and unsaved-change protection.
- Implement home, pet cards, portrait timeline, landscape timeline, memory detail, and basic account/app settings in Thai and English.
- Add Supabase Auth, Postgres, Storage, explicit Data API grants, and Row Level Security as the production backend foundation.
- Isolate Flutter presentation and domain logic from Supabase behind repositories and data sources so APIs and persistence can evolve independently.
- Model pet membership, memory authorship, memory-to-pet relationships, published/edit-draft versions, media metadata, privacy state, and deletion lifecycle now, while deferring later-phase user experiences.
- Add local draft recovery and retryable upload/sync states so unstable connectivity does not silently lose journal work.
- Defer shared links, contributors beyond the owner membership, recap/slideshow generation, notifications, ownership transfer, support/admin web, monetization, and physical-product workflows.

## Capabilities

### New Capabilities

- `account-access`: User registration, verification, sign-in, session handling, and password recovery behavior.
- `pet-profiles`: Multi-pet onboarding, profile management, and first-memory milestone behavior.
- `memory-authoring`: Memory media, metadata, decoration, draft, publish, edit-draft, and deletion behavior.
- `memory-timeline`: Home, pet selection, timeline ordering/orientation, memory detail, and visibility behavior.
- `journal-data-foundation`: Durable ownership, membership, versioning, media persistence, local recovery, API authorization, and future-compatible data boundaries.
- `app-preferences`: Basic account settings, Thai/English language selection, and persisted user preferences.

### Modified Capabilities

None. The project has no existing durable OpenSpec capabilities.

## Impact

- New Flutter source project under `pawlum_flutter/` with mobile platform configuration, feature modules, tests, and generated lockfiles.
- New Supabase project structure containing reproducible migrations, RLS policies, Storage policies, seeds, and database policy tests; connecting to a hosted Supabase project remains environment-configured.
- New dependencies for Flutter state/navigation, Supabase, media picking, localization, local draft persistence, and testing.
- The supplied standalone HTML/ZIP prototype remains a read-only design reference and is not used as the runtime application.
- Phase 1 establishes identifiers and relationship tables needed by later phases but does not expose deferred capabilities in the UI or public API.
