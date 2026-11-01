# Feature boundaries

Each feature owns `data/`, `domain/`, and `presentation/` layers. Presentation
may depend on domain contracts; data implements those contracts; domain remains
plain Dart and does not import Flutter, GetX, Drift, or Supabase.

Phase 1 feature roots are `account_access`, `pet_profiles`, `memory_authoring`,
`memory_timeline`, `recently_deleted`, and `app_preferences`. The `app_shell`
feature is the first vertical slice and proves the dependency direction with an
in-memory repository.
