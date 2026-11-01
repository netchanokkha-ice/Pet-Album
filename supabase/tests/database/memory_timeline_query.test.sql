begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public;

select plan(7);

insert into auth.users (id, email)
values
  ('00000000-0000-4000-8000-000000000701', 'timeline-owner@example.test'),
  ('00000000-0000-4000-8000-000000000702', 'timeline-outsider@example.test');

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000701', true);
set local role authenticated;
select public.initialize_pet_journal(
  '10000000-0000-4000-8000-000000000701',
  '20000000-0000-4000-8000-000000000701',
  '30000000-0000-4000-8000-000000000701',
  '40000000-0000-4000-8000-000000000701',
  '50000000-0000-4000-8000-000000000701',
  'Timeline cat',
  'cat',
  null,
  null,
  null,
  null,
  'Newest published memory',
  current_date
);
insert into public.memory_media (
  id, memory_version_id, object_path, media_type, sort_order, is_cover, upload_state
) values (
  '60000000-0000-4000-8000-000000000701',
  '40000000-0000-4000-8000-000000000701',
  '00000000-0000-4000-8000-000000000701/memory/newest.jpg',
  'image', 0, true, 'uploaded'
);
select public.publish_memory(
  '30000000-0000-4000-8000-000000000701',
  '40000000-0000-4000-8000-000000000701'
);

reset role;
insert into public.memories (id, creator_user_id, lifecycle_status, privacy)
values
  ('30000000-0000-4000-8000-000000000702', '00000000-0000-4000-8000-000000000701', 'draft', 'only_me'),
  ('30000000-0000-4000-8000-000000000703', '00000000-0000-4000-8000-000000000701', 'draft', 'only_me');
insert into public.memory_versions (
  id, memory_id, created_by_user_id, version_number, version_state, title, memory_date
) values
  (
    '40000000-0000-4000-8000-000000000702',
    '30000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000701',
    1, 'draft', 'Older draft memory', current_date - 1
  ),
  (
    '40000000-0000-4000-8000-000000000703',
    '30000000-0000-4000-8000-000000000703',
    '00000000-0000-4000-8000-000000000701',
    1, 'draft', 'Deleted private memory', current_date - 2
  );
update public.memories
set current_working_version_id = case id
  when '30000000-0000-4000-8000-000000000702'::uuid
    then '40000000-0000-4000-8000-000000000702'::uuid
  else '40000000-0000-4000-8000-000000000703'::uuid
end
where id in (
  '30000000-0000-4000-8000-000000000702',
  '30000000-0000-4000-8000-000000000703'
);
insert into public.pet_memories (id, pet_id, memory_id, created_by_user_id)
values
  (
    '50000000-0000-4000-8000-000000000702',
    '10000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000702',
    '00000000-0000-4000-8000-000000000701'
  ),
  (
    '50000000-0000-4000-8000-000000000703',
    '10000000-0000-4000-8000-000000000701',
    '30000000-0000-4000-8000-000000000703',
    '00000000-0000-4000-8000-000000000701'
  );
update public.memories
set lifecycle_status = 'soft_deleted',
    deleted_at = now(),
    deletion_expires_at = now() + interval '7 days',
    pre_deletion_status = 'draft'
where id = '30000000-0000-4000-8000-000000000703';

select ok(
  has_function_privilege('authenticated', 'public.get_memory_timeline(uuid,date,uuid,integer)', 'EXECUTE'),
  'authenticated can execute the timeline query'
);
select ok(
  not has_function_privilege('anon', 'public.get_memory_timeline(uuid,date,uuid,integer)', 'EXECUTE'),
  'anonymous callers cannot execute the timeline query'
);

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000701', true);
set local role authenticated;
select is(
  (select count(*)::bigint from public.get_memory_timeline('10000000-0000-4000-8000-000000000701')),
  2::bigint,
  'active published and draft memories are visible while soft-deleted memory is excluded'
);
select results_eq(
  $$select title from public.get_memory_timeline('10000000-0000-4000-8000-000000000701')$$,
  $$values ('Newest published memory'::text), ('Older draft memory'::text)$$,
  'timeline orders entries by memory date descending'
);
select is(
  (
    select working_version_state
    from public.get_memory_timeline('10000000-0000-4000-8000-000000000701')
    where memory_id = '30000000-0000-4000-8000-000000000702'
  ),
  'draft',
  'authorized working memory carries a draft indicator'
);
select is(
  (
    select working_version_id
    from public.get_memory_timeline('10000000-0000-4000-8000-000000000701')
    where memory_id = '30000000-0000-4000-8000-000000000702'
  ),
  '40000000-0000-4000-8000-000000000702'::uuid,
  'authorized draft includes the working version id for exact resume routing'
);

reset role;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000702', true);
set local role authenticated;
select throws_matching(
  $$select * from public.get_memory_timeline('10000000-0000-4000-8000-000000000701')$$,
  'pet ownership required',
  'non-owner cannot read the private timeline'
);

reset role;
select * from finish();
rollback;
