begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public;

select plan(22);

insert into auth.users (id, email)
values
  ('00000000-0000-4000-8000-000000000301', 'rpc-owner@example.test'),
  ('00000000-0000-4000-8000-000000000302', 'rpc-outsider@example.test');

select ok(
  has_function_privilege('authenticated', 'public.publish_memory(uuid,uuid)', 'EXECUTE'),
  'authenticated can execute publish RPC'
);
select ok(
  not has_function_privilege('anon', 'public.publish_memory(uuid,uuid)', 'EXECUTE'),
  'anonymous callers cannot execute publish RPC'
);

set local role anon;
select throws_matching(
  $$
    select public.initialize_pet_journal(
      '10000000-0000-4000-8000-000000000301',
      '20000000-0000-4000-8000-000000000301',
      '30000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000301',
      '50000000-0000-4000-8000-000000000301',
      'Mali',
      'cat'
    )
  $$,
  'permission denied.*initialize_pet_journal',
  'anonymous pet initialization is denied'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000301',
  true
);
set local role authenticated;

select lives_ok(
  $$
    select public.initialize_pet_journal(
      '10000000-0000-4000-8000-000000000301',
      '20000000-0000-4000-8000-000000000301',
      '30000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000301',
      '50000000-0000-4000-8000-000000000301',
      'Mali',
      'cat',
      null,
      null,
      null,
      null,
      'วันแรกของเรา',
      current_date
    )
  $$,
  'owner initializes the pet journal atomically'
);
select is((select count(*)::bigint from public.pets), 1::bigint, 'pet was created');
select is((select count(*)::bigint from public.pet_memberships), 1::bigint, 'owner membership was created');
select is((select count(*)::bigint from public.memories), 1::bigint, 'first memory was created');
select is(
  (
    select count(*)::bigint
    from public.memory_versions as version
    join public.pet_memories as relation on relation.memory_id = version.memory_id
  ),
  1::bigint,
  'working version and pet-memory relation were created'
);
select is(
  (
    select (public.initialize_pet_journal(
      '10000000-0000-4000-8000-000000000301',
      '20000000-0000-4000-8000-000000000301',
      '30000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000301',
      '50000000-0000-4000-8000-000000000301',
      'Mali',
      'cat'
    ) ->> 'replayed')::boolean
  ),
  true,
  'retry returns the existing aggregate'
);
select throws_matching(
  $$
    select public.initialize_pet_journal(
      '10000000-0000-4000-8000-000000000399',
      '20000000-0000-4000-8000-000000000399',
      '30000000-0000-4000-8000-000000000399',
      '40000000-0000-4000-8000-000000000399',
      '50000000-0000-4000-8000-000000000399',
      'Invalid other',
      'other'
    )
  $$,
  'pets_custom_type_check',
  'invalid initialization fails inside the transaction'
);
select is(
  (select count(*)::bigint from public.pets where id = '10000000-0000-4000-8000-000000000399'),
  0::bigint,
  'failed initialization leaves no partial pet'
);

select lives_ok(
  $$
    insert into public.memory_media (
      id,
      memory_version_id,
      object_path,
      media_type,
      sort_order,
      upload_state
    ) values (
      '60000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000301',
      '00000000-0000-4000-8000-000000000301/memory/first.jpg',
      'image',
      0,
      'uploaded'
    )
  $$,
  'owner records uploaded media before publication'
);
select lives_ok(
  $$select public.publish_memory('30000000-0000-4000-8000-000000000301', '40000000-0000-4000-8000-000000000301')$$,
  'owner publishes the initial version atomically'
);
select ok(
  (
    select lifecycle_status = 'published'
      and current_published_version_id = '40000000-0000-4000-8000-000000000301'
      and current_working_version_id is null
    from public.memories
    where id = '30000000-0000-4000-8000-000000000301'
  ),
  'publication promotes the version and clears the working pointer'
);
select is(
  (
    select (public.publish_memory(
      '30000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000301'
    ) ->> 'replayed')::boolean
  ),
  true,
  'publication retry is idempotent'
);

select lives_ok(
  $$select public.begin_memory_edit('30000000-0000-4000-8000-000000000301', '40000000-0000-4000-8000-000000000302')$$,
  'owner creates an edit draft atomically'
);
select is(
  (
    select current_published_version_id
    from public.memories
    where id = '30000000-0000-4000-8000-000000000301'
  ),
  '40000000-0000-4000-8000-000000000301'::uuid,
  'creating an edit draft keeps the old published version readable'
);
select is(
  (
    select (public.begin_memory_edit(
      '30000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000399'
    ) ->> 'working_version_id')
  ),
  '40000000-0000-4000-8000-000000000302',
  'editing retry resumes the existing working version'
);

reset role;
insert into public.memory_media (
  id,
  memory_version_id,
  object_path,
  media_type,
  sort_order,
  upload_state
) values (
  '60000000-0000-4000-8000-000000000302',
  '40000000-0000-4000-8000-000000000302',
  '00000000-0000-4000-8000-000000000301/memory/edit.jpg',
  'image',
  0,
  'uploaded'
);
set local role authenticated;
select lives_ok(
  $$select public.promote_memory_version('30000000-0000-4000-8000-000000000301', '40000000-0000-4000-8000-000000000302')$$,
  'owner promotes an edit draft atomically'
);
select ok(
  (
    select bool_and(
      (id = '40000000-0000-4000-8000-000000000301' and version_state = 'superseded')
      or (id = '40000000-0000-4000-8000-000000000302' and version_state = 'published')
    )
    from public.memory_versions
    where memory_id = '30000000-0000-4000-8000-000000000301'
  ),
  'promotion supersedes the old version and publishes the edit'
);
select is(
  (
    select (public.promote_memory_version(
      '30000000-0000-4000-8000-000000000301',
      '40000000-0000-4000-8000-000000000302'
    ) ->> 'replayed')::boolean
  ),
  true,
  'promotion retry is idempotent'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000302',
  true
);
set local role authenticated;
select throws_matching(
  $$select public.publish_memory('30000000-0000-4000-8000-000000000301', '40000000-0000-4000-8000-000000000302')$$,
  'memory ownership required',
  'non-owner cannot call a publication transition'
);

reset role;
select * from finish();
rollback;
