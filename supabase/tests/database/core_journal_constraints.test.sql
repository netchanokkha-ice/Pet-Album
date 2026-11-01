begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public;

select plan(21);

select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'public'
      and table_name in (
        'pets',
        'pet_memberships',
        'memories',
        'memory_versions',
        'pet_memories',
        'memory_media'
      )
      and column_name = 'id'
      and column_default is null
  ),
  6::bigint,
  'draftable record UUIDs are supplied by clients'
);

insert into auth.users (id, email)
values
  ('00000000-0000-4000-8000-000000000001', 'owner-one@pawlum.test'),
  ('00000000-0000-4000-8000-000000000002', 'owner-two@pawlum.test');

insert into public.pets (id, owner_user_id, name, pet_type)
values
  (
    '10000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    'Mali',
    'cat'
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000002',
    'Mochi',
    'dog'
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
    '20000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    'owner',
    'active',
    true,
    true,
    true,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    '10000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000002',
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
    '30000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    'draft'
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000002',
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
    '40000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000001',
    1,
    'draft',
    current_date
  ),
  (
    '40000000-0000-4000-8000-000000000002',
    '30000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000002',
    1,
    'draft',
    current_date
  );

update public.memories
set current_working_version_id = case id
  when '30000000-0000-4000-8000-000000000001'::uuid
    then '40000000-0000-4000-8000-000000000001'::uuid
  else '40000000-0000-4000-8000-000000000002'::uuid
end
where id in (
  '30000000-0000-4000-8000-000000000001'::uuid,
  '30000000-0000-4000-8000-000000000002'::uuid
);

insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
values (
  '50000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001'
);

select throws_matching(
  $$
    insert into public.pet_memberships (
      id, pet_id, user_id, role, status
    ) values (
      '20000000-0000-4000-8000-000000000010',
      '10000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000002',
      'admin',
      'active'
    )
  $$,
  'pet_memberships_role_check',
  'unsupported membership roles are rejected'
);

insert into public.pets (id, owner_user_id, name, pet_type)
values (
  '10000000-0000-4000-8000-000000000003',
  '00000000-0000-4000-8000-000000000001',
  'Nom Yen',
  'cat'
);

select throws_matching(
  $$
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
      '20000000-0000-4000-8000-000000000011',
      '10000000-0000-4000-8000-000000000003',
      '00000000-0000-4000-8000-000000000002',
      'owner',
      'active',
      true,
      true,
      true,
      true
    )
  $$,
  'active owner membership must match pets.owner_user_id',
  'an owner membership must match the pet owner'
);

delete from public.pets
where id = '10000000-0000-4000-8000-000000000003';

select throws_matching(
  $$
    delete from public.pet_memberships
    where id = '20000000-0000-4000-8000-000000000001'
  $$,
  'pet must have exactly one active owner membership',
  'the sole active owner membership cannot be removed'
);

select throws_matching(
  $$
    update public.pets
    set owner_user_id = '00000000-0000-4000-8000-000000000002'
    where id = '10000000-0000-4000-8000-000000000001'
  $$,
  'active owner membership must match pets.owner_user_id',
  'pet ownership cannot diverge from the active owner membership'
);

select throws_matching(
  $$
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
      '20000000-0000-4000-8000-000000000012',
      '10000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000002',
      'owner',
      'active',
      true,
      true,
      true,
      true
    )
  $$,
  'pet_memberships_one_active_owner_idx',
  'a pet cannot have two active owners'
);

select throws_matching(
  $$
    insert into public.memories (id, creator_user_id, lifecycle_status)
    values (
      '30000000-0000-4000-8000-000000000010',
      '00000000-0000-4000-8000-000000000001',
      'archived'
    )
  $$,
  'memories_lifecycle_status_check',
  'unsupported memory lifecycle states are rejected'
);

select throws_matching(
  $$
    insert into public.memories (id, creator_user_id, lifecycle_status, privacy)
    values (
      '30000000-0000-4000-8000-000000000011',
      '00000000-0000-4000-8000-000000000001',
      'draft',
      'public'
    )
  $$,
  'memories_privacy_check',
  'unsupported privacy states are rejected'
);

select throws_matching(
  $$
    update public.memories
    set
      lifecycle_status = 'soft_deleted',
      pre_deletion_status = 'draft',
      deleted_at = now(),
      deletion_expires_at = now() + interval '6 days'
    where id = '30000000-0000-4000-8000-000000000001'
  $$,
  'memories_deletion_lifecycle_check',
  'memory deletion must retain the seven-day recovery window'
);

select throws_matching(
  $$
    update public.memories
    set current_working_version_id = '40000000-0000-4000-8000-000000000002'
    where id = '30000000-0000-4000-8000-000000000001'
  $$,
  'memories_working_version_fkey',
  'a working version must belong to its memory'
);

select throws_matching(
  $$
    insert into public.memory_versions (
      id,
      memory_id,
      created_by_user_id,
      base_version_id,
      version_number,
      version_state,
      memory_date,
      published_at
    ) values (
      '40000000-0000-4000-8000-000000000010',
      '30000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000001',
      '40000000-0000-4000-8000-000000000001',
      1,
      'superseded',
      current_date,
      now()
    )
  $$,
  'memory_versions_memory_version_number_key',
  'version numbers are unique inside one memory'
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
      '40000000-0000-4000-8000-000000000011',
      '30000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000001',
      2,
      'editing',
      current_date
    )
  $$,
  'memory_versions_(version_state|publication_lifecycle)_check',
  'unsupported version states are rejected'
);

select throws_matching(
  $$
    insert into public.memory_versions (
      id,
      memory_id,
      created_by_user_id,
      version_number,
      version_state,
      memory_date,
      published_at
    ) values (
      '40000000-0000-4000-8000-000000000012',
      '30000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000001',
      2,
      'superseded',
      current_date + 1,
      now()
    )
  $$,
  'memory_versions_memory_date_check',
  'future memory dates are rejected'
);

select throws_matching(
  $$
    insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
    values (
      '50000000-0000-4000-8000-000000000010',
      '10000000-0000-4000-8000-000000000099',
      '30000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000001'
    )
  $$,
  'pet_memories_pet_id_fkey',
  'pet-memory relations require an existing pet'
);

select throws_matching(
  $$
    insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
    values (
      '50000000-0000-4000-8000-000000000011',
      '10000000-0000-4000-8000-000000000001',
      '30000000-0000-4000-8000-000000000001',
      '00000000-0000-4000-8000-000000000001'
    )
  $$,
  'pet_memories_pet_memory_key',
  'duplicate pet-memory relations are rejected'
);

select throws_matching(
  $$
    update public.pets
    set
      deleted_at = now(),
      deletion_expires_at = now() + interval '8 days'
    where id = '10000000-0000-4000-8000-000000000001'
  $$,
  'pets_deletion_lifecycle_check',
  'pet deletion must use the seven-day recovery window'
);

select throws_matching(
  $$
    insert into public.user_preferences (user_id, language_code)
    values ('00000000-0000-4000-8000-000000000001', 'fr')
  $$,
  'user_preferences_language_code_check',
  'only Thai and English preferences are accepted'
);

select throws_matching(
  $$
    insert into public.memory_media (
      id, memory_version_id, object_path, media_type, sort_order, upload_state
    ) values (
      '60000000-0000-4000-8000-000000000010',
      '40000000-0000-4000-8000-000000000001',
      'memory/test/invalid-state.jpg',
      'image',
      0,
      'unknown'
    )
  $$,
  'memory_media_upload_state_check',
  'unsupported media upload states are rejected'
);

insert into public.memory_media (
  id, memory_version_id, object_path, media_type, sort_order, upload_state
)
values
  (
    '60000000-0000-4000-8000-000000000001',
    '40000000-0000-4000-8000-000000000001',
    'memory/test/image-1.jpg',
    'image',
    0,
    'uploaded'
  ),
  (
    '60000000-0000-4000-8000-000000000002',
    '40000000-0000-4000-8000-000000000001',
    'memory/test/image-2.jpg',
    'image',
    1,
    'uploaded'
  ),
  (
    '60000000-0000-4000-8000-000000000003',
    '40000000-0000-4000-8000-000000000001',
    'memory/test/image-3.jpg',
    'image',
    2,
    'uploaded'
  );

select throws_matching(
  $$
    insert into public.memory_media (
      id, memory_version_id, object_path, media_type, sort_order, upload_state
    ) values (
      '60000000-0000-4000-8000-000000000004',
      '40000000-0000-4000-8000-000000000001',
      'memory/test/image-4.jpg',
      'image',
      3,
      'uploaded'
    )
  $$,
  'memory version exceeds media limits',
  'a memory version cannot contain more than three images'
);

insert into public.memory_media (
  id, memory_version_id, object_path, media_type, sort_order, upload_state
)
values (
  '60000000-0000-4000-8000-000000000005',
  '40000000-0000-4000-8000-000000000001',
  'memory/test/video-1.mp4',
  'video',
  3,
  'uploaded'
);

delete from public.memory_media
where id = '60000000-0000-4000-8000-000000000003';

select throws_matching(
  $$
    insert into public.memory_media (
      id, memory_version_id, object_path, media_type, sort_order, upload_state
    ) values (
      '60000000-0000-4000-8000-000000000006',
      '40000000-0000-4000-8000-000000000001',
      'memory/test/video-2.mp4',
      'video',
      2,
      'uploaded'
    )
  $$,
  'memory version exceeds media limits',
  'a memory version cannot contain more than one video'
);

select throws_matching(
  $$
    insert into public.memory_media (
      id, memory_version_id, object_path, media_type, sort_order, upload_state
    ) values (
      '60000000-0000-4000-8000-000000000007',
      '40000000-0000-4000-8000-000000000001',
      'memory/test/duplicate-order.jpg',
      'image',
      0,
      'uploaded'
    )
  $$,
  'memory_media_version_sort_order_key',
  'media order is unique inside one version'
);

select * from finish();
rollback;
