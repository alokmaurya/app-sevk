-- ══════════════════════════════════════════
-- SEVK — Supabase Database Setup
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ══════════════════════════════════════════

-- 1. Services table (lookup — created first, referenced by vendors & bookings)
create table public.services (
  id          text        primary key,
  name        text        not null,
  emoji       text        not null,
  description text        not null,
  created_at  timestamptz default now()
);

alter table public.services enable row level security;

-- Services are publicly readable (no auth required)
create policy "Anyone can view services"
  on public.services for select using (true);

-- Seed the five services
insert into public.services (id, name, emoji, description) values
  ('electrician', 'Electrician',      '⚡', 'Wiring, panels, fault finding & repairs'),
  ('plumber',     'Plumber',          '🔧', 'Leaks, pipe bursts & full installations'),
  ('wall',        'Wall Specialists', '🧱', 'Plastering, drywall & surface finishes'),
  ('glass',       'Glass Works',      '🪟', 'Windows, doors, glazing & replacements'),
  ('woodwork',    'Wood Work',              '🪵', 'Carpentry, furniture & custom woodwork'),
  ('painting',    'Painting & Decorating',  '🏠', 'Interior/exterior painting, wallpapering & decorating'),
  ('hvac',        'HVAC & Climate Control', '❄️', 'AC installation, heating systems & ventilation'),
  ('locksmith',   'Locksmith & Security',   '🔒', 'Lock fitting, key cutting & security systems');

-- 2. Customers table (must be created BEFORE bookings — bookings FK references it)
create table public.customers (
  id         uuid        default gen_random_uuid() primary key,
  user_id    uuid        references auth.users(id) on delete cascade not null unique,
  name       text        not null,
  email      text        not null,
  phone      text        default null,
  created_at timestamptz default now()
);

-- 2. Vendors table (must be created BEFORE bookings — bookings FK references it)
create table public.vendors (
  id             uuid        default gen_random_uuid() primary key,
  user_id        uuid        references auth.users(id) on delete cascade not null unique,
  name           text        not null,
  phone          text        not null,
  email          text        not null,
  service_id     text        not null,
  service_name   text        not null,
  service_emoji  text        not null,
  status         text        default 'active'
                             check (status in ('active', 'inactive')),
  created_at     timestamptz default now()
);

-- 3. Bookings table
create table public.bookings (
  id             uuid        default gen_random_uuid() primary key,
  customer_id    uuid        references public.customers(id) on delete cascade not null,
  ref_number     text        not null,
  service_id     text        not null,
  service_name   text        not null,
  service_emoji  text        not null,
  date           date        not null,
  time           text        not null,
  name           text        not null,
  phone          text        not null,
  email          text        not null,
  address        text        not null,
  notes          text        default '',
  status         text        default 'Scheduled'
                             check (status in ('Scheduled', 'In Progress', 'Completed')),
  vendor_id      uuid        references public.vendors(id) on delete set null,
  vendor_name    text        default null,
  otp            text        default null,
  started_at     timestamptz default null,
  completion_otp text        default null,
  completed_at   timestamptz default null,
  rating         integer     default null check (rating >= 1 and rating <= 5),
  created_at     timestamptz default now()
);

-- 4. Enable Row Level Security
alter table public.customers enable row level security;
alter table public.vendors   enable row level security;
alter table public.bookings  enable row level security;

-- ── Customer profile policies ──
create policy "Customers can insert their own profile"
  on public.customers for insert
  with check (auth.uid() = user_id);

create policy "Customers can view their own profile"
  on public.customers for select
  using (auth.uid() = user_id);

create policy "Customers can update their own profile"
  on public.customers for update
  using (auth.uid() = user_id);

-- ── Vendor profile policies ──
create policy "Vendors can insert their own profile"
  on public.vendors for insert
  with check (auth.uid() = user_id);

create policy "Vendors can view their own profile"
  on public.vendors for select
  using (auth.uid() = user_id);

create policy "Vendors can update their own profile"
  on public.vendors for update
  using (auth.uid() = user_id);

-- ── Booking policies (customers) ──
create policy "Customers can insert their own bookings"
  on public.bookings for insert
  with check (
    exists (
      select 1 from public.customers c
      where c.user_id = auth.uid()
        and c.id = bookings.customer_id
    )
  );

create policy "Customers can view their own bookings"
  on public.bookings for select
  using (
    exists (
      select 1 from public.customers c
      where c.user_id = auth.uid()
        and c.id = bookings.customer_id
    )
  );

create policy "Customers can submit rating on completed bookings"
  on public.bookings for update
  using (
    status = 'Completed' and
    exists (
      select 1 from public.customers c
      where c.user_id = auth.uid()
        and c.id = bookings.customer_id
    )
  )
  with check (
    exists (
      select 1 from public.customers c
      where c.user_id = auth.uid()
        and c.id = bookings.customer_id
    )
  );

-- ── Booking policies (vendors) ──
-- Vendors can see all unassigned bookings for their service type
create policy "Vendors can view available jobs for their service"
  on public.bookings for select
  using (
    exists (
      select 1 from public.vendors v
      where v.user_id = auth.uid()
        and v.service_id = bookings.service_id
        and v.status = 'active'
    )
  );

-- Vendors can see their own accepted jobs
create policy "Vendors can view their accepted jobs"
  on public.bookings for select
  using (
    exists (
      select 1 from public.vendors v
      where v.user_id = auth.uid()
        and v.id = bookings.vendor_id
    )
  );

-- Vendors can accept an unassigned booking (set vendor_id + status)
create policy "Vendors can accept unassigned jobs"
  on public.bookings for update
  using (
    bookings.vendor_id is null
    and exists (
      select 1 from public.vendors v
      where v.user_id = auth.uid()
        and v.service_id = bookings.service_id
        and v.status = 'active'
    )
  );

-- Vendors can update status on their own accepted jobs
create policy "Vendors can update status on their jobs"
  on public.bookings for update
  using (
    exists (
      select 1 from public.vendors v
      where v.user_id = auth.uid()
        and v.id = bookings.vendor_id
    )
  );

-- ══════════════════════════════════════════
-- IF YOUR TABLES ALREADY EXIST — run only what's missing:
-- ══════════════════════════════════════════

-- Create services table if missing:
-- create table public.services (id text primary key, name text not null, emoji text not null, description text not null, created_at timestamptz default now());
-- alter table public.services enable row level security;
-- create policy "Anyone can view services" on public.services for select using (true);
-- insert into public.services (id, name, emoji, description) values
--   ('electrician','Electrician','⚡','Wiring, panels, fault finding & repairs'),
--   ('plumber','Plumber','🔧','Leaks, pipe bursts & full installations'),
--   ('wall','Wall Specialists','🧱','Plastering, drywall & surface finishes'),
--   ('glass','Glass Works','🪟','Windows, doors, glazing & replacements'),
--   ('woodwork','Wood Work','🪵','Carpentry, furniture & custom woodwork');

-- Add new services to an existing services table:
-- insert into public.services (id, name, emoji, description) values
--   ('woodwork',  'Wood Work',              '🪵', 'Carpentry, furniture & custom woodwork'),
--   ('painting',  'Painting & Decorating',  '🏠', 'Interior/exterior painting, wallpapering & decorating'),
--   ('hvac',      'HVAC & Climate Control', '❄️', 'AC installation, heating systems & ventilation'),
--   ('locksmith', 'Locksmith & Security',   '🔒', 'Lock fitting, key cutting & security systems')
--   on conflict (id) do nothing;

-- Create customers table if missing:
-- create table public.customers (
--   id uuid default gen_random_uuid() primary key,
--   user_id uuid references auth.users(id) on delete cascade not null unique,
--   name text not null, email text not null, phone text default null,
--   created_at timestamptz default now()
-- );
-- alter table public.customers enable row level security;
-- (then add the three customer policies above)

-- Rename bookings.user_id → customer_id and re-point FK to customers:
-- alter table public.bookings rename column user_id to customer_id;
-- alter table public.bookings
--   drop constraint bookings_user_id_fkey,
--   add constraint bookings_customer_id_fkey
--     foreign key (customer_id) references public.customers(id) on delete cascade;

-- Drop old booking customer policies and recreate with customer_id:
-- drop policy "Customers can insert their own bookings" on public.bookings;
-- drop policy "Customers can view their own bookings" on public.bookings;
-- drop policy "Customers can submit rating on completed bookings" on public.bookings;
-- (then add the updated policies above)

-- Backfill customers table from existing auth.users (adjust as needed):
-- insert into public.customers (user_id, name, email)
--   select id, coalesce(raw_user_meta_data->>'first_name','') || ' ' ||
--          coalesce(raw_user_meta_data->>'last_name',''), email
--   from auth.users
--   where id not in (select user_id from public.vendors)
--   on conflict do nothing;
