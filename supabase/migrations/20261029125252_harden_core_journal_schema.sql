-- Strengthen the core journal model without generating identifiers on the
-- server. Draftable records keep the UUID supplied by the client.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

alter table public.profiles
  add column updated_at timestamptz not null default now();

alter table public.user_preferences
  add column updated_at timestamptz not null default now();

alter table public.pets
  add column updated_at timestamptz not null default now(),
  add column deleted_at timestamptz,
  add column deletion_expires_at timestamptz;

alter table public.pet_memberships
  add column updated_at timestamptz not null default now(),
  add column removed_at timestamptz;

alter table public.memories
  add column updated_at timestamptz not null default now(),
  add column published_at timestamptz,
  add column deleted_at timestamptz,
  add column deletion_expires_at timestamptz,
  add column purged_at timestamptz,
  add column pre_deletion_status text;

alter table public.memory_versions
  add column updated_at timestamptz not null default now(),
  add column published_at timestamptz;

alter table public.memory_media
  add column updated_at timestamptz not null default now();

alter table public.pet_memberships
  add constraint pet_memberships_pet_user_key unique (pet_id, user_id);

alter table public.memory_versions
  add constraint memory_versions_memory_id_id_key unique (memory_id, id),
  add constraint memory_versions_memory_version_number_key unique (memory_id, version_number);

alter table public.pet_memories
  add constraint pet_memories_pet_memory_key unique (pet_id, memory_id);

alter table public.memory_media
  add constraint memory_media_object_path_key unique (object_path),
  add constraint memory_media_version_sort_order_key unique (memory_version_id, sort_order);

alter table public.profiles
  add constraint profiles_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade;

alter table public.user_preferences
  add constraint user_preferences_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade;

alter table public.pets
  add constraint pets_owner_user_id_fkey
    foreign key (owner_user_id) references auth.users (id) on delete restrict;

alter table public.pet_memberships
  add constraint pet_memberships_pet_id_fkey
    foreign key (pet_id) references public.pets (id) on delete cascade,
  add constraint pet_memberships_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete restrict;

alter table public.memories
  add constraint memories_creator_user_id_fkey
    foreign key (creator_user_id) references auth.users (id) on delete restrict;

alter table public.memory_versions
  add constraint memory_versions_memory_id_fkey
    foreign key (memory_id) references public.memories (id) on delete cascade,
  add constraint memory_versions_created_by_user_id_fkey
    foreign key (created_by_user_id) references auth.users (id) on delete restrict,
  add constraint memory_versions_base_version_fkey
    foreign key (memory_id, base_version_id)
    references public.memory_versions (memory_id, id);

alter table public.memories
  add constraint memories_published_version_fkey
    foreign key (id, current_published_version_id)
    references public.memory_versions (memory_id, id),
  add constraint memories_working_version_fkey
    foreign key (id, current_working_version_id)
    references public.memory_versions (memory_id, id);

alter table public.pet_memories
  add constraint pet_memories_pet_id_fkey
    foreign key (pet_id) references public.pets (id) on delete cascade,
  add constraint pet_memories_memory_id_fkey
    foreign key (memory_id) references public.memories (id) on delete cascade,
  add constraint pet_memories_created_by_user_id_fkey
    foreign key (created_by_user_id) references auth.users (id) on delete restrict;

alter table public.memory_media
  add constraint memory_media_memory_version_id_fkey
    foreign key (memory_version_id) references public.memory_versions (id) on delete cascade;

alter table public.profiles
  add constraint profiles_display_name_check
    check (display_name is null or nullif(btrim(display_name), '') is not null),
  add constraint profiles_timestamps_check
    check (updated_at >= created_at);

alter table public.user_preferences
  add constraint user_preferences_language_code_check
    check (language_code in ('th', 'en')),
  add constraint user_preferences_preferences_object_check
    check (jsonb_typeof(preferences) = 'object'),
  add constraint user_preferences_timestamps_check
    check (updated_at >= created_at);

alter table public.pets
  add constraint pets_name_check
    check (nullif(btrim(name), '') is not null),
  add constraint pets_pet_type_check
    check (nullif(btrim(pet_type), '') is not null and pet_type = lower(pet_type)),
  add constraint pets_custom_type_check
    check (
      (pet_type = 'other' and nullif(btrim(custom_type_label), '') is not null)
      or (pet_type <> 'other' and custom_type_label is null)
    ),
  add constraint pets_dates_check
    check (
      (birth_date is null or birth_date <= current_date)
      and (first_met_date is null or first_met_date <= current_date)
    ),
  add constraint pets_deletion_lifecycle_check
    check (
      (deleted_at is null and deletion_expires_at is null)
      or (
        deleted_at is not null
        and deletion_expires_at = deleted_at + interval '7 days'
      )
    ),
  add constraint pets_timestamps_check
    check (
      updated_at >= created_at
      and (deleted_at is null or deleted_at >= created_at)
    );

alter table public.pet_memberships
  add constraint pet_memberships_role_check
    check (role in ('owner', 'contributor', 'viewer')),
  add constraint pet_memberships_status_check
    check (status in ('active', 'removed')),
  add constraint pet_memberships_owner_capabilities_check
    check (
      role <> 'owner'
      or (
        status = 'active'
        and can_edit_profile
        and can_create_memories
        and can_manage_memories
        and can_manage_members
      )
    ),
  add constraint pet_memberships_removal_lifecycle_check
    check (
      (status = 'active' and removed_at is null)
      or (status = 'removed' and removed_at is not null)
    ),
  add constraint pet_memberships_timestamps_check
    check (
      updated_at >= created_at
      and (removed_at is null or removed_at >= created_at)
    );

alter table public.memories
  add constraint memories_lifecycle_status_check
    check (
      lifecycle_status in (
        'draft',
        'publishing',
        'published',
        'publish_failed',
        'soft_deleted',
        'purged'
      )
    ),
  add constraint memories_privacy_check
    check (privacy in ('only_me', 'pet_members', 'anyone_with_link')),
  add constraint memories_published_state_check
    check (
      (lifecycle_status <> 'published')
      or (current_published_version_id is not null and published_at is not null)
    ),
  add constraint memories_draft_state_check
    check (
      lifecycle_status <> 'draft'
      or (current_published_version_id is null and published_at is null)
    ),
  add constraint memories_published_reference_check
    check (published_at is null or current_published_version_id is not null),
  add constraint memories_pre_deletion_status_check
    check (
      pre_deletion_status is null
      or pre_deletion_status in ('draft', 'publishing', 'published', 'publish_failed')
    ),
  add constraint memories_deletion_lifecycle_check
    check (
      (
        lifecycle_status not in ('soft_deleted', 'purged')
        and deleted_at is null
        and deletion_expires_at is null
        and purged_at is null
        and pre_deletion_status is null
      )
      or (
        lifecycle_status = 'soft_deleted'
        and deleted_at is not null
        and deletion_expires_at = deleted_at + interval '7 days'
        and purged_at is null
        and pre_deletion_status is not null
      )
      or (
        lifecycle_status = 'purged'
        and deleted_at is not null
        and deletion_expires_at = deleted_at + interval '7 days'
        and purged_at is not null
        and purged_at >= deletion_expires_at
        and pre_deletion_status is not null
      )
    ),
  add constraint memories_timestamps_check
    check (
      updated_at >= created_at
      and (published_at is null or published_at >= created_at)
      and (deleted_at is null or deleted_at >= created_at)
    );

alter table public.memory_versions
  add constraint memory_versions_version_number_check
    check (version_number > 0),
  add constraint memory_versions_version_state_check
    check (version_state in ('draft', 'edit_draft', 'published', 'superseded')),
  add constraint memory_versions_base_version_check
    check (base_version_id is null or base_version_id <> id),
  add constraint memory_versions_memory_date_check
    check (memory_date <= current_date),
  add constraint memory_versions_title_check
    check (title is null or nullif(btrim(title), '') is not null),
  add constraint memory_versions_decoration_object_check
    check (jsonb_typeof(decoration_data) = 'object'),
  add constraint memory_versions_layout_object_check
    check (jsonb_typeof(layout_data) = 'object'),
  add constraint memory_versions_presentation_schema_version_check
    check (presentation_schema_version > 0),
  add constraint memory_versions_publication_lifecycle_check
    check (
      (version_state in ('draft', 'edit_draft') and published_at is null)
      or (version_state in ('published', 'superseded') and published_at is not null)
    ),
  add constraint memory_versions_timestamps_check
    check (
      updated_at >= created_at
      and (published_at is null or published_at >= created_at)
    );

alter table public.memory_media
  add constraint memory_media_object_path_check
    check (nullif(btrim(object_path), '') is not null),
  add constraint memory_media_media_type_check
    check (media_type in ('image', 'video')),
  add constraint memory_media_sort_order_check
    check (sort_order between 0 and 3),
  add constraint memory_media_upload_state_check
    check (upload_state in ('local_selected', 'queued', 'uploading', 'uploaded', 'failed', 'removed')),
  add constraint memory_media_dimensions_check
    check (
      (byte_size is null or byte_size >= 0)
      and (pixel_width is null or pixel_width > 0)
      and (pixel_height is null or pixel_height > 0)
      and (duration_ms is null or duration_ms >= 0)
    ),
  add constraint memory_media_checksum_check
    check (checksum_sha256 is null or checksum_sha256 ~ '^[0-9a-f]{64}$'),
  add constraint memory_media_presentation_object_check
    check (jsonb_typeof(presentation_data) = 'object'),
  add constraint memory_media_timestamps_check
    check (updated_at >= created_at);

create unique index pet_memberships_one_active_owner_idx
  on public.pet_memberships (pet_id)
  where role = 'owner' and status = 'active';

create unique index memory_versions_one_working_version_idx
  on public.memory_versions (memory_id)
  where version_state in ('draft', 'edit_draft');

create unique index memory_versions_one_published_version_idx
  on public.memory_versions (memory_id)
  where version_state = 'published';

create unique index memory_media_one_cover_idx
  on public.memory_media (memory_version_id)
  where is_cover;

create index pets_owner_active_idx
  on public.pets (owner_user_id, id)
  where deleted_at is null;

create index pet_memberships_user_status_pet_idx
  on public.pet_memberships (user_id, status, pet_id);

create index memories_creator_status_created_idx
  on public.memories (creator_user_id, lifecycle_status, created_at desc);

create index memories_published_version_idx
  on public.memories (id, current_published_version_id);

create index memories_working_version_idx
  on public.memories (id, current_working_version_id);

create index memory_versions_creator_idx
  on public.memory_versions (created_by_user_id);

create index memory_versions_base_version_idx
  on public.memory_versions (memory_id, base_version_id);

create index memory_versions_timeline_idx
  on public.memory_versions (memory_id, version_state, memory_date desc);

create index pet_memories_memory_pet_idx
  on public.pet_memories (memory_id, pet_id);

create index pet_memories_creator_idx
  on public.pet_memories (created_by_user_id);

create function private.assert_pet_owner_integrity()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  checked_pet_id uuid;
  expected_owner_user_id uuid;
  active_owner_count bigint;
begin
  if tg_table_name = 'pets' then
    checked_pet_id := new.id;
  else
    checked_pet_id := coalesce(new.pet_id, old.pet_id);
  end if;

  select owner_user_id
  into expected_owner_user_id
  from public.pets
  where id = checked_pet_id;

  if not found then
    return null;
  end if;

  select count(*)
  into active_owner_count
  from public.pet_memberships
  where pet_id = checked_pet_id
    and role = 'owner'
    and status = 'active';

  if active_owner_count <> 1 then
    raise exception using
      errcode = '23514',
      message = 'pet must have exactly one active owner membership';
  end if;

  if not exists (
    select 1
    from public.pet_memberships
    where pet_id = checked_pet_id
      and user_id = expected_owner_user_id
      and role = 'owner'
      and status = 'active'
  ) then
    raise exception using
      errcode = '23514',
      message = 'active owner membership must match pets.owner_user_id';
  end if;

  return null;
end;
$function$;

revoke all on function private.assert_pet_owner_integrity() from public, anon, authenticated;

create constraint trigger pet_memberships_owner_integrity_constraint
after insert or update or delete on public.pet_memberships
deferrable initially immediate
for each row execute function private.assert_pet_owner_integrity();

create constraint trigger pets_owner_integrity_constraint
after update on public.pets
deferrable initially immediate
for each row execute function private.assert_pet_owner_integrity();

create function private.assert_memory_media_limits()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  checked_version_id uuid;
  image_count bigint;
  video_count bigint;
  media_count bigint;
begin
  checked_version_id := coalesce(new.memory_version_id, old.memory_version_id);

  if not exists (
    select 1
    from public.memory_versions
    where id = checked_version_id
  ) then
    return null;
  end if;

  select
    count(*) filter (where media_type = 'image'),
    count(*) filter (where media_type = 'video'),
    count(*)
  into image_count, video_count, media_count
  from public.memory_media
  where memory_version_id = checked_version_id
    and upload_state <> 'removed';

  if image_count > 3 or video_count > 1 or media_count > 4 then
    raise exception using
      errcode = '23514',
      message = 'memory version exceeds media limits';
  end if;

  return null;
end;
$function$;

revoke all on function private.assert_memory_media_limits() from public, anon, authenticated;

create constraint trigger memory_media_limits_constraint
after insert or update or delete on public.memory_media
deferrable initially immediate
for each row execute function private.assert_memory_media_limits();
