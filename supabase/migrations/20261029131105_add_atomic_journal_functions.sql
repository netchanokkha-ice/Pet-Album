-- Publication pointers and version states are mutated only by the atomic RPCs.
revoke update on public.memories from authenticated;
grant update (
  lifecycle_status,
  privacy,
  updated_at,
  deleted_at,
  deletion_expires_at,
  purged_at,
  pre_deletion_status
) on public.memories to authenticated;

revoke update on public.memory_versions from authenticated;
grant update (
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
  updated_at
) on public.memory_versions to authenticated;

create or replace function public.initialize_pet_journal(
  p_pet_id uuid,
  p_membership_id uuid,
  p_memory_id uuid,
  p_version_id uuid,
  p_relation_id uuid,
  p_name text,
  p_pet_type text,
  p_custom_type_label text default null,
  p_profile_image_object_path text default null,
  p_birth_date date default null,
  p_first_met_date date default null,
  p_first_memory_title text default null,
  p_first_memory_date date default current_date
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
begin
  if caller_id is null then
    raise exception using errcode = '42501', message = 'authentication required';
  end if;

  if exists (select 1 from public.pets where id = p_pet_id) then
    if exists (
      select 1
      from public.pets as pet
      join public.pet_memberships as membership
        on membership.id = p_membership_id
       and membership.pet_id = pet.id
       and membership.user_id = caller_id
       and membership.role = 'owner'
       and membership.status = 'active'
      join public.pet_memories as relation
        on relation.id = p_relation_id
       and relation.pet_id = pet.id
       and relation.memory_id = p_memory_id
      join public.memories as memory
        on memory.id = relation.memory_id
       and memory.creator_user_id = caller_id
       and memory.is_first_memory
      join public.memory_versions as version
        on version.id = p_version_id
       and version.memory_id = memory.id
      where pet.id = p_pet_id
        and pet.owner_user_id = caller_id
        and memory.current_working_version_id = version.id
    ) then
      return jsonb_build_object(
        'pet_id', p_pet_id,
        'memory_id', p_memory_id,
        'working_version_id', p_version_id,
        'replayed', true
      );
    end if;

    raise exception using errcode = '23505', message = 'pet initialization idempotency conflict';
  end if;

  insert into public.pets (
    id,
    owner_user_id,
    name,
    pet_type,
    custom_type_label,
    profile_image_object_path,
    birth_date,
    first_met_date
  ) values (
    p_pet_id,
    caller_id,
    p_name,
    p_pet_type,
    p_custom_type_label,
    p_profile_image_object_path,
    p_birth_date,
    p_first_met_date
  );

  insert into public.pet_memberships (
    id,
    pet_id,
    user_id,
    role,
    status,
    can_edit_profile,
    can_create_memories,
    can_manage_memories,
    can_manage_members
  ) values (
    p_membership_id,
    p_pet_id,
    caller_id,
    'owner',
    'active',
    true,
    true,
    true,
    true
  );

  insert into public.memories (
    id,
    creator_user_id,
    lifecycle_status,
    privacy,
    is_first_memory
  ) values (
    p_memory_id,
    caller_id,
    'draft',
    'only_me',
    true
  );

  insert into public.memory_versions (
    id,
    memory_id,
    created_by_user_id,
    version_number,
    version_state,
    title,
    memory_date
  ) values (
    p_version_id,
    p_memory_id,
    caller_id,
    1,
    'draft',
    p_first_memory_title,
    p_first_memory_date
  );

  update public.memories
  set current_working_version_id = p_version_id,
      updated_at = now()
  where id = p_memory_id;

  insert into public.pet_memories (
    id,
    pet_id,
    memory_id,
    created_by_user_id
  ) values (
    p_relation_id,
    p_pet_id,
    p_memory_id,
    caller_id
  );

  return jsonb_build_object(
    'pet_id', p_pet_id,
    'memory_id', p_memory_id,
    'working_version_id', p_version_id,
    'replayed', false
  );
end;
$$;

create or replace function public.publish_memory(
  p_memory_id uuid,
  p_version_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  memory_row public.memories%rowtype;
  version_row public.memory_versions%rowtype;
  published_time timestamptz := clock_timestamp();
begin
  if caller_id is null then
    raise exception using errcode = '42501', message = 'authentication required';
  end if;

  select * into memory_row
  from public.memories
  where id = p_memory_id
  for update;

  if not found or not private.is_memory_owner(p_memory_id) then
    raise exception using errcode = '42501', message = 'memory ownership required';
  end if;

  if memory_row.current_published_version_id = p_version_id
     and memory_row.lifecycle_status = 'published' then
    return jsonb_build_object(
      'memory_id', p_memory_id,
      'published_version_id', p_version_id,
      'replayed', true
    );
  end if;

  if memory_row.current_published_version_id is not null
     or memory_row.current_working_version_id is distinct from p_version_id
     or memory_row.lifecycle_status not in ('draft', 'publish_failed') then
    raise exception 'memory is not ready for initial publication';
  end if;

  select * into version_row
  from public.memory_versions
  where id = p_version_id and memory_id = p_memory_id
  for update;

  if not found or version_row.version_state <> 'draft' then
    raise exception 'working draft is not publishable';
  end if;

  if not exists (
    select 1 from public.memory_media
    where memory_version_id = p_version_id and upload_state = 'uploaded'
  ) or exists (
    select 1 from public.memory_media
    where memory_version_id = p_version_id
      and upload_state not in ('uploaded', 'removed')
  ) then
    raise exception 'all required media must be uploaded before publication';
  end if;

  update public.memory_versions
  set version_state = 'published',
      published_at = published_time,
      updated_at = published_time
  where id = p_version_id;

  update public.memories
  set lifecycle_status = 'published',
      current_published_version_id = p_version_id,
      current_working_version_id = null,
      published_at = published_time,
      updated_at = published_time
  where id = p_memory_id;

  return jsonb_build_object(
    'memory_id', p_memory_id,
    'published_version_id', p_version_id,
    'replayed', false
  );
end;
$$;

create or replace function public.promote_memory_version(
  p_memory_id uuid,
  p_version_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  memory_row public.memories%rowtype;
  version_row public.memory_versions%rowtype;
  published_time timestamptz := clock_timestamp();
begin
  if caller_id is null then
    raise exception using errcode = '42501', message = 'authentication required';
  end if;

  select * into memory_row
  from public.memories
  where id = p_memory_id
  for update;

  if not found or not private.is_memory_owner(p_memory_id) then
    raise exception using errcode = '42501', message = 'memory ownership required';
  end if;

  if memory_row.current_published_version_id = p_version_id
     and memory_row.current_working_version_id is null
     and memory_row.lifecycle_status = 'published' then
    return jsonb_build_object(
      'memory_id', p_memory_id,
      'published_version_id', p_version_id,
      'replayed', true
    );
  end if;

  if memory_row.current_published_version_id is null
     or memory_row.current_working_version_id is distinct from p_version_id
     or memory_row.lifecycle_status <> 'published' then
    raise exception 'memory is not ready to promote an edit draft';
  end if;

  select * into version_row
  from public.memory_versions
  where id = p_version_id and memory_id = p_memory_id
  for update;

  if not found or version_row.version_state <> 'edit_draft' then
    raise exception 'working version is not an edit draft';
  end if;

  if not exists (
    select 1 from public.memory_media
    where memory_version_id = p_version_id and upload_state = 'uploaded'
  ) or exists (
    select 1 from public.memory_media
    where memory_version_id = p_version_id
      and upload_state not in ('uploaded', 'removed')
  ) then
    raise exception 'all required media must be uploaded before promotion';
  end if;

  update public.memory_versions
  set version_state = 'superseded',
      updated_at = published_time
  where id = memory_row.current_published_version_id;

  update public.memory_versions
  set version_state = 'published',
      published_at = published_time,
      updated_at = published_time
  where id = p_version_id;

  update public.memories
  set current_published_version_id = p_version_id,
      current_working_version_id = null,
      updated_at = published_time
  where id = p_memory_id;

  return jsonb_build_object(
    'memory_id', p_memory_id,
    'published_version_id', p_version_id,
    'replayed', false
  );
end;
$$;

revoke all on function public.initialize_pet_journal(
  uuid, uuid, uuid, uuid, uuid, text, text, text, text, date, date, text, date
) from public, anon, authenticated, service_role;
revoke all on function public.publish_memory(uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.promote_memory_version(uuid, uuid)
  from public, anon, authenticated, service_role;

grant execute on function public.initialize_pet_journal(
  uuid, uuid, uuid, uuid, uuid, text, text, text, text, date, date, text, date
) to authenticated;
grant execute on function public.publish_memory(uuid, uuid) to authenticated;
grant execute on function public.promote_memory_version(uuid, uuid) to authenticated;
