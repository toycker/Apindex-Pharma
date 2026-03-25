-- Migration for a new Supabase project.
-- Purpose:
-- 1) Ensure minimal admin/auth bootstrap tables exist (admin_roles + profiles).
-- 2) Promote an existing user to admin access (Owner role with full permissions).
-- 3) Assign and normalize WhatsApp OTP phone number.
--
-- Update these values before running:
--   v_admin_email
--   v_input_phone

do $$
declare
  -- EDIT THESE TWO VALUES
  v_admin_email text := lower('kartavyatech@gmail.com');
  v_input_phone text := '9265348797';

  v_digits text;
  v_normalized_phone text;
  v_user_id uuid;
  v_owner_role_id text;
  v_conflict_exists boolean;
begin
  -- Extension for gen_random_uuid()
  create extension if not exists pgcrypto;

  -- Ensure admin_roles table exists
  create table if not exists public.admin_roles (
    id text primary key default ('role_' || gen_random_uuid()::text),
    name text not null unique,
    permissions jsonb not null default '[]'::jsonb,
    is_system boolean default false,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
  );

  -- Ensure profiles table exists (minimal shape required by this app)
  create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text,
    contact_email text,
    first_name text,
    last_name text,
    phone text,
    role text default 'customer',
    admin_role_id text references public.admin_roles(id),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
  );

  -- Add missing columns safely if table already existed with partial schema
  alter table public.profiles add column if not exists email text;
  alter table public.profiles add column if not exists contact_email text;
  alter table public.profiles add column if not exists first_name text;
  alter table public.profiles add column if not exists last_name text;
  alter table public.profiles add column if not exists phone text;
  alter table public.profiles add column if not exists role text default 'customer';
  alter table public.profiles add column if not exists admin_role_id text references public.admin_roles(id);
  alter table public.profiles add column if not exists created_at timestamptz default now();
  alter table public.profiles add column if not exists updated_at timestamptz default now();

  -- Normalize phone to 91XXXXXXXXXX format.
  v_digits := regexp_replace(v_input_phone, '\D', '', 'g');

  if length(v_digits) = 10 then
    v_normalized_phone := '91' || v_digits;
  elsif length(v_digits) = 12 and left(v_digits, 2) = '91' then
    v_normalized_phone := v_digits;
  else
    raise exception 'Invalid phone format. Use 10 digits or 91XXXXXXXXXX.';
  end if;

  if v_normalized_phone !~ '^91[6-9][0-9]{9}$' then
    raise exception 'Invalid Indian mobile number after normalization: %', v_normalized_phone;
  end if;

  -- Find user in auth.users by email
  select u.id
  into v_user_id
  from auth.users u
  where lower(u.email) = v_admin_email
  limit 1;

  if v_user_id is null then
    raise exception 'No auth user found for email: %. Create/sign-in this user first.', v_admin_email;
  end if;

  -- Ensure profile row exists for this auth user
  insert into public.profiles (id, email, created_at, updated_at)
  values (v_user_id, v_admin_email, now(), now())
  on conflict (id) do update
    set email = coalesce(public.profiles.email, excluded.email),
        updated_at = now();

  -- Prevent phone conflicts in public.profiles.
  select exists (
    select 1
    from public.profiles p
    where p.phone = v_normalized_phone
      and p.id <> v_user_id
  )
  into v_conflict_exists;

  if v_conflict_exists then
    raise exception 'Phone % is already used by another row in public.profiles', v_normalized_phone;
  end if;

  -- Prevent phone conflicts in auth.users.
  select exists (
    select 1
    from auth.users u
    where u.phone = v_normalized_phone
      and u.id <> v_user_id
  )
  into v_conflict_exists;

  if v_conflict_exists then
    raise exception 'Phone % is already used by another row in auth.users', v_normalized_phone;
  end if;

  -- Ensure Owner role exists and has full access wildcard.
  insert into public.admin_roles (name, permissions, is_system)
  values ('Owner', '["*"]'::jsonb, true)
  on conflict (name) do update
    set permissions = '["*"]'::jsonb,
        is_system = true,
        updated_at = now()
  returning id into v_owner_role_id;

  -- Keep role='admin' for app compatibility and assign owner admin_role_id.
  update public.profiles p
  set
    role = 'admin',
    admin_role_id = v_owner_role_id,
    phone = v_normalized_phone,
    updated_at = now()
  where p.id = v_user_id;

  -- Sync auth.users phone + metadata.
  update auth.users u
  set
    phone = v_normalized_phone,
    phone_confirmed_at = coalesce(u.phone_confirmed_at, now()),
    raw_user_meta_data = coalesce(u.raw_user_meta_data, '{}'::jsonb)
      || jsonb_build_object(
        'phone', v_normalized_phone,
        'phone_number', v_normalized_phone
      ),
    updated_at = now()
  where u.id = v_user_id;

  raise notice 'Admin setup complete. email=%, user_id=%, phone=%, owner_role_id=%',
    v_admin_email, v_user_id, v_normalized_phone, v_owner_role_id;
end $$;

-- Verification query
select
  p.id,
  p.email,
  p.role,
  p.admin_role_id,
  ar.name as admin_role_name,
  ar.permissions,
  p.phone as profile_phone,
  u.phone as auth_phone,
  p.updated_at
from public.profiles p
left join public.admin_roles ar on ar.id = p.admin_role_id
left join auth.users u on u.id = p.id
where lower(p.email) = lower('kartavyatech@gmail.com');
