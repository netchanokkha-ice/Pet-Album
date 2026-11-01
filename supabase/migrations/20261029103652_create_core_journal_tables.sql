-- Pawlum core journal records. IDs are intentionally supplied by clients so a
-- local draft can keep the same identity through retries and remote sync.

create table public.profiles (
  user_id uuid primary key,
  display_name text,
  avatar_object_path text,
  created_at timestamptz not null default now()
);

create table public.user_preferences (
  user_id uuid primary key,
  language_code text not null default 'th',
  preferences jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.pets (
  id uuid primary key,
  owner_user_id uuid not null,
  name text not null,
  pet_type text not null,
  custom_type_label text,
  profile_image_object_path text,
  birth_date date,
  first_met_date date,
  created_at timestamptz not null default now()
);

create table public.pet_memberships (
  id uuid primary key,
  pet_id uuid not null,
  user_id uuid not null,
  role text not null,
  status text not null,
  can_edit_profile boolean not null default false,
  can_create_memories boolean not null default false,
  can_manage_memories boolean not null default false,
  can_manage_members boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.memories (
  id uuid primary key,
  creator_user_id uuid not null,
  lifecycle_status text not null,
  privacy text not null default 'only_me',
  current_published_version_id uuid,
  current_working_version_id uuid,
  is_first_memory boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.memory_versions (
  id uuid primary key,
  memory_id uuid not null,
  created_by_user_id uuid not null,
  base_version_id uuid,
  version_number bigint not null,
  version_state text not null,
  title text,
  caption text,
  memory_date date not null,
  mood text,
  location text,
  occasion text,
  theme_key text not null default 'pawlum_default',
  template_key text not null default 'classic',
  layout_key text not null default 'single',
  decoration_data jsonb not null default '{}'::jsonb,
  layout_data jsonb not null default '{}'::jsonb,
  presentation_schema_version integer not null default 1,
  created_at timestamptz not null default now()
);

create table public.pet_memories (
  id uuid primary key,
  pet_id uuid not null,
  memory_id uuid not null,
  created_by_user_id uuid not null,
  created_at timestamptz not null default now()
);

create table public.memory_media (
  id uuid primary key,
  memory_version_id uuid not null,
  object_path text not null,
  thumbnail_object_path text,
  media_type text not null,
  sort_order integer not null,
  is_cover boolean not null default false,
  mime_type text,
  byte_size bigint,
  pixel_width integer,
  pixel_height integer,
  duration_ms bigint,
  presentation_data jsonb not null default '{}'::jsonb,
  upload_state text not null,
  checksum_sha256 text,
  created_at timestamptz not null default now()
);
