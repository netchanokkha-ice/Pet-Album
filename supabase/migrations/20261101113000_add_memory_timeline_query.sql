create or replace function public.get_memory_timeline(
  p_pet_id uuid,
  p_before_date date default null,
  p_before_memory_id uuid default null,
  p_limit integer default 20
)
returns table (
  memory_id uuid,
  visible_version_id uuid,
  pet_id uuid,
  title text,
  caption text,
  memory_date date,
  cover_object_path text,
  working_version_state text
)
language plpgsql
security definer
set search_path = ''
stable
as $$
begin
  if auth.uid() is null then
    raise exception using errcode = '42501', message = 'authentication required';
  end if;
  if not private.is_pet_owner(p_pet_id) then
    raise exception using errcode = '42501', message = 'pet ownership required';
  end if;
  if p_limit < 1 or p_limit > 50 then
    raise exception 'timeline limit must be between 1 and 50';
  end if;
  if (p_before_date is null) <> (p_before_memory_id is null) then
    raise exception 'timeline cursor must include both date and memory id';
  end if;

  return query
  select
    memory.id,
    visible_version.id,
    relation.pet_id,
    coalesce(visible_version.title, 'Untitled memory'),
    visible_version.caption,
    visible_version.memory_date,
    cover.object_path,
    working_version.version_state
  from public.pet_memories as relation
  join public.memories as memory
    on memory.id = relation.memory_id
  join public.memory_versions as visible_version
    on visible_version.id = coalesce(
      memory.current_published_version_id,
      memory.current_working_version_id
    )
  left join public.memory_versions as working_version
    on working_version.id = memory.current_working_version_id
  left join lateral (
    select media.object_path
    from public.memory_media as media
    where media.memory_version_id = visible_version.id
      and media.upload_state = 'uploaded'
    order by media.is_cover desc, media.sort_order asc
    limit 1
  ) as cover on true
  where relation.pet_id = p_pet_id
    and memory.lifecycle_status not in ('soft_deleted', 'purged')
    and (
      p_before_date is null
      or (visible_version.memory_date, memory.id)
         < (p_before_date, p_before_memory_id)
    )
  order by visible_version.memory_date desc, memory.id desc
  limit p_limit + 1;
end;
$$;

revoke all on function public.get_memory_timeline(uuid, date, uuid, integer)
  from public, anon, authenticated, service_role;
grant execute on function public.get_memory_timeline(uuid, date, uuid, integer)
  to authenticated;
