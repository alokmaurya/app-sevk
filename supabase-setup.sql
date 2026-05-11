-- ══════════════════════════════════════════
-- SEVK — Supabase Database Setup
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ══════════════════════════════════════════

-- 1. Bookings table
create table public.bookings (
  id             uuid        default gen_random_uuid() primary key,
  user_id        uuid        references auth.users(id) on delete cascade not null,
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
  created_at     timestamptz default now()
);

-- 2. Vendors table
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

-- 3. Enable Row Level Security
alter table public.bookings enable row level security;
alter table public.vendors  enable row level security;

-- ── Booking policies (customers) ──
create policy "Customers can insert their own bookings"
  on public.bookings for insert
  with check (auth.uid() = user_id);

create policy "Customers can view their own bookings"
  on public.bookings for select
  using (auth.uid() = user_id);

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

-- ══════════════════════════════════════════
-- IF YOUR TABLES ALREADY EXIST — run only what's missing:
-- ══════════════════════════════════════════

-- Add vendor_id to existing bookings table:
-- alter table public.bookings
--   add column if not exists vendor_id uuid references public.vendors(id) on delete set null;

-- Add status column to existing bookings table:
-- alter table public.bookings
--   add column if not exists status text default 'Scheduled'
--   check (status in ('Scheduled', 'In Progress', 'Completed'));
