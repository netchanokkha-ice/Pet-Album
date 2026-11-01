-- Create or resume a working edit version without moving the published pointer.
create or replace function public.begin_memory_edit(
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
  published_row public.memory_versions%rowtype;
  working_row public.memory_versions%rowtype;
  next_version_number bigint;
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

  if memory_row.lifecycle_status <> 'published'
     or memory_row.current_published_version_id is null then
    raise exception 'only a published memory can create an edit draft';
  end if;

  if memory_row.current_working_version_id is not null then
    select * into working_row
    from public.memory_versions
    where id = memory_row.current_working_version_id
      and memory_id = p_memory_id;

    if not found
       or working_row.version_state <> 'edit_draft'
       or working_row.base_version_id is distinct from memory_row.current_published_version_id then
      raise exception 'memory working version is not a resumable edit draft';
    end if;

    return jsonb_build_object(
      'memory_id', p_memory_id,
      'working_version_id', working_row.id,
      'base_published_version_id', memory_row.current_published_version_id,
      'replayed', true
    );
  end if;

  if exists (select 1 from public.memory_versions where id = p_version_id) then
    raise exception using errcode = '23505', message = 'edit draft idempotency conflict';
  end if;

  select * into published_row
  from public.memory_versions
  where id = memory_row.current_published_version_id
    and memory_id = p_memory_id
    and version_state = 'published'
  for share;

  if not found then
    raise exception 'published version is not available for editing';
  end if;

  select coalesce(max(version_number), 0) + 1
  into next_version_number
  from public.memory_versions
  where memory_id = p_memory_id;

  insert into public.memory_versions (
    id,
    memory_id,
    created_by_user_id,
    base_version_id,
    version_number,
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
    presentation_schema_version
  ) values (
    p_version_id,
    p_memory_id,
    caller_id,
    published_row.id,
    next_version_number,
    'edit_draft',
    published_row.title,
    published_row.caption,
    published_row.memory_date,
    published_row.mood,
    published_row.location,
    published_row.occasion,
    published_row.theme_key,
    published_row.template_key,
    published_row.layout_key,
    published_row.decoration_data,
    published_row.layout_data,
    published_row.presentation_schema_version
  );

  update public.memories
  set current_working_version_id = p_version_id,
      updated_at = clock_timestamp()
  where id = p_memory_id;

  return jsonb_build_object(
    'memory_id', p_memory_id,
    'working_version_id', p_version_id,
    'base_published_version_id', published_row.id,
    'replayed', false
  );
end;
$$;

revoke all on function public.begin_memory_edit(uuid, uuid)
  from public, anon, authenticated, service_role;
grant execute on function public.begin_memory_edit(uuid, uuid) to authenticated;
