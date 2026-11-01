insert into storage.buckets (id, name, public)
values
  ('pet-media', 'pet-media', false),
  ('memory-media', 'memory-media', false)
on conflict (id) do update
set
  name = excluded.name,
  public = false;

-- Paths are account-scoped and retain stable aggregate identifiers after the
-- first segment, for example:
--   pet-media/<user-id>/<pet-id>/profile/<object-id>.jpg
--   memory-media/<user-id>/<memory-id>/<version-id>/<media-id>.jpg
create policy pet_media_owner_select
on storage.objects for select to authenticated
using (
  bucket_id = 'pet-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy pet_media_owner_insert
on storage.objects for insert to authenticated
with check (
  bucket_id = 'pet-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy pet_media_owner_update
on storage.objects for update to authenticated
using (
  bucket_id = 'pet-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'pet-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy memory_media_storage_owner_select
on storage.objects for select to authenticated
using (
  bucket_id = 'memory-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy memory_media_storage_owner_insert
on storage.objects for insert to authenticated
with check (
  bucket_id = 'memory-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy memory_media_storage_owner_update
on storage.objects for update to authenticated
using (
  bucket_id = 'memory-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'memory-media'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);
