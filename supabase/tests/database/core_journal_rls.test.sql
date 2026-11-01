begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public;

select plan(50);

insert into auth.users (id, email)
values
  ('00000000-0000-4000-8000-000000000101', 'rls-owner@example.test'),
  ('00000000-0000-4000-8000-000000000102', 'rls-other-owner@example.test'),
  ('00000000-0000-4000-8000-000000000103', 'rls-outsider@example.test');

insert into public.profiles (user_id, display_name)
values
  ('00000000-0000-4000-8000-000000000101', 'Owner'),
  ('00000000-0000-4000-8000-000000000102', 'Other owner');

insert into public.user_preferences (user_id)
values
  ('00000000-0000-4000-8000-000000000101'),
  ('00000000-0000-4000-8000-000000000102');

insert into public.pets (id, owner_user_id, name, pet_type)
values
  (
    '10000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101',
    'Mali',
    'cat'
  ),
  (
    '10000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102',
    'Mochi',
    'cat'
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
)
values
  (
    '20000000-0000-4000-8000-000000000101',
    '10000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101',
    'owner',
    'active',
    true,
    true,
    true,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000102',
    '10000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102',
    'owner',
    'active',
    true,
    true,
    true,
    true
  );

insert into public.memories (id, creator_user_id, lifecycle_status)
values
  (
    '30000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101',
    'draft'
  ),
  (
    '30000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102',
    'draft'
  );

insert into public.memory_versions (
  id,
  memory_id,
  created_by_user_id,
  version_number,
  version_state,
  memory_date
)
values
  (
    '40000000-0000-4000-8000-000000000101',
    '30000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101',
    1,
    'draft',
    current_date
  ),
  (
    '40000000-0000-4000-8000-000000000102',
    '30000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102',
    1,
    'draft',
    current_date
  );

update public.memories
set current_working_version_id = case id
  when '30000000-0000-4000-8000-000000000101'::uuid
    then '40000000-0000-4000-8000-000000000101'::uuid
  else '40000000-0000-4000-8000-000000000102'::uuid
end
where id in (
  '30000000-0000-4000-8000-000000000101'::uuid,
  '30000000-0000-4000-8000-000000000102'::uuid
);

insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
values
  (
    '50000000-0000-4000-8000-000000000101',
    '10000000-0000-4000-8000-000000000101',
    '30000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101'
  ),
  (
    '50000000-0000-4000-8000-000000000102',
    '10000000-0000-4000-8000-000000000102',
    '30000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102'
  );

insert into public.memory_media (
  id,
  memory_version_id,
  object_path,
  media_type,
  sort_order,
  upload_state
)
values
  (
    '60000000-0000-4000-8000-000000000101',
    '40000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000101/memory-101/image.jpg',
    'image',
    0,
    'queued'
  ),
  (
    '60000000-0000-4000-8000-000000000102',
    '40000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000102/memory-102/image.jpg',
    'image',
    0,
    'queued'
  );

select is(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  true,
  'profiles has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.user_preferences'::regclass),
  true,
  'user_preferences has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.pets'::regclass),
  true,
  'pets has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.pet_memberships'::regclass),
  true,
  'pet_memberships has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.memories'::regclass),
  true,
  'memories has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.memory_versions'::regclass),
  true,
  'memory_versions has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.pet_memories'::regclass),
  true,
  'pet_memories has RLS enabled'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.memory_media'::regclass),
  true,
  'memory_media has RLS enabled'
);

select is(
  (select count(*)::bigint from pg_policies where schemaname = 'public'),
  22::bigint,
  'all required operation-specific policies exist'
);
select is(
  (
    select count(*)::bigint
    from pg_policies
    where schemaname = 'public' and cmd = 'ALL'
  ),
  0::bigint,
  'no broad ALL policy replaces per-operation policies'
);

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000101',
  true
);
set local role authenticated;

select is((select count(*)::bigint from public.profiles), 1::bigint, 'owner can read own profile');
select is((select count(*)::bigint from public.user_preferences), 1::bigint, 'owner can read own preferences');
select is((select count(*)::bigint from public.pets), 1::bigint, 'owner can read own pet');
select is((select count(*)::bigint from public.pet_memberships), 1::bigint, 'owner can read own membership');
select is((select count(*)::bigint from public.memories), 1::bigint, 'owner can read own memory');
select is((select count(*)::bigint from public.memory_versions), 1::bigint, 'owner can read own version');
select is((select count(*)::bigint from public.pet_memories), 1::bigint, 'owner can read own pet-memory relation');
select is((select count(*)::bigint from public.memory_media), 1::bigint, 'owner can read own media');

select lives_ok(
  $$update public.profiles set display_name = 'Owner updated' where user_id = '00000000-0000-4000-8000-000000000101'$$,
  'owner can update own profile'
);
select lives_ok(
  $$update public.user_preferences set language_code = 'en' where user_id = '00000000-0000-4000-8000-000000000101'$$,
  'owner can update own preferences'
);
select lives_ok(
  $$update public.pets set name = 'Mali updated' where id = '10000000-0000-4000-8000-000000000101'$$,
  'owner can update own pet'
);
select lives_ok(
  $$update public.memories set privacy = 'pet_members' where id = '30000000-0000-4000-8000-000000000101'$$,
  'owner can update own memory'
);
select lives_ok(
  $$update public.memory_versions set caption = 'Updated caption' where id = '40000000-0000-4000-8000-000000000101'$$,
  'owner can update own version'
);
select lives_ok(
  $$update public.memory_media set presentation_data = '{"fit":"cover"}'::jsonb where id = '60000000-0000-4000-8000-000000000101'$$,
  'owner can update own media'
);

select lives_ok(
  $$
    insert into public.memories (id, creator_user_id, lifecycle_status)
    values (
      '30000000-0000-4000-8000-000000000103',
      '00000000-0000-4000-8000-000000000101',
      'draft'
    )
  $$,
  'owner can insert a memory draft'
);
select lives_ok(
  $$
    insert into public.memory_versions (
      id,
      memory_id,
      created_by_user_id,
      version_number,
      version_state,
      memory_date
    ) values (
      '40000000-0000-4000-8000-000000000103',
      '30000000-0000-4000-8000-000000000103',
      '00000000-0000-4000-8000-000000000101',
      1,
      'draft',
      current_date
    )
  $$,
  'owner can insert a version for an owned draft'
);
select lives_ok(
  $$
    insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
    values (
      '50000000-0000-4000-8000-000000000103',
      '10000000-0000-4000-8000-000000000101',
      '30000000-0000-4000-8000-000000000103',
      '00000000-0000-4000-8000-000000000101'
    )
  $$,
  'owner can relate an owned memory to an owned pet'
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
      '60000000-0000-4000-8000-000000000103',
      '40000000-0000-4000-8000-000000000103',
      '00000000-0000-4000-8000-000000000101/memory-103/image.jpg',
      'image',
      0,
      'queued'
    )
  $$,
  'owner can insert media for an owned version'
);
select lives_ok(
  $$delete from public.memory_media where id = '60000000-0000-4000-8000-000000000103'$$,
  'owner can delete own draft media'
);
select lives_ok(
  $$delete from public.pet_memories where id = '50000000-0000-4000-8000-000000000103'$$,
  'owner can delete own pet-memory relation'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000103',
  true
);
set local role authenticated;

select is((select count(*)::bigint from public.profiles), 0::bigint, 'non-owner cannot read profiles');
select is((select count(*)::bigint from public.user_preferences), 0::bigint, 'non-owner cannot read preferences');
select is((select count(*)::bigint from public.pets), 0::bigint, 'non-owner cannot read pets');
select is((select count(*)::bigint from public.pet_memberships), 0::bigint, 'non-owner cannot read memberships');
select is((select count(*)::bigint from public.memories), 0::bigint, 'non-owner cannot read memories');
select is((select count(*)::bigint from public.memory_versions), 0::bigint, 'non-owner cannot read versions');
select is((select count(*)::bigint from public.pet_memories), 0::bigint, 'non-owner cannot read pet-memory relations');
select is((select count(*)::bigint from public.memory_media), 0::bigint, 'non-owner cannot read media');

select throws_matching(
  $$
    insert into public.memories (id, creator_user_id, lifecycle_status)
    values (
      '30000000-0000-4000-8000-000000000104',
      '00000000-0000-4000-8000-000000000101',
      'draft'
    )
  $$,
  'row-level security policy.*memories',
  'non-owner cannot insert a memory for another user'
);
select throws_matching(
  $$
    insert into public.memory_versions (
      id,
      memory_id,
      created_by_user_id,
      version_number,
      version_state,
      memory_date
    ) values (
      '40000000-0000-4000-8000-000000000104',
      '30000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000103',
      2,
      'draft',
      current_date
    )
  $$,
  'row-level security policy.*memory_versions',
  'non-owner cannot insert a version on another memory'
);
select throws_matching(
  $$
    insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
    values (
      '50000000-0000-4000-8000-000000000104',
      '10000000-0000-4000-8000-000000000101',
      '30000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000103'
    )
  $$,
  'row-level security policy.*pet_memories',
  'non-owner cannot create another owner relationship'
);
select throws_matching(
  $$
    insert into public.memory_media (
      id,
      memory_version_id,
      object_path,
      media_type,
      sort_order,
      upload_state
    ) values (
      '60000000-0000-4000-8000-000000000104',
      '40000000-0000-4000-8000-000000000101',
      'outsider/image.jpg',
      'image',
      1,
      'queued'
    )
  $$,
  'row-level security policy.*memory_media',
  'non-owner cannot insert media on another version'
);

reset role;
select set_config('request.jwt.claim.sub', '', true);
set local role anon;

select throws_matching($$select * from public.profiles$$, 'permission denied.*profiles', 'anonymous profile access is denied');
select throws_matching($$select * from public.user_preferences$$, 'permission denied.*user_preferences', 'anonymous preferences access is denied');
select throws_matching($$select * from public.pets$$, 'permission denied.*pets', 'anonymous pet access is denied');
select throws_matching($$select * from public.pet_memberships$$, 'permission denied.*pet_memberships', 'anonymous membership access is denied');
select throws_matching($$select * from public.memories$$, 'permission denied.*memories', 'anonymous memory access is denied');
select throws_matching($$select * from public.memory_versions$$, 'permission denied.*memory_versions', 'anonymous version access is denied');
select throws_matching($$select * from public.pet_memories$$, 'permission denied.*pet_memories', 'anonymous relation access is denied');
select throws_matching($$select * from public.memory_media$$, 'permission denied.*memory_media', 'anonymous media access is denied');

reset role;
select * from finish();
rollback;
