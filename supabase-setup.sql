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
  created_at     timestamptz default now()
);

-- 2. Enable Row Level Security (users can only see their own bookings)
alter table public.bookings enable row level security;

create policy "Users can insert their own bookings"
  on public.bookings for insert
  with check (auth.uid() = user_id);

create policy "Users can view their own bookings"
  on public.bookings for select
  using (auth.uid() = user_id);
