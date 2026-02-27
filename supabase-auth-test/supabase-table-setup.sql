-- Run this in Supabase Dashboard → SQL Editor → New query, then Run.
-- This creates a table that stores user email/name when they sign in with Google.

-- Table to hold user profile data (so you see rows in Table Editor)
create table if not exists public.auth_users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  avatar_url text,
  updated_at timestamptz default now()
);

-- Allow the app to read/write this table (RLS)
alter table public.auth_users enable row level security;

-- Drop existing policies so this script can be run again without errors
drop policy if exists "Users can insert own row" on public.auth_users;
drop policy if exists "Users can update own row" on public.auth_users;
drop policy if exists "Users can read own row" on public.auth_users;

-- Users can insert their own row (first sign-in)
create policy "Users can insert own row"
  on public.auth_users for insert
  with check (auth.uid() = id);

-- Users can update their own row (e.g. name/avatar change on next sign-in)
create policy "Users can update own row"
  on public.auth_users for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Users can read their own row
create policy "Users can read own row"
  on public.auth_users for select
  using (auth.uid() = id);

-- Optional: service role can read all (for admin). Skip if you don't need it.
-- create policy "Service role read all" on public.auth_users for select using (auth.jwt() ->> 'role' = 'service_role');

comment on table public.auth_users is 'Stores email/name from Google sign-in; one row per user.';

-- Optional: payments table to record Razorpay payments for signed-in users (for testing both together)
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  razorpay_order_id text not null,
  razorpay_payment_id text,
  amount_paise integer not null,
  currency text default 'INR',
  created_at timestamptz default now()
);

alter table public.payments enable row level security;

drop policy if exists "Users can insert own payments" on public.payments;
drop policy if exists "Users can read own payments" on public.payments;

create policy "Users can insert own payments"
  on public.payments for insert
  with check (auth.uid() = user_id);

create policy "Users can read own payments"
  on public.payments for select
  using (auth.uid() = user_id);

create index if not exists payments_user_id_idx on public.payments(user_id);

comment on table public.payments is 'Stores Razorpay payment info for testing auth + payment together.';
