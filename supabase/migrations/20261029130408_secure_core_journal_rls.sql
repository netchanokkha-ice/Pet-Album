-- Opt repository-managed API tables out of broad platform defaults.
alter default privileges for role postgres in schema public
  revoke select, insert, update, delete on tables from anon, authenticated;

alter default privileges for role postgres in schema public
  revoke execute on functions from public, anon, authenticated;

revoke all privileges on table
  public.profiles,
  public.user_preferences,
  public.pets,
  public.pet_memberships,
  public.memories,
  public.memory_versions,
  public.pet_memories,
  public.memory_media
from public, anon, authenticated;

grant usage on schema public to authenticated;

grant select, insert on public.profiles to authenticated;
grant update (display_name, avatar_object_path, updated_at)
  on public.profiles to authenticated;

grant select, insert on public.user_preferences to authenticated;
grant update (language_code, preferences, updated_at)
  on public.user_preferences to authenticated;

grant select on public.pets to authenticated;
grant update (
  name,
  custom_type_label,
  profile_image_object_path,
  birth_date,
  first_met_date,
  updated_at,
  deleted_at,
  deletion_expires_at
) on public.pets to authenticated;

grant select on public.pet_memberships to authenticated;

grant select, insert on public.memories to authenticated;
grant update (
  lifecycle_status,
  privacy,
  current_published_version_id,
  current_working_version_id,
  updated_at,
  published_at,
  deleted_at,
  deletion_expires_at,
  purged_at,
  pre_deletion_status
) on public.memories to authenticated;

grant select, insert on public.memory_versions to authenticated;
grant update (
  version_state,
  title,
  caption,
  memory_date,
  mood,
  location,
  occasion,
  theme_key,
  template_key,
  layout_key,
  decoration_data,
  layout_data,
  presentation_schema_version,
  updated_at,
  published_at
) on public.memory_versions to authenticated;

grant select, insert, delete on public.pet_memories to authenticated;

grant select, insert, delete on public.memory_media to authenticated;
grant update (
  object_path,
  thumbnail_object_path,
  media_type,
  sort_order,
  is_cover,
  mime_type,
  byte_size,
  pixel_width,
  pixel_height,
  duration_ms,
  presentation_data,
  upload_state,
  checksum_sha256,
  updated_at
) on public.memory_media to authenticated;

alter table public.profiles enable row level security;
alter table public.user_preferences enable row level security;
alter table public.pets enable row level security;
alter table public.pet_memberships enable row level security;
alter table public.memories enable row level security;
alter table public.memory_versions enable row level security;
alter table public.pet_memories enable row level security;
alter table public.memory_media enable row level security;

-- These helpers bypass RLS only to resolve the ownership graph. They always bind
-- the decision to the caller's auth.uid(), live in a non-exposed schema, and are
-- executable only while evaluating authenticated policies.
create or replace function private.is_pet_owner(target_pet_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select auth.uid()) is not null
    and exists (
      select 1
      from public.pets
      where id = target_pet_id
        and owner_user_id = (select auth.uid())
    );
$$;

create or replace function private.is_memory_owner(target_memory_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select auth.uid()) is not null
    and (
      exists (
        select 1
        from public.pet_memories as relation
        join public.pets as pet on pet.id = relation.pet_id
        where relation.memory_id = target_memory_id
          and pet.owner_user_id = (select auth.uid())
      )
      or (
        exists (
          select 1
          from public.memories as memory
          where memory.id = target_memory_id
            and memory.creator_user_id = (select auth.uid())
        )
        and not exists (
          select 1
          from public.pet_memories as relation
          where relation.memory_id = target_memory_id
        )
      )
    );
$$;

create or replace function private.is_version_owner(target_version_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.memory_versions as version
    where version.id = target_version_id
      and private.is_memory_owner(version.memory_id)
  );
$$;

revoke all on function private.is_pet_owner(uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.is_memory_owner(uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.is_version_owner(uuid)
  from public, anon, authenticated, service_role;

grant execute on function private.is_pet_owner(uuid) to authenticated;
grant execute on function private.is_memory_owner(uuid) to authenticated;
grant execute on function private.is_version_owner(uuid) to authenticated;

create policy profiles_owner_select
on public.profiles for select to authenticated
using ((select auth.uid()) is not null and user_id = (select auth.uid()));

create policy profiles_owner_insert
on public.profiles for insert to authenticated
with check ((select auth.uid()) is not null and user_id = (select auth.uid()));

create policy profiles_owner_update
on public.profiles for update to authenticated
using ((select auth.uid()) is not null and user_id = (select auth.uid()))
with check ((select auth.uid()) is not null and user_id = (select auth.uid()));

create policy user_preferences_owner_select
on public.user_preferences for select to authenticated
using ((select auth.uid()) is not null and user_id = (select auth.uid()));

create policy user_preferences_owner_insert
on public.user_preferences for insert to authenticated
with check ((select auth.uid()) is not null and user_id = (select auth.uid()));

create policy user_preferences_owner_update
on public.user_preferences for update to authenticated
using ((select auth.uid()) is not null and user_id = (select auth.uid()))
with check ((select auth.uid()) is not null and user_id = (select auth.uid()));

create policy pets_owner_select
on public.pets for select to authenticated
using ((select auth.uid()) is not null and owner_user_id = (select auth.uid()));

create policy pets_owner_update
on public.pets for update to authenticated
using ((select auth.uid()) is not null and owner_user_id = (select auth.uid()))
with check ((select auth.uid()) is not null and owner_user_id = (select auth.uid()));

create policy pet_memberships_owner_select
on public.pet_memberships for select to authenticated
using (private.is_pet_owner(pet_id));

create policy memories_owner_select
on public.memories for select to authenticated
using (private.is_memory_owner(id));

create policy memories_owner_insert
on public.memories for insert to authenticated
with check (
  (select auth.uid()) is not null
  and creator_user_id = (select auth.uid())
);

create policy memories_owner_update
on public.memories for update to authenticated
using (private.is_memory_owner(id))
with check (private.is_memory_owner(id));

create policy memory_versions_owner_select
on public.memory_versions for select to authenticated
using (private.is_memory_owner(memory_id));

create policy memory_versions_owner_insert
on public.memory_versions for insert to authenticated
with check (
  (select auth.uid()) is not null
  and created_by_user_id = (select auth.uid())
  and private.is_memory_owner(memory_id)
);

create policy memory_versions_owner_update
on public.memory_versions for update to authenticated
using (private.is_memory_owner(memory_id))
with check (private.is_memory_owner(memory_id));

create policy pet_memories_owner_select
on public.pet_memories for select to authenticated
using (private.is_pet_owner(pet_id) and private.is_memory_owner(memory_id));

create policy pet_memories_owner_insert
on public.pet_memories for insert to authenticated
with check (
  (select auth.uid()) is not null
  and created_by_user_id = (select auth.uid())
  and private.is_pet_owner(pet_id)
  and private.is_memory_owner(memory_id)
);

create policy pet_memories_owner_delete
on public.pet_memories for delete to authenticated
using (private.is_pet_owner(pet_id) and private.is_memory_owner(memory_id));

create policy memory_media_owner_select
on public.memory_media for select to authenticated
using (private.is_version_owner(memory_version_id));

create policy memory_media_owner_insert
on public.memory_media for insert to authenticated
with check (private.is_version_owner(memory_version_id));

create policy memory_media_owner_update
on public.memory_media for update to authenticated
using (private.is_version_owner(memory_version_id))
with check (private.is_version_owner(memory_version_id));

create policy memory_media_owner_delete
on public.memory_media for delete to authenticated
using (private.is_version_owner(memory_version_id));
