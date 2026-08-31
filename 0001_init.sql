-- IC: Home — Phase 1 schema
-- Table names stay generic (homes, home_assets, maintenance_tasks) even
-- though the product surface speaks in incident-command language
-- (Resources, Action Items, Incident Log) — the schema shouldn't have to
-- be renamed every time the product's voice changes.
-- Every table is scoped to auth.uid() via homes.user_id, either directly
-- or through a join, and RLS is enabled everywhere. Users only ever see
-- their own data; the AI layer inherits the same restriction because it
-- reads through the same Supabase client with the user's session.

create table if not exists homes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  address text not null,
  year_built int,
  square_footage int,
  bedrooms int,
  bathrooms numeric,
  created_at timestamptz not null default now()
);

create type asset_category as enum (
  'hvac','water_heater','pool','roof','appliance','vehicle','electrical','plumbing','other'
);

create table if not exists home_assets (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references homes(id) on delete cascade,
  category asset_category not null,
  manufacturer text,
  model_number text,
  serial_number text,
  install_date date,
  estimated_age_years numeric,
  specs jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists asset_photos (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references home_assets(id) on delete cascade,
  storage_path text not null,
  ai_extracted_data jsonb default '{}'::jsonb,
  uploaded_at timestamptz not null default now()
);

create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references homes(id) on delete cascade,
  asset_id uuid references home_assets(id) on delete set null,
  doc_type text not null check (doc_type in ('warranty','receipt','manual','inspection','insurance','other')),
  storage_path text not null,
  ai_extracted_data jsonb default '{}'::jsonb,
  expiry_date date,
  uploaded_at timestamptz not null default now()
);

create table if not exists maintenance_tasks (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references home_assets(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'upcoming' check (status in ('today','this_week','this_month','upcoming','overdue','completed')),
  due_date date,
  completed_date date,
  completed_by text,
  cost numeric,
  recurrence_interval_days int
);

create table if not exists service_records (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references home_assets(id) on delete cascade,
  performed_date date not null,
  performed_by text,
  cost numeric,
  notes text
);

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  asset_id uuid references home_assets(id) on delete cascade,
  message text not null,
  type text,
  sent_at timestamptz default now(),
  read_at timestamptz
);

-- ---------- Row Level Security ----------

alter table homes enable row level security;
alter table home_assets enable row level security;
alter table asset_photos enable row level security;
alter table documents enable row level security;
alter table maintenance_tasks enable row level security;
alter table service_records enable row level security;
alter table notifications enable row level security;

create policy "homes: owner full access" on homes
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "home_assets: owner full access" on home_assets
  for all using (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()))
  with check (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()));

create policy "asset_photos: owner full access" on asset_photos
  for all using (exists (
    select 1 from home_assets a join homes h on h.id = a.home_id
    where a.id = asset_id and h.user_id = auth.uid()
  ));

create policy "documents: owner full access" on documents
  for all using (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()))
  with check (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()));

create policy "maintenance_tasks: owner full access" on maintenance_tasks
  for all using (exists (
    select 1 from home_assets a join homes h on h.id = a.home_id
    where a.id = asset_id and h.user_id = auth.uid()
  ));

create policy "service_records: owner full access" on service_records
  for all using (exists (
    select 1 from home_assets a join homes h on h.id = a.home_id
    where a.id = asset_id and h.user_id = auth.uid()
  ));

create policy "notifications: owner full access" on notifications
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
