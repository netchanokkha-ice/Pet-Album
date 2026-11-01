begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public;

select plan(16);

select is(
  (
    select count(*)::bigint
    from storage.buckets
    where id in ('pet-media', 'memory-media')
  ),
  2::bigint,
  'both media buckets exist'
);
select is(
  (select public from storage.buckets where id = 'pet-media'),
  false,
  'pet media bucket is private'
);
select is(
  (select public from storage.buckets where id = 'memory-media'),
  false,
  'memory media bucket is private'
);
select is(
  (
    select count(*)::bigint
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname in (
        'pet_media_owner_select',
        'pet_media_owner_insert',
        'pet_media_owner_update',
        'memory_media_storage_owner_select',
        'memory_media_storage_owner_insert',
        'memory_media_storage_owner_update'
      )
  ),
  6::bigint,
  'upload, read, and replace policies exist for both buckets'
);

insert into auth.users (id, email)
values
  ('00000000-0000-4000-8000-000000000201', 'storage-owner@example.test'),
  ('00000000-0000-4000-8000-000000000202', 'storage-outsider@example.test');

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000201',
  true
);
set local role authenticated;

select lives_ok(
  $$
    insert into storage.objects (bucket_id, name, metadata)
    values (
      'pet-media',
      '00000000-0000-4000-8000-000000000201/10000000-0000-4000-8000-000000000201/profile/portrait.jpg',
      '{"mimetype":"image/jpeg"}'::jsonb
    )
  $$,
  'owner can upload pet media in the account path'
);
select lives_ok(
  $$
    insert into storage.objects (bucket_id, name, metadata)
    values (
      'memory-media',
      '00000000-0000-4000-8000-000000000201/30000000-0000-4000-8000-000000000201/40000000-0000-4000-8000-000000000201/60000000-0000-4000-8000-000000000201.jpg',
      '{"mimetype":"image/jpeg"}'::jsonb
    )
  $$,
  'owner can upload memory media in the account path'
);
select is(
  (select count(*)::bigint from storage.objects where bucket_id = 'pet-media'),
  1::bigint,
  'owner can read pet media'
);
select is(
  (select count(*)::bigint from storage.objects where bucket_id = 'memory-media'),
  1::bigint,
  'owner can read memory media'
);
select lives_ok(
  $$
    update storage.objects
    set metadata = '{"mimetype":"image/webp","replaced":true}'::jsonb
    where bucket_id = 'pet-media'
  $$,
  'owner can replace pet media metadata'
);
select lives_ok(
  $$
    update storage.objects
    set metadata = '{"mimetype":"image/webp","replaced":true}'::jsonb
    where bucket_id = 'memory-media'
  $$,
  'owner can replace memory media metadata'
);
select throws_matching(
  $$
    insert into storage.objects (bucket_id, name)
    values (
      'pet-media',
      '00000000-0000-4000-8000-000000000202/other-pet/profile.jpg'
    )
  $$,
  'row-level security policy.*objects',
  'owner cannot upload into another account pet path'
);
select throws_matching(
  $$
    insert into storage.objects (bucket_id, name)
    values (
      'memory-media',
      '00000000-0000-4000-8000-000000000202/other-memory/version/media.jpg'
    )
  $$,
  'row-level security policy.*objects',
  'owner cannot upload into another account memory path'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000202',
  true
);
set local role authenticated;

select is(
  (select count(*)::bigint from storage.objects where bucket_id = 'pet-media'),
  0::bigint,
  'cross-user pet media reads return no rows'
);
select is(
  (select count(*)::bigint from storage.objects where bucket_id = 'memory-media'),
  0::bigint,
  'cross-user memory media reads return no rows'
);
update storage.objects
set metadata = '{"tampered":true}'::jsonb
where bucket_id = 'pet-media';

update storage.objects
set metadata = '{"tampered":true}'::jsonb
where bucket_id = 'memory-media';

reset role;
select is(
  (
    select coalesce(metadata ->> 'tampered', 'false')
    from storage.objects
    where bucket_id = 'pet-media'
      and name = '00000000-0000-4000-8000-000000000201/10000000-0000-4000-8000-000000000201/profile/portrait.jpg'
  ),
  'false',
  'cross-user pet media replace changes no rows'
);
select is(
  (
    select coalesce(metadata ->> 'tampered', 'false')
    from storage.objects
    where bucket_id = 'memory-media'
      and name = '00000000-0000-4000-8000-000000000201/30000000-0000-4000-8000-000000000201/40000000-0000-4000-8000-000000000201/60000000-0000-4000-8000-000000000201.jpg'
  ),
  'false',
  'cross-user memory media replace changes no rows'
);

select * from finish();
rollback;
