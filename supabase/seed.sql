-- Deterministic local-only fixtures. These placeholder Auth rows have no
-- password and cannot sign in; use the local Auth UI for login-capable users.

insert into auth.users (
  id,
  aud,
  role,
  email,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-4000-8000-000000000401',
    'authenticated',
    'authenticated',
    'alice.seed@pawlum.local',
    '2025-01-01 00:00:00+00',
    '{"provider":"email","providers":["email"]}',
    '{"display_name":"Alice Seed"}',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  ),
  (
    '00000000-0000-4000-8000-000000000402',
    'authenticated',
    'authenticated',
    'bob.seed@pawlum.local',
    '2025-01-01 00:00:00+00',
    '{"provider":"email","providers":["email"]}',
    '{"display_name":"Bob Seed"}',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  );
insert into public.profiles (
  user_id,
  display_name,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-4000-8000-000000000401',
    'Alice Seed',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  ),
  (
    '00000000-0000-4000-8000-000000000402',
    'Bob Seed',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  );

insert into public.user_preferences (
  user_id,
  language_code,
  preferences,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-4000-8000-000000000401',
    'th',
    '{"seed":"alice"}',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  ),
  (
    '00000000-0000-4000-8000-000000000402',
    'en',
    '{"seed":"bob"}',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  );

insert into public.pets (
  id,
  owner_user_id,
  name,
  pet_type,
  birth_date,
  first_met_date,
  created_at,
  updated_at
)
values
  (
    '10000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401',
    'มะลิ',
    'cat',
    '2022-02-14',
    '2022-05-01',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  ),
  (
    '10000000-0000-4000-8000-000000000402',
    '00000000-0000-4000-8000-000000000402',
    'Mochi',
    'dog',
    '2023-03-20',
    '2023-06-10',
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
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
  can_manage_members,
  created_at,
  updated_at
)
values
  (
    '20000000-0000-4000-8000-000000000401',
    '10000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401',
    'owner',
    'active',
    true,
    true,
    true,
    true,
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  ),
  (
    '20000000-0000-4000-8000-000000000402',
    '10000000-0000-4000-8000-000000000402',
    '00000000-0000-4000-8000-000000000402',
    'owner',
    'active',
    true,
    true,
    true,
    true,
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  );

insert into public.memories (
  id,
  creator_user_id,
  lifecycle_status,
  privacy,
  is_first_memory,
  created_at,
  updated_at
)
values
  (
    '30000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401',
    'draft',
    'only_me',
    true,
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  ),
  (
    '30000000-0000-4000-8000-000000000402',
    '00000000-0000-4000-8000-000000000402',
    'draft',
    'only_me',
    true,
    '2025-01-01 00:00:00+00',
    '2025-01-01 00:00:00+00'
  );

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
  theme_key,
  template_key,
  layout_key,
  decoration_data,
  layout_data,
  presentation_schema_version,
  created_at,
  updated_at,
  published_at
)
values
  (
    '40000000-0000-4000-8000-000000000401',
    '30000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401',
    null,
    1,
    'published',
    'วันแรกของมะลิ',
    'ความทรงจำที่พร้อมแสดงบนไทม์ไลน์',
    '2024-12-31',
    'paper_cream',
    'polaroid',
    'single',
    '{"stickers":[]}',
    '{"version":1}',
    1,
    '2025-01-01 00:00:00+00',
    '2025-01-02 00:00:00+00',
    '2025-01-02 00:00:00+00'
  ),
  (
    '40000000-0000-4000-8000-000000000411',
    '30000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401',
    '40000000-0000-4000-8000-000000000401',
    2,
    'edit_draft',
    'วันแรกของมะลิ (กำลังแก้ไข)',
    'ฉบับร่างที่ยังไม่แทนฉบับเผยแพร่',
    '2024-12-31',
    'paper_cream',
    'polaroid',
    'single',
    '{"stickers":["heart"]}',
    '{"version":1}',
    1,
    '2025-02-01 00:00:00+00',
    '2025-02-01 00:00:00+00',
    null
  ),
  (
    '40000000-0000-4000-8000-000000000402',
    '30000000-0000-4000-8000-000000000402',
    '00000000-0000-4000-8000-000000000402',
    null,
    1,
    'draft',
    'Mochi draft',
    'A local-style draft waiting for upload.',
    '2025-01-15',
    'paper_cream',
    'polaroid',
    'single',
    '{"stickers":[]}',
    '{"version":1}',
    1,
    '2025-01-15 00:00:00+00',
    '2025-01-15 00:00:00+00',
    null
  );

update public.memories
set
  lifecycle_status = 'published',
  current_published_version_id = '40000000-0000-4000-8000-000000000401',
  current_working_version_id = '40000000-0000-4000-8000-000000000411',
  published_at = '2025-01-02 00:00:00+00',
  updated_at = '2025-02-01 00:00:00+00'
where id = '30000000-0000-4000-8000-000000000401';

update public.memories
set
  current_working_version_id = '40000000-0000-4000-8000-000000000402',
  updated_at = '2025-01-15 00:00:00+00'
where id = '30000000-0000-4000-8000-000000000402';

insert into public.pet_memories (
  id,
  pet_id,
  memory_id,
  created_by_user_id,
  created_at
)
values
  (
    '50000000-0000-4000-8000-000000000401',
    '10000000-0000-4000-8000-000000000401',
    '30000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401',
    '2025-01-01 00:00:00+00'
  ),
  (
    '50000000-0000-4000-8000-000000000402',
    '10000000-0000-4000-8000-000000000402',
    '30000000-0000-4000-8000-000000000402',
    '00000000-0000-4000-8000-000000000402',
    '2025-01-01 00:00:00+00'
  );

insert into public.memory_media (
  id,
  memory_version_id,
  object_path,
  media_type,
  sort_order,
  is_cover,
  mime_type,
  upload_state,
  presentation_data,
  created_at,
  updated_at
)
values
  (
    '60000000-0000-4000-8000-000000000401',
    '40000000-0000-4000-8000-000000000401',
    '00000000-0000-4000-8000-000000000401/30000000-0000-4000-8000-000000000401/40000000-0000-4000-8000-000000000401/60000000-0000-4000-8000-000000000401.jpg',
    'image',
    0,
    true,
    'image/jpeg',
    'uploaded',
    '{"fit":"cover"}',
    '2025-01-01 00:00:00+00',
    '2025-01-02 00:00:00+00'
  ),
  (
    '60000000-0000-4000-8000-000000000411',
    '40000000-0000-4000-8000-000000000411',
    '00000000-0000-4000-8000-000000000401/30000000-0000-4000-8000-000000000401/40000000-0000-4000-8000-000000000411/60000000-0000-4000-8000-000000000411.jpg',
    'image',
    0,
    true,
    'image/jpeg',
    'queued',
    '{"fit":"cover"}',
    '2025-02-01 00:00:00+00',
    '2025-02-01 00:00:00+00'
  ),
  (
    '60000000-0000-4000-8000-000000000402',
    '40000000-0000-4000-8000-000000000402',
    '00000000-0000-4000-8000-000000000402/30000000-0000-4000-8000-000000000402/40000000-0000-4000-8000-000000000402/60000000-0000-4000-8000-000000000402.jpg',
    'image',
    0,
    true,
    'image/jpeg',
    'queued',
    '{"fit":"cover"}',
    '2025-01-15 00:00:00+00',
    '2025-01-15 00:00:00+00'
  );
