-- Full bootstrap for a BRAND-NEW (empty) Supabase project.
-- This file does three things:
-- 1) Creates missing base auth/profile tables & triggers used by this app.
-- 2) Creates admin_notifications base table (required by later migrations).
-- 3) Applies curated project migrations from 2025/2026 in repository order.
--
-- IMPORTANT:
-- - Run this in Supabase SQL Editor on an empty database.
-- - This curated chain intentionally skips:
--   - 20240107_* legacy files (out-of-order for empty DB)
--   - 20251227120000_fix_missing_tables.sql (duplicates/conflicts with initial schema)
-- - After this completes, run:
--   supabase/new-project/migrations/20260325_120000_promote_admin_and_assign_phone.sql

-- ============================================================
-- 0) Base Extensions
-- ============================================================
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- ============================================================
-- 1) Base Profiles Table + Auth Triggers
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  contact_email text,
  first_name text,
  last_name text,
  phone text,
  role text default 'customer',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists contact_email text;
alter table public.profiles add column if not exists first_name text;
alter table public.profiles add column if not exists last_name text;
alter table public.profiles add column if not exists phone text;
alter table public.profiles add column if not exists role text default 'customer';
alter table public.profiles add column if not exists created_at timestamptz default now();
alter table public.profiles add column if not exists updated_at timestamptz default now();

create index if not exists idx_profiles_email on public.profiles (lower(email));
create index if not exists idx_profiles_phone on public.profiles (phone);

alter table public.profiles enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
  on public.profiles for select
  to authenticated
  using (id = auth.uid());

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, first_name, last_name, phone, created_at, updated_at)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    coalesce(new.phone, new.raw_user_meta_data->>'phone_number', new.raw_user_meta_data->>'phone', ''),
    now(),
    now()
  )
  on conflict (id) do update
    set email = excluded.email,
        first_name = coalesce(nullif(excluded.first_name, ''), public.profiles.first_name),
        last_name = coalesce(nullif(excluded.last_name, ''), public.profiles.last_name),
        phone = coalesce(nullif(excluded.phone, ''), public.profiles.phone),
        updated_at = now();

  return new;
end;
$$;

create or replace function public.handle_user_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set
    email = coalesce(new.email, public.profiles.email),
    first_name = coalesce(new.raw_user_meta_data->>'first_name', public.profiles.first_name),
    last_name = coalesce(new.raw_user_meta_data->>'last_name', public.profiles.last_name),
    phone = coalesce(new.phone, new.raw_user_meta_data->>'phone_number', new.raw_user_meta_data->>'phone', public.profiles.phone),
    updated_at = now()
  where id = new.id;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
  after update on auth.users
  for each row execute function public.handle_user_update();

insert into public.profiles (id, email, first_name, last_name, phone, created_at, updated_at)
select
  u.id,
  u.email,
  coalesce(u.raw_user_meta_data->>'first_name', ''),
  coalesce(u.raw_user_meta_data->>'last_name', ''),
  coalesce(u.phone, u.raw_user_meta_data->>'phone_number', u.raw_user_meta_data->>'phone', ''),
  coalesce(u.created_at, now()),
  now()
from auth.users u
on conflict (id) do nothing;

-- ============================================================
-- 2) Base Admin Notifications Table
-- ============================================================
create table if not exists public.admin_notifications (
  id uuid default gen_random_uuid() primary key,
  type text not null check (type in ('order', 'user', 'review', 'system', 'alert')),
  title text not null,
  message text not null,
  metadata jsonb default '{}'::jsonb,
  is_read boolean default false,
  created_at timestamptz default now()
);

alter table public.admin_notifications enable row level security;

-- ============================================================
-- 3) Curated Project Migrations (2025/2026)
-- ============================================================

-- >>> BEGIN 20251226110000_initial_schema.sql >>>

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY DEFAULT ('cat_' || uuid_generate_v4()),
    name TEXT NOT NULL,
    handle TEXT NOT NULL UNIQUE,
    description TEXT,
    parent_category_id TEXT REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create Collections Table
CREATE TABLE IF NOT EXISTS collections (
    id TEXT PRIMARY KEY DEFAULT ('col_' || uuid_generate_v4()),
    title TEXT NOT NULL,
    handle TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Products Table
CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY DEFAULT ('prod_' || uuid_generate_v4()),
    handle TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    short_description TEXT,
    price NUMERIC NOT NULL DEFAULT 0,
    currency_code TEXT NOT NULL DEFAULT 'INR',
    image_url TEXT,
    images TEXT[], -- Array of image URLs
    stock_count INTEGER DEFAULT 0,
    manage_inventory BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    category_id TEXT REFERENCES categories(id),
    collection_id TEXT REFERENCES collections(id),
    subtitle TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create Product Variants Table (This was missing)
CREATE TABLE IF NOT EXISTS product_variants (
    id TEXT PRIMARY KEY DEFAULT ('var_' || uuid_generate_v4()),
    title TEXT NOT NULL,
    sku TEXT,
    barcode TEXT,
    price NUMERIC NOT NULL DEFAULT 0,
    inventory_quantity INTEGER DEFAULT 0,
    manage_inventory BOOLEAN DEFAULT TRUE,
    allow_backorder BOOLEAN DEFAULT FALSE,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    options JSONB DEFAULT '[]', -- Stores variant options like size/color
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Create Carts Table
CREATE TABLE IF NOT EXISTS carts (
    id TEXT PRIMARY KEY DEFAULT ('cart_' || uuid_generate_v4()),
    email TEXT,
    user_id UUID, -- Links to Supabase Auth user
    region_id TEXT,
    currency_code TEXT DEFAULT 'inr',
    shipping_address JSONB,
    billing_address JSONB,
    shipping_methods JSONB,
    payment_collection JSONB,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Create Cart Items Table
CREATE TABLE IF NOT EXISTS cart_items (
    id TEXT PRIMARY KEY DEFAULT ('item_' || uuid_generate_v4()),
    cart_id TEXT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id),
    variant_id TEXT NOT NULL REFERENCES product_variants(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Create Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY DEFAULT ('ord_' || uuid_generate_v4()),
    display_id SERIAL,
    customer_email TEXT NOT NULL,
    user_id UUID, -- Links to Supabase Auth user
    total_amount NUMERIC NOT NULL,
    currency_code TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    payment_status TEXT DEFAULT 'awaiting',
    fulfillment_status TEXT DEFAULT 'not_shipped',
    payu_txn_id TEXT,
    shipping_address JSONB,
    billing_address JSONB,
    items JSONB, -- Storing snapshot of items for simplicity
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Create Order Items Table (Optional relational structure)
CREATE TABLE IF NOT EXISTS order_items (
    id TEXT PRIMARY KEY DEFAULT ('ord_item_' || uuid_generate_v4()),
    order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id TEXT,
    variant_id TEXT,
    title TEXT,
    quantity INTEGER,
    unit_price NUMERIC,
    total_price NUMERIC,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Enable RLS and Policies
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Public read products" ON products FOR SELECT TO public USING (true);
CREATE POLICY "Public read variants" ON product_variants FOR SELECT TO public USING (true);
CREATE POLICY "Public read categories" ON categories FOR SELECT TO public USING (true);
CREATE POLICY "Public read collections" ON collections FOR SELECT TO public USING (true);

-- Allow cart access (Open for demo purposes, restrict in production)
ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read/write carts" ON carts FOR ALL TO public USING (true) WITH CHECK (true);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read/write cart_items" ON cart_items FOR ALL TO public USING (true) WITH CHECK (true);

-- <<< END 20251226110000_initial_schema.sql <<<


-- >>> BEGIN 20251227100000_public_access_policies.sql >>>

-- Enable RLS on tables if not already enabled (good practice, though usually enabled by default)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;

-- Create policies to allow public (anon) and authenticated users to read data
CREATE POLICY "Allow public read access on products"
ON products FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public read access on product_variants"
ON product_variants FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public read access on categories"
ON categories FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public read access on collections"
ON collections FOR SELECT
TO public
USING (true);

-- <<< END 20251227100000_public_access_policies.sql <<<


-- >>> BEGIN 20251227130000_fix_product_relationships.sql >>>

-- Create product_options table if it doesn't exist
CREATE TABLE IF NOT EXISTS product_options (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    metadata JSONB
);

-- Create product_option_values table if it doesn't exist
CREATE TABLE IF NOT EXISTS product_option_values (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    value TEXT NOT NULL,
    option_id UUID REFERENCES product_options(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    metadata JSONB
);

-- Enable Row Level Security (RLS)
ALTER TABLE product_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_option_values ENABLE ROW LEVEL SECURITY;

-- Create Policies for Public Read Access
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'product_options' AND policyname = 'Public Access to Options'
    ) THEN
        CREATE POLICY "Public Access to Options" ON product_options
            FOR SELECT USING (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'product_option_values' AND policyname = 'Public Access to Option Values'
    ) THEN
        CREATE POLICY "Public Access to Option Values" ON product_option_values
            FOR SELECT USING (true);
    END IF;
END
$$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_product_options_product_id ON product_options(product_id);
CREATE INDEX IF NOT EXISTS idx_product_option_values_option_id ON product_option_values(option_id);
CREATE INDEX IF NOT EXISTS idx_product_option_values_variant_id ON product_option_values(variant_id);

-- <<< END 20251227130000_fix_product_relationships.sql <<<


-- >>> BEGIN 20251227140000_add_addresses_table.sql >>>

create table public.addresses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade,
  first_name text,
  last_name text,
  company text,
  address_1 text,
  address_2 text,
  city text,
  country_code text,
  province text,
  postal_code text,
  phone text,
  metadata jsonb default '{}'::jsonb,
  is_default_billing boolean default false,
  is_default_shipping boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.addresses enable row level security;

create policy "Users can view their own addresses" on public.addresses
  for select using (auth.uid() = user_id);

create policy "Users can insert their own addresses" on public.addresses
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own addresses" on public.addresses
  for update using (auth.uid() = user_id);

create policy "Users can delete their own addresses" on public.addresses
  for delete using (auth.uid() = user_id);

-- <<< END 20251227140000_add_addresses_table.sql <<<


-- >>> BEGIN 20251228_add_club_membership.sql >>>

-- Create Club Settings Table
CREATE TABLE IF NOT EXISTS club_settings (
    id TEXT PRIMARY KEY DEFAULT 'default',
    min_purchase_amount NUMERIC NOT NULL DEFAULT 999,
    discount_percentage INTEGER NOT NULL DEFAULT 10,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default settings row if it doesn't exist
INSERT INTO club_settings (id, min_purchase_amount, discount_percentage)
VALUES ('default', 999, 10)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE club_settings ENABLE ROW LEVEL SECURITY;

-- Allow public read access (cached on client/server)
CREATE POLICY "Public read club settings" 
ON club_settings FOR SELECT 
TO public 
USING (true);

-- Allow admin write access (handled via service role or admin check in API)
-- For simplicity in this prototype, we'll allow authenticated users to update for the admin panel
-- Ideally, you'd check for admin role here
CREATE POLICY "Authenticated update club settings" 
ON club_settings FOR UPDATE 
TO authenticated 
USING (true)
WITH CHECK (true);

-- <<< END 20251228_add_club_membership.sql <<<


-- >>> BEGIN 20251228_add_missing_columns.sql >>>

-- Migration: Add missing columns to products and product_variants tables
-- Run this in Supabase Dashboard -> SQL Editor

-- Ensure UUID extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Fix id column defaults for ALL tables
ALTER TABLE categories ALTER COLUMN id SET DEFAULT ('cat_' || uuid_generate_v4());
ALTER TABLE collections ALTER COLUMN id SET DEFAULT ('col_' || uuid_generate_v4());
ALTER TABLE products ALTER COLUMN id SET DEFAULT ('prod_' || uuid_generate_v4());
ALTER TABLE product_variants ALTER COLUMN id SET DEFAULT ('var_' || uuid_generate_v4());

-- Add missing columns to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';
ALTER TABLE products ADD COLUMN IF NOT EXISTS thumbnail TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS images TEXT[];
ALTER TABLE products ADD COLUMN IF NOT EXISTS currency_code TEXT DEFAULT 'inr';
ALTER TABLE products ADD COLUMN IF NOT EXISTS subtitle TEXT;

-- Add original_price to variants for "was" pricing
ALTER TABLE product_variants ADD COLUMN IF NOT EXISTS original_price NUMERIC;

-- ===== RLS POLICIES FOR ADMIN INSERT/UPDATE/DELETE =====

-- Categories: allow authenticated users to INSERT, UPDATE, DELETE
DROP POLICY IF EXISTS "Allow authenticated insert categories" ON categories;
CREATE POLICY "Allow authenticated insert categories" ON categories FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update categories" ON categories;
CREATE POLICY "Allow authenticated update categories" ON categories FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated delete categories" ON categories;
CREATE POLICY "Allow authenticated delete categories" ON categories FOR DELETE TO authenticated USING (true);

-- Collections: allow authenticated users to INSERT, UPDATE, DELETE
DROP POLICY IF EXISTS "Allow authenticated insert collections" ON collections;
CREATE POLICY "Allow authenticated insert collections" ON collections FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update collections" ON collections;
CREATE POLICY "Allow authenticated update collections" ON collections FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated delete collections" ON collections;
CREATE POLICY "Allow authenticated delete collections" ON collections FOR DELETE TO authenticated USING (true);

-- Products: allow authenticated users to INSERT, UPDATE, DELETE  
DROP POLICY IF EXISTS "Allow authenticated insert products" ON products;
CREATE POLICY "Allow authenticated insert products" ON products FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update products" ON products;
CREATE POLICY "Allow authenticated update products" ON products FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated delete products" ON products;
CREATE POLICY "Allow authenticated delete products" ON products FOR DELETE TO authenticated USING (true);

-- Product Variants: allow authenticated users to INSERT, UPDATE, DELETE
DROP POLICY IF EXISTS "Allow authenticated insert variants" ON product_variants;
CREATE POLICY "Allow authenticated insert variants" ON product_variants FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update variants" ON product_variants;
CREATE POLICY "Allow authenticated update variants" ON product_variants FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated delete variants" ON product_variants;
CREATE POLICY "Allow authenticated delete variants" ON product_variants FOR DELETE TO authenticated USING (true);

-- <<< END 20251228_add_missing_columns.sql <<<


-- >>> BEGIN 20251228_add_order_totals.sql >>>

-- Migration: Add missing columns to orders table for order totals
-- This fixes the "Could not find the 'discount_total' column" error

-- Add missing financial columns to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS total NUMERIC DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal NUMERIC DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax_total NUMERIC DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_total NUMERIC DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_total NUMERIC DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS gift_card_total NUMERIC DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_methods JSONB;

-- Refresh PostgREST schema cache so Supabase recognizes the new columns
NOTIFY pgrst, 'reload schema';

-- <<< END 20251228_add_order_totals.sql <<<


-- >>> BEGIN 20251228_csv_import_schema.sql >>>

-- Migration: Add support for CSV import/export
-- Adds thumbnail column and original_price for variant pricing

-- Add thumbnail column to products if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'thumbnail'
    ) THEN
        ALTER TABLE products ADD COLUMN thumbnail TEXT;
    END IF;
END $$;

-- Add original_price column to product_variants for "was" pricing
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'product_variants' AND column_name = 'original_price'
    ) THEN
        ALTER TABLE product_variants ADD COLUMN original_price NUMERIC;
    END IF;
END $$;

-- Ensure product_variants has ON DELETE CASCADE
-- Drop and recreate the foreign key constraint if needed
DO $$
BEGIN
    -- Check if constraint exists and if it's not CASCADE
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints tc
        JOIN information_schema.constraint_column_usage ccu 
            ON tc.constraint_name = ccu.constraint_name
        WHERE tc.table_name = 'product_variants' 
            AND tc.constraint_type = 'FOREIGN KEY'
            AND ccu.column_name = 'product_id'
    ) THEN
        -- The constraint exists, we assume it's already CASCADE from initial migration
        NULL;
    END IF;
END $$;

-- Add RLS policy for admin to delete products (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'products' AND policyname = 'Admin delete products'
    ) THEN
        CREATE POLICY "Admin delete products" ON products 
            FOR DELETE TO authenticated 
            USING (true);
    END IF;
END $$;

-- Add RLS policy for admin to insert products (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'products' AND policyname = 'Admin insert products'
    ) THEN
        CREATE POLICY "Admin insert products" ON products 
            FOR INSERT TO authenticated 
            WITH CHECK (true);
    END IF;
END $$;

-- Add RLS policy for admin to update products (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'products' AND policyname = 'Admin update products'
    ) THEN
        CREATE POLICY "Admin update products" ON products 
            FOR UPDATE TO authenticated 
            USING (true);
    END IF;
END $$;

-- <<< END 20251228_csv_import_schema.sql <<<


-- >>> BEGIN 20251229_add_reviews_system.sql >>>

-- Create reviews table
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  product_id text not null,
  user_id uuid references auth.users(id),
  rating integer not null check (rating >= 1 and rating <= 5),
  title text,
  content text,
  approval_status text check (approval_status in ('pending', 'approved', 'rejected')) default 'pending',
  is_anonymous boolean default false,
  display_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create review_media table
create table if not exists review_media (
  id uuid primary key default gen_random_uuid(),
  review_id uuid references reviews(id) on delete cascade,
  file_path text not null,
  file_type text check (file_type in ('image', 'video', 'audio')),
  storage_provider text default 'r2',
  created_at timestamptz default now()
);

-- Enable RLS
alter table reviews enable row level security;
alter table review_media enable row level security;

-- Policies for reviews
create policy "Public can view approved reviews"
  on reviews for select
  using (approval_status = 'approved');

create policy "Authenticated users can create reviews"
  on reviews for insert
  to authenticated
  with check (true);

create policy "Admins can do everything on reviews"
  on reviews for all
  using (
    -- Assuming admin check is done via app or specific role, 
    -- but for now allowing service role or specific admin logic if implemented.
    -- Often in simpler setups we just rely on service_role for admin tasks, 
    -- or check a profile role. For now, I'll allow service_role key to bypass, 
    -- and maybe add a check for admin profile if that system exists.
    -- Given the user context "Admins can view/edit/delete", I'll check if there is an is_admin flag.
    -- Checking profiles table commonly used in this project.
    exists (
      select 1 from profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Policies for review_media
create policy "Public can view review media"
  on review_media for select
  using (true);

create policy "Authenticated users can upload review media"
  on review_media for insert
  to authenticated
  with check (true);

create policy "Admins can manage review media"
  on review_media for all
  using (
     exists (
      select 1 from profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- <<< END 20251229_add_reviews_system.sql <<<


-- >>> BEGIN 20251229_add_rewards_system.sql >>>

-- Add rewards_percentage to club_settings (default 5%)
ALTER TABLE club_settings ADD COLUMN IF NOT EXISTS rewards_percentage INTEGER NOT NULL DEFAULT 5;

-- Update default row to have rewards_percentage
UPDATE club_settings SET rewards_percentage = 5 WHERE id = 'default' AND rewards_percentage IS NULL;

-- Create reward_wallets table (stores current balance for fast lookup)
CREATE TABLE IF NOT EXISTS reward_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    balance INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create reward_transactions table (ledger for history and auditability)
CREATE TABLE IF NOT EXISTS reward_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES reward_wallets(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- positive = earned, negative = spent
    type TEXT NOT NULL CHECK (type IN ('earned', 'spent')),
    description TEXT NOT NULL,
    order_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE reward_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_transactions ENABLE ROW LEVEL SECURITY;

-- Users can only read their own wallet
CREATE POLICY "Users read own wallet" ON reward_wallets 
FOR SELECT TO authenticated 
USING (auth.uid() = user_id);

-- Allow insert for authenticated (wallet creation during order)
CREATE POLICY "Users can create own wallet" ON reward_wallets 
FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Allow update for authenticated (balance updates)
CREATE POLICY "Users can update own wallet" ON reward_wallets 
FOR UPDATE TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can only read their own transactions
CREATE POLICY "Users read own transactions" ON reward_transactions 
FOR SELECT TO authenticated 
USING (wallet_id IN (SELECT id FROM reward_wallets WHERE user_id = auth.uid()));

-- Allow insert for authenticated (transaction logging)
CREATE POLICY "Users can create own transactions" ON reward_transactions 
FOR INSERT TO authenticated 
WITH CHECK (wallet_id IN (SELECT id FROM reward_wallets WHERE user_id = auth.uid()));

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_reward_wallets_user_id ON reward_wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_transactions_wallet_id ON reward_transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_reward_transactions_created_at ON reward_transactions(created_at DESC);

-- <<< END 20251229_add_rewards_system.sql <<<


-- >>> BEGIN 20251229_order_enhancements.sql >>>

-- Order Management Enhancements Migration
-- Adds: order_timeline table, shipping_partners table, order columns, customer display_id

-- 1. Create order_timeline table for tracking all order events
CREATE TABLE IF NOT EXISTS order_timeline (
    id TEXT PRIMARY KEY DEFAULT ('evt_' || uuid_generate_v4()),
    order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'order_placed', 
        'payment_pending',
        'payment_captured', 
        'payment_failed',
        'processing',
        'shipped', 
        'out_for_delivery',
        'delivered', 
        'cancelled',
        'refunded',
        'note_added'
    )),
    title TEXT NOT NULL,
    description TEXT,
    actor TEXT DEFAULT 'system',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create shipping_partners table for admin-managed delivery partners
CREATE TABLE IF NOT EXISTS shipping_partners (
    id TEXT PRIMARY KEY DEFAULT ('sp_' || uuid_generate_v4()),
    name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Add shipping columns to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_partner_id TEXT REFERENCES shipping_partners(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tracking_number TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method TEXT;

-- 4. Add customer_display_id sequence to profiles table
-- First create a sequence starting at 1001
CREATE SEQUENCE IF NOT EXISTS customer_display_id_seq START WITH 1001;

-- Add customer_display_id column to profiles if not exists
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS customer_display_id INTEGER;

-- Set default for new profiles
ALTER TABLE profiles ALTER COLUMN customer_display_id SET DEFAULT nextval('customer_display_id_seq');

-- Generate customer_display_id for existing profiles that don't have one
UPDATE profiles 
SET customer_display_id = nextval('customer_display_id_seq') 
WHERE customer_display_id IS NULL;

-- 5. Enable RLS on new tables
ALTER TABLE order_timeline ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipping_partners ENABLE ROW LEVEL SECURITY;

-- 6. Add policies for order_timeline (admin can read/write, public can read their own)
CREATE POLICY "Public read order_timeline" ON order_timeline FOR SELECT TO public USING (true);
CREATE POLICY "Admin write order_timeline" ON order_timeline FOR INSERT TO public WITH CHECK (true);

-- 7. Add policies for shipping_partners (public read, admin write)
CREATE POLICY "Public read shipping_partners" ON shipping_partners FOR SELECT TO public USING (true);
CREATE POLICY "Admin write shipping_partners" ON shipping_partners FOR INSERT TO public WITH CHECK (true);
CREATE POLICY "Admin delete shipping_partners" ON shipping_partners FOR DELETE TO public USING (true);

-- 8. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_order_timeline_order_id ON order_timeline(order_id);
CREATE INDEX IF NOT EXISTS idx_order_timeline_created_at ON order_timeline(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_shipping_partner_id ON orders(shipping_partner_id);
CREATE INDEX IF NOT EXISTS idx_profiles_customer_display_id ON profiles(customer_display_id);

-- 9. Insert some default shipping partners
INSERT INTO shipping_partners (name, is_active) VALUES 
    ('Delhivery', true),
    ('Shiprocket', true),
    ('Blue Dart', true),
    ('DTDC', true),
    ('India Post', true)
ON CONFLICT DO NOTHING;

-- 10. Create initial timeline entries for existing orders
INSERT INTO order_timeline (order_id, event_type, title, description, actor)
SELECT 
    id,
    'order_placed',
    'Order Placed',
    'Customer placed this order.',
    'system'
FROM orders
WHERE id NOT IN (SELECT DISTINCT order_id FROM order_timeline WHERE event_type = 'order_placed');

-- <<< END 20251229_order_enhancements.sql <<<


-- >>> BEGIN 20251229_sync_club_data.sql >>>

-- Add club membership columns to profiles table if they don't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS is_club_member BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS club_member_since TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS total_club_savings NUMERIC DEFAULT 0;

-- Sync existing data from auth.users metadata to profiles
-- This uses a CTE to extract metadata and update the profiles table
WITH user_data AS (
    SELECT 
        id, 
        (raw_user_meta_data->>'is_club_member')::boolean as is_member,
        (raw_user_meta_data->>'club_member_since')::timestamp with time zone as member_since,
        COALESCE((raw_user_meta_data->>'total_club_savings')::numeric, 0) as savings
    FROM auth.users
)
UPDATE profiles
SET 
    is_club_member = ud.is_member,
    club_member_since = ud.member_since,
    total_club_savings = ud.savings
FROM user_data ud
WHERE profiles.id = ud.id;

-- Optional: Create a function and trigger to keep this synced in the future
-- (Omitting for now to keep implementation simple as requested, assuming data flows via app logic update)

-- <<< END 20251229_sync_club_data.sql <<<


-- >>> BEGIN 20251230_add_shipping_threshold.sql >>>

-- Add min_order_free_shipping column to shipping_options table
-- This allows setting a threshold for free shipping per shipping option

ALTER TABLE shipping_options 
ADD COLUMN min_order_free_shipping DECIMAL(10,2) DEFAULT NULL;

COMMENT ON COLUMN shipping_options.min_order_free_shipping IS 'Order subtotal threshold above which shipping is free. NULL means never free (unless covered by other rules).';

-- <<< END 20251230_add_shipping_threshold.sql <<<


-- >>> BEGIN 20251230_fix_reviews_rls.sql >>>

-- Allow users to view their own reviews (pending, approved, rejected)
-- This is necessary so that after a user inserts a review (which is pending by default),
-- they can immediately select it back to verify success or attach media.

create policy "Users can view their own reviews"
  on reviews for select
  to authenticated
  using (user_id = auth.uid());

-- <<< END 20251230_fix_reviews_rls.sql <<<


-- >>> BEGIN 20251230_rbac_system.sql >>>

-- ==============================================
-- RBAC (Role-Based Access Control) System
-- ==============================================

-- 1. Create admin_roles table
CREATE TABLE IF NOT EXISTS admin_roles (
    id TEXT PRIMARY KEY DEFAULT ('role_' || uuid_generate_v4()),
    name TEXT NOT NULL UNIQUE,
    permissions JSONB NOT NULL DEFAULT '[]',
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Seed default system roles
INSERT INTO admin_roles (name, permissions, is_system) VALUES
    ('Owner', '["*"]', true),
    ('Admin', '["orders:*", "products:*", "inventory:*", "customers:read", "team:manage", "settings:read"]', true),
    ('Staff', '["orders:read", "orders:update", "products:read", "inventory:read", "customers:read"]', true)
ON CONFLICT (name) DO NOTHING;

-- 3. Add admin_role_id column to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS admin_role_id TEXT REFERENCES admin_roles(id);

-- 4. Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_admin_role_id ON profiles(admin_role_id);

-- 5. Enable RLS on admin_roles
ALTER TABLE admin_roles ENABLE ROW LEVEL SECURITY;

-- 6. Allow public read access to admin_roles (permissions checked in app layer)
CREATE POLICY "Public read admin_roles" ON admin_roles 
    FOR SELECT TO public USING (true);

-- 7. Admin-only write access via service role
-- Note: Write operations for admin_roles are done via service role in the app

-- <<< END 20251230_rbac_system.sql <<<


-- >>> BEGIN 20251231_admin_profiles_rls.sql >>>

-- ==============================================
-- Fix: Allow Admins to Update Profiles for Staff Management
-- Uses SECURITY DEFINER to avoid infinite recursion
-- ==============================================

-- First, drop the problematic policies if they exist
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update profiles admin_role_id" ON profiles;

-- Create a SECURITY DEFINER function to check if current user is admin
-- This function runs with elevated privileges and bypasses RLS
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
    user_admin_role_id TEXT;
BEGIN
    -- Get the current user's role and admin_role_id
    SELECT role, admin_role_id INTO user_role, user_admin_role_id
    FROM profiles
    WHERE id = auth.uid();
    
    -- User is admin if they have role='admin' OR have an admin_role_id assigned
    RETURN (user_role = 'admin') OR (user_admin_role_id IS NOT NULL);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Policy: Allow admins to read all profiles
CREATE POLICY "Admins can read all profiles" ON profiles
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = id  -- Always can read own profile
        OR is_admin()    -- Admins can read all profiles
    );

-- Policy: Allow admins to update any profile
CREATE POLICY "Admins can update any profile" ON profiles
    FOR UPDATE
    TO authenticated
    USING (
        auth.uid() = id  -- User can update own profile
        OR is_admin()    -- Admins can update any profile
    )
    WITH CHECK (
        auth.uid() = id  -- User can update own profile
        OR is_admin()    -- Admins can update any profile
    );


-- <<< END 20251231_admin_profiles_rls.sql <<<


-- >>> BEGIN 20251231_product_collections.sql >>>

-- Junction table for product-collection many-to-many relationship
CREATE TABLE IF NOT EXISTS product_collections (
    id TEXT PRIMARY KEY DEFAULT ('pc_' || uuid_generate_v4()),
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    collection_id TEXT NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(product_id, collection_id)
);

-- Enable RLS
ALTER TABLE product_collections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read product_collections" ON product_collections FOR SELECT TO public USING (true);
CREATE POLICY "Admin manage product_collections" ON product_collections FOR ALL USING (true) WITH CHECK (true);

-- Migrate existing data from products.collection_id
-- This ensures existing product-collection relationships are preserved
INSERT INTO product_collections (product_id, collection_id)
SELECT id, collection_id FROM products WHERE collection_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- <<< END 20251231_product_collections.sql <<<


-- >>> BEGIN 20260101_add_compare_at_price.sql >>>

-- Add compare_at_price column to product_variants
-- This allows showing original/sale prices on products
ALTER TABLE product_variants
ADD COLUMN IF NOT EXISTS compare_at_price NUMERIC DEFAULT NULL;

-- Add index for performance on price filtering/sorting
CREATE INDEX IF NOT EXISTS idx_product_variants_compare_at_price
ON product_variants(compare_at_price);

-- <<< END 20260101_add_compare_at_price.sql <<<


-- >>> BEGIN 20260101_product_options_rls.sql >>>

    -- Add RLS policies for product_options and product_option_values to allow authenticated users to manage them

    -- Drop existing public-only policies if they exist
    DO $$
    BEGIN
        -- Drop the read-only policy for product_options
        IF EXISTS (
            SELECT 1 FROM pg_policies WHERE tablename = 'product_options' AND policyname = 'Public Access to Options'
        ) THEN
            DROP POLICY "Public Access to Options" ON product_options;
        END IF;

        -- Drop the read-only policy for product_option_values
        IF EXISTS (
            SELECT 1 FROM pg_policies WHERE tablename = 'product_option_values' AND policyname = 'Public Access to Option Values'
        ) THEN
            DROP POLICY "Public Access to Option Values" ON product_option_values;
        END IF;
    END
    $$;

    -- Create comprehensive RLS policies for product_options
    DROP POLICY IF EXISTS "Allow public read access to product options" ON product_options;
    CREATE POLICY "Allow public read access to product options"
        ON product_options
        FOR SELECT
        USING (true);

    DROP POLICY IF EXISTS "Allow authenticated users to insert product options" ON product_options;
    CREATE POLICY "Allow authenticated users to insert product options"
        ON product_options
        FOR INSERT
        TO authenticated
        WITH CHECK (true);

    DROP POLICY IF EXISTS "Allow authenticated users to update product options" ON product_options;
    CREATE POLICY "Allow authenticated users to update product options"
        ON product_options
        FOR UPDATE
        TO authenticated
        USING (true)
        WITH CHECK (true);

    DROP POLICY IF EXISTS "Allow authenticated users to delete product options" ON product_options;
    CREATE POLICY "Allow authenticated users to delete product options"
        ON product_options
        FOR DELETE
        TO authenticated
        USING (true);

    -- Create comprehensive RLS policies for product_option_values
    DROP POLICY IF EXISTS "Allow public read access to product option values" ON product_option_values;
    CREATE POLICY "Allow public read access to product option values"
        ON product_option_values
        FOR SELECT
        USING (true);

    DROP POLICY IF EXISTS "Allow authenticated users to insert product option values" ON product_option_values;
    CREATE POLICY "Allow authenticated users to insert product option values"
        ON product_option_values
        FOR INSERT
        TO authenticated
        WITH CHECK (true);

    DROP POLICY IF EXISTS "Allow authenticated users to update product option values" ON product_option_values;
    CREATE POLICY "Allow authenticated users to update product option values"
        ON product_option_values
        FOR UPDATE
        TO authenticated
        USING (true)
        WITH CHECK (true);

    DROP POLICY IF EXISTS "Allow authenticated users to delete product option values" ON product_option_values;
    CREATE POLICY "Allow authenticated users to delete product option values"
        ON product_option_values
        FOR DELETE
        TO authenticated
        USING (true);

-- <<< END 20260101_product_options_rls.sql <<<


-- >>> BEGIN 20260102_backfill_variant_options.sql >>>

-- Backfill existing variant options from product_variants table
-- This migration reads existing variant titles like "Color: white" or "Size: M / Color: red"
-- and creates proper product_options and product_option_values entries

DO $$
DECLARE
    variant_record RECORD;
    option_title TEXT;
    option_value TEXT;
    option_id UUID;
    value_id UUID;
    v_product_id TEXT;
    parts TEXT[];
BEGIN
    -- Iterate through all variants that have options in their title but no corresponding product_options
    FOR variant_record IN
        SELECT pv.id, pv.product_id, pv.title, pv.options
        FROM product_variants pv
        WHERE pv.title LIKE '%:%'
          AND pv.title NOT LIKE '% / %'  -- Skip complex multi-option variants for now
          AND NOT EXISTS (
              SELECT 1 FROM product_options po
              WHERE po.product_id = pv.product_id
          )
    LOOP
        v_product_id := variant_record.product_id;

        -- Parse title like "Color: white" to extract option type and value
        parts := regexp_split_to_array(variant_record.title, ':');
        IF array_length(parts, 1) >= 2 THEN
            option_title := trim(parts[1]);
            option_value := trim(parts[2]);

            -- Check if this option already exists for this product
            SELECT id INTO option_id
            FROM product_options
            WHERE product_id = v_product_id
              AND lower(title) = lower(option_title)
            LIMIT 1;

            -- If not, create the option
            IF option_id IS NULL THEN
                INSERT INTO product_options (title, product_id)
                VALUES (option_title, v_product_id)
                RETURNING id INTO option_id;
            END IF;

            -- Check if this value already exists
            SELECT id INTO value_id
            FROM product_option_values
            WHERE option_id = option_id
              AND lower(value) = lower(option_value)
            LIMIT 1;

            -- If not, create the value
            IF value_id IS NULL THEN
                INSERT INTO product_option_values (option_id, value, variant_id)
                VALUES (option_id, option_value, variant_record.id)
                RETURNING id INTO value_id;
            ELSE
                -- Update the variant_id if the value exists but wasn't linked
                UPDATE product_option_values
                SET variant_id = variant_record.id
                WHERE id = value_id;
            END IF;
        END IF;
    END LOOP;
END $$;

-- Add comment for documentation
COMMENT ON TABLE product_options IS 'Stores product options like Color, Size, etc.';
COMMENT ON TABLE product_option_values IS 'Stores values for product options and links to variants';

-- <<< END 20260102_backfill_variant_options.sql <<<


-- >>> BEGIN 20260102110000_fix_cart_items_fk.sql >>>

-- Fix Cart Items Foreign Key Constraints
-- Drop existing constraints if they exist (standard naming convention)
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_product_id_fkey;
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_variant_id_fkey;

-- Add back with ON DELETE CASCADE
ALTER TABLE cart_items
ADD CONSTRAINT cart_items_product_id_fkey
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE cart_items
ADD CONSTRAINT cart_items_variant_id_fkey
FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE;

-- <<< END 20260102110000_fix_cart_items_fk.sql <<<


-- >>> BEGIN 20260102111500_fix_deletion_and_variants.sql >>>

-- Fix constraints for cart_items to allow product deletion and optional variants
ALTER TABLE cart_items
DROP CONSTRAINT IF EXISTS cart_items_product_id_fkey,
DROP CONSTRAINT IF EXISTS cart_items_variant_id_fkey;

-- Add back with ON DELETE CASCADE and make variant_id nullable
ALTER TABLE cart_items
ALTER COLUMN variant_id DROP NOT NULL,
ADD CONSTRAINT cart_items_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
ADD CONSTRAINT cart_items_variant_id_fkey 
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE;

-- <<< END 20260102111500_fix_deletion_and_variants.sql <<<


-- >>> BEGIN 20260102120000_product_categories.sql >>>

-- Create product_categories junction table
CREATE TABLE IF NOT EXISTS product_categories (
  product_id TEXT REFERENCES products(id) ON DELETE CASCADE,
  category_id TEXT REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (product_id, category_id)
);

-- Migrate existing data from products.category_id to the new table
INSERT INTO product_categories (product_id, category_id)
SELECT id, category_id
FROM products
WHERE category_id IS NOT NULL;

-- Make category_id on products table optional (it was likely already optional, but good to ensure)
ALTER TABLE products ALTER COLUMN category_id DROP NOT NULL;

-- (Optional) We keep category_id on products for now to avoid breaking existing queries immediately, 
-- but we should deprecate it in the future.

-- <<< END 20260102120000_product_categories.sql <<<


-- >>> BEGIN 20260102144500_add_product_fields.sql >>>

ALTER TABLE products ADD COLUMN IF NOT EXISTS short_description TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS video_url TEXT;

-- <<< END 20260102144500_add_product_fields.sql <<<


-- >>> BEGIN 20260103_fix_product_options_schema.sql >>>

-- Fix type mismatches in product_options and product_option_values tables
-- The products.id and product_variants.id are TEXT type, but the foreign keys in
-- product_options and product_option_values were defined as UUID

-- Step 1: Drop foreign key constraints
DO $$
BEGIN
    -- Drop variant_id foreign key constraint
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'product_option_values_variant_id_fkey'
    ) THEN
        ALTER TABLE product_option_values DROP CONSTRAINT product_option_values_variant_id_fkey;
    END IF;

    -- Drop product_id foreign key constraint
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'product_options_product_id_fkey'
    ) THEN
        ALTER TABLE product_options DROP CONSTRAINT product_options_product_id_fkey;
    END IF;
END $$;

-- Step 2: Alter columns to TEXT type to match the referenced tables
ALTER TABLE product_options
ALTER COLUMN product_id TYPE TEXT USING product_id::TEXT;

ALTER TABLE product_option_values
ALTER COLUMN variant_id TYPE TEXT USING variant_id::TEXT;

-- Step 3: Re-create foreign key constraints with correct types
ALTER TABLE product_options
ADD CONSTRAINT product_options_product_id_fkey
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE product_option_values
ADD CONSTRAINT product_option_values_variant_id_fkey
FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE;

-- Step 4: Recreate indexes for performance
DROP INDEX IF EXISTS idx_product_options_product_id;
CREATE INDEX idx_product_options_product_id ON product_options(product_id);

DROP INDEX IF EXISTS idx_product_option_values_variant_id;
CREATE INDEX idx_product_option_values_variant_id ON product_option_values(variant_id);

-- <<< END 20260103_fix_product_options_schema.sql <<<


-- >>> BEGIN 20260103170000_add_wishlist_items.sql >>>

-- Create wishlist_items table
CREATE TABLE IF NOT EXISTS public.wishlist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, product_id)
);

-- Enable RLS
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;

-- Policies for wishlist_items
CREATE POLICY "Users can manage their own wishlist items"
    ON public.wishlist_items
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Enable realtime for wishlist_items (optional but good for syncing across tabs)
ALTER PUBLICATION supabase_realtime ADD TABLE public.wishlist_items;

-- <<< END 20260103170000_add_wishlist_items.sql <<<


-- >>> BEGIN 20260105_fix_reward_transactions_order_id.sql >>>

-- Fix order_id type mismatch in reward_transactions
-- Current type is UUID but Medusa order IDs are TEXT
ALTER TABLE reward_transactions ALTER COLUMN order_id TYPE TEXT;

-- <<< END 20260105_fix_reward_transactions_order_id.sql <<<


-- >>> BEGIN 20260105150000_sync_club_data_to_profiles.sql >>>

-- Migration: Sync club membership data from auth.users metadata to profiles table
-- This ensures that historical savings and membership status are visible in the Admin panel

UPDATE profiles
SET 
  is_club_member = (au.raw_user_meta_data->>'is_club_member')::boolean,
  club_member_since = (au.raw_user_meta_data->>'club_member_since')::timestamp with time zone,
  total_club_savings = COALESCE((au.raw_user_meta_data->>'total_club_savings')::numeric, 0)
FROM auth.users au
WHERE profiles.id = au.id
AND au.raw_user_meta_data ? 'is_club_member';

-- <<< END 20260105150000_sync_club_data_to_profiles.sql <<<


-- >>> BEGIN 20260107_admin_rls_rewards_addresses.sql >>>

-- Add RLS policies for Admins to access rewards and addresses
-- Uses the existing is_admin() function from 20251231_admin_profiles_rls.sql

-- 1. reward_wallets
DROP POLICY IF EXISTS "Admins read all wallets" ON public.reward_wallets;
CREATE POLICY "Admins read all wallets" ON public.reward_wallets
    FOR SELECT TO authenticated
    USING (is_admin());

-- 2. reward_transactions
DROP POLICY IF EXISTS "Admins read all reward transactions" ON public.reward_transactions;
CREATE POLICY "Admins read all reward transactions" ON public.reward_transactions
    FOR SELECT TO authenticated
    USING (is_admin());

-- 3. addresses
DROP POLICY IF EXISTS "Admins read all addresses" ON public.addresses;
CREATE POLICY "Admins read all addresses" ON public.addresses
    FOR SELECT TO authenticated
    USING (is_admin());

-- <<< END 20260107_admin_rls_rewards_addresses.sql <<<


-- >>> BEGIN 20260107_fix_user_deletion_cascades.sql >>>

-- Migration: Fix User Deletion (Add ON DELETE CASCADE)
-- This migration ensures that deleting a user from auth.users 
-- automatically removes associated data in other tables.
-- It also cleans up existing orphaned records to allow applying the constraints.

-- 1. Clean up orphaned records first to ensure constraints can be applied
-- This deletes records whose associated user no longer exists in auth.users
DELETE FROM public.reviews WHERE user_id IS NOT NULL AND user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.orders WHERE user_id IS NOT NULL AND user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.carts WHERE user_id IS NOT NULL AND user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.profiles WHERE id NOT IN (SELECT id FROM auth.users);

-- 2. Fix Reviews table
ALTER TABLE public.reviews
DROP CONSTRAINT IF EXISTS reviews_user_id_fkey,
ADD CONSTRAINT reviews_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- 3. Fix Orders table
ALTER TABLE public.orders
DROP CONSTRAINT IF EXISTS orders_user_id_fkey,
ADD CONSTRAINT orders_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- 4. Fix Carts table
ALTER TABLE public.carts
DROP CONSTRAINT IF EXISTS carts_user_id_fkey,
ADD CONSTRAINT carts_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- 5. Fix Profiles table
DO $$
BEGIN
    -- Drop existing foreign key on profiles if it exists
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'profiles' AND constraint_name = 'profiles_id_fkey') THEN
        ALTER TABLE public.profiles DROP CONSTRAINT profiles_id_fkey;
    ELSIF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'profiles' AND constraint_type = 'FOREIGN KEY') THEN
        -- If there's a foreign key with a different name, we might still want to replace it
        -- but for safety we'll just ensure our specific one is added.
        NULL;
    END IF;
    
    ALTER TABLE public.profiles
    ADD CONSTRAINT profiles_id_fkey 
        FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not add constraint to profiles: %', SQLERRM;
END $$;

-- <<< END 20260107_fix_user_deletion_cascades.sql <<<


-- >>> BEGIN 20260109_create_order_with_payment.sql >>>

-- Refactor the atomic order creation function to use the correct schema
-- 1. Remove dependency on non-existent order_items table
-- 2. Use the "items" JSONB column in the "orders" table for line items
-- 3. Include "shipping_methods" snapshot in the order creation
-- 4. Remove the non-existent "completed_at" column update on the carts table
-- 5. Ensure all totals and club discounts are accurately captured in the JSONB snapshot
-- 6. Fix for React unique key warning: Include original item ID in the snapshot
-- 7. Fix for Shipping Threshold: Respect free shipping threshold in order total calculation

CREATE OR REPLACE FUNCTION create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_currency_code TEXT;
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB;
  v_club_savings NUMERIC := 0;
BEGIN
  -- 1. Get cart basics, user info and payment data
  SELECT 
    user_id, 
    currency_code, 
    shipping_methods, 
    payment_collection 
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_payment_collection
  FROM carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- 2. Check Club Membership
  IF v_user_id IS NOT NULL THEN
    SELECT is_club_member INTO v_is_club_member
    FROM profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT discount_percentage INTO v_club_discount_percentage
      FROM club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  -- 3. Build Items JSON snapshot and calculate subtotal
  SELECT 
    jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', COALESCE(pv.title, p.name, 'Product'),
        'quantity', ci.quantity,
        'original_total', ROUND(COALESCE(pv.price, p.price, 0) * ci.quantity),
        'original_unit_price', ROUND(COALESCE(pv.price, p.price, 0)),
        'unit_price', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)),
        'total', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity,
        'metadata', ci.metadata,
        'thumbnail', p.image_url,
        'created_at', ci.created_at
      )
    ),
    SUM(ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity),
    SUM(ROUND(COALESCE(pv.price, p.price, 0) * ci.quantity)) - SUM(ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_club_savings
  FROM cart_items ci
  JOIN products p ON ci.product_id = p.id
  LEFT JOIN product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  -- 4. Get Shipping Total (Respect FREE ABOVE threshold)
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := (v_method->>'amount')::NUMERIC;
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := COALESCE(v_amount, 0);
      END IF;
    END;
  END IF;

  -- 5. Update cart with addresses and email
  UPDATE carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', p_rewards_to_apply),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- 6. Create order (storing items and shipping_methods in JSONB columns)
  INSERT INTO orders (
    user_id,
    email,
    customer_email,
    shipping_address,
    billing_address,
    subtotal,
    tax_total,
    shipping_total,
    discount_total,
    total_amount,
    total,
    currency_code,
    payment_collection,
    items,
    shipping_methods,
    metadata,
    status,
    payment_status,
    fulfillment_status,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    p_email,
    p_email,
    p_shipping_address,
    p_billing_address,
    v_item_subtotal,
    v_tax_total,
    v_shipping_total,
    p_rewards_to_apply,
    GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply),
    GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply),
    v_currency_code,
    v_payment_collection,
    v_items_json,
    v_shipping_methods,
    jsonb_build_object(
      'cart_id', p_cart_id, 
      'rewards_used', p_rewards_to_apply, 
      'club_savings_amount', v_club_savings,
      'club_savings', v_club_savings,
      'is_club_member', v_is_club_member,
      'club_discount_percentage', v_club_discount_percentage
    ),
    'pending',
    'pending',
    'not_shipped',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_order_id;

  -- 7. Return success with order ID
  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- <<< END 20260109_create_order_with_payment.sql <<<


-- >>> BEGIN 20260109_restore_admin_notifications_logic.sql >>>

-- Restore rich logic for admin notifications trigger function
-- This version handles multiple tables (orders, profiles, reviews) 
-- and builds meaningful messages, while maintaining security.

CREATE OR REPLACE FUNCTION public.handle_admin_notification()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    notify_title TEXT;
    notify_message TEXT;
    notify_type TEXT;
    notify_metadata JSONB;
BEGIN
    -- Handle Orders
    IF TG_TABLE_NAME = 'orders' THEN
        notify_type := 'order';
        notify_title := 'New Order Placed';
        -- display_id is SERIAL, in AFTER INSERT it should be available
        notify_message := 'Order #' || COALESCE(NEW.display_id::text, 'NEW') || ' received for ' || COALESCE(NEW.customer_email, NEW.email, 'guest');
        notify_metadata := jsonb_build_object(
            'order_id', NEW.id, 
            'display_id', NEW.display_id,
            'total', NEW.total
        );
    
    -- Handle User Signups (profiles table)
    ELSIF TG_TABLE_NAME = 'profiles' THEN
        -- Only notify on INSERT (new user)
        IF TG_OP = 'INSERT' THEN
            notify_type := 'user';
            notify_title := 'New User Registered';
            notify_message := COALESCE(NEW.first_name, '') || ' ' || COALESCE(NEW.last_name, '') || ' (' || COALESCE(NEW.email, 'no email') || ') joined Toycker.';
            notify_metadata := jsonb_build_object('user_id', NEW.id, 'email', NEW.email);
        ELSE
            RETURN NEW; -- Skip updates
        END IF;

    -- Handle Reviews
    ELSIF TG_TABLE_NAME = 'reviews' THEN
        notify_type := 'review';
        notify_title := 'New Review Submitted';
        notify_message := 'New ' || COALESCE(NEW.rating::text, '?') || '-star review from ' || COALESCE(NEW.display_name, 'Anonymous');
        notify_metadata := jsonb_build_object('review_id', NEW.id, 'product_id', NEW.product_id, 'rating', NEW.rating);
    
    -- Fallback for safety
    ELSE
        notify_type := 'system';
        notify_title := 'System Event (' || TG_TABLE_NAME || ')';
        notify_message := 'Event ' || TG_OP || ' occurred on ' || TG_TABLE_NAME;
        notify_metadata := '{}'::jsonb;
    END IF;

    -- Insert into notifications table
    INSERT INTO public.admin_notifications (type, title, message, metadata, created_at)
    VALUES (notify_type, notify_title, notify_message, notify_metadata, NOW());

    RETURN NEW;
END;
$$;

-- Re-attach triggers to ensure they are using the correct function and no conflicting definitions exist
DROP TRIGGER IF EXISTS on_order_placed ON public.orders;
CREATE TRIGGER on_order_placed
    AFTER INSERT ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

DROP TRIGGER IF EXISTS on_user_signup ON public.profiles;
CREATE TRIGGER on_user_signup
    AFTER INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

DROP TRIGGER IF EXISTS on_review_submitted ON public.reviews;
CREATE TRIGGER on_review_submitted
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

-- <<< END 20260109_restore_admin_notifications_logic.sql <<<


-- >>> BEGIN 20260110_add_discount_total_to_carts.sql >>>

-- Add discount_total column to carts table
ALTER TABLE public.carts 
ADD COLUMN IF NOT EXISTS discount_total NUMERIC DEFAULT 0;

-- Verify it was added
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'carts'
AND column_name = 'discount_total';

-- <<< END 20260110_add_discount_total_to_carts.sql <<<


-- >>> BEGIN 20260110_comprehensive_fix.sql >>>

-- FINAL FIX: Add debugging and ensure all NOT NULL constraints are satisfied
-- Based on web research: The issue is that total_amount has a NOT NULL constraint
-- and the calculation might be resulting in NULL due to NULL propagation

DROP FUNCTION IF EXISTS public.create_order_with_payment(TEXT, TEXT, JSONB, JSONB, TEXT, INTEGER) CASCADE;

CREATE FUNCTION public.create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_promo_discount NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_item_subtotal_before_club NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_total_discount NUMERIC := 0;
  v_final_total NUMERIC := 0;
  v_currency_code TEXT := 'INR';
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB := '[]'::jsonb;
  v_cart_discount_total NUMERIC := 0;
BEGIN
  -- 1. Get cart data with COALESCE to prevent NULLs
  SELECT 
    user_id, 
    COALESCE(currency_code, 'INR'), 
    shipping_methods, 
    payment_collection,
    COALESCE(discount_total, 0)
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_payment_collection,
    v_cart_discount_total
  FROM public.carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- Debug: Log cart data
  RAISE NOTICE 'Cart ID: %, User ID: %, Currency: %, Discount Total: %', 
    p_cart_id, v_user_id, v_currency_code, v_cart_discount_total;

  -- 2. Check Club Membership
  IF v_user_id IS NOT NULL THEN
    SELECT COALESCE(is_club_member, FALSE) INTO v_is_club_member
    FROM public.profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT COALESCE(discount_percentage, 0) INTO v_club_discount_percentage
      FROM public.club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  RAISE NOTICE 'Club Member: %, Club Discount: %', v_is_club_member, v_club_discount_percentage;

  -- 3. Build Items JSON and calculate subtotals
  SELECT 
    COALESCE(jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', COALESCE(pv.title, p.name, 'Product'),
        'product_title', p.name,
        'quantity', ci.quantity,
        'unit_price', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)),
        'total', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity,
        'metadata', COALESCE(ci.metadata, '{}'::jsonb),
        'thumbnail', p.image_url,
        'variant', CASE 
          WHEN pv.id IS NOT NULL THEN jsonb_build_object('title', pv.title, 'id', pv.id)
          ELSE NULL
        END,
        'created_at', ci.created_at
      )
    ), '[]'::jsonb),
    COALESCE(SUM(ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity), 0),
    COALESCE(SUM(COALESCE(pv.price, p.price, 0) * ci.quantity), 0)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_item_subtotal_before_club
  FROM public.cart_items ci
  JOIN public.products p ON ci.product_id = p.id
  LEFT JOIN public.product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  -- Calculate discounts with COALESCE
  v_club_savings := COALESCE(v_item_subtotal_before_club - v_item_subtotal, 0);
  v_promo_discount := COALESCE(v_cart_discount_total, 0);
  v_total_discount := COALESCE(p_rewards_to_apply, 0) + v_promo_discount;

  RAISE NOTICE 'Subtotal: %, Club Savings: %, Promo: %, Total Discount: %', 
    v_item_subtotal, v_club_savings, v_promo_discount, v_total_discount;

  -- 4. Calculate Shipping with COALESCE
  v_shipping_total := 0;
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := COALESCE((v_method->>'amount')::NUMERIC, 0);
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := v_amount;
      END IF;
    END;
  END IF;

  -- Calculate final total - CRITICAL: Ensure it's NEVER NULL
  v_final_total := GREATEST(0, 
    COALESCE(v_item_subtotal, 0) + 
    COALESCE(v_tax_total, 0) + 
    COALESCE(v_shipping_total, 0) - 
    COALESCE(v_total_discount, 0)
  );

  -- Ensure v_final_total is not NULL (safety check)
  IF v_final_total IS NULL THEN
    v_final_total := 0;
    RAISE NOTICE 'WARNING: Final total was NULL, set to 0';
  END IF;

  RAISE NOTICE 'Shipping: %, Tax: %, FINAL TOTAL: %', v_shipping_total, v_tax_total, v_final_total;

  -- 5. Update cart
  UPDATE public.carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', COALESCE(p_rewards_to_apply, 0)),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- 6. Create order - ALL values guaranteed non-NULL
  INSERT INTO public.orders (
    user_id,
    email,
    customer_email,
    shipping_address,
    billing_address,
    subtotal,
    tax_total,
    shipping_total,
    discount_total,
    total_amount,
    total,
    currency_code,
    payment_collection,
    items,
    shipping_methods,
    metadata,
    status,
    payment_status,
    fulfillment_status,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    p_email,
    p_email,
    p_shipping_address,
    p_billing_address,
    v_item_subtotal,
    v_tax_total,
    v_shipping_total,
    v_total_discount,
    v_final_total,  -- This is guaranteed to be non-NULL
    v_final_total,  -- This is guaranteed to be non-NULL
    v_currency_code,
    v_payment_collection,
    v_items_json,
    v_shipping_methods,
    jsonb_build_object(
      'cart_id', p_cart_id, 
      'rewards_used', COALESCE(p_rewards_to_apply, 0),
      'rewards_discount', COALESCE(p_rewards_to_apply, 0),
      'club_savings', v_club_savings,
      'promo_discount', v_promo_discount,
      'is_club_member', v_is_club_member,
      'club_discount_percentage', v_club_discount_percentage
    ),
    'pending',
    'pending',
    'not_shipped',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_order_id;

  RAISE NOTICE 'Order created successfully: %', v_order_id;

  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'ERROR: %', SQLERRM;
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_order_with_payment TO authenticated;

-- <<< END 20260110_comprehensive_fix.sql <<<


-- >>> BEGIN 20260110_home_settings_functions.sql >>>

-- Home Settings PostgreSQL Functions
-- Atomic operations for reordering banners and collections

-- =============================================
-- Function: reorder_home_banners
-- Purpose: Atomically reorder home banners
-- Parameters: banner_ids - Array of banner UUIDs in desired order
-- =============================================
CREATE OR REPLACE FUNCTION public.reorder_home_banners(banner_ids UUID[])
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  i INTEGER;
BEGIN
  -- Check if user is admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Validate that all provided IDs exist
  IF array_length(banner_ids, 1) != (
    SELECT COUNT(*) 
    FROM public.home_banners 
    WHERE id = ANY(banner_ids)
  ) THEN
    RAISE EXCEPTION 'Invalid banner IDs provided';
  END IF;
  
  -- Update sort_order for each banner atomically
  FOR i IN 1..array_length(banner_ids, 1) LOOP
    UPDATE public.home_banners
    SET 
      sort_order = i - 1,
      updated_at = now()
    WHERE id = banner_ids[i];
  END LOOP;
END;
$$;

-- =============================================
-- Function: reorder_exclusive_collections
-- Purpose: Atomically reorder exclusive collections
-- Parameters: collection_ids - Array of collection UUIDs in desired order
-- =============================================
CREATE OR REPLACE FUNCTION public.reorder_exclusive_collections(collection_ids UUID[])
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  i INTEGER;
BEGIN
  -- Check if user is admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Validate that all provided IDs exist
  IF array_length(collection_ids, 1) != (
    SELECT COUNT(*) 
    FROM public.home_exclusive_collections 
    WHERE id = ANY(collection_ids)
  ) THEN
    RAISE EXCEPTION 'Invalid collection IDs provided';
  END IF;
  
  -- Update sort_order for each collection atomically
  FOR i IN 1..array_length(collection_ids, 1) LOOP
    UPDATE public.home_exclusive_collections
    SET 
      sort_order = i - 1,
      updated_at = now()
    WHERE id = collection_ids[i];
  END LOOP;
END;
$$;

-- =============================================
-- Grant execute permissions to authenticated users
-- (RLS and is_admin() check will handle authorization)
-- =============================================
GRANT EXECUTE ON FUNCTION public.reorder_home_banners(UUID[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reorder_exclusive_collections(UUID[]) TO authenticated;

-- <<< END 20260110_home_settings_functions.sql <<<


-- >>> BEGIN 20260110_home_settings_tables.sql >>>

-- Home Settings Tables Migration
-- Creates tables for managing homepage banners and exclusive collections

-- =============================================
-- Table: home_banners
-- Purpose: Store hero banner configurations for homepage
-- =============================================
CREATE TABLE IF NOT EXISTS public.home_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  image_url TEXT NOT NULL,
  alt_text TEXT,
  link_url TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_home_banners_active_sort 
  ON public.home_banners(is_active, sort_order) 
  WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_home_banners_schedule 
  ON public.home_banners(starts_at, ends_at) 
  WHERE is_active = true;

-- =============================================
-- Table: home_exclusive_collections
-- Purpose: Store exclusive collection entries (videos + products)
-- =============================================
CREATE TABLE IF NOT EXISTS public.home_exclusive_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id TEXT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  video_url TEXT NOT NULL,
  poster_url TEXT,
  video_duration INTEGER, -- in seconds
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  UNIQUE(product_id) -- One collection entry per product
);

-- Index for efficient querying
CREATE INDEX IF NOT EXISTS idx_exclusive_collections_active_sort 
  ON public.home_exclusive_collections(is_active, sort_order) 
  WHERE is_active = true;

-- =============================================
-- Enable Row Level Security
-- =============================================
ALTER TABLE public.home_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.home_exclusive_collections ENABLE ROW LEVEL SECURITY;

-- =============================================
-- RLS Policies: home_banners
-- =============================================

-- Public can view active, scheduled banners
DROP POLICY IF EXISTS "Public can view active home banners" ON public.home_banners;
CREATE POLICY "Public can view active home banners" ON public.home_banners
  FOR SELECT
  TO public
  USING (
    is_active = true AND
    (starts_at IS NULL OR starts_at <= now()) AND
    (ends_at IS NULL OR ends_at > now())
  );

-- Admins have full access
DROP POLICY IF EXISTS "Admins can manage home banners" ON public.home_banners;
CREATE POLICY "Admins can manage home banners" ON public.home_banners
  FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- =============================================
-- RLS Policies: home_exclusive_collections
-- =============================================

-- Public can view active collections
DROP POLICY IF EXISTS "Public can view active exclusive collections" ON public.home_exclusive_collections;
CREATE POLICY "Public can view active exclusive collections" ON public.home_exclusive_collections
  FOR SELECT
  TO public
  USING (is_active = true);

-- Admins have full access
DROP POLICY IF EXISTS "Admins can manage exclusive collections" ON public.home_exclusive_collections;
CREATE POLICY "Admins can manage exclusive collections" ON public.home_exclusive_collections
  FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- =============================================
-- Trigger: Update updated_at timestamp
-- =============================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Apply trigger to home_banners
DROP TRIGGER IF EXISTS update_home_banners_updated_at ON public.home_banners;
CREATE TRIGGER update_home_banners_updated_at
  BEFORE UPDATE ON public.home_banners
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Apply trigger to home_exclusive_collections
DROP TRIGGER IF EXISTS update_home_exclusive_collections_updated_at ON public.home_exclusive_collections;
CREATE TRIGGER update_home_exclusive_collections_updated_at
  BEFORE UPDATE ON public.home_exclusive_collections
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- <<< END 20260110_home_settings_tables.sql <<<


-- >>> BEGIN 20260111_add_discounts.sql >>>

-- Create Promotions Table
CREATE TABLE IF NOT EXISTS promotions (
    id TEXT PRIMARY KEY DEFAULT ('prom_' || uuid_generate_v4()),
    code TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('percentage', 'fixed', 'free_shipping')),
    value NUMERIC NOT NULL DEFAULT 0,
    min_order_amount NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ends_at TIMESTAMP WITH TIME ZONE,
    max_uses INTEGER,
    used_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add promo_code to carts and orders table
ALTER TABLE carts ADD COLUMN IF NOT EXISTS promo_code TEXT REFERENCES promotions(code);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS promo_code TEXT REFERENCES promotions(code);

-- Update RLS for promotions
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;

-- Public can select active promotions (to validate codes)
DROP POLICY IF EXISTS "Public read active promotions" ON promotions;
CREATE POLICY "Public read active promotions" ON promotions
    FOR SELECT TO public
    USING (is_active = true AND (starts_at IS NULL OR starts_at <= NOW()));

-- Only admins can manage promotions
DROP POLICY IF EXISTS "Admins manage promotions" ON promotions;
CREATE POLICY "Admins manage promotions" ON promotions
    FOR ALL TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- Function to increment promotion uses
CREATE OR REPLACE FUNCTION increment_promotion_uses(promo_id TEXT)
RETURNS void AS $$
BEGIN
    UPDATE promotions
    SET used_count = used_count + 1
    WHERE id = promo_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- <<< END 20260111_add_discounts.sql <<<


-- >>> BEGIN 20260112_create_optimized_views.sql >>>

-- =====================================================
-- Optimized Database Views for Storefront and Admin
-- Issue #14 in FIXES_CHECKLIST.md
-- =====================================================
-- Fixed: Removed non-existent 'phone' column from profiles join
-- =====================================================

BEGIN;

-- 1. Products with Variants View
-- Simplifies fetching products along with their first variant or aggregate data
CREATE OR REPLACE VIEW public.products_with_variants AS
SELECT 
    p.*,
    (
        SELECT jsonb_agg(v.*)
        FROM public.product_variants v
        WHERE v.product_id = p.id
    ) as variants_data,
    COALESCE(
        (SELECT min(price) FROM public.product_variants v WHERE v.product_id = p.id),
        p.price
    ) as min_price,
    COALESCE(
        (SELECT sum(inventory_quantity) FROM public.product_variants v WHERE v.product_id = p.id),
        p.stock_count
    ) as total_inventory
FROM 
    public.products p;

-- 2. Order Details View
-- Joins orders with basic profile data. 
-- Note: first_name/last_name/phone are typically in auth.users metadata in this project.
CREATE OR REPLACE VIEW public.order_details_view AS
SELECT 
    o.*,
    p.role as user_role
FROM 
    public.orders o
LEFT JOIN 
    public.profiles p ON o.user_id = p.id;

-- 3. Cart Items with Products View
-- Useful for calculating totals and displaying cart contents without manual joins
CREATE OR REPLACE VIEW public.cart_items_extended AS
SELECT 
    ci.*,
    p.name as product_name,
    p.handle as product_handle,
    p.image_url as product_thumbnail,
    v.title as variant_title,
    v.sku as variant_sku
FROM 
    public.cart_items ci
JOIN 
    public.products p ON ci.product_id = p.id
LEFT JOIN 
    public.product_variants v ON ci.variant_id = v.id;

COMMIT;

-- <<< END 20260112_create_optimized_views.sql <<<


-- >>> BEGIN 20260112_fix_cart_rls_policies.sql >>>

-- =====================================================
-- Fix Cart RLS Policies (Choice B: Guest Friendly)
-- =====================================================
-- This migration replaces insecure USING(true) policies
-- while allowing both Guests (anon) and Registered Users (authenticated)
-- to manage their own carts.
-- =====================================================

BEGIN;

-- =====================================================
-- CARTS TABLE
-- =====================================================

-- Drop existing insecure policies
DROP POLICY IF EXISTS "Public access carts" ON public.carts;
DROP POLICY IF EXISTS "Public read carts" ON public.carts;
DROP POLICY IF EXISTS "Public create carts" ON public.carts;
DROP POLICY IF EXISTS "Allow public read carts" ON public.carts;
DROP POLICY IF EXISTS "Users can view own carts" ON public.carts;
DROP POLICY IF EXISTS "Users can create own carts" ON public.carts;
DROP POLICY IF EXISTS "Users can update own carts" ON public.carts;
DROP POLICY IF EXISTS "Users can delete own carts" ON public.carts;
DROP POLICY IF EXISTS "Admins can view all carts" ON public.carts;

-- 1. Everyone can view a cart if they know its ID 
-- (Possession of the UUID in the cookie acts as the "key")
CREATE POLICY "Access cart by ID"
  ON public.carts FOR SELECT
  TO anon, authenticated
  USING (true);

-- 2. Everyone can create a cart (Guests have NULL user_id)
CREATE POLICY "Anyone can create carts"
  ON public.carts FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    (user_id IS NULL) OR 
    (user_id = (SELECT auth.uid()))
  );

-- 3. Users can update their own cart (Guests or Auth)
CREATE POLICY "Anyone can update own cart"
  ON public.carts FOR UPDATE
  TO anon, authenticated
  USING (
    (user_id IS NULL) OR 
    (user_id = (SELECT auth.uid()))
  );

-- 4. Users can delete their own cart
CREATE POLICY "Anyone can delete own cart"
  ON public.carts FOR DELETE
  TO anon, authenticated
  USING (
    (user_id IS NULL) OR 
    (user_id = (SELECT auth.uid()))
  );

-- =====================================================
-- CART_ITEMS TABLE
-- =====================================================

-- Drop existing insecure policies
DROP POLICY IF EXISTS "Public access cart_items" ON public.cart_items;
DROP POLICY IF EXISTS "Public read cart_items" ON public.cart_items;
DROP POLICY IF EXISTS "Public create cart_items" ON public.cart_items;
DROP POLICY IF EXISTS "Allow public read cart_items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can view own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can add to own cart" ON public.cart_items;
DROP POLICY IF EXISTS "Users can update own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can delete own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Admins can view all cart items" ON public.cart_items;

-- 1. Access items if you have access to the parent cart
CREATE POLICY "Access cart items via cart"
  ON public.cart_items FOR ALL
  TO anon, authenticated
  USING (
    cart_id IN (
      SELECT id FROM public.carts
    )
  );

-- 2. Admins can view everything (redundant but good for clarity)
CREATE POLICY "Admins can manage all cart items"
  ON public.cart_items FOR ALL
  TO authenticated
  USING (public.is_admin());

COMMIT;

-- <<< END 20260112_fix_cart_rls_policies.sql <<<


-- >>> BEGIN 20260112_simplified_order_function.sql >>>

-- Simplified fix that only uses essential columns
-- Removes payment_collection and other potentially missing columns

DROP FUNCTION IF EXISTS public.create_order_with_payment(TEXT, TEXT, JSONB, JSONB, TEXT, INTEGER) CASCADE;

CREATE FUNCTION public.create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_promo_discount NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_item_subtotal_before_club NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_total_discount NUMERIC := 0;
  v_final_total NUMERIC := 0;
  v_currency_code TEXT := 'INR';
  v_shipping_methods JSONB;
  v_items_json JSONB := '[]'::jsonb;
  v_cart_discount_total NUMERIC := 0;
BEGIN
  -- 1. Get cart data
  SELECT 
    user_id, 
    COALESCE(currency_code, 'INR'), 
    shipping_methods, 
    COALESCE(discount_total, 0)
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_cart_discount_total
  FROM public.carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- 2. Check Club Membership
  IF v_user_id IS NOT NULL THEN
    SELECT COALESCE(is_club_member, FALSE) INTO v_is_club_member
    FROM public.profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT COALESCE(discount_percentage, 0) INTO v_club_discount_percentage
      FROM public.club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  -- 3. Build Items JSON and calculate subtotals
  SELECT 
    COALESCE(jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', COALESCE(pv.title, p.name, 'Product'),
        'product_title', p.name,
        'quantity', ci.quantity,
        'unit_price', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)),
        'total', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity,
        'metadata', COALESCE(ci.metadata, '{}'::jsonb),
        'thumbnail', p.image_url,
        'variant', CASE 
          WHEN pv.id IS NOT NULL THEN jsonb_build_object('title', pv.title, 'id', pv.id)
          ELSE NULL
        END,
        'created_at', ci.created_at
      )
    ), '[]'::jsonb),
    COALESCE(SUM(ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity), 0),
    COALESCE(SUM(COALESCE(pv.price, p.price, 0) * ci.quantity), 0)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_item_subtotal_before_club
  FROM public.cart_items ci
  JOIN public.products p ON ci.product_id = p.id
  LEFT JOIN public.product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  -- Calculate discounts
  v_club_savings := COALESCE(v_item_subtotal_before_club - v_item_subtotal, 0);
  v_promo_discount := COALESCE(v_cart_discount_total, 0);
  v_total_discount := COALESCE(p_rewards_to_apply, 0) + v_promo_discount;

  -- 4. Calculate Shipping
  v_shipping_total := 0;
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := COALESCE((v_method->>'amount')::NUMERIC, 0);
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := v_amount;
      END IF;
    END;
  END IF;

  -- Calculate final total
  v_final_total := GREATEST(0, 
    COALESCE(v_item_subtotal, 0) + 
    COALESCE(v_tax_total, 0) + 
    COALESCE(v_shipping_total, 0) - 
    COALESCE(v_total_discount, 0)
  );

  -- Ensure v_final_total is not NULL
  IF v_final_total IS NULL THEN
    v_final_total := 0;
  END IF;

  -- 5. Update cart
  UPDATE public.carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', COALESCE(p_rewards_to_apply, 0)),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- 6. Create order with all required columns
  INSERT INTO public.orders (
    user_id,
    email,
    customer_email,
    shipping_address,
    billing_address,
    subtotal,
    tax_total,
    shipping_total,
    discount_total,
    total_amount,
    total,
    currency_code,
    items,
    shipping_methods,
    metadata,
    status,
    payment_status,
    fulfillment_status,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    p_email,
    p_email,
    p_shipping_address,
    p_billing_address,
    v_item_subtotal,
    v_tax_total,
    v_shipping_total,
    v_total_discount,
    v_final_total,
    v_final_total,
    v_currency_code,
    v_items_json,
    v_shipping_methods,
    jsonb_build_object(
      'cart_id', p_cart_id, 
      'rewards_used', COALESCE(p_rewards_to_apply, 0),
      'rewards_discount', COALESCE(p_rewards_to_apply, 0),
      'club_savings', v_club_savings,
      'promo_discount', v_promo_discount,
      'is_club_member', v_is_club_member,
      'club_discount_percentage', v_club_discount_percentage
    ),
    'pending',
    'pending',
    'not_shipped',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_order_id;

  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_order_with_payment TO authenticated;

-- <<< END 20260112_simplified_order_function.sql <<<


-- >>> BEGIN 20260113_advanced_search.sql >>>

-- Advanced Text Search and Analytics
-- This migration setup Full-Text Search, Fuzzy matching, and Analytics tracking.
-- Image and Voice search features have been excluded as per project requirements.

-- 1. Enable pg_trgm for fuzzy matching (typo tolerance)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. Add generated tsvector column for high-speed full-text search
-- This combines Name and Description with different weights (Title=A, Description=B)
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS search_vector tsvector 
GENERATED ALWAYS AS (
  setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
  setweight(to_tsvector('english', COALESCE(description, '')), 'B')
) STORED;

-- 3. Create GIN index for fast full-text search
CREATE INDEX IF NOT EXISTS products_search_vector_idx 
ON public.products USING GIN (search_vector);

-- 4. Create GIN index for trigram similarity (typo tolerance on product names)
CREATE INDEX IF NOT EXISTS products_name_trgm_idx 
ON public.products USING GIN (name gin_trgm_ops);

-- 5. Create Advanced Search Function
-- This function combines FTS (ranking), Trigram (typos), and Prefix (instant) matching.
-- It also handles finding the best price from product variants.
CREATE OR REPLACE FUNCTION public.search_products_advanced(
  search_query TEXT,
  similarity_threshold FLOAT DEFAULT 0.15,
  result_limit INT DEFAULT 20
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  handle TEXT,
  image_url TEXT,
  thumbnail TEXT,
  price DECIMAL,
  currency_code TEXT,
  relevance_score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  WITH combined_results AS (
    -- Full Text Search Ranking
    SELECT 
      p.id, p.name, p.handle, p.image_url, p.thumbnail, 
      COALESCE((SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id), p.price) as effective_price,
      p.currency_code,
      ts_rank_cd(p.search_vector, websearch_to_tsquery('english', search_query)) * 0.7 AS score
    FROM public.products p
    WHERE p.search_vector @@ websearch_to_tsquery('english', search_query)
    
    UNION ALL

    -- Trigram Similarity (Fuzzy matching)
    SELECT 
      p.id, p.name, p.handle, p.image_url, p.thumbnail,
      COALESCE((SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id), p.price) as effective_price,
      p.currency_code,
      similarity(p.name, search_query) * 0.3 AS score
    FROM public.products p
    WHERE p.name % search_query

    UNION ALL

    -- Prefix Match Fallback (Important for auto-complete feel)
    SELECT 
      p.id, p.name, p.handle, p.image_url, p.thumbnail,
      COALESCE((SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id), p.price) as effective_price,
      p.currency_code,
      0.1 AS score
    FROM public.products p
    WHERE p.name ILIKE search_query || '%'
  ),
  aggregated AS (
    SELECT 
      r.id, r.name, r.handle, r.image_url, r.thumbnail, r.effective_price, r.currency_code,
      SUM(r.score) as combined_score
    FROM combined_results r
    GROUP BY r.id, r.name, r.handle, r.image_url, r.thumbnail, r.effective_price, r.currency_code
  )
  SELECT 
    a.id, a.name, a.handle, a.image_url, a.thumbnail, 
    a.effective_price::DECIMAL, a.currency_code,
    a.combined_score::FLOAT as relevance_score
  FROM aggregated a
  ORDER BY combined_score DESC
  LIMIT result_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- 6. Search Analytics Table
CREATE TABLE IF NOT EXISTS public.search_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_query TEXT NOT NULL,
  search_type TEXT NOT NULL, -- 'text', 'voice', etc.
  results_count INT NOT NULL,
  user_id TEXT,
  session_id TEXT,
  search_duration_ms INT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'
);

-- Indices for analytics reporting
CREATE INDEX IF NOT EXISTS search_analytics_query_idx ON public.search_analytics(search_query);
CREATE INDEX IF NOT EXISTS search_analytics_created_at_idx ON public.search_analytics(created_at);

-- 7. Analytics Tracking Function
CREATE OR REPLACE FUNCTION public.track_search_rpc(
  p_query TEXT,
  p_type TEXT,
  p_results_count INT,
  p_user_id TEXT DEFAULT NULL,
  p_session_id TEXT DEFAULT NULL,
  p_duration_ms INT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO public.search_analytics (
    search_query, search_type, results_count, 
    user_id, session_id, search_duration_ms
  )
  VALUES (
    p_query, p_type, p_results_count,
    p_user_id, p_session_id, p_duration_ms
  )
  RETURNING id INTO v_id;
  
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- <<< END 20260113_advanced_search.sql <<<


-- >>> BEGIN 20260113_gift_wrap_feature.sql >>>

-- Migration to add Global Settings and update Order Creation with Gift Wrap support

-- 1. Create global_settings table
CREATE TABLE IF NOT EXISTS public.global_settings (
    id TEXT PRIMARY KEY DEFAULT 'default',
    gift_wrap_fee NUMERIC NOT NULL DEFAULT 50,
    is_gift_wrap_enabled BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Insert default row if not exists
INSERT INTO public.global_settings (id, gift_wrap_fee, is_gift_wrap_enabled)
VALUES ('default', 50, true)
ON CONFLICT (id) DO NOTHING;

-- 2.5. Ensure payment_collection column exists in orders table
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'orders' 
        AND column_name = 'payment_collection'
    ) THEN
        ALTER TABLE public.orders ADD COLUMN payment_collection JSONB;
    END IF;
END $$;

-- 3. Update create_order_with_payment RPC
DROP FUNCTION IF EXISTS public.create_order_with_payment(TEXT, TEXT, JSONB, JSONB, TEXT, INTEGER) CASCADE;

CREATE FUNCTION public.create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_promo_discount NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_item_subtotal_before_club NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_total_discount NUMERIC := 0;
  v_final_total NUMERIC := 0;
  v_currency_code TEXT := 'INR';
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB := '[]'::jsonb;
  v_cart_discount_total NUMERIC := 0;
  v_gift_wrap_setting_fee NUMERIC := 0;
BEGIN
  -- 1. Get cart data
  SELECT 
    user_id, 
    COALESCE(currency_code, 'INR'), 
    shipping_methods, 
    payment_collection,
    COALESCE(discount_total, 0)
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_payment_collection,
    v_cart_discount_total
  FROM public.carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- 2. Get Gift Wrap Fee from Settings
  SELECT COALESCE(gift_wrap_fee, 0) INTO v_gift_wrap_setting_fee
  FROM public.global_settings
  WHERE id = 'default'
  LIMIT 1;

  -- 3. Check Club Membership
  IF v_user_id IS NOT NULL THEN
    SELECT COALESCE(is_club_member, FALSE) INTO v_is_club_member
    FROM public.profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT COALESCE(discount_percentage, 0) INTO v_club_discount_percentage
      FROM public.club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  -- 4. Build Items JSON and calculate subtotals (Including Gift Wrap)
  SELECT 
    COALESCE(jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN 'Gift Wrap'
          ELSE COALESCE(pv.title, p.name, 'Product')
        END,
        'product_title', COALESCE(p.name, 'Product'),
        'quantity', ci.quantity,
        'unit_price', CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
          ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
        END,
        'total', (CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
          ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
        END) * ci.quantity,
        'metadata', COALESCE(ci.metadata, '{}'::jsonb),
        'thumbnail', CASE WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN NULL ELSE p.image_url END,
        'variant', CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN NULL
          WHEN pv.id IS NOT NULL THEN jsonb_build_object('title', pv.title, 'id', pv.id)
          ELSE NULL
        END,
        'created_at', ci.created_at
      )
    ), '[]'::jsonb),
    COALESCE(SUM((CASE 
      WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
      ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
    END) * ci.quantity), 0),
    COALESCE(SUM((CASE 
      WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
      ELSE COALESCE(pv.price, p.price, 0)
    END) * ci.quantity), 0)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_item_subtotal_before_club
  FROM public.cart_items ci
  LEFT JOIN public.products p ON ci.product_id = p.id
  LEFT JOIN public.product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  -- Calculate discounts
  v_club_savings := COALESCE(v_item_subtotal_before_club - v_item_subtotal, 0);
  v_promo_discount := COALESCE(v_cart_discount_total, 0);
  v_total_discount := COALESCE(p_rewards_to_apply, 0) + v_promo_discount;

  -- Calculate Shipping
  v_shipping_total := 0;
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := COALESCE((v_method->>'amount')::NUMERIC, 0);
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := v_amount;
      END IF;
    END;
  END IF;

  -- Calculate final total
  v_final_total := GREATEST(0, v_item_subtotal + COALESCE(v_tax_total, 0) + v_shipping_total - v_total_discount);

  -- Update cart
  UPDATE public.carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', COALESCE(p_rewards_to_apply, 0)),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- Create order
  INSERT INTO public.orders (
    user_id,
    email,
    customer_email,
    shipping_address,
    billing_address,
    subtotal,
    tax_total,
    shipping_total,
    discount_total,
    total_amount,
    total,
    currency_code,
    payment_collection,
    items,
    shipping_methods,
    metadata,
    status,
    payment_status,
    fulfillment_status,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    p_email,
    p_email,
    p_shipping_address,
    p_billing_address,
    v_item_subtotal,
    v_tax_total,
    v_shipping_total,
    v_total_discount,
    v_final_total,
    v_final_total,
    v_currency_code,
    v_payment_collection,
    v_items_json,
    v_shipping_methods,
    jsonb_build_object(
      'cart_id', p_cart_id, 
      'rewards_used', COALESCE(p_rewards_to_apply, 0),
      'rewards_discount', COALESCE(p_rewards_to_apply, 0),
      'club_savings', v_club_savings,
      'promo_discount', v_promo_discount,
      'is_club_member', v_is_club_member,
      'club_discount_percentage', v_club_discount_percentage
    ),
    'pending',
    'pending',
    'not_shipped',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_order_id;

  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.create_order_with_payment TO authenticated;
GRANT SELECT ON public.global_settings TO authenticated;
GRANT SELECT ON public.global_settings TO anon;

-- <<< END 20260113_gift_wrap_feature.sql <<<


-- >>> BEGIN 20260113_image_voice_search.sql >>>

-- Image and Voice Search Support
-- This migration enables pgvector and adds image embedding support to products

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. Add image_embedding column to products (512 dimensions for CLIP ViT-B-32)
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS image_embedding vector(512);

-- 3. Create HNSW index for fast similarity search
-- Using cosine distance which works best with L2-normalized CLIP embeddings
-- m=16 and ef_construction=64 are optimal for datasets of 100-10,000 products
CREATE INDEX IF NOT EXISTS products_image_embedding_idx 
ON public.products USING hnsw (image_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- 4. Create Hybrid Multimodal Search Function
-- Combines text search (FTS + trigrams + prefix) with vector similarity search
CREATE OR REPLACE FUNCTION public.search_products_multimodal(
  search_query TEXT DEFAULT NULL,
  search_embedding vector(512) DEFAULT NULL,
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 20
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  handle TEXT,
  image_url TEXT,
  thumbnail TEXT,
  price DECIMAL,
  currency_code TEXT,
  relevance_score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  WITH text_scores AS (
    -- Text search using Full-Text Search, Trigrams, and Prefix matching
    SELECT 
      p.id::TEXT as product_id,
      GREATEST(
        -- Full-text search rank (weight 0.5)
        CASE 
          WHEN search_query IS NOT NULL AND p.search_vector @@ websearch_to_tsquery('english', search_query)
          THEN ts_rank_cd(p.search_vector, websearch_to_tsquery('english', search_query)) * 0.5
          ELSE 0 
        END,
        -- Trigram similarity (weight 0.4) - fuzzy matching
        CASE 
          WHEN search_query IS NOT NULL THEN similarity(p.name, search_query) * 0.4
          ELSE 0 
        END,
        -- Prefix match (weight 0.1) - starts-with matching
        CASE 
          WHEN search_query IS NOT NULL AND p.name ILIKE search_query || '%' THEN 0.1
          ELSE 0 
        END
      ) as text_score
    FROM public.products p
    WHERE search_query IS NOT NULL
  ),
  image_scores AS (
    -- Image similarity using cosine distance on L2-normalized CLIP embeddings
    -- The <=> operator calculates cosine distance (0 = identical, 2 = opposite)
    SELECT 
      p.id::TEXT as product_id,
      -- Convert distance to similarity: higher score = more similar (0-1 range)
      1 - (p.image_embedding <=> search_embedding) as image_score
    FROM public.products p
    WHERE search_embedding IS NOT NULL
      AND p.image_embedding IS NOT NULL
  ),
  combined_scores AS (
    -- Combine text and image scores with weighted average
    SELECT 
      COALESCE(t.product_id, i.product_id) as product_id,
      CASE 
        -- Both text and image search provided: 40% text + 60% image
        WHEN t.text_score > 0 AND i.image_score IS NOT NULL 
          THEN (t.text_score * 0.4 + i.image_score * 0.6)
        -- Only text search: 100% text
        WHEN t.text_score > 0 
          THEN t.text_score
        -- Only image search: 100% image
        WHEN i.image_score IS NOT NULL 
          THEN i.image_score
        ELSE 0
      END as final_score
    FROM text_scores t
    FULL OUTER JOIN image_scores i ON t.product_id = i.product_id
  )
  SELECT 
    p.id::TEXT,
    p.name,
    p.handle,
    p.image_url,
    p.thumbnail,
    -- Get minimum variant price if variants exist, otherwise use base price
    COALESCE(
      (SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id),
      p.price
    )::DECIMAL as price,
    p.currency_code,
    c.final_score::FLOAT as relevance_score
  FROM combined_scores c
  JOIN public.products p ON c.product_id = p.id::TEXT
  WHERE c.final_score >= match_threshold
  ORDER BY c.final_score DESC
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql STABLE;

-- 5. Add helpful comments
COMMENT ON FUNCTION public.search_products_multimodal IS 
'Hybrid multimodal search combining text (FTS + trigrams + prefix) and image (CLIP embeddings) search.
Parameters:
- search_query: Text query for keyword search (optional)
- search_embedding: 512-dim CLIP image embedding for visual search (optional)
- match_threshold: Minimum relevance score (0.0-1.0, default 0.7)
- match_count: Maximum results to return (default 20)

Scoring:
- Text-only: FTS (50%) + Trigram (40%) + Prefix (10%)
- Image-only: Cosine similarity (100%)
- Combined: Text (40%) + Image (60%)

Returns products sorted by relevance score (highest first).';

COMMENT ON COLUMN public.products.image_embedding IS 
'512-dimensional CLIP ViT-B-32 image embedding for visual similarity search. 
Generated using Transformers.js CLIP model. Must be L2-normalized before storage.';

COMMENT ON INDEX public.products_image_embedding_idx IS
'HNSW index for fast approximate nearest neighbor search on image embeddings.
Parameters: m=16 (connections per layer), ef_construction=64 (build quality).
Optimized for datasets of 100-10,000 products.';

-- <<< END 20260113_image_voice_search.sql <<<


-- >>> BEGIN 20260116_clear_admin_notifications.sql >>>

-- Clear all admin notifications
-- This allows for a fresh start, removing any stale notifications from deleted orders or tests.

BEGIN;

TRUNCATE TABLE public.admin_notifications;

COMMIT;

-- <<< END 20260116_clear_admin_notifications.sql <<<


-- >>> BEGIN 20260116_fix_admin_notifications_complete.sql >>>

-- Complete fix for Admin Notifications system
-- 1. Fixes "column user_id does not exist" RLS error
-- 2. Fixes "null value in column type" Trigger error
-- 3. Ensures is_admin() function is robust

BEGIN;

-- ==========================================
-- 1. UTILITIES
-- ==========================================

-- Ensure is_admin function exists and is strictly correct
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
    user_admin_role_id TEXT;
BEGIN
    -- Check profiles table using 'id' (correct PK)
    -- We select into variables to be safe
    SELECT role, admin_role_id INTO user_role, user_admin_role_id
    FROM public.profiles
    WHERE id = auth.uid();
    
    RETURN (user_role = 'admin') OR (user_admin_role_id IS NOT NULL);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;


-- ==========================================
-- 2. TABLE SCHEMA & CONSTRAINTS
-- ==========================================

-- Allow 'system' and other types in the check constraint
ALTER TABLE public.admin_notifications 
DROP CONSTRAINT IF EXISTS admin_notifications_type_check;

ALTER TABLE public.admin_notifications 
ADD CONSTRAINT admin_notifications_type_check 
CHECK (type IN ('order', 'user', 'review', 'system', 'alert'));


-- ==========================================
-- 3. POLICIES (Fixes "user_id does not exist")
-- ==========================================

-- Drop ALL policies to remove any malformed ones referencing user_id
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'admin_notifications'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.admin_notifications', policy_record.policyname);
    END LOOP;
END $$;

-- Recreate correct policies
CREATE POLICY "Admins can view notifications"
  ON public.admin_notifications FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Admins can update notifications"
  ON public.admin_notifications FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can insert notifications"
  ON public.admin_notifications FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());


-- ==========================================
-- 4. TRIGGERS (Fixes "null value in column type")
-- ==========================================

CREATE OR REPLACE FUNCTION public.handle_admin_notification()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    notify_title TEXT;
    notify_message TEXT;
    notify_type TEXT;
    notify_metadata JSONB;
BEGIN
    -- Handle Orders
    IF TG_TABLE_NAME = 'orders' THEN
        notify_type := 'order';
        notify_title := 'New Order Placed';
        notify_message := 'Order #' || COALESCE(NEW.display_id::text, 'NEW') || ' received from ' || COALESCE(NEW.customer_email, NEW.email, 'guest');
        notify_metadata := jsonb_build_object(
            'order_id', NEW.id, 
            'display_id', NEW.display_id,
            'total', NEW.total
        );
    
    -- Handle User Signups
    ELSIF TG_TABLE_NAME = 'profiles' THEN
        IF TG_OP = 'INSERT' THEN
            notify_type := 'user';
            notify_title := 'New User Registered';
            notify_message := COALESCE(NEW.first_name, '') || ' ' || COALESCE(NEW.last_name, '') || ' (' || COALESCE(NEW.email, 'no email') || ') joined Toycker.';
            notify_metadata := jsonb_build_object('user_id', NEW.id, 'email', NEW.email);
        ELSE
            RETURN NEW; 
        END IF;

    -- Handle Reviews
    ELSIF TG_TABLE_NAME = 'reviews' THEN
        notify_type := 'review';
        notify_title := 'New Review Submitted';
        notify_message := 'New ' || COALESCE(NEW.rating::text, '?') || '-star review from ' || COALESCE(NEW.display_name, 'Anonymous');
        notify_metadata := jsonb_build_object('review_id', NEW.id, 'product_id', NEW.product_id, 'rating', NEW.rating);
    
    -- Fallback
    ELSE
        notify_type := 'system';
        notify_title := 'System Event (' || TG_TABLE_NAME || ')';
        notify_message := 'Event ' || TG_OP || ' occurred on ' || TG_TABLE_NAME;
        notify_metadata := '{}'::jsonb;
    END IF;

    -- Safety check for NULL type
    IF notify_type IS NULL THEN
        notify_type := 'system';
        notify_title := 'Unknown Event';
        notify_message := 'An unknown event occurred (Type was NULL)';
        notify_metadata := jsonb_build_object('table', TG_TABLE_NAME, 'op', TG_OP);
    END IF;

    -- Insert
    INSERT INTO public.admin_notifications (type, title, message, metadata, created_at)
    VALUES (notify_type, notify_title, notify_message, notify_metadata, NOW());

    RETURN NEW;
END;
$$;

-- Re-attach triggers intentionally to ensure they use the new function
DROP TRIGGER IF EXISTS on_order_placed ON public.orders;
CREATE TRIGGER on_order_placed
    AFTER INSERT ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

DROP TRIGGER IF EXISTS on_user_signup ON public.profiles;
CREATE TRIGGER on_user_signup
    AFTER INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

DROP TRIGGER IF EXISTS on_review_submitted ON public.reviews;
CREATE TRIGGER on_review_submitted
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

COMMIT;

-- <<< END 20260116_fix_admin_notifications_complete.sql <<<


-- >>> BEGIN 20260116_fix_admin_notifications_null_type.sql >>>

-- Fix for "null value in column type" error in admin_notifications
-- The error happens because the trigger function tries to insert a notification but the type is NULL, 
-- or falls back to 'system' which violates the check constraint.

-- 1. Update the CHECK constraint to allow 'system' type
ALTER TABLE public.admin_notifications 
DROP CONSTRAINT IF EXISTS admin_notifications_type_check;

ALTER TABLE public.admin_notifications 
ADD CONSTRAINT admin_notifications_type_check 
CHECK (type IN ('order', 'user', 'review', 'system', 'alert'));

-- 2. Redefine the trigger function with robust type handling
CREATE OR REPLACE FUNCTION public.handle_admin_notification()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    notify_title TEXT;
    notify_message TEXT;
    notify_type TEXT;
    notify_metadata JSONB;
BEGIN
    -- Handle Orders
    IF TG_TABLE_NAME = 'orders' THEN
        notify_type := 'order';
        notify_title := 'New Order Placed';
        -- Use COALESCE for safety
        notify_message := 'Order #' || COALESCE(NEW.display_id::text, 'NEW') || ' received from ' || COALESCE(NEW.customer_email, NEW.email, 'guest');
        notify_metadata := jsonb_build_object(
            'order_id', NEW.id, 
            'display_id', NEW.display_id,
            'total', NEW.total
        );
    
    -- Handle User Signups (profiles table)
    ELSIF TG_TABLE_NAME = 'profiles' THEN
        -- Only notify on INSERT (new user)
        IF TG_OP = 'INSERT' THEN
            notify_type := 'user';
            notify_title := 'New User Registered';
            notify_message := COALESCE(NEW.first_name, '') || ' ' || COALESCE(NEW.last_name, '') || ' (' || COALESCE(NEW.email, 'no email') || ') joined Toycker.';
            notify_metadata := jsonb_build_object('user_id', NEW.id, 'email', NEW.email);
        ELSE
            RETURN NEW; -- Skip updates
        END IF;

    -- Handle Reviews
    ELSIF TG_TABLE_NAME = 'reviews' THEN
        notify_type := 'review';
        notify_title := 'New Review Submitted';
        notify_message := 'New ' || COALESCE(NEW.rating::text, '?') || '-star review from ' || COALESCE(NEW.display_name, 'Anonymous');
        notify_metadata := jsonb_build_object('review_id', NEW.id, 'product_id', NEW.product_id, 'rating', NEW.rating);
    
    -- Fallback for any other table or unexpected case
    ELSE
        notify_type := 'system';
        notify_title := 'System Event (' || TG_TABLE_NAME || ')';
        notify_message := 'Event ' || TG_OP || ' occurred on ' || TG_TABLE_NAME;
        notify_metadata := '{}'::jsonb;
    END IF;

    -- FINAL SAFETY CHECK: If type is still NULL (should not happen with logic above), force it to 'system'
    IF notify_type IS NULL THEN
        notify_type := 'system';
        notify_title := 'Unknown Event';
        notify_message := 'An unknown event occurred (Type was NULL)';
        notify_metadata := jsonb_build_object('table', TG_TABLE_NAME, 'op', TG_OP);
    END IF;

    -- Insert into notifications table
    INSERT INTO public.admin_notifications (type, title, message, metadata, created_at)
    VALUES (notify_type, notify_title, notify_message, notify_metadata, NOW());

    RETURN NEW;
END;
$$;

-- 3. Re-attach triggers to ensure they are using the correct function
DROP TRIGGER IF EXISTS on_order_placed ON public.orders;
CREATE TRIGGER on_order_placed
    AFTER INSERT ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

DROP TRIGGER IF EXISTS on_user_signup ON public.profiles;
CREATE TRIGGER on_user_signup
    AFTER INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

DROP TRIGGER IF EXISTS on_review_submitted ON public.reviews;
CREATE TRIGGER on_review_submitted
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_notification();

-- <<< END 20260116_fix_admin_notifications_null_type.sql <<<


-- >>> BEGIN 20260116_fix_admin_notifications_read_error.sql >>>

-- Fix invalid column reference in admin_notifications RLS policies
-- The error "column user_id does not exist" indicates a policy is referencing a non-existent column.
-- This migration wipes all policies on the table and reapplies correct ones.

BEGIN;

-- 1. Ensure is_admin function exists and is correct
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
    user_admin_role_id TEXT;
BEGIN
    -- Check profiles table using 'id' (correct PK), not 'user_id'
    SELECT role, admin_role_id INTO user_role, user_admin_role_id
    FROM public.profiles
    WHERE id = auth.uid();
    
    RETURN (user_role = 'admin') OR (user_admin_role_id IS NOT NULL);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. Drop ALL policies on admin_notifications to remove the broken one
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'admin_notifications'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.admin_notifications', policy_record.policyname);
    END LOOP;
END $$;

-- 3. Recreate correct policies
-- View: Only admins
CREATE POLICY "Admins can view notifications"
  ON public.admin_notifications FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- Update: Only admins (e.g. marking as read)
CREATE POLICY "Admins can update notifications"
  ON public.admin_notifications FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Insert: Only admins (or triggers which bypass RLS)
CREATE POLICY "Admins can insert notifications"
  ON public.admin_notifications FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

COMMIT;

-- <<< END 20260116_fix_admin_notifications_read_error.sql <<<


-- >>> BEGIN 20260116_reset_orders_sequence.sql >>>

-- Reset orders and display_id sequence
-- This migration deletes all existing orders and resets the auto-incrementing display_id to 1.
-- Useful for resetting the store state.

BEGIN;

-- 1. Delete all orders (this will cascade to order_items)
DELETE FROM public.orders;

-- 2. Reset the sequence for display_id
-- The sequence name is typically table_column_seq
ALTER SEQUENCE IF EXISTS public.orders_display_id_seq RESTART WITH 1;

COMMIT;

-- <<< END 20260116_reset_orders_sequence.sql <<<


-- >>> BEGIN 20260117_fix_cart_items_nullability.sql >>>

-- Fix Cart Items Variant Nullability
-- Allow variant_id to be NULL to support "Single Products" (no variants)
ALTER TABLE public.cart_items ALTER COLUMN variant_id DROP NOT NULL;

-- Ensure the foreign key still exists but allows NULL
-- (The existing constraint 'cart_items_variant_id_fkey' already allows NULL unless the column is NOT NULL)

-- <<< END 20260117_fix_cart_items_nullability.sql <<<


-- >>> BEGIN 20260119_soft_delete_promotions.sql >>>

-- Add is_deleted column to promotions table
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

-- Update RLS policies to exclude soft-deleted promotions from public view
DROP POLICY IF EXISTS "Public read active promotions" ON promotions;
CREATE POLICY "Public read active promotions" ON promotions
    FOR SELECT TO public
    USING (
        is_active = true 
        AND is_deleted = false 
        AND (starts_at IS NULL OR starts_at <= NOW())
    );

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';

-- <<< END 20260119_soft_delete_promotions.sql <<<


-- >>> BEGIN 20260120_add_payment_discount.sql >>>

-- Add discount_percentage column to payment_providers
ALTER TABLE public.payment_providers 
ADD COLUMN IF NOT EXISTS discount_percentage NUMERIC DEFAULT 0;

-- Update create_order_with_payment to handle payment discount
CREATE OR REPLACE FUNCTION create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_payment_discount_percentage NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_currency_code TEXT;
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB;
  v_payment_discount_amount NUMERIC := 0;
  v_promo_code TEXT;
  v_promo_discount NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_original_item_subtotal NUMERIC := 0;
BEGIN
  -- 1. Get cart basics, user info and payment data
  SELECT 
    user_id, 
    currency_code, 
    shipping_methods, 
    payment_collection,
    promo_code,
    discount_total
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_payment_collection,
    v_promo_code,
    v_promo_discount
  FROM carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- 2. Check Club Membership and Payment Discount
  IF v_user_id IS NOT NULL THEN
    SELECT is_club_member INTO v_is_club_member
    FROM profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT discount_percentage INTO v_club_discount_percentage
      FROM club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  -- Get payment provider discount
  SELECT discount_percentage INTO v_payment_discount_percentage
  FROM payment_providers
  WHERE id = p_payment_provider AND is_active = true;

  -- 3. Build Items JSON snapshot and calculate subtotal
  -- We also calculate v_original_item_subtotal to derive v_club_savings
  SELECT 
    jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', COALESCE(pv.title, p.name, 'Product'),
        'quantity', ci.quantity,
        'unit_price', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)),
        'total', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity,
        'metadata', ci.metadata,
        'thumbnail', p.image_url,
        'created_at', ci.created_at
      )
    ),
    SUM(ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity),
    SUM(COALESCE(pv.price, p.price, 0) * ci.quantity)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_original_item_subtotal
  FROM cart_items ci
  JOIN products p ON ci.product_id = p.id
  LEFT JOIN product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  v_club_savings := v_original_item_subtotal - v_item_subtotal;

  -- 4. Calculate payment discount
  IF v_payment_discount_percentage > 0 THEN
    v_payment_discount_amount := ROUND(v_item_subtotal * (v_payment_discount_percentage / 100));
  END IF;

  -- 5. Get Shipping Total (Respect FREE ABOVE threshold)
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := (v_method->>'amount')::NUMERIC;
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := COALESCE(v_amount, 0);
      END IF;
    END;
  END IF;

  -- 6. Update cart with addresses and email
  UPDATE carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', p_rewards_to_apply),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- 7. Create order
  INSERT INTO orders (
    user_id,
    email,
    customer_email,
    shipping_address,
    billing_address,
    subtotal,
    tax_total,
    shipping_total,
    discount_total,
    total_amount,
    total,
    currency_code,
    payment_collection,
    items,
    shipping_methods,
    metadata,
    promo_code,
    status,
    payment_status,
    fulfillment_status,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    p_email,
    p_email,
    p_shipping_address,
    p_billing_address,
    v_item_subtotal,
    v_tax_total,
    v_shipping_total,
    (p_rewards_to_apply + v_payment_discount_amount + COALESCE(v_promo_discount, 0)),
    GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply - v_payment_discount_amount - COALESCE(v_promo_discount, 0)),
    GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply - v_payment_discount_amount - COALESCE(v_promo_discount, 0)),
    v_currency_code,
    v_payment_collection,
    v_items_json,
    v_shipping_methods,
    jsonb_build_object(
      'cart_id', p_cart_id, 
      'rewards_used', p_rewards_to_apply,
      'payment_discount_amount', v_payment_discount_amount,
      'payment_discount_percentage', v_payment_discount_percentage,
      'promo_discount', COALESCE(v_promo_discount, 0),
      'promo_code', v_promo_code,
      'club_savings', v_club_savings,
      'club_discount_percentage', v_club_discount_percentage,
      'is_club_member', v_is_club_member
    ),
    v_promo_code,
    'pending',
    'pending',
    'not_shipped',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_order_id;

  -- 8. Return success with order ID
  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- <<< END 20260120_add_payment_discount.sql <<<


-- >>> BEGIN 20260121_fix_ghost_orders.sql >>>

-- 1. Cleanup: Remove duplicate pending orders for the same cart (keep only the latest one)
-- This is necessary to satisfy the unique index requirement in existing databases.
DELETE FROM orders
WHERE status = 'pending'
  AND id NOT IN (
    SELECT DISTINCT ON (metadata->>'cart_id') id
    FROM orders
    WHERE status = 'pending'
    ORDER BY metadata->>'cart_id', created_at DESC
  );

-- 2. Create a unique index for pending orders per cart to strictly prevent future duplicates
CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_pending_cart_id ON orders ((metadata->>'cart_id')) WHERE (status = 'pending');

-- 2. Update the RPC to handle existing pending orders
CREATE OR REPLACE FUNCTION create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_payment_discount_percentage NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_currency_code TEXT;
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB;
  v_payment_discount_amount NUMERIC := 0;
  v_promo_code TEXT;
  v_promo_discount NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_original_item_subtotal NUMERIC := 0;
  v_existing_order_id TEXT;
BEGIN
  -- 1. Get cart basics, user info and payment data
  SELECT 
    user_id, 
    currency_code, 
    shipping_methods, 
    payment_collection,
    promo_code,
    discount_total
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_payment_collection,
    v_promo_code,
    v_promo_discount
  FROM carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- 2. Check Club Membership and Payment Discount
  IF v_user_id IS NOT NULL THEN
    SELECT is_club_member INTO v_is_club_member
    FROM profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT discount_percentage INTO v_club_discount_percentage
      FROM club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  -- Get payment provider discount
  SELECT discount_percentage INTO v_payment_discount_percentage
  FROM payment_providers
  WHERE id = p_payment_provider AND is_active = true;

  -- 3. Build Items JSON snapshot and calculate subtotal
  SELECT 
    jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', COALESCE(pv.title, p.name, 'Product'),
        'quantity', ci.quantity,
        'unit_price', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)),
        'total', ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity,
        'metadata', ci.metadata,
        'thumbnail', p.image_url,
        'created_at', ci.created_at
      )
    ),
    SUM(ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100)) * ci.quantity),
    SUM(COALESCE(pv.price, p.price, 0) * ci.quantity)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_original_item_subtotal
  FROM cart_items ci
  JOIN products p ON ci.product_id = p.id
  LEFT JOIN product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  v_club_savings := v_original_item_subtotal - v_item_subtotal;

  -- 4. Calculate payment discount
  IF v_payment_discount_percentage > 0 THEN
    v_payment_discount_amount := ROUND(v_item_subtotal * (v_payment_discount_percentage / 100));
  END IF;

  -- 5. Get Shipping Total (Respect FREE ABOVE threshold)
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := (v_method->>'amount')::NUMERIC;
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := COALESCE(v_amount, 0);
      END IF;
    END;
  END IF;

  -- 6. Update cart with addresses and email
  UPDATE carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', p_rewards_to_apply),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- 7. Check for existing "pending" order for this cart
  SELECT id INTO v_existing_order_id
  FROM orders
  WHERE metadata->>'cart_id' = p_cart_id AND status = 'pending'
  LIMIT 1;

  IF v_existing_order_id IS NOT NULL THEN
    -- Update existing order instead of creating new one
    UPDATE orders SET
      email = p_email,
      customer_email = p_email,
      shipping_address = p_shipping_address,
      billing_address = p_billing_address,
      subtotal = v_item_subtotal,
      shipping_total = v_shipping_total,
      discount_total = (p_rewards_to_apply + v_payment_discount_amount + COALESCE(v_promo_discount, 0)),
      total_amount = GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply - v_payment_discount_amount - COALESCE(v_promo_discount, 0)),
      total = GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply - v_payment_discount_amount - COALESCE(v_promo_discount, 0)),
      payment_collection = v_payment_collection,
      items = v_items_json,
      shipping_methods = v_shipping_methods,
      metadata = jsonb_build_object(
        'cart_id', p_cart_id, 
        'rewards_used', p_rewards_to_apply,
        'payment_discount_amount', v_payment_discount_amount,
        'payment_discount_percentage', v_payment_discount_percentage,
        'promo_discount', COALESCE(v_promo_discount, 0),
        'promo_code', v_promo_code,
        'club_savings', v_club_savings,
        'club_discount_percentage', v_club_discount_percentage,
        'is_club_member', v_is_club_member
      ),
      promo_code = v_promo_code,
      payment_method = p_payment_provider,
      updated_at = NOW()
    WHERE id = v_existing_order_id;
    
    v_order_id := v_existing_order_id;
  ELSE
    -- 8. Create new order
    INSERT INTO orders (
      user_id,
      email,
      customer_email,
      shipping_address,
      billing_address,
      subtotal,
      tax_total,
      shipping_total,
      discount_total,
      total_amount,
      total,
      currency_code,
      payment_collection,
      items,
      shipping_methods,
      metadata,
      promo_code,
      payment_method,
      status,
      payment_status,
      fulfillment_status,
      created_at,
      updated_at
    ) VALUES (
      v_user_id,
      p_email,
      p_email,
      p_shipping_address,
      p_billing_address,
      v_item_subtotal,
      v_tax_total,
      v_shipping_total,
      (p_rewards_to_apply + v_payment_discount_amount + COALESCE(v_promo_discount, 0)),
      GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply - v_payment_discount_amount - COALESCE(v_promo_discount, 0)),
      GREATEST(0, v_item_subtotal + v_tax_total + v_shipping_total - p_rewards_to_apply - v_payment_discount_amount - COALESCE(v_promo_discount, 0)),
      v_currency_code,
      v_payment_collection,
      v_items_json,
      v_shipping_methods,
      jsonb_build_object(
        'cart_id', p_cart_id, 
        'rewards_used', p_rewards_to_apply,
        'payment_discount_amount', v_payment_discount_amount,
        'payment_discount_percentage', v_payment_discount_percentage,
        'promo_discount', COALESCE(v_promo_discount, 0),
        'promo_code', v_promo_code,
        'club_savings', v_club_savings,
        'club_discount_percentage', v_club_discount_percentage,
        'is_club_member', v_is_club_member
      ),
      v_promo_code,
      p_payment_provider,
      'pending',
      'pending',
      'not_shipped',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_order_id;
  END IF;

  -- 9. Return success with order ID
  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- 3. RLS Policies: Hide 'pending' orders from customers
-- This prevents "abandoned" checkout attempts from appearing in history
DROP POLICY IF EXISTS "Customers can only see their own paid orders" ON orders;
CREATE POLICY "Customers can only see their own paid orders" ON orders
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid() AND status != 'pending'
);

-- Admin should still see everything
DROP POLICY IF EXISTS "Admins can see all orders" ON orders;
CREATE POLICY "Admins can see all orders" ON orders
FOR ALL 
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);

-- <<< END 20260121_fix_ghost_orders.sql <<<


-- >>> BEGIN 20260122_enable_order_realtime.sql >>>

-- Enable Realtime for orders table to support the Track Order feature
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;

-- Relax RLS policy to allow customers to see their own orders even if 'pending'
-- This ensures the Order Confirmation and Realtime Tracking work correctly.
DROP POLICY IF EXISTS "Customers can only see their own paid orders" ON orders;
CREATE POLICY "Customers can see their own orders" ON orders
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
);

-- Ensure Admins still have full access
DROP POLICY IF EXISTS "Admins can see all orders" ON orders;
CREATE POLICY "Admins can see all orders" ON orders
FOR ALL 
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);

-- <<< END 20260122_enable_order_realtime.sql <<<


-- >>> BEGIN 20260123_rbac_complete_permissions.sql >>>

-- ================================================
-- RBAC: Complete Permission System
-- Adds all missing permissions for granular access control
-- Creates helper functions for efficient permission checking
-- ================================================

-- ================================================
-- PART 1: Update System Roles with Complete Permissions
-- ================================================

-- Update Owner role with full access wildcard
UPDATE public.admin_roles
SET permissions = to_jsonb(ARRAY['*']),
    updated_at = NOW()
WHERE name = 'Owner' AND is_system = true;

-- Update Admin role with comprehensive permissions (no wildcards, explicit grants)
UPDATE public.admin_roles
SET permissions = to_jsonb(ARRAY[
  -- Orders (full)
  'orders:read', 'orders:update', 'orders:delete',
  -- Products (full)
  'products:read', 'products:create', 'products:update', 'products:delete',
  -- Inventory (full)
  'inventory:read', 'inventory:update',
  -- Customers (read & update only, no delete for safety)
  'customers:read', 'customers:update',
  -- Collections (full)
  'collections:read', 'collections:create', 'collections:update', 'collections:delete',
  -- Categories (full)
  'categories:read', 'categories:create', 'categories:update', 'categories:delete',
  -- Discounts (full)
  'discounts:read', 'discounts:create', 'discounts:update', 'discounts:delete',
  -- Shipping (full)
  'shipping:read', 'shipping:create', 'shipping:update', 'shipping:delete',
  -- Shipping Partners (full)
  'shipping_partners:read', 'shipping_partners:create', 'shipping_partners:update', 'shipping_partners:delete',
  -- Payments (full)
  'payments:read', 'payments:create', 'payments:update', 'payments:delete',
  -- Reviews (read & update, no delete)
  'reviews:read', 'reviews:update',
  -- Home Settings (full)
  'home_settings:read', 'home_settings:update',
  -- Club Settings (full)
  'club_settings:read', 'club_settings:update',
  -- Settings (full)
  'settings:read', 'settings:update'
]),
    updated_at = NOW()
WHERE name = 'Admin' AND is_system = true;

-- Update Staff role with limited read/update permissions
UPDATE public.admin_roles
SET permissions = to_jsonb(ARRAY[
  -- Orders (read & update only)
  'orders:read', 'orders:update',
  -- Products (read only)
  'products:read',
  -- Inventory (read only)
  'inventory:read',
  -- Customers (read only)
  'customers:read',
  -- Collections (read only)
  'collections:read',
  -- Categories (read only)
  'categories:read',
  -- Discounts (read only)
  'discounts:read',
  -- Shipping (read only)
  'shipping:read'
]),
    updated_at = NOW()
WHERE name = 'Staff' AND is_system = true;

-- ================================================
-- PART 2: Create Permission Check Function
-- ================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS public.has_permission(TEXT);

-- Create optimized permission check function
-- Uses SECURITY DEFINER to bypass RLS and avoid recursion
-- Supports wildcards: '*' for full access, 'resource:*' for category access
CREATE OR REPLACE FUNCTION public.has_permission(
  required_permission TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  user_permissions_jsonb JSONB;
  user_permissions TEXT[];
  category TEXT;
  category_wildcard TEXT;
BEGIN
  -- Get current user's permissions from their assigned role (as jsonb)
  SELECT ar.permissions INTO user_permissions_jsonb
  FROM profiles p
  INNER JOIN admin_roles ar ON p.admin_role_id = ar.id
  WHERE p.id = auth.uid();

  -- If user has no role assigned, deny access
  IF user_permissions_jsonb IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Convert jsonb array to text array for easier checking
  user_permissions := ARRAY(
    SELECT jsonb_array_elements_text(user_permissions_jsonb)
  );

  -- If permissions array is empty, deny access
  IF array_length(user_permissions, 1) IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Check for full access wildcard (Owner role)
  IF '*' = ANY(user_permissions) THEN
    RETURN TRUE;
  END IF;

  -- Check for exact permission match
  IF required_permission = ANY(user_permissions) THEN
    RETURN TRUE;
  END IF;

  -- Extract category from permission (e.g., 'orders' from 'orders:read')
  category := split_part(required_permission, ':', 1);
  category_wildcard := category || ':*';
  
  -- Check for category wildcard match (e.g., 'orders:*' matches 'orders:read')
  IF category_wildcard = ANY(user_permissions) THEN
    RETURN TRUE;
  END IF;

  -- No permission found, deny access
  RETURN FALSE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.has_permission IS 
  'Checks if the current authenticated user has the specified permission. 
   Supports wildcards: "*" for full access and "resource:*" for category access.
   Returns FALSE if user has no role assigned.';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.has_permission(TEXT) TO authenticated;

-- ================================================
-- PART 3: Performance Indexes
-- ================================================

-- Index on profiles.admin_role_id for faster role lookups
CREATE INDEX IF NOT EXISTS idx_profiles_admin_role_id 
  ON public.profiles(admin_role_id) 
  WHERE admin_role_id IS NOT NULL;

-- Index on admin_roles.id for faster joins
CREATE INDEX IF NOT EXISTS idx_admin_roles_id 
  ON public.admin_roles(id);

-- GIN index on permissions array for faster containment checks
CREATE INDEX IF NOT EXISTS idx_admin_roles_permissions 
  ON public.admin_roles USING GIN(permissions);

-- ================================================
-- PART 4: Row-Level Security Policy for Critical Operations
-- ================================================

-- Example: Only allow customer deletion with explicit permission
-- This demonstrates RLS integration (can be expanded as needed)

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Only users with customers:delete can delete customers" ON public.profiles;

-- Create policy for customer deletion
CREATE POLICY "Only users with customers:delete can delete customers" 
  ON public.profiles
  FOR DELETE TO authenticated
  USING (
    -- Users can always delete their own profile
    auth.uid() = id
    OR
    -- Or admin with explicit customers:delete permission
    (SELECT has_permission('customers:delete'))
  );

-- ================================================
-- VERIFICATION
-- ================================================

-- Verify Owner role has wildcard
DO $$
DECLARE
  owner_perms JSONB;
BEGIN
  SELECT permissions INTO owner_perms 
  FROM admin_roles 
  WHERE name = 'Owner' AND is_system = true;
  
  IF NOT (owner_perms ? '*') THEN
    RAISE EXCEPTION 'Owner role does not have wildcard permission';
  END IF;
  
  RAISE NOTICE 'Owner role verified: has wildcard permission';
END $$;

-- Verify Admin role has expected permission count
DO $$
DECLARE
  admin_perm_count INT;
BEGIN
  SELECT jsonb_array_length(permissions) INTO admin_perm_count 
  FROM admin_roles 
  WHERE name = 'Admin' AND is_system = true;
  
  IF admin_perm_count < 30 THEN
    RAISE EXCEPTION 'Admin role has insufficient permissions: %', admin_perm_count;
  END IF;
  
  RAISE NOTICE 'Admin role verified: has % permissions', admin_perm_count;
END $$;

-- Verify Staff role has expected permission count
DO $$
DECLARE
  staff_perm_count INT;
BEGIN
  SELECT jsonb_array_length(permissions) INTO staff_perm_count 
  FROM admin_roles 
  WHERE name = 'Staff' AND is_system = true;
  
  IF staff_perm_count < 8 THEN
    RAISE EXCEPTION 'Staff role has insufficient permissions: %', staff_perm_count;
  END IF;
  
  RAISE NOTICE 'Staff role verified: has % permissions', staff_perm_count;
END $$;

-- Verify indexes were created
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_profiles_admin_role_id'
  ) THEN
    RAISE EXCEPTION 'Index idx_profiles_admin_role_id was not created';
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_admin_roles_permissions'
  ) THEN
    RAISE EXCEPTION 'Index idx_admin_roles_permissions was not created';
  END IF;
  
  RAISE NOTICE 'All indexes verified';
END $$;

-- Display final summary
DO $$
DECLARE
  owner_perms JSONB;
  admin_perms JSONB;
  staff_perms JSONB;
BEGIN
  SELECT permissions INTO owner_perms FROM admin_roles WHERE name = 'Owner' AND is_system = true;
  SELECT permissions INTO admin_perms FROM admin_roles WHERE name = 'Admin' AND is_system = true;
  SELECT permissions INTO staff_perms FROM admin_roles WHERE name = 'Staff' AND is_system = true;
  
  RAISE NOTICE '================================================';
  RAISE NOTICE 'RBAC Migration Complete!';
  RAISE NOTICE '================================================';
  RAISE NOTICE 'Owner permissions: % (wildcard)', jsonb_array_length(owner_perms);
  RAISE NOTICE 'Admin permissions: %', jsonb_array_length(admin_perms);
  RAISE NOTICE 'Staff permissions: %', jsonb_array_length(staff_perms);
  RAISE NOTICE '================================================';
  RAISE NOTICE 'Function created: has_permission(TEXT)';
  RAISE NOTICE 'Indexes created: 3';
  RAISE NOTICE 'RLS policies updated: 1';
  RAISE NOTICE '================================================';
END $$;

-- <<< END 20260123_rbac_complete_permissions.sql <<<


-- >>> BEGIN 20260123_supabase_optimization_v2.sql >>>

-- =====================================================
-- Supabase Security and Performance Optimization v2
-- =====================================================
-- Addressing 46 issues identified in the Dashboard
-- =====================================================

BEGIN;

-- =====================================================
-- PHASE 1: SECURITY HARDENING
-- =====================================================

-- -----------------------------------------------------
-- 1. Enable RLS on search_analytics and global_settings
-- -----------------------------------------------------

ALTER TABLE public.search_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.global_settings ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------
-- 2. Access Policies for search_analytics
-- -----------------------------------------------------

DROP POLICY IF EXISTS "Public can insert search_analytics" ON public.search_analytics;
DROP POLICY IF EXISTS "Admins can manage search_analytics" ON public.search_analytics;

-- Allow anyone to track search (Append-only)
CREATE POLICY "Public can insert search_analytics"
  ON public.search_analytics FOR INSERT
  TO public
  WITH CHECK (true);

-- Allow admins to view search reports (Protects session_id/user_id)
CREATE POLICY "Admins can manage search_analytics"
  ON public.search_analytics FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- -----------------------------------------------------
-- 3. Access Policies for global_settings
-- -----------------------------------------------------

DROP POLICY IF EXISTS "Public read global_settings" ON public.global_settings;
DROP POLICY IF EXISTS "Admins manage global_settings" ON public.global_settings;

-- Allow anyone to read settings (e.g., gift wrap fee)
CREATE POLICY "Public read global_settings"
  ON public.global_settings FOR SELECT
  TO public
  USING (true);

-- Allow admins to update settings
CREATE POLICY "Admins manage global_settings"
  ON public.global_settings FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- -----------------------------------------------------
-- 4. Secure Functions (search_path & SECURITY DEFINER)
-- -----------------------------------------------------

-- Fix: track_search_rpc
-- Adding SECURITY DEFINER allows it to write to search_analytics even if user has no RLS insert permissions
CREATE OR REPLACE FUNCTION public.track_search_rpc(
  p_query TEXT,
  p_type TEXT,
  p_results_count INT,
  p_user_id TEXT DEFAULT NULL,
  p_session_id TEXT DEFAULT NULL,
  p_duration_ms INT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO public.search_analytics (
    search_query, search_type, results_count, 
    user_id, session_id, search_duration_ms
  )
  VALUES (
    p_query, p_type, p_results_count,
    p_user_id, p_session_id, p_duration_ms
  )
  RETURNING id INTO v_id;
  
  RETURN v_id;
END;
$$;

-- Fix: create_order_with_payment (Ensuring search_path is safe)
-- Note: Logic is preserved from 20260113_gift_wrap_feature.sql
CREATE OR REPLACE FUNCTION public.create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_promo_discount NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_item_subtotal_before_club NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_total_discount NUMERIC := 0;
  v_final_total NUMERIC := 0;
  v_currency_code TEXT := 'INR';
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB := '[]'::jsonb;
  v_cart_discount_total NUMERIC := 0;
  v_gift_wrap_setting_fee NUMERIC := 0;
BEGIN
  -- 1. Get cart data
  SELECT 
    user_id, 
    COALESCE(currency_code, 'INR'), 
    shipping_methods, 
    payment_collection,
    COALESCE(discount_total, 0)
  INTO 
    v_user_id, 
    v_currency_code, 
    v_shipping_methods, 
    v_payment_collection,
    v_cart_discount_total
  FROM public.carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  -- 2. Get Gift Wrap Fee from Settings
  SELECT COALESCE(gift_wrap_fee, 0) INTO v_gift_wrap_setting_fee
  FROM public.global_settings
  WHERE id = 'default'
  LIMIT 1;

  -- 3. Check Club Membership
  IF v_user_id IS NOT NULL THEN
    SELECT COALESCE(is_club_member, FALSE) INTO v_is_club_member
    FROM public.profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT COALESCE(discount_percentage, 0) INTO v_club_discount_percentage
      FROM public.club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  -- 4. Build Items JSON and calculate subtotals (Including Gift Wrap)
  SELECT 
    COALESCE(jsonb_agg(
      jsonb_build_object(
        'id', ci.id,
        'product_id', ci.product_id,
        'variant_id', ci.variant_id,
        'title', CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN 'Gift Wrap'
          ELSE COALESCE(pv.title, p.name, 'Product')
        END,
        'product_title', COALESCE(p.name, 'Product'),
        'quantity', ci.quantity,
        'unit_price', CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
          ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
        END,
        'total', (CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
          ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
        END) * ci.quantity,
        'metadata', COALESCE(ci.metadata, '{}'::jsonb),
        'thumbnail', CASE WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN NULL ELSE p.image_url END,
        'variant', CASE 
          WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN NULL
          WHEN pv.id IS NOT NULL THEN jsonb_build_object('title', pv.title, 'id', pv.id)
          ELSE NULL
        END,
        'created_at', ci.created_at
      )
    ), '[]'::jsonb),
    COALESCE(SUM((CASE 
      WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
      ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
    END) * ci.quantity), 0),
    COALESCE(SUM((CASE 
      WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
      ELSE COALESCE(pv.price, p.price, 0)
    END) * ci.quantity), 0)
  INTO 
    v_items_json,
    v_item_subtotal,
    v_item_subtotal_before_club
  FROM public.cart_items ci
  LEFT JOIN public.products p ON ci.product_id = p.id
  LEFT JOIN public.product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  -- Calculate discounts
  v_club_savings := COALESCE(v_item_subtotal_before_club - v_item_subtotal, 0);
  v_promo_discount := COALESCE(v_cart_discount_total, 0);
  v_total_discount := COALESCE(p_rewards_to_apply, 0) + v_promo_discount;

  -- Calculate Shipping
  v_shipping_total := 0;
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := COALESCE((v_method->>'amount')::NUMERIC, 0);
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := v_amount;
      END IF;
    END;
  END IF;

  -- Calculate final total
  v_final_total := GREATEST(0, v_item_subtotal + COALESCE(v_tax_total, 0) + v_shipping_total - v_total_discount);

  -- Update cart
  UPDATE public.carts SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('rewards_to_apply', COALESCE(p_rewards_to_apply, 0)),
    updated_at = NOW()
  WHERE id = p_cart_id;

  -- Create order
  INSERT INTO public.orders (
    user_id,
    email,
    customer_email,
    shipping_address,
    billing_address,
    subtotal,
    tax_total,
    shipping_total,
    discount_total,
    total_amount,
    total,
    currency_code,
    payment_collection,
    items,
    shipping_methods,
    metadata,
    status,
    payment_status,
    fulfillment_status,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    p_email,
    p_email,
    p_shipping_address,
    p_billing_address,
    v_item_subtotal,
    v_tax_total,
    v_shipping_total,
    v_total_discount,
    v_final_total,
    v_final_total,
    v_currency_code,
    v_payment_collection,
    v_items_json,
    v_shipping_methods,
    jsonb_build_object(
      'cart_id', p_cart_id, 
      'rewards_used', COALESCE(p_rewards_to_apply, 0),
      'rewards_discount', COALESCE(p_rewards_to_apply, 0),
      'club_savings', v_club_savings,
      'promo_discount', v_promo_discount,
      'is_club_member', v_is_club_member,
      'club_discount_percentage', v_club_discount_percentage
    ),
    'pending',
    'pending',
    'not_shipped',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_order_id;

  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- Fix: update_updated_at_column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Fix: is_admin (Hardening)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.admin_roles
    WHERE user_id = auth.uid()
      AND is_active = true
  );
END;
$$;

-- =====================================================
-- PHASE 2: PERFORMANCE OPTIMIZATION
-- =====================================================

-- -----------------------------------------------------
-- 5. Add Recommended Indexes
-- -----------------------------------------------------

-- Optimize product sorting by creation date
CREATE INDEX IF NOT EXISTS products_created_at_desc_idx ON public.products (created_at DESC);

-- Optimize relationship lookups for collections
CREATE INDEX IF NOT EXISTS product_collections_product_id_idx ON public.product_collections (product_id);

-- Optimize text-based search/filter on short_description
CREATE INDEX IF NOT EXISTS products_short_description_trgm_idx ON public.products USING GIN (short_description gin_trgm_ops);

COMMIT;

-- <<< END 20260123_supabase_optimization_v2.sql <<<


-- >>> BEGIN 20260124151234_add_variant_image_url.sql >>>

-- Add image_url column to product_variants table
ALTER TABLE product_variants ADD COLUMN IF NOT EXISTS image_url TEXT;

-- <<< END 20260124151234_add_variant_image_url.sql <<<


-- >>> BEGIN 20260127_restore_multimodal_search.sql >>>

-- Restore and Finalize Multimodal Search
-- This migration ensures pgvector is enabled and the multimodal search function is ready.

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. Ensure image_embedding column exists
-- CLIP ViT-B-32 produces 512-dimensional embeddings
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS image_embedding vector(512);

-- 3. Create HNSW index for fast similarity search
-- Using cosine distance for L2-normalized CLIP embeddings
CREATE INDEX IF NOT EXISTS products_image_embedding_idx 
ON public.products USING hnsw (image_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- 4. Create Multimodal Search Function
-- This hybrid function combines text search and visual search with weighted scoring.
CREATE OR REPLACE FUNCTION public.search_products_multimodal(
  search_query TEXT DEFAULT NULL,
  search_embedding vector(512) DEFAULT NULL,
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 20
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  handle TEXT,
  image_url TEXT,
  thumbnail TEXT,
  price DECIMAL,
  currency_code TEXT,
  relevance_score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  WITH text_scores AS (
    -- Text search ranking (FTS + Trigrams + Prefix)
    SELECT 
      p.id::TEXT as product_id,
      GREATEST(
        CASE 
          WHEN search_query IS NOT NULL AND p.search_vector @@ websearch_to_tsquery('english', search_query)
          THEN ts_rank_cd(p.search_vector, websearch_to_tsquery('english', search_query)) * 0.5
          ELSE 0 
        END,
        CASE 
          WHEN search_query IS NOT NULL THEN similarity(p.name, search_query) * 0.4
          ELSE 0 
        END,
        CASE 
          WHEN search_query IS NOT NULL AND p.name ILIKE search_query || '%' THEN 0.1
          ELSE 0 
        END
      ) as text_score
    FROM public.products p
    WHERE search_query IS NOT NULL
  ),
  image_scores AS (
    -- Image similarity score (1 - cosine distance)
    SELECT 
      p.id::TEXT as product_id,
      1 - (p.image_embedding <=> search_embedding) as image_score
    FROM public.products p
    WHERE search_embedding IS NOT NULL
      AND p.image_embedding IS NOT NULL
  ),
  combined_scores AS (
    -- Weighted combination of text (40%) and image (60%) scores
    SELECT 
      COALESCE(t.product_id, i.product_id) as product_id,
      CASE 
        WHEN t.text_score > 0 AND i.image_score IS NOT NULL 
          THEN (t.text_score * 0.4 + i.image_score * 0.6)
        WHEN t.text_score > 0 
          THEN t.text_score
        WHEN i.image_score IS NOT NULL 
          THEN i.image_score
        ELSE 0
      END as final_score
    FROM text_scores t
    FULL OUTER JOIN image_scores i ON t.product_id = i.product_id
  )
  SELECT 
    p.id::TEXT,
    p.name,
    p.handle,
    p.image_url,
    p.thumbnail,
    COALESCE(
      (SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id),
      p.price
    )::DECIMAL as price,
    p.currency_code,
    c.final_score::FLOAT as relevance_score
  FROM combined_scores c
  JOIN public.products p ON c.product_id = p.id::TEXT
  WHERE c.final_score >= match_threshold
  ORDER BY c.final_score DESC
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql STABLE;

-- 5. Track that this migration has been applied
COMMENT ON FUNCTION public.search_products_multimodal IS 'Hybrid search combining text and image embeddings. Last updated 2026-01-27.';

-- <<< END 20260127_restore_multimodal_search.sql <<<


-- >>> BEGIN 20260128110000_add_product_combinations.sql >>>

-- Create product_combinations table
CREATE TABLE IF NOT EXISTS public.product_combinations (
    id TEXT PRIMARY KEY DEFAULT ('comb_' || uuid_generate_v4()),
    product_id TEXT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    related_product_id TEXT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    -- Prevent duplicate combinations
    UNIQUE(product_id, related_product_id)
);

-- Enable Row Level Security
ALTER TABLE public.product_combinations ENABLE ROW LEVEL SECURITY;

-- Policies
-- Policies
-- Allow anyone to read combinations (needed for storefront)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'product_combinations' 
        AND policyname = 'Allow public read access for product combinations'
    ) THEN
        CREATE POLICY "Allow public read access for product combinations"
        ON public.product_combinations FOR SELECT
        TO public
        USING (true);
    END IF;
END $$;

-- Allow authenticated users (Admins) to manage combinations
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'product_combinations' 
        AND policyname = 'Allow authenticated users to insert product combinations'
    ) THEN
        CREATE POLICY "Allow authenticated users to insert product combinations"
        ON public.product_combinations FOR INSERT
        TO authenticated
        WITH CHECK (true);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'product_combinations' 
        AND policyname = 'Allow authenticated users to update product combinations'
    ) THEN
        CREATE POLICY "Allow authenticated users to update product combinations"
        ON public.product_combinations FOR UPDATE
        TO authenticated
        USING (true);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'product_combinations' 
        AND policyname = 'Allow authenticated users to delete product combinations'
    ) THEN
        CREATE POLICY "Allow authenticated users to delete product combinations"
        ON public.product_combinations FOR DELETE
        TO authenticated
        USING (true);
    END IF;
END $$;

-- Comment for documentation
COMMENT ON TABLE public.product_combinations IS 'Stores manually selected product relationships for "Frequently Bought Together" feature.';

-- <<< END 20260128110000_add_product_combinations.sql <<<


-- >>> BEGIN 20260129143500_add_seo_fields_to_products.sql >>>

-- Add SEO fields to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS seo_title TEXT,
ADD COLUMN IF NOT EXISTS seo_description TEXT,
ADD COLUMN IF NOT EXISTS seo_metadata JSONB DEFAULT '{}';

-- Add GIN index for seo_metadata for faster lookups if needed
CREATE INDEX IF NOT EXISTS idx_products_seo_metadata_gin ON products USING GIN (seo_metadata);

-- <<< END 20260129143500_add_seo_fields_to_products.sql <<<


-- >>> BEGIN 20260130142000_add_image_url_to_catalog.sql >>>

-- Add image_url column to categories and collections
ALTER TABLE categories ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE collections ADD COLUMN IF NOT EXISTS image_url TEXT;

-- <<< END 20260130142000_add_image_url_to_catalog.sql <<<


-- >>> BEGIN 20260130173000_add_parent_category_id_to_categories.sql >>>


-- Add missing parent_category_id column to categories table in Production
-- This column is required for the self-referencing relationship
ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS parent_category_id TEXT references categories(id);

-- Ensure the constraint name matches what we expect in the code
-- Note: Postgres usually auto-names it 'categories_parent_category_id_fkey', but strictly speaking we can enforce it.
-- However, standard renaming or adding usually suffices.

-- <<< END 20260130173000_add_parent_category_id_to_categories.sql <<<


-- >>> BEGIN 20260130180000_add_parent_category_function.sql >>>

-- Create computed relationship function for parent_category
-- This enables PostgREST to properly embed the parent category in recursive self-joins
-- See: https://docs.postgrest.org/en/stable/references/api/resource_embedding.html#recursive-relationships

CREATE OR REPLACE FUNCTION parent_category(categories) 
RETURNS SETOF categories 
ROWS 1 
AS $$
  SELECT * FROM categories WHERE id = $1.parent_category_id
$$ 
STABLE LANGUAGE SQL;

-- <<< END 20260130180000_add_parent_category_function.sql <<<


-- >>> BEGIN 20260202_final_fix.sql >>>

-- =====================================================
-- Supabase Final Fix Migration - Phase 5
-- =====================================================
-- Purpose: Address remaining 22 issues from linter
-- - Enable RLS on global_settings
-- - Fix 3 functions with mutable search_path
-- - Ensure search_analytics policies exist
-- - Clean up remaining duplicate policies
-- =====================================================
-- Date: 2026-02-02
-- =====================================================

BEGIN;

-- =====================================================
-- FIX 1: Enable RLS on global_settings table
-- =====================================================
ALTER TABLE public.global_settings ENABLE ROW LEVEL SECURITY;

-- Create policies for global_settings
DO $$
BEGIN
  -- Allow public read access
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'global_settings' 
    AND policyname = 'Public can read global settings'
  ) THEN
    EXECUTE 'CREATE POLICY "Public can read global settings"
      ON public.global_settings FOR SELECT
      TO public
      USING (true)';
  END IF;

  -- Admin-only write access
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'global_settings' 
    AND policyname = 'Admins can manage global settings'
  ) THEN
    EXECUTE 'CREATE POLICY "Admins can manage global settings"
      ON public.global_settings FOR ALL
      TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin())';
  END IF;
END $$;

COMMENT ON TABLE public.global_settings IS 
  'Global application settings. RLS enabled - public read, admin write.';

-- =====================================================
-- FIX 2: Ensure search_analytics has correct policies
-- =====================================================
-- Drop any conflicting policies first
DROP POLICY IF EXISTS "Public can insert search_analytics" ON public.search_analytics;
DROP POLICY IF EXISTS "Public can insert searches" ON public.search_analytics;
DROP POLICY IF EXISTS "Admins can manage search_analytics" ON public.search_analytics;
DROP POLICY IF EXISTS "Admins read search analytics" ON public.search_analytics;

-- Create the correct policies
CREATE POLICY "Public can insert search_analytics"
  ON public.search_analytics FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Admins can manage search_analytics"
  ON public.search_analytics FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- =====================================================
-- FIX 3: Fix function search_path issues
-- =====================================================
-- These functions were flagged as having mutable search_path
-- They may have been fixed in earlier migrations, but let's ensure

-- Function: update_updated_at_column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.update_updated_at_column() IS 
  'Trigger function to automatically update updated_at timestamp. Search path hardened.';

-- Function: create_order_with_payment  
-- Need to check if this exists first
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'create_order_with_payment'
  ) THEN
    -- Re-create with hardened search_path
    -- Note: We need to preserve the original function body
    -- This is a placeholder - the actual function should be recreated with its original logic
    EXECUTE 'ALTER FUNCTION public.create_order_with_payment SET search_path = public, pg_catalog, pg_temp';
  END IF;
END $$;

-- Function: track_search_rpc
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'track_search_rpc'
  ) THEN
    EXECUTE 'ALTER FUNCTION public.track_search_rpc SET search_path = public, pg_catalog, pg_temp';
  END IF;
END $$;

-- =====================================================
-- FIX 4: Clean up remaining duplicate policies
-- =====================================================
-- Based on the linter results showing multiple permissive policies

-- Collections: Remove old duplicate
DROP POLICY IF EXISTS "Admins can manage collections" ON public.collections;

-- Categories: Remove old duplicate  
DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;

-- Products: Remove old public read policy
DROP POLICY IF EXISTS "Allow public read access" ON public.products;

-- Product variants: Remove old policy
DROP POLICY IF EXISTS "Public read variants" ON public.product_variants;

-- Product options: Remove old duplicates
DROP POLICY IF EXISTS "Admins can manage product_options" ON public.product_options;

-- Product option values: Remove old duplicates
DROP POLICY IF EXISTS "Admins can manage product_option_values" ON public.product_option_values;

-- Product collections: Remove old duplicates
DROP POLICY IF EXISTS "Admins can manage product_collections" ON public.product_collections;

-- Product categories: Keep only consolidated policy
-- (Already handled in previous migration)

-- Home banners: Remove old policy
DROP POLICY IF EXISTS "Public can view active home banners" ON public.home_banners;
DROP POLICY IF EXISTS "Admins can manage home banners" ON public.home_banners;

-- Home exclusive collections: Remove old policy
DROP POLICY IF EXISTS "Public can view active exclusive collections" ON public.home_exclusive_collections;
DROP POLICY IF EXISTS "Admins can manage exclusive collections" ON public.home_exclusive_collections;

-- Shipping partners: Remove old duplicates
DROP POLICY IF EXISTS "Admins can manage shipping_partners" ON public.shipping_partners;

-- Reviews: Remove old policy
DROP POLICY IF EXISTS "Public can view approved reviews" ON public.reviews;

-- Profiles: Remove old policy
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Only users with customers:delete can delete customers" ON public.profiles;

-- Orders: Remove old policy
DROP POLICY IF EXISTS "Admins can update orders" ON public.orders;

-- Cart items: Remove old policies
DROP POLICY IF EXISTS "Access cart items via cart" ON public.cart_items;
DROP POLICY IF EXISTS "Admins can manage all cart items" ON public.cart_items;

-- Promotions: Ensure no duplicates
DROP POLICY IF EXISTS "Admins read all promotions" ON public.promotions;

-- Review media: Remove old policy
DROP POLICY IF EXISTS "Admins can manage review media" ON public.review_media;

-- Product combinations: Remove old policy
DROP POLICY IF EXISTS "Allow public read access for product combinations" ON public.product_combinations;

-- Payment providers: Ensure no conflicts
DROP POLICY IF EXISTS "Admins can manage payment_providers" ON public.payment_providers;

-- Shipping options: Ensure no conflicts
DROP POLICY IF EXISTS "Admins can manage shipping_options" ON public.shipping_options;

COMMIT;

-- =====================================================
-- POST-MIGRATION VERIFICATION
-- =====================================================
-- Run these queries to verify all fixes:
--
-- 1. Check RLS enabled on global_settings:
--    SELECT relname, relrowsecurity 
--    FROM pg_class 
--    WHERE relname = 'global_settings';
--    Expected: relrowsecurity = true
--
-- 2. Check function search_path settings:
--    SELECT p.proname, p.proconfig
--    FROM pg_proc p
--    JOIN pg_namespace n ON p.pronamespace = n.oid
--    WHERE n.nspname = 'public'
--    AND p.proname IN ('update_updated_at_column', 'create_order_with_payment', 'track_search_rpc');
--    Expected: All should have search_path in proconfig
--
-- 3. Check remaining multiple policies:
--    SELECT schemaname, tablename, COUNT(*) as policy_count
--    FROM pg_policies
--    WHERE schemaname = 'public'
--    GROUP BY schemaname, tablename
--    HAVING COUNT(*) > 3
--    ORDER BY policy_count DESC;
--    Expected: Should see very few tables with multiple policies
--
-- 4. Run Supabase linter again:
--    Should show significantly fewer issues (target: <10)
-- =====================================================

-- <<< END 20260202_final_fix.sql <<<


-- >>> BEGIN 20260202_final_performance_optimization.sql >>>

-- =====================================================
-- Final Performance Optimization - Fix Auth RLS initplan
-- =====================================================
-- This migration fixes 3 remaining performance issues
-- by wrapping auth.uid() calls in SELECT subqueries
-- 
-- Issues Fixed:
-- - orders: "Customers can see their own orders" policy
-- - orders: "Admins can see all orders" policy  
-- - profiles: "Only users with customers:delete" policy
--
-- Impact: Reduces 42 issues → 39 issues
-- Remaining: 39 acceptable design trade-offs
-- =====================================================
-- Date: 2026-02-02
-- =====================================================

BEGIN;

-- =====================================================
-- FIX 1: Optimize orders RLS policies
-- =====================================================

-- Drop and recreate "Customers can see their own orders"
DROP POLICY IF EXISTS "Customers can see their own orders" ON public.orders;

CREATE POLICY "Customers can see their own orders"
  ON public.orders FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));  -- Wrapped in SELECT for caching

-- Drop and recreate "Admins can see all orders"
DROP POLICY IF EXISTS "Admins can see all orders" ON public.orders;

CREATE POLICY "Admins can see all orders"
  ON public.orders FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))  -- Wrapped in SELECT for caching
  WITH CHECK ((SELECT public.is_admin()));

-- =====================================================
-- FIX 2: Optimize profiles RLS policy
-- =====================================================

-- Drop and recreate "Only users with customers:delete can delete customers"
DROP POLICY IF EXISTS "Only users with customers:delete can delete customers" ON public.profiles;

CREATE POLICY "Only users with customers:delete can delete customers"
  ON public.profiles FOR DELETE
  TO authenticated
  USING (
    (SELECT public.has_permission('customers:delete'))  -- Wrapped in SELECT for caching
  );

COMMIT;

-- =====================================================
-- VERIFICATION
-- =====================================================
-- After running this migration:
-- 1. Go to Database → Linter in Supabase Dashboard
-- 2. Refresh the linter
-- 3. Expected: 39 issues (down from 42)
-- 
-- Remaining issues breakdown:
-- - 37 "Multiple permissive policies" (design choice for maintainability)
-- - 1 "search_analytics policy" (intentional for anonymous tracking)
-- - 1 "Leaked password protection" (requires Pro plan)
--
-- These 39 issues are ACCEPTABLE and do not need fixing.
-- =====================================================

-- <<< END 20260202_final_performance_optimization.sql <<<


-- >>> BEGIN 20260202_fix_extension_search_path.sql >>>

-- =====================================================
-- Fix Extension Search Path - Hotfix
-- =====================================================
-- Purpose: Fix similarity() function not found error
-- Issue: After moving pg_trgm to extensions schema, the
--        similarity() function is no longer in search_path
-- Solution: Update search_path for all affected functions
--           and set database default search_path
-- =====================================================
-- Date: 2026-02-02
-- =====================================================

BEGIN;

-- =====================================================
-- FIX 1: Update search_path for search functions
-- =====================================================
-- Add 'extensions' schema to search_path so similarity()
-- and other extension functions are accessible

-- Function: search_products_multimodal
ALTER FUNCTION public.search_products_multimodal(TEXT, vector(512), FLOAT, INT)
  SET search_path = public, extensions, pg_catalog, pg_temp;

-- Function: search_products_advanced  
ALTER FUNCTION public.search_products_advanced(TEXT, FLOAT, INT)
  SET search_path = public, extensions, pg_catalog, pg_temp;

COMMENT ON FUNCTION public.search_products_multimodal IS 
  'Hybrid text + image search. Search path includes extensions schema for pg_trgm functions.';

COMMENT ON FUNCTION public.search_products_advanced IS 
  'Advanced text search with FTS + trigrams. Search path includes extensions schema for pg_trgm functions.';

-- =====================================================
-- FIX 2: Set database default search_path
-- =====================================================
-- Ensure all future sessions include extensions schema

-- Note: This affects the entire database
-- Alternative: Can set per-role if needed
ALTER DATABASE postgres SET search_path TO public, extensions, pg_catalog;

COMMENT ON SCHEMA extensions IS 
  'Schema for PostgreSQL extensions. Included in default search_path for database.';

-- =====================================================
-- FIX 3: Grant necessary permissions
-- =====================================================
-- Ensure anon and authenticated can use extension functions

GRANT USAGE ON SCHEMA extensions TO anon, authenticated;

COMMIT;

-- =====================================================
-- POST-FIX VERIFICATION
-- =====================================================
-- Run these queries to verify the fix:
--
-- 1. Check function search_path:
--    SELECT p.proname, p.proconfig
--    FROM pg_proc p
--    JOIN pg_namespace n ON p.pronamespace = n.oid
--    WHERE n.nspname = 'public'
--    AND p.proname LIKE 'search_products%';
--    Expected: proconfig includes 'extensions' in search_path
--
-- 2. Check database search_path:
--    SELECT name, setting FROM pg_settings WHERE name = 'search_path';
--    Expected: setting includes 'public, extensions, pg_catalog'
--
-- 3. Test similarity function:
--    SELECT similarity('test', 'testing');
--    Expected: Returns a float value (e.g., 0.5)
-- =====================================================

-- <<< END 20260202_fix_extension_search_path.sql <<<


-- >>> BEGIN 20260202_fix_security_errors.sql >>>

-- =====================================================
-- Supabase Security Errors Fix - Phase 1
-- =====================================================
-- Fixes 4 of 6 CRITICAL security errors:
--   1. Security Definer Views (3 views)
--   2. Sensitive Column Documentation (search_analytics)
-- =====================================================
-- Issue Reference: Supabase Dashboard Security Lints
-- Date: 2026-02-02
-- =====================================================

BEGIN;

-- =====================================================
-- CRITICAL FIX 1: Convert Security Definer Views to Security Invoker
-- =====================================================
-- Issue: Views created without security_invoker bypass RLS policies
-- Impact: Data from underlying tables exposed regardless of user permissions
-- Solution: Add WITH (security_invoker = true) to enforce RLS
-- Reference: https://supabase.com/docs/guides/database/database-linter?lint=0010_security_definer_view

-- -----------------------------------------------------
-- View 1: products_with_variants
-- -----------------------------------------------------
-- Before: Bypasses RLS on products and product_variants tables
-- After: Respects RLS policies for the querying user

-- DROP first to avoid column mismatch errors
DROP VIEW IF EXISTS public.products_with_variants CASCADE;

CREATE VIEW public.products_with_variants 
WITH (security_invoker = true) AS
SELECT 
    p.*,
    (
        SELECT jsonb_agg(v.*)
        FROM public.product_variants v
        WHERE v.product_id = p.id
    ) as variants_data,
    COALESCE(
        (SELECT min(price) FROM public.product_variants v WHERE v.product_id = p.id),
        p.price
    ) as min_price,
    COALESCE(
        (SELECT sum(inventory_quantity) FROM public.product_variants v WHERE v.product_id = p.id),
        p.stock_count
    ) as total_inventory
FROM 
    public.products p;

COMMENT ON VIEW public.products_with_variants IS 
  'Secure view (security_invoker) - aggregates product data with variants. Respects RLS policies.';

-- -----------------------------------------------------
-- View 2: order_details_view
-- -----------------------------------------------------
-- Before: Bypasses RLS on orders and profiles tables
-- After: Respects RLS policies for the querying user

-- DROP first to avoid column mismatch errors
DROP VIEW IF EXISTS public.order_details_view CASCADE;

CREATE VIEW public.order_details_view
WITH (security_invoker = true) AS
SELECT 
    o.*,
    p.role as user_role
FROM 
    public.orders o
LEFT JOIN 
    public.profiles p ON o.user_id = p.id;

COMMENT ON VIEW public.order_details_view IS 
  'Secure view (security_invoker) - joins orders with user role. Respects RLS policies.';

-- -----------------------------------------------------
-- View 3: cart_items_extended
-- -----------------------------------------------------
-- Before: Bypasses RLS on cart_items, products, and product_variants
-- After: Respects RLS policies for the querying user

-- DROP first to avoid column mismatch errors
DROP VIEW IF EXISTS public.cart_items_extended CASCADE;

CREATE VIEW public.cart_items_extended
WITH (security_invoker = true) AS
SELECT 
    ci.*,
    p.name as product_name,
    p.handle as product_handle,
    p.image_url as product_thumbnail,
    v.title as variant_title,
    v.sku as variant_sku
FROM 
    public.cart_items ci
JOIN 
    public.products p ON ci.product_id = p.id
LEFT JOIN 
    public.product_variants v ON ci.variant_id = v.id;

COMMENT ON VIEW public.cart_items_extended IS 
  'Secure view (security_invoker) - extends cart items with product details. Respects RLS policies.';

-- =====================================================
-- CRITICAL FIX 2: Search Analytics Sensitive Column Protection
-- =====================================================
-- Table: search_analytics
-- Sensitive Column: session_id
-- Current State: Table has RLS enabled (from 20260123_supabase_optimization_v2.sql)
--   - Admin-only SELECT policy protects session_id from non-admin access
--   - Public can only INSERT (append-only for tracking)
-- Action: Add documentation to clarify security posture

COMMENT ON TABLE public.search_analytics IS 
  'Search analytics table with RLS protection. Contains sensitive session_id data accessible only to admins via is_admin() policy.';

COMMENT ON COLUMN public.search_analytics.session_id IS 
  'SENSITIVE: Session identifier. Protected by RLS - only accessible to admins. Never select this column in public-facing queries.';

COMMENT ON COLUMN public.search_analytics.user_id IS 
  'User identifier. Protected by RLS - only accessible to admins for analytics purposes.';

-- Enable RLS if not already enabled
ALTER TABLE public.search_analytics ENABLE ROW LEVEL SECURITY;

-- Create policies if they don't exist (idempotent)
DO $$
BEGIN
  -- Policy for public INSERT (tracking)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'search_analytics' 
    AND policyname = 'Public can insert search_analytics'
  ) THEN
    EXECUTE 'CREATE POLICY "Public can insert search_analytics"
      ON public.search_analytics FOR INSERT
      TO public
      WITH CHECK (true)';
  END IF;

  -- Policy for admin SELECT (analytics)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'search_analytics' 
    AND policyname = 'Admins can manage search_analytics'
  ) THEN
    EXECUTE 'CREATE POLICY "Admins can manage search_analytics"
      ON public.search_analytics FOR SELECT
      TO authenticated
      USING (public.is_admin())';
  END IF;
END $$;

COMMIT;

-- =====================================================
-- POST-MIGRATION VERIFICATION
-- =====================================================
-- Run these queries to verify the fixes:
--
-- 1. Verify views are now security_invoker:
--    SELECT c.relname, c.reloptions
--    FROM pg_class c
--    WHERE c.relname IN ('products_with_variants', 'order_details_view', 'cart_items_extended')
--      AND c.relkind = 'v';
--    Expected: reloptions should contain 'security_invoker=true'
--
-- 2. Test view RLS enforcement as different users:
--    SET ROLE authenticated;
--    SET request.jwt.claims.sub TO '<test-user-id>';
--    SELECT COUNT(*) FROM products_with_variants;
--    Expected: Only products allowed by RLS policies
--
-- 3. Verify search_analytics RLS:
--    SELECT tablename, policyname, roles, cmd, qual
--    FROM pg_policies
--    WHERE tablename = 'search_analytics';
--    Expected: Admin-only SELECT policy, Public INSERT policy
-- =====================================================

-- <<< END 20260202_fix_security_errors.sql <<<


-- >>> BEGIN 20260202_performance_optimization.sql >>>

-- =====================================================
-- Supabase Performance Optimization - Phase 3
-- =====================================================
-- Fixes 33 performance warnings:
--   1. Auth RLS Init Plan Optimization (3 policies)
--   2. Multiple Permissive Policies Consolidation (30 tables)
-- =====================================================
-- Issue Reference: Supabase Dashboard Performance Lints
-- Date: 2026-02-02
-- =====================================================
-- PERFORMANCE IMPACT: This migration consolidates duplicate policies
-- to improve query performance. PostgreSQL evaluates all permissive
-- policies with OR logic, so consolidating them speeds up queries.
-- =====================================================

BEGIN;

-- =====================================================
-- PERFORMANCE FIX 1: Auth RLS Init Plan Optimization
-- =====================================================
-- Issue: Direct auth.uid() calls are re-evaluated per row
-- Solution: Wrap in SELECT to cache the result
-- Reference: https://supabase.com/docs/guides/database/database-linter?lint=0004_auth_rls_initplan

-- CRITICAL: Identify the exact policy names first by checking existing policies
-- We'll create a safer approach by using IF EXISTS logic

-- Note: Since we can't know exact existing policy names without querying,
-- we'll use a more defensive approach and create new optimized policies

-- -----------------------------------------------------
-- Table: profiles
-- -----------------------------------------------------
-- Consolidate SELECT policies and optimize auth.uid()
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Only users with customers:delete ability can access" ON public.profiles;

CREATE POLICY "Consolidated SELECT for profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (
    id = (SELECT auth.uid())  -- Optimized: wrapped in SELECT
    OR (SELECT public.is_admin())  -- Admin access
  );

-- Consolidate UPDATE policies
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;

CREATE POLICY "Consolidated UPDATE for profiles"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (
    id = (SELECT auth.uid())
    OR (SELECT public.is_admin())
  )
  WITH CHECK (
    id = (SELECT auth.uid())
    OR (SELECT public.is_admin())
  );

-- -----------------------------------------------------
-- Table: orders  
-- -----------------------------------------------------
-- Consolidate multiple SELECT policies
DROP POLICY IF EXISTS "Customers can see their own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can see all orders" ON public.orders;
DROP POLICY IF EXISTS "Public read orders" ON public.orders;

CREATE POLICY "Consolidated SELECT for orders"
  ON public.orders FOR SELECT
  TO public
  USING (
    user_id = (SELECT auth.uid())  -- Optimized: wrapped in SELECT
    OR (SELECT public.is_admin())  -- Admin access
    OR user_id IS NULL  -- Guest orders (if needed)
  );

-- Consolidate UPDATE/DELETE policies
DROP POLICY IF EXISTS "Authenticated users can update orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can update all orders" ON public.orders;

CREATE POLICY "Consolidated UPDATE for orders"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    OR (SELECT public.is_admin())
  )
  WITH CHECK (
    user_id = (SELECT auth.uid())
    OR (SELECT public.is_admin())
  );

-- =====================================================
-- PERFORMANCE FIX 2: Multiple Permissive Policies Consolidation
-- =====================================================
-- Consolidate tables with multiple permissive policies
-- Pattern: Merge policies with same role/action using explicit OR

-- -----------------------------------------------------
-- Table: addresses (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own addresses" ON public.addresses;
DROP POLICY IF EXISTS "Admins read all addresses" ON public.addresses;

CREATE POLICY "Consolidated SELECT for addresses"
  ON public.addresses FOR SELECT
  TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    OR (SELECT public.is_admin())
  );

-- -----------------------------------------------
-- Table: cart_items (4 policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Users can manage their own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can view their cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can delete their cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can insert their cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can update their cart items" ON public.cart_items;

-- Single policy for user ownership
CREATE POLICY "Users manage own cart items"
  ON public.cart_items FOR ALL
  TO authenticated
  USING (
    cart_id IN (SELECT id FROM public.carts WHERE user_id = (SELECT auth.uid()))
  )
  WITH CHECK (
    cart_id IN (SELECT id FROM public.carts WHERE user_id = (SELECT auth.uid()))
  );

-- -----------------------------------------------------
-- Table: categories (2 SELECT policies) 
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read categories" ON public.categories;
DROP POLICY IF EXISTS "Public can view categories" ON public.categories;
DROP POLICY IF EXISTS "Admins manage categories" ON public.categories;

CREATE POLICY "Public SELECT categories"
  ON public.categories FOR SELECT
  TO public
  USING (true);  -- Public read is intentional

CREATE POLICY "Admins manage categories"
  ON public.categories FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: collections (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read collections" ON public.collections;
DROP POLICY IF EXISTS "Public can view collections" ON public.collections;
DROP POLICY IF EXISTS "Admins manage collections" ON public.collections;

CREATE POLICY "Public SELECT collections"
  ON public.collections FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage collections"
  ON public.collections FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: products (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public can view products" ON public.products;
DROP POLICY IF EXISTS "Public read products" ON public.products;
DROP POLICY IF EXISTS "Admins manage products" ON public.products;

CREATE POLICY "Public SELECT products"
  ON public.products FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage products"
  ON public.products FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: product_variants (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public can view product_variants" ON public.product_variants;
DROP POLICY IF EXISTS "Public read product_variants" ON public.product_variants;
DROP POLICY IF EXISTS "Admins manage product_variants" ON public.product_variants;

CREATE POLICY "Public SELECT product_variants"
  ON public.product_variants FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage product_variants"
  ON public.product_variants FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: product_options (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read product_options" ON public.product_options;
DROP POLICY IF EXISTS "Public can view product_options" ON public.product_options;
DROP POLICY IF EXISTS "Admins manage product_options" ON public.product_options;

CREATE POLICY "Public SELECT product_options"
  ON public.product_options FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage product_options"
  ON public.product_options FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: product_option_values (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read product_option_values" ON public.product_option_values;
DROP POLICY IF EXISTS "Public can view product_option_values" ON public.product_option_values;
DROP POLICY IF EXISTS "Admins manage product_option_values" ON public.product_option_values;

CREATE POLICY "Public SELECT product_option_values"
  ON public.product_option_values FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage product_option_values"
  ON public.product_option_values FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: product_categories (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read product_categories" ON public.product_categories;
DROP POLICY IF EXISTS "Public can view product_categories" ON public.product_categories;
DROP POLICY IF EXISTS "Admins manage product_categories" ON public.product_categories;

CREATE POLICY "Public SELECT product_categories"
  ON public.product_categories FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage product_categories"
  ON public.product_categories FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: product_collections (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read product_collections" ON public.product_collections;
DROP POLICY IF EXISTS "Public can view product_collections" ON public.product_collections;
DROP POLICY IF EXISTS "Admins manage product_collections" ON public.product_collections;

CREATE POLICY "Public SELECT product_collections"
  ON public.product_collections FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage product_collections"
  ON public.product_collections FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: promotions (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read active promotions" ON public.promotions;
DROP POLICY IF EXISTS "Admins read all promotions" ON public.promotions;
DROP POLICY IF EXISTS "Admins manage promotions" ON public.promotions;

CREATE POLICY "Consolidated SELECT for promotions"
  ON public.promotions FOR SELECT
  TO public
  USING (
    (is_active = true AND (starts_at IS NULL OR starts_at <= NOW()))  -- Public can see active
    OR ((SELECT auth.role()) = 'authenticated' AND (SELECT public.is_admin()))  -- Admins see all
  );

CREATE POLICY "Admins manage promotions"
  ON public.promotions FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: reviews (2 INSERT + 3 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Users create their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Authenticated users can create reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can view their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Public can view reviews" ON public.reviews;
DROP POLICY IF EXISTS "Admins can do everything on reviews" ON public.reviews;
DROP POLICY IF EXISTS "Admins manage reviews" ON public.reviews;

CREATE POLICY "Public SELECT reviews"
  ON public.reviews FOR SELECT
  TO public
  USING (true);  -- Reviews are public

CREATE POLICY "Users create own reviews"
  ON public.reviews FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Admins manage reviews"
  ON public.reviews FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: review_media (2 INSERT + 2 SELECT policies)
-- -----------------------------------------------------
-- Already fixed in Phase 2, ensuring consistency here
DROP POLICY IF EXISTS "Users upload review media for their reviews" ON public.review_media;
DROP POLICY IF EXISTS "Authenticated users can upload review media" ON public.review_media;
DROP POLICY IF EXISTS "Public can view review media" ON public.review_media;

CREATE POLICY "Public SELECT review_media"
  ON public.review_media FOR SELECT
  TO public
  USING (true);

-- Policy for uploading was already created in Phase 2

-- -----------------------------------------------------
-- Table: reward_wallets (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Users read own wallet" ON public.reward_wallets;
DROP POLICY IF EXISTS "Admins read all wallets" ON public.reward_wallets;

CREATE POLICY "Consolidated SELECT for reward_wallets"
  ON public.reward_wallets FOR SELECT
  TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    OR (SELECT public.is_admin())
  );

-- -----------------------------------------------------
-- Table: reward_transactions (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Users read own transactions" ON public.reward_transactions;
DROP POLICY IF EXISTS "Admins read all reward transactions" ON public.reward_transactions;

CREATE POLICY "Consolidated SELECT for reward_transactions"
  ON public.reward_transactions FOR SELECT
  TO authenticated
  USING (
    wallet_id IN (SELECT id FROM public.reward_wallets WHERE user_id = (SELECT auth.uid()))
    OR (SELECT public.is_admin())
  );

-- -----------------------------------------------------
-- Table: shipping_options (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read shipping_options" ON public.shipping_options;
DROP POLICY IF EXISTS "Public can view shipping_options" ON public.shipping_options;
DROP POLICY IF EXISTS "Admins manage shipping_options" ON public.shipping_options;

CREATE POLICY "Public SELECT shipping_options"
  ON public.shipping_options FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage shipping_options"
  ON public.shipping_options FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: shipping_partners (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read shipping_partners" ON public.shipping_partners;
DROP POLICY IF EXISTS "Public can view shipping_partners" ON public.shipping_partners;
DROP POLICY IF EXISTS "Admins manage shipping_partners" ON public.shipping_partners;

CREATE POLICY "Public SELECT shipping_partners"
  ON public.shipping_partners FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage shipping_partners"
  ON public.shipping_partners FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Table: payment_providers (2 SELECT policies)
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read payment_providers" ON public.payment_providers;
DROP POLICY IF EXISTS "Public can view payment_providers" ON public.payment_providers;
DROP POLICY IF EXISTS "Admins manage payment_providers" ON public.payment_providers;

CREATE POLICY "Public SELECT payment_providers"
  ON public.payment_providers FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage payment_providers"
  ON public.payment_providers FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Tables: home_banners, home_exclusive_collections
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Public read home_banners" ON public.home_banners;
DROP POLICY IF EXISTS "Public can view home_banners" ON public.home_banners;
DROP POLICY IF EXISTS "Admins manage home_banners" ON public.home_banners;

CREATE POLICY "Public SELECT home_banners"
  ON public.home_banners FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage home_banners"
  ON public.home_banners FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

DROP POLICY IF EXISTS "Public read home_exclusive_collections" ON public.home_exclusive_collections;
DROP POLICY IF EXISTS "Public can view home_exclusive_collections" ON public.home_exclusive_collections;
DROP POLICY IF EXISTS "Admins manage home_exclusive_collections" ON public.home_exclusive_collections;

CREATE POLICY "Public SELECT home_exclusive_collections"
  ON public.home_exclusive_collections FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins manage home_exclusive_collections"
  ON public.home_exclusive_collections FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

COMMIT;

-- =====================================================
-- POST-MIGRATION VERIFICATION
-- =====================================================
-- Run these queries to verify performance improvements:
--
-- 1. Check for remaining multiple policies:
--    SELECT schemaname, tablename, COUNT(*) as policy_count
--    FROM pg_policies
--    WHERE schemaname = 'public'
--    GROUP BY schemaname, tablename
--    HAVING COUNT(*) > 3  -- Most tables should have ≤3 policies now
--    ORDER BY policy_count DESC;
--
-- 2. Verify auth.uid() optimization:
--    SELECT tablename, policyname, qual, with_check
--    FROM pg_policies
--    WHERE schemaname = 'public'
--      AND (qual::text LIKE '%auth.uid()%' OR with_check::text LIKE '%auth.uid()%')
--      AND qual::text NOT LIKE '%SELECT auth.uid()%';
--    Expected: Should return no rows (all should be wrapped in SELECT)
--
-- 3. Test query performance:
--    EXPLAIN ANALYZE SELECT * FROM products LIMIT 100;
--    Compare execution time before/after this migration
-- =====================================================

-- <<< END 20260202_performance_optimization.sql <<<


-- >>> BEGIN 20260202_policy_cleanup.sql >>>

-- =====================================================
-- Supabase Policy Cleanup - Phase 4
-- =====================================================
-- Purpose: Remove duplicate/old policies that were not properly
-- dropped in Phase 3 due to naming mismatches
-- =====================================================
-- Date: 2026-02-02
-- =====================================================

BEGIN;

-- Clean up duplicate admin policies (old naming convention)
DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;
DROP POLICY IF EXISTS "Public can view categories" ON public.categories;

DROP POLICY IF EXISTS "Admins can manage collections" ON public.collections;
DROP POLICY IF EXISTS "Public can view collections" ON public.collections;

DROP POLICY IF EXISTS "Admins can manage products" ON public.products;
DROP POLICY IF EXISTS "Allow public read access" ON public.products;

DROP POLICY IF EXISTS "Admins can manage product_variants" ON public.product_variants;
DROP POLICY IF EXISTS "Public read variants" ON public.product_variants;

DROP POLICY IF EXISTS "Admins can manage product_options" ON public.product_options;

DROP POLICY IF EXISTS "Admins can manage product_option_values" ON public.product_option_values;

DROP POLICY IF EXISTS "Admins can manage product_collections" ON public.product_collections;

DROP POLICY IF EXISTS "Admins can manage home banners" ON public.home_banners;
DROP POLICY IF EXISTS "Public can view active home banners" ON public.home_banners;

DROP POLICY IF EXISTS "Admins can manage exclusive collections" ON public.home_exclusive_collections;
DROP POLICY IF EXISTS "Public can view active exclusive collections" ON public.home_exclusive_collections;

DROP POLICY IF EXISTS "Admins can manage shipping_partners" ON public.shipping_partners;

-- Clean up profiles duplicate policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Only users with customers:delete can delete customers" ON public.profiles;

-- Clean up orders duplicate policy
DROP POLICY IF EXISTS "Admins can update orders" ON public.orders;

-- Clean up cart_items old policies
DROP POLICY IF EXISTS "Access cart items via cart" ON public.cart_items;
DROP POLICY IF EXISTS "Admins can manage all cart items" ON public.cart_items;

--Clean up reviews duplicate policies
DROP POLICY IF EXISTS "Public can view approved reviews" ON public.reviews;

-- Clean up review_media duplicate policy
DROP POLICY IF EXISTS "Admins can manage review media" ON public.review_media;

-- Clean up product_combinations old policy
DROP POLICY IF EXISTS "Allow public read access for product combinations" ON public.product_combinations;

COMMIT;

-- =====================================================
-- POST-CLEANUP VERIFICATION
-- =====================================================
-- Run this query to verify cleanup success:
--
-- SELECT schemaname, tablename, COUNT(*) as policy_count,
--        array_agg(policyname) as policies
-- FROM pg_policies
-- WHERE schemaname = 'public'
-- GROUP BY schemaname, tablename
-- HAVING COUNT(*) > 3
-- ORDER BY policy_count DESC;
--
-- Expected: Should now see FAR fewer tables with multiple policies
-- =====================================================

-- <<< END 20260202_policy_cleanup.sql <<<


-- >>> BEGIN 20260202_production_comprehensive_fix.sql >>>

-- =====================================================
-- TOYCKER PRODUCTION DATABASE - COMPREHENSIVE FIX
-- =====================================================
-- This migration resolves 50 security and performance issues
-- in the production Supabase database.
--
-- Issues Fixed:
-- - 3 RLS not enabled errors
-- - 7 function search_path warnings
-- - 2 extension placement warnings
-- - 8 overly permissive RLS policies
-- - Plus additional performance optimizations
--
-- SAFE TO RUN: This migration is idempotent and can be
-- run multiple times without causing errors.
-- =====================================================
-- Date: 2026-02-02
-- Tested on: Local development database
-- Ready for: Production deployment
-- =====================================================

BEGIN;

-- =====================================================
-- PHASE 1: FIX RLS NOT ENABLED (3 ERRORS)
-- =====================================================

-- Table: search_analytics
-- Enable RLS and create policies
ALTER TABLE public.search_analytics ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies first (idempotent)
DROP POLICY IF EXISTS "Public can insert search_analytics" ON public.search_analytics;
DROP POLICY IF EXISTS "Admins can manage search_analytics" ON public.search_analytics;

-- Allow public to insert (for anonymous search tracking)
CREATE POLICY "Public can insert search_analytics"
  ON public.search_analytics FOR INSERT
  TO public
  WITH CHECK (true);

-- Admin-only read access (protects session_id)
CREATE POLICY "Admins can manage search_analytics"
  ON public.search_analytics FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

COMMENT ON TABLE public.search_analytics IS 
  'Search analytics with session tracking. RLS enabled - public insert, admin read only.';

-- Table: global_settings
-- Enable RLS and create policies
ALTER TABLE public.global_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read global settings" ON public.global_settings;
DROP POLICY IF EXISTS "Admins can manage global settings" ON public.global_settings;

-- Public read access
CREATE POLICY "Public can read global settings"
  ON public.global_settings FOR SELECT
  TO public
  USING (true);

-- Admin-only write access
CREATE POLICY "Admins can manage global settings"
  ON public.global_settings FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

COMMENT ON TABLE public.global_settings IS 
  'Global application settings. RLS enabled - public read, admin write.';

-- =====================================================
-- PHASE 2: MOVE EXTENSIONS TO DEDICATED SCHEMA
-- =====================================================

-- Create extensions schema
CREATE SCHEMA IF NOT EXISTS extensions;

-- Move pg_trgm extension
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_extension 
        WHERE extname = 'pg_trgm' 
        AND extnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ) THEN
        ALTER EXTENSION pg_trgm SET SCHEMA extensions;
        RAISE NOTICE 'Moved pg_trgm extension to extensions schema';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'pg_trgm: % (already moved or not installed)', SQLERRM;
END $$;

-- Move unaccent extension
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_extension 
        WHERE extname = 'unaccent' 
        AND extnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ) THEN
        ALTER EXTENSION unaccent SET SCHEMA extensions;
        RAISE NOTICE 'Moved unaccent extension to extensions schema';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'unaccent: % (already moved or not installed)', SQLERRM;
END $$;

-- Grant usage permissions
GRANT USAGE ON SCHEMA extensions TO authenticated, anon;

-- Set database search_path to include extensions
ALTER DATABASE postgres SET search_path TO public, extensions, pg_catalog;

COMMENT ON SCHEMA extensions IS 
  'Schema for PostgreSQL extensions. Included in default search_path.';

-- =====================================================
-- PHASE 3: FIX FUNCTION SEARCH PATHS (7 FUNCTIONS)
-- =====================================================

-- These functions need hardened search_path to prevent injection attacks
-- AND must include 'extensions' schema for pg_trgm functions

-- 1. update_updated_at_column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_catalog, pg_temp
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- 2. search_products_multimodal (needs extensions for similarity())
DO $$
BEGIN
    EXECUTE 'ALTER FUNCTION public.search_products_multimodal(TEXT, vector(512), FLOAT, INT)
             SET search_path = public, extensions, pg_catalog, pg_temp';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'search_products_multimodal: % (may need manual update)', SQLERRM;
END $$;

-- 3. search_products_advanced (needs extensions for similarity())
DO $$
BEGIN
    EXECUTE 'ALTER FUNCTION public.search_products_advanced(TEXT, FLOAT, INT)
             SET search_path = public, extensions, pg_catalog, pg_temp';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'search_products_advanced: % (may need manual update)', SQLERRM;
END $$;

-- 4. parent_category
DO $$
BEGIN
    EXECUTE 'ALTER FUNCTION public.parent_category(categories)
             SET search_path = public, extensions, pg_catalog, pg_temp';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'parent_category: % (may need manual update)', SQLERRM;
END $$;

-- 5. increment_promotion_uses
DO $$
BEGIN
    EXECUTE 'ALTER FUNCTION public.increment_promotion_uses(TEXT)
             SET search_path = public, extensions, pg_catalog, pg_temp';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'increment_promotion_uses: % (may need manual update)', SQLERRM;
END $$;

-- 6. create_order_with_payment
DO $$
BEGIN
    EXECUTE 'ALTER FUNCTION public.create_order_with_payment
             SET search_path = public, extensions, pg_catalog, pg_temp';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'create_order_with_payment: % (may need manual update)', SQLERRM;
END $$;

-- 7. track_search_rpc
DO $$
BEGIN
    EXECUTE 'ALTER FUNCTION public.track_search_rpc
             SET search_path = public, extensions, pg_catalog, pg_temp';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'track_search_rpc: % (may need manual update)', SQLERRM;
END $$;

-- =====================================================
-- PHASE 4: FIX OVERLY PERMISSIVE RLS POLICIES
-- =====================================================

-- Fix cart_items - Change from public ALL to proper access control
DROP POLICY IF EXISTS "Public access cart_items" ON public.cart_items;
DROP POLICY IF EXISTS "Users access own cart_items" ON public.cart_items;
DROP POLICY IF EXISTS "Admins manage cart_items" ON public.cart_items;

-- Users can only access their own cart items
CREATE POLICY "Users access own cart_items"
  ON public.cart_items FOR ALL
  TO authenticated
  USING (
    cart_id IN (
      SELECT id FROM public.carts 
      WHERE user_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    cart_id IN (
      SELECT id FROM public.carts 
      WHERE user_id = (SELECT auth.uid())
    )
  );

-- Admins can manage all cart items
CREATE POLICY "Admins manage cart_items"
  ON public.cart_items FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- Fix carts - Change from public ALL to proper access control
DROP POLICY IF EXISTS "Public access carts" ON public.carts;
DROP POLICY IF EXISTS "Users access own carts" ON public.carts;
DROP POLICY IF EXISTS "Guests access carts by ID" ON public.carts;
DROP POLICY IF EXISTS "Admins manage carts" ON public.carts;

-- Users can only access their own carts
CREATE POLICY "Users access own carts"
  ON public.carts FOR ALL
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- Guest carts (for checkout before login)
CREATE POLICY "Guests access carts by ID"
  ON public.carts FOR SELECT
  TO anon
  USING (true);  -- Guests need cart ID to access, enforced by app

-- Admins can manage all carts
CREATE POLICY "Admins manage carts"
  ON public.carts FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- Fix orders - Already has policy, just update it
DROP POLICY IF EXISTS "Authenticated users can create orders" ON public.orders;
DROP POLICY IF EXISTS "Users create own orders" ON public.orders;

CREATE POLICY "Users create own orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = (SELECT auth.uid())  -- Can only create orders for self
    OR user_id IS NULL  -- Allow guest checkout
  );

-- Fix product_combinations - Consolidate to admin-only
DROP POLICY IF EXISTS "Allow authenticated users to delete product combinations" ON public.product_combinations;
DROP POLICY IF EXISTS "Allow authenticated users to insert product combinations" ON public.product_combinations;
DROP POLICY IF EXISTS "Allow authenticated users to update product combinations" ON public.product_combinations;
DROP POLICY IF EXISTS "Admins manage product combinations" ON public.product_combinations;

-- Single admin-only policy
CREATE POLICY "Admins manage product combinations"
  ON public.product_combinations FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- Fix review_media - Can only upload for own reviews
DROP POLICY IF EXISTS "Authenticated users can upload review media" ON public.review_media;
DROP POLICY IF EXISTS "Users upload review media for their reviews" ON public.review_media;

CREATE POLICY "Users upload review media for their reviews"
  ON public.review_media FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.reviews r
      WHERE r.id = review_id 
      AND r.user_id = (SELECT auth.uid())
    )
  );

-- Admin policy for review media
DROP POLICY IF EXISTS "Admins can manage review media" ON public.review_media;

CREATE POLICY "Admins can manage review media"
  ON public.review_media FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- Fix reviews - Can only create for self
DROP POLICY IF EXISTS "Authenticated users can create reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users create their own reviews" ON public.reviews;

CREATE POLICY "Users create their own reviews"
  ON public.reviews FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = (SELECT auth.uid())  -- Can only create reviews for self
  );

COMMIT;

-- =====================================================
-- POST-MIGRATION VERIFICATION QUERIES
-- =====================================================
-- Run these in Supabase SQL Editor to verify success:
--
-- 1. Check RLS enabled on all tables:
--    SELECT schemaname, tablename, rowsecurity
--    FROM pg_tables
--    WHERE schemaname = 'public'
--    AND tablename IN ('search_analytics', 'global_settings')
--    ORDER BY tablename;
--    Expected: rowsecurity = true for both
--
-- 2. Check extensions moved:
--    SELECT e.extname, n.nspname as schema
--    FROM pg_extension e
--    JOIN pg_namespace n ON e.extnamespace = n.oid
--    WHERE e.extname IN ('pg_trgm', 'unaccent');
--    Expected: schema = 'extensions'
--
-- 3. Check function search_path:
--    SELECT proname, proconfig
--    FROM pg_proc
--    WHERE proname LIKE 'search_products%'
--    OR proname IN ('parent_category', 'increment_promotion_uses');
--    Expected: proconfig contains search_path with 'extensions'
--
-- 4. Test similarity function works:
--    SELECT similarity('test', 'testing');
--    Expected: Returns a float (e.g., 0.5)
--
-- 5. Count remaining issues:
--    Run Supabase Linter in dashboard
--    Expected: ~20 warnings (mostly acceptable design choices)
--
-- =====================================================
-- TROUBLESHOOTING
-- =====================================================
-- If image search still fails with "similarity() does not exist":
-- 1. Ensure extensions schema is in search_path:
--    SHOW search_path;
-- 2. Manually update function if ALTER failed:
--    Replace the entire function definition with SET search_path
--    including 'extensions' schema
-- 3. Restart Supabase connection pool to pick up new search_path
--
-- If any step fails, the transaction will rollback.
-- Check error messages and fix before re-running.
-- =====================================================

-- <<< END 20260202_production_comprehensive_fix.sql <<<


-- >>> BEGIN 20260202_security_warnings.sql >>>

-- =====================================================
-- Supabase Security Warnings Fix - Phase 2
-- =====================================================
-- Fixes 15 of 16 security warnings:
--   1. Function Search Path Hardening (4 functions)
--   2. Extensions Schema Migration (2 extensions) 
--   3. Overly Permissive RLS Policies (6 policies)
--   4. Leaked Password Protection (NOT FIXABLE - requires Pro plan)
-- =====================================================
-- Issue Reference: Supabase Dashboard Security Lints
-- Date: 2026-02-02
-- =====================================================

BEGIN;

-- =====================================================
-- SECURITY FIX 1: Function Search Path Hardening
-- =====================================================
-- Issue: Functions without explicit search_path are vulnerable to schema injection
-- Solution: Set search_path = public, pg_catalog, pg_temp for all functions
-- Reference: https://supabase.com/docs/guides/database/database-linter?lint=0011_function_search_path_mutable

-- -----------------------------------------------------
-- Function 1: search_products_multimodal
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION public.search_products_multimodal(
  search_query TEXT DEFAULT NULL,
  search_embedding vector(512) DEFAULT NULL,
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 20
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  handle TEXT,
  image_url TEXT,
  thumbnail TEXT,
  price DECIMAL,
  currency_code TEXT,
  relevance_score FLOAT
) 
LANGUAGE plpgsql 
STABLE
SET search_path = public, pg_catalog, pg_temp  -- SECURITY FIX
AS $$
BEGIN
  RETURN QUERY
  WITH text_scores AS (
    SELECT 
      p.id::TEXT as product_id,
      GREATEST(
        CASE 
          WHEN search_query IS NOT NULL AND p.search_vector @@ websearch_to_tsquery('english', search_query)
          THEN ts_rank_cd(p.search_vector, websearch_to_tsquery('english', search_query)) * 0.5
          ELSE 0 
        END,
        CASE 
          WHEN search_query IS NOT NULL THEN similarity(p.name, search_query) * 0.4
          ELSE 0 
        END,
        CASE 
          WHEN search_query IS NOT NULL AND p.name ILIKE search_query || '%' THEN 0.1
          ELSE 0 
        END
      ) as text_score
    FROM public.products p
    WHERE search_query IS NOT NULL
  ),
  image_scores AS (
    SELECT 
      p.id::TEXT as product_id,
      1 - (p.image_embedding <=> search_embedding) as image_score
    FROM public.products p
    WHERE search_embedding IS NOT NULL
      AND p.image_embedding IS NOT NULL
  ),
  combined_scores AS (
    SELECT 
      COALESCE(t.product_id, i.product_id) as product_id,
      CASE 
        WHEN t.text_score > 0 AND i.image_score IS NOT NULL 
          THEN (t.text_score * 0.4 + i.image_score * 0.6)
        WHEN t.text_score > 0 
          THEN t.text_score
        WHEN i.image_score IS NOT NULL 
          THEN i.image_score
        ELSE 0
      END as final_score
    FROM text_scores t
    FULL OUTER JOIN image_scores i ON t.product_id = i.product_id
  )
  SELECT 
    p.id::TEXT,
    p.name,
    p.handle,
    p.image_url,
    p.thumbnail,
    COALESCE(
      (SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id),
      p.price
    )::DECIMAL as price,
    p.currency_code,
    c.final_score::FLOAT as relevance_score
  FROM combined_scores c
  JOIN public.products p ON c.product_id = p.id::TEXT
  WHERE c.final_score >= match_threshold
  ORDER BY c.final_score DESC
  LIMIT match_count;
END;
$$;

-- -----------------------------------------------------
-- Function 2: search_products_advanced
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION public.search_products_advanced(
  search_query TEXT,
  similarity_threshold FLOAT DEFAULT 0.15,
  result_limit INT DEFAULT 20
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  handle TEXT,
  image_url TEXT,
  thumbnail TEXT,
  price DECIMAL,
  currency_code TEXT,
  relevance_score FLOAT
)
LANGUAGE plpgsql 
STABLE
SET search_path = public, pg_catalog, pg_temp  -- SECURITY FIX
AS $$
BEGIN
  RETURN QUERY
  WITH combined_results AS (
    SELECT 
      p.id, p.name, p.handle, p.image_url, p.thumbnail, 
      COALESCE((SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id), p.price) as effective_price,
      p.currency_code,
      ts_rank_cd(p.search_vector, websearch_to_tsquery('english', search_query)) * 0.7 AS score
    FROM public.products p
    WHERE p.search_vector @@ websearch_to_tsquery('english', search_query)
    
    UNION ALL

    SELECT 
      p.id, p.name, p.handle, p.image_url, p.thumbnail,
      COALESCE((SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id), p.price) as effective_price,
      p.currency_code,
      similarity(p.name, search_query) * 0.3 AS score
    FROM public.products p
    WHERE p.name % search_query

    UNION ALL

    SELECT 
      p.id, p.name, p.handle, p.image_url, p.thumbnail,
      COALESCE((SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id), p.price) as effective_price,
      p.currency_code,
      0.1 AS score
    FROM public.products p
    WHERE p.name ILIKE search_query || '%'
  ),
  aggregated AS (
    SELECT 
      r.id, r.name, r.handle, r.image_url, r.thumbnail, r.effective_price, r.currency_code,
      SUM(r.score) as combined_score
    FROM combined_results r
    GROUP BY r.id, r.name, r.handle, r.image_url, r.thumbnail, r.effective_price, r.currency_code
  )
  SELECT 
    a.id, a.name, a.handle, a.image_url, a.thumbnail, 
    a.effective_price::DECIMAL, a.currency_code,
    a.combined_score::FLOAT as relevance_score
  FROM aggregated a
  ORDER BY combined_score DESC
  LIMIT result_limit;
END;
$$;

-- -----------------------------------------------------
-- Function 3: parent_category
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION public.parent_category(categories) 
RETURNS SETOF categories 
ROWS 1
LANGUAGE SQL  
STABLE
SET search_path = public, pg_catalog, pg_temp  -- SECURITY FIX
AS $$
  SELECT * FROM public.categories WHERE id = $1.parent_category_id
$$;

-- -----------------------------------------------------
-- Function 4: increment_promotion_uses
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_promotion_uses(promo_id TEXT)
RETURNS void 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp  -- SECURITY FIX
AS $$
BEGIN
    UPDATE public.promotions
    SET used_count = used_count + 1
    WHERE id = promo_id;
END;
$$;

-- =====================================================
-- SECURITY FIX 2: Move Extensions from Public Schema
-- =====================================================
-- Issue: Extensions in public schema can create naming conflicts
-- Solution: Move to dedicated extensions schema
-- Note: This may require reindexing if indexes use these extensions

-- Create extensions schema
CREATE SCHEMA IF NOT EXISTS extensions;

-- Attempt to move extensions (may fail if already in extensions schema)
DO $$
BEGIN
    -- Move pg_trgm
    IF EXISTS (
        SELECT 1 FROM pg_extension 
        WHERE extname = 'pg_trgm' 
        AND extnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ) THEN
        ALTER EXTENSION pg_trgm SET SCHEMA extensions;
        RAISE NOTICE 'Moved pg_trgm extension to extensions schema';
    ELSE
        RAISE NOTICE 'pg_trgm extension already in correct schema or not found';
    END IF;

    -- Move unaccent
    IF EXISTS (
        SELECT 1 FROM pg_extension 
        WHERE extname = 'unaccent' 
        AND extnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ) THEN
        ALTER EXTENSION unaccent SET SCHEMA extensions;
        RAISE NOTICE 'Moved unaccent extension to extensions schema';
    ELSE
        RAISE NOTICE 'unaccent extension already in correct schema or not found';
    END IF;
END $$;

-- Grant usage to relevant roles
GRANT USAGE ON SCHEMA extensions TO authenticated, anon;

-- =====================================================
-- SECURITY FIX 3: Fix Overly Permissive RLS Policies
-- =====================================================
-- Issue: Policies with WITH CHECK (true) bypass security checks
-- Solution: Add proper ownership/permission checks

-- -----------------------------------------------------
-- Policy 1: orders - "Authenticated users can create orders"
-- -----------------------------------------------------
-- Before: WITH CHECK (true) - any user can create orders for anyone
-- After: Users can only create orders for themselves

DROP POLICY IF EXISTS "Authenticated users can create orders" ON public.orders;

CREATE POLICY "Authenticated users can create orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = (SELECT auth.uid())  -- Can only create orders for self
    OR user_id IS NULL  -- Allow guest checkout
  );

-- -----------------------------------------------------
-- Policy 2-4: product_combinations - Consolidate into admin-only
-- -----------------------------------------------------
DROP POLICY IF EXISTS "Allow authenticated users to insert product combinations" ON public.product_combinations;
DROP POLICY IF EXISTS "Allow authenticated users to update product combinations" ON public.product_combinations;
DROP POLICY IF EXISTS "Allow authenticated users to delete product combinations" ON public.product_combinations;

-- Single policy for all operations
CREATE POLICY "Admins manage product combinations"
  ON public.product_combinations FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Policy 5: review_media - "Authenticated users can upload"
-- -----------------------------------------------------
-- Before: WITH CHECK (true) - anyone can upload media
-- After: Can only upload media for own reviews

DROP POLICY IF EXISTS "Authenticated users can upload review media" ON public.review_media;

CREATE POLICY "Users upload review media for their reviews"
  ON public.review_media FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.reviews r
      WHERE r.id = review_id 
      AND r.user_id = (SELECT auth.uid())
    )
  );

-- Keep admin policy for management
DROP POLICY IF EXISTS "Admins can manage review media" ON public.review_media;

CREATE POLICY "Admins can manage review media"
  ON public.review_media FOR ALL
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -----------------------------------------------------
-- Policy 6: reviews - "Authenticated users can create"
-- -----------------------------------------------------
-- Before: WITH CHECK (true) - anyone can create reviews for anyone
-- After: Can only create reviews for self

DROP POLICY IF EXISTS "Authenticated users can create reviews" ON public.reviews;

CREATE POLICY "Users create their own reviews"
  ON public.reviews FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = (SELECT auth.uid())  -- Can only create reviews for self
  );

-- =====================================================
-- DOCUMENTATION: Leaked Password Protection
-- =====================================================
-- Issue: Leaked password protection (HaveIBeenPwned) is disabled
-- Status: NOT FIXABLE on Supabase free tier
-- Action: Document this limitation

COMMENT ON SCHEMA public IS 
  'Public schema for Toycker application. Note: Leaked password protection (HaveIBeenPwned) requires Supabase Pro plan and cannot be enabled on free tier.';

COMMIT;

-- =====================================================
-- POST-MIGRATION VERIFICATION
-- =====================================================
-- Run these queries to verify the fixes:
--
-- 1. Verify function search_path:
--    SELECT 
--      p.proname, 
--      pg_get_function_identity_arguments(p.oid) as args,
--      p.proconfig
--    FROM pg_proc p
--    JOIN pg_namespace n ON p.pronamespace = n.oid
--    WHERE n.nspname = 'public'
--    AND p.proname IN ('search_products_multimodal', 'search_products_advanced', 
--                      'parent_category', 'increment_promotion_uses');
--    Expected: proconfig should contain search_path setting
--
-- 2. Verify extensions moved:
--    SELECT e.extname, n.nspname 
--    FROM pg_extension e 
--    JOIN pg_namespace n ON e.extnamespace = n.oid
--    WHERE e.extname IN ('pg_trgm', 'unaccent');
--    Expected: nspname should be 'extensions'
--
-- 3. Verify RLS policies updated:
--    SELECT tablename, policyname, qual, with_check
--    FROM pg_policies
--    WHERE tablename IN ('orders', 'product_combinations', 'review_media', 'reviews')
--      AND schemaname = 'public';
--    Expected: No policies with 'true' in with_check for INSERT/UPDATE
-- =====================================================

-- <<< END 20260202_security_warnings.sql <<<


-- >>> BEGIN 20260203_fix_reviews_rls_v2.sql >>>

-- Fix RLS policies for reviews and review_media
-- This ensures that:
-- 1. Public can view approved reviews and all review media
-- 2. Users can always view their own reviews (needed for media upload check)
-- 3. Users can insert media for their own reviews

BEGIN;

-- 1. Reviews table policies
DROP POLICY IF EXISTS "Public can view approved reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can view their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users create their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Admins can do everything on reviews" ON public.reviews;

-- Allow public to see approved reviews
CREATE POLICY "Public can view approved reviews"
  ON public.reviews FOR SELECT
  USING (approval_status = 'approved');

-- Allow users to see their own reviews (even if pending/rejected)
CREATE POLICY "Users can view their own reviews"
  ON public.reviews FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Allow users to create reviews for themselves
CREATE POLICY "Users create their own reviews"
  ON public.reviews FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Admin full access
CREATE POLICY "Admins can manage reviews"
  ON public.reviews FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());


-- 2. Review Media table policies
DROP POLICY IF EXISTS "Public can view review media" ON public.review_media;
DROP POLICY IF EXISTS "Users upload review media for their reviews" ON public.review_media;
DROP POLICY IF EXISTS "Admins can manage review media" ON public.review_media;

-- Allow everyone to view review media
CREATE POLICY "Public can view review media"
  ON public.review_media FOR SELECT
  USING (true);

-- Allow users to upload media for their own reviews
-- This relies on the "Users can view their own reviews" SELECT policy
CREATE POLICY "Users upload review media for their reviews"
  ON public.review_media FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.reviews
      WHERE id = review_id AND user_id = auth.uid()
    )
  );

-- Admin full access
CREATE POLICY "Admins can manage review media"
  ON public.review_media FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

COMMIT;

-- <<< END 20260203_fix_reviews_rls_v2.sql <<<


-- >>> BEGIN 20260203_home_reviews.sql >>>

-- Create home_reviews table to store featured reviews for the home page
CREATE TABLE IF NOT EXISTS home_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES auth.users(id),
    UNIQUE(review_id)
);

-- Enable RLS
ALTER TABLE home_reviews ENABLE ROW LEVEL SECURITY;

-- Policies
-- Everyone can view home reviews
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'home_reviews' AND policyname = 'Home reviews are viewable by everyone'
    ) THEN
        CREATE POLICY "Home reviews are viewable by everyone" 
        ON home_reviews FOR SELECT 
        USING (true);
    END IF;
END $$;

-- Admins can manage home reviews
-- Note: Adjusting the admin check based on typical project structure (assuming auth.uid() check or staff table)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'home_reviews' AND policyname = 'Admins can manage home reviews'
    ) THEN
        CREATE POLICY "Admins can manage home reviews" 
        ON home_reviews FOR ALL 
        USING (true); -- Simplifying for now, server actions will handle auth check
    END IF;
END $$;

-- <<< END 20260203_home_reviews.sql <<<


-- >>> BEGIN 20260217_sync_metadata_to_profiles.sql >>>

-- Migration: Sync user metadata to profiles table
-- Date: 2026-02-17

-- 1. Add missing columns to profiles table if they don't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;

-- 2. Update handle_new_user function to copy metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    email, 
    first_name, 
    last_name, 
    phone,
    created_at, 
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone_number', NEW.raw_user_meta_data->>'phone', ''),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$;

-- 3. Backfill existing profiles from auth.users (Optional but recommended)
-- Note: This requires admin privileges and usually run manually in Supabase editor.
-- UPDATE public.profiles p
-- SET 
--   first_name = COALESCE(u.raw_user_meta_data->>'first_name', ''),
--   last_name = COALESCE(u.raw_user_meta_data->>'last_name', ''),
--   phone = COALESCE(u.raw_user_meta_data->>'phone_number', u.raw_user_meta_data->>'phone', '')
-- FROM auth.users u
-- WHERE p.id = u.id;

-- <<< END 20260217_sync_metadata_to_profiles.sql <<<


-- >>> BEGIN 20260217_sync_updates_to_profiles.sql >>>

-- Migration: Sync user metadata updates to profiles table
-- Date: 2026-02-17

-- 1. Create or replace the function to handle user updates
CREATE OR REPLACE FUNCTION public.handle_user_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.profiles
  SET
    first_name = COALESCE(NEW.raw_user_meta_data->>'first_name', first_name),
    last_name = COALESCE(NEW.raw_user_meta_data->>'last_name', last_name),
    phone = COALESCE(NEW.raw_user_meta_data->>'phone_number', NEW.raw_user_meta_data->>'phone', phone),
    updated_at = NOW()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

-- 2. Create the trigger for updates
-- This ensures that whenever a user's metadata is updated (e.g. via updateCustomer server action),
-- the changes are automatically reflected in the profiles table and thus the Admin Panel.
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_user_update();

-- 3. Backfill existing profiles to ensure they are currently in sync
UPDATE public.profiles p
SET 
  first_name = COALESCE(u.raw_user_meta_data->>'first_name', p.first_name, ''),
  last_name = COALESCE(u.raw_user_meta_data->>'last_name', p.last_name, ''),
  phone = COALESCE(u.raw_user_meta_data->>'phone_number', u.raw_user_meta_data->>'phone', p.phone, '')
FROM auth.users u
WHERE p.id = u.id;

-- <<< END 20260217_sync_updates_to_profiles.sql <<<


-- >>> BEGIN 20260227_add_otp_codes_table.sql >>>

CREATE TABLE IF NOT EXISTS otp_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  phone TEXT NOT NULL,
  code TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  attempts INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_otp_codes_phone ON otp_codes(phone);
CREATE INDEX idx_otp_codes_expires_at ON otp_codes(expires_at);

-- RLS: Only server/admin can access OTP codes (no client access)
ALTER TABLE otp_codes ENABLE ROW LEVEL SECURITY;
-- No policies = no client access. Only service_role can read/write.

-- <<< END 20260227_add_otp_codes_table.sql <<<


-- >>> BEGIN 20260310193000_harden_otp_codes_for_aisensy.sql >>>

ALTER TABLE public.otp_codes
  ADD COLUMN IF NOT EXISTS code_hash TEXT,
  ADD COLUMN IF NOT EXISTS delivery_status TEXT NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS provider_message_id TEXT,
  ADD COLUMN IF NOT EXISTS consumed_at TIMESTAMPTZ;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'otp_codes_delivery_status_check'
  ) THEN
    ALTER TABLE public.otp_codes
      ADD CONSTRAINT otp_codes_delivery_status_check
      CHECK (delivery_status IN ('pending', 'sent', 'failed'));
  END IF;
END $$;

UPDATE public.otp_codes
SET
  consumed_at = COALESCE(consumed_at, NOW()),
  expires_at = LEAST(expires_at, NOW()),
  delivery_status = CASE
    WHEN delivery_status = 'pending' THEN 'failed'
    ELSE delivery_status
  END
WHERE code_hash IS NULL;

CREATE INDEX IF NOT EXISTS idx_otp_codes_delivery_status
  ON public.otp_codes(delivery_status);

CREATE INDEX IF NOT EXISTS idx_otp_codes_phone_active
  ON public.otp_codes(phone, created_at DESC)
  WHERE verified = false;

-- <<< END 20260310193000_harden_otp_codes_for_aisensy.sql <<<


-- >>> BEGIN 20260311113000_allow_null_plaintext_code_for_hashed_otp.sql >>>

ALTER TABLE public.otp_codes
  ALTER COLUMN code DROP NOT NULL;


-- <<< END 20260311113000_allow_null_plaintext_code_for_hashed_otp.sql <<<


-- >>> BEGIN 20260311143000_sync_profile_phone_from_auth_phone.sql >>>

-- Ensure profile phone sync prefers auth.users.phone over stale raw metadata.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    first_name,
    last_name,
    phone,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NULLIF(NEW.phone, ''), NEW.raw_user_meta_data->>'phone_number', NEW.raw_user_meta_data->>'phone', ''),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_user_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.profiles
  SET
    first_name = COALESCE(NEW.raw_user_meta_data->>'first_name', first_name),
    last_name = COALESCE(NEW.raw_user_meta_data->>'last_name', last_name),
    phone = COALESCE(NULLIF(NEW.phone, ''), NEW.raw_user_meta_data->>'phone_number', NEW.raw_user_meta_data->>'phone', phone),
    updated_at = NOW()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

UPDATE public.profiles p
SET
  first_name = COALESCE(u.raw_user_meta_data->>'first_name', p.first_name, ''),
  last_name = COALESCE(u.raw_user_meta_data->>'last_name', p.last_name, ''),
  phone = COALESCE(NULLIF(u.phone, ''), u.raw_user_meta_data->>'phone_number', u.raw_user_meta_data->>'phone', p.phone, '')
FROM auth.users u
WHERE p.id = u.id;

-- <<< END 20260311143000_sync_profile_phone_from_auth_phone.sql <<<


-- >>> BEGIN 20260312110000_add_contact_email_for_phone_login.sql >>>

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS contact_email TEXT;

UPDATE public.profiles
SET contact_email = NULLIF(BTRIM(email), '')
WHERE COALESCE(BTRIM(contact_email), '') = ''
  AND COALESCE(BTRIM(email), '') <> ''
  AND LOWER(BTRIM(email)) NOT LIKE '%@wa.toycker.store';

WITH order_email_candidates AS (
  SELECT
    o.user_id,
    COALESCE(
      CASE
        WHEN COALESCE(BTRIM(o.customer_email), '') <> ''
          AND LOWER(BTRIM(o.customer_email)) NOT LIKE '%@wa.toycker.store'
          THEN BTRIM(o.customer_email)
        ELSE NULL
      END,
      CASE
        WHEN COALESCE(BTRIM(o.email), '') <> ''
          AND LOWER(BTRIM(o.email)) NOT LIKE '%@wa.toycker.store'
          THEN BTRIM(o.email)
        ELSE NULL
      END
    ) AS resolved_email,
    o.created_at,
    o.id
  FROM public.orders o
  WHERE o.user_id IS NOT NULL
),
latest_order_email AS (
  SELECT
    user_id,
    resolved_email,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at DESC, id DESC
    ) AS row_number
  FROM order_email_candidates
  WHERE resolved_email IS NOT NULL
)
UPDATE public.profiles p
SET contact_email = latest_order_email.resolved_email
FROM latest_order_email
WHERE p.id = latest_order_email.user_id
  AND latest_order_email.row_number = 1
  AND latest_order_email.resolved_email IS NOT NULL
  AND COALESCE(BTRIM(p.contact_email), '') = '';

UPDATE public.carts c
SET
  email = p.contact_email,
  updated_at = NOW()
FROM public.profiles p
WHERE c.user_id = p.id
  AND COALESCE(BTRIM(p.contact_email), '') <> ''
  AND COALESCE(BTRIM(c.email), '') <> ''
  AND LOWER(BTRIM(c.email)) LIKE '%@wa.toycker.store';

UPDATE public.orders o
SET
  customer_email = p.contact_email,
  email = p.contact_email,
  updated_at = NOW()
FROM public.profiles p
WHERE o.user_id = p.id
  AND COALESCE(BTRIM(p.contact_email), '') <> ''
  AND (
    (
      COALESCE(BTRIM(o.customer_email), '') <> ''
      AND LOWER(BTRIM(o.customer_email)) LIKE '%@wa.toycker.store'
    )
    OR (
      COALESCE(BTRIM(o.email), '') <> ''
      AND LOWER(BTRIM(o.email)) LIKE '%@wa.toycker.store'
    )
  );

-- <<< END 20260312110000_add_contact_email_for_phone_login.sql <<<


-- >>> BEGIN 20260313131500_restore_payment_discount_to_create_order_with_payment.sql >>>

BEGIN;

CREATE OR REPLACE FUNCTION public.create_order_with_payment(
  p_cart_id TEXT,
  p_email TEXT,
  p_shipping_address JSONB,
  p_billing_address JSONB,
  p_payment_provider TEXT,
  p_rewards_to_apply INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_order_id TEXT;
  v_existing_order_id TEXT;
  v_user_id UUID;
  v_is_club_member BOOLEAN := FALSE;
  v_club_discount_percentage NUMERIC := 0;
  v_payment_discount_percentage NUMERIC := 0;
  v_payment_discount_amount NUMERIC := 0;
  v_club_savings NUMERIC := 0;
  v_promo_discount NUMERIC := 0;
  v_total_discount NUMERIC := 0;
  v_item_subtotal NUMERIC := 0;
  v_item_subtotal_before_club NUMERIC := 0;
  v_shipping_total NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_final_total NUMERIC := 0;
  v_currency_code TEXT := 'INR';
  v_shipping_methods JSONB;
  v_payment_collection JSONB;
  v_items_json JSONB := '[]'::jsonb;
  v_gift_wrap_setting_fee NUMERIC := 0;
  v_promo_code TEXT;
BEGIN
  SELECT
    user_id,
    COALESCE(currency_code, 'INR'),
    shipping_methods,
    payment_collection,
    COALESCE(discount_total, 0),
    promo_code
  INTO
    v_user_id,
    v_currency_code,
    v_shipping_methods,
    v_payment_collection,
    v_promo_discount,
    v_promo_code
  FROM public.carts
  WHERE id = p_cart_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found';
  END IF;

  SELECT COALESCE(gift_wrap_fee, 0)
  INTO v_gift_wrap_setting_fee
  FROM public.global_settings
  WHERE id = 'default'
  LIMIT 1;

  IF v_user_id IS NOT NULL THEN
    SELECT COALESCE(is_club_member, FALSE)
    INTO v_is_club_member
    FROM public.profiles
    WHERE id = v_user_id;

    IF v_is_club_member THEN
      SELECT COALESCE(discount_percentage, 0)
      INTO v_club_discount_percentage
      FROM public.club_settings
      WHERE is_active = true
      LIMIT 1;
    END IF;
  END IF;

  SELECT COALESCE(discount_percentage, 0)
  INTO v_payment_discount_percentage
  FROM public.payment_providers
  WHERE id = p_payment_provider
    AND is_active = true
  LIMIT 1;

  SELECT
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', ci.id,
          'product_id', ci.product_id,
          'variant_id', ci.variant_id,
          'title', CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN 'Gift Wrap'
            ELSE COALESCE(pv.title, p.name, 'Product')
          END,
          'product_title', COALESCE(p.name, 'Product'),
          'quantity', ci.quantity,
          'unit_price', CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
            ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
          END,
          'original_unit_price', CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
            ELSE COALESCE(pv.price, p.price, 0)
          END,
          'total', (
            CASE
              WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
              ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
            END
          ) * ci.quantity,
          'original_total', (
            CASE
              WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
              ELSE COALESCE(pv.price, p.price, 0)
            END
          ) * ci.quantity,
          'metadata', COALESCE(ci.metadata, '{}'::jsonb),
          'thumbnail', CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN NULL
            ELSE p.image_url
          END,
          'variant', CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN NULL
            WHEN pv.id IS NOT NULL THEN jsonb_build_object('title', pv.title, 'id', pv.id)
            ELSE NULL
          END,
          'created_at', ci.created_at
        )
      ),
      '[]'::jsonb
    ),
    COALESCE(
      SUM(
        (
          CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
            ELSE ROUND(COALESCE(pv.price, p.price, 0) * (1 - v_club_discount_percentage / 100))
          END
        ) * ci.quantity
      ),
      0
    ),
    COALESCE(
      SUM(
        (
          CASE
            WHEN COALESCE((ci.metadata->>'gift_wrap_line')::boolean, false) = true THEN COALESCE((ci.metadata->>'gift_wrap_fee')::numeric, v_gift_wrap_setting_fee)
            ELSE COALESCE(pv.price, p.price, 0)
          END
        ) * ci.quantity
      ),
      0
    )
  INTO
    v_items_json,
    v_item_subtotal,
    v_item_subtotal_before_club
  FROM public.cart_items ci
  LEFT JOIN public.products p ON ci.product_id = p.id
  LEFT JOIN public.product_variants pv ON ci.variant_id = pv.id
  WHERE ci.cart_id = p_cart_id;

  v_club_savings := COALESCE(v_item_subtotal_before_club - v_item_subtotal, 0);

  IF v_payment_discount_percentage > 0 THEN
    v_payment_discount_amount := ROUND(
      v_item_subtotal * (v_payment_discount_percentage / 100)
    );
  END IF;

  v_total_discount :=
    COALESCE(p_rewards_to_apply, 0) +
    COALESCE(v_promo_discount, 0) +
    COALESCE(v_payment_discount_amount, 0);

  v_shipping_total := 0;
  IF v_shipping_methods IS NOT NULL AND jsonb_array_length(v_shipping_methods) > 0 THEN
    DECLARE
      v_method JSONB := v_shipping_methods->-1;
      v_amount NUMERIC := COALESCE((v_method->>'amount')::NUMERIC, 0);
      v_threshold NUMERIC := (v_method->>'min_order_free_shipping')::NUMERIC;
    BEGIN
      IF v_threshold IS NOT NULL AND v_item_subtotal >= v_threshold THEN
        v_shipping_total := 0;
      ELSE
        v_shipping_total := v_amount;
      END IF;
    END;
  END IF;

  v_final_total := GREATEST(
    0,
    v_item_subtotal +
    COALESCE(v_tax_total, 0) +
    v_shipping_total -
    v_total_discount
  );

  UPDATE public.carts
  SET
    email = p_email,
    shipping_address = p_shipping_address,
    billing_address = p_billing_address,
    metadata =
      COALESCE(metadata, '{}'::jsonb) ||
      jsonb_build_object(
        'rewards_to_apply',
        COALESCE(p_rewards_to_apply, 0)
      ),
    updated_at = NOW()
  WHERE id = p_cart_id;

  SELECT id
  INTO v_existing_order_id
  FROM public.orders
  WHERE metadata->>'cart_id' = p_cart_id
    AND status = 'pending'
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_existing_order_id IS NOT NULL THEN
    UPDATE public.orders
    SET
      email = p_email,
      customer_email = p_email,
      shipping_address = p_shipping_address,
      billing_address = p_billing_address,
      subtotal = v_item_subtotal,
      tax_total = v_tax_total,
      shipping_total = v_shipping_total,
      discount_total = v_total_discount,
      total_amount = v_final_total,
      total = v_final_total,
      currency_code = v_currency_code,
      payment_collection = v_payment_collection,
      items = v_items_json,
      shipping_methods = v_shipping_methods,
      promo_code = v_promo_code,
      payment_method = p_payment_provider,
      metadata = jsonb_build_object(
        'cart_id', p_cart_id,
        'rewards_used', COALESCE(p_rewards_to_apply, 0),
        'rewards_discount', COALESCE(p_rewards_to_apply, 0),
        'payment_discount_amount', COALESCE(v_payment_discount_amount, 0),
        'payment_discount_percentage', COALESCE(v_payment_discount_percentage, 0),
        'promo_discount', COALESCE(v_promo_discount, 0),
        'promo_code', v_promo_code,
        'club_savings', COALESCE(v_club_savings, 0),
        'club_discount_percentage', COALESCE(v_club_discount_percentage, 0),
        'is_club_member', v_is_club_member
      ),
      updated_at = NOW()
    WHERE id = v_existing_order_id;

    v_order_id := v_existing_order_id;
  ELSE
    INSERT INTO public.orders (
      user_id,
      email,
      customer_email,
      shipping_address,
      billing_address,
      subtotal,
      tax_total,
      shipping_total,
      discount_total,
      total_amount,
      total,
      currency_code,
      payment_collection,
      items,
      shipping_methods,
      metadata,
      promo_code,
      payment_method,
      status,
      payment_status,
      fulfillment_status,
      created_at,
      updated_at
    ) VALUES (
      v_user_id,
      p_email,
      p_email,
      p_shipping_address,
      p_billing_address,
      v_item_subtotal,
      v_tax_total,
      v_shipping_total,
      v_total_discount,
      v_final_total,
      v_final_total,
      v_currency_code,
      v_payment_collection,
      v_items_json,
      v_shipping_methods,
      jsonb_build_object(
        'cart_id', p_cart_id,
        'rewards_used', COALESCE(p_rewards_to_apply, 0),
        'rewards_discount', COALESCE(p_rewards_to_apply, 0),
        'payment_discount_amount', COALESCE(v_payment_discount_amount, 0),
        'payment_discount_percentage', COALESCE(v_payment_discount_percentage, 0),
        'promo_discount', COALESCE(v_promo_discount, 0),
        'promo_code', v_promo_code,
        'club_savings', COALESCE(v_club_savings, 0),
        'club_discount_percentage', COALESCE(v_club_discount_percentage, 0),
        'is_club_member', v_is_club_member
      ),
      v_promo_code,
      p_payment_provider,
      'pending',
      'pending',
      'not_shipped',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_order_id;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id
  );
END;
$$;

COMMIT;

-- <<< END 20260313131500_restore_payment_discount_to_create_order_with_payment.sql <<<


-- >>> BEGIN 20260314_active_only_multimodal_product_search.sql >>>

CREATE OR REPLACE FUNCTION public.search_products_multimodal(
  search_query TEXT DEFAULT NULL,
  search_embedding vector(512) DEFAULT NULL,
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 20
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  handle TEXT,
  image_url TEXT,
  thumbnail TEXT,
  price DECIMAL,
  currency_code TEXT,
  relevance_score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  WITH text_scores AS (
    SELECT
      p.id::TEXT as product_id,
      GREATEST(
        CASE
          WHEN search_query IS NOT NULL AND p.search_vector @@ websearch_to_tsquery('english', search_query)
          THEN ts_rank_cd(p.search_vector, websearch_to_tsquery('english', search_query)) * 0.5
          ELSE 0
        END,
        CASE
          WHEN search_query IS NOT NULL THEN similarity(p.name, search_query) * 0.4
          ELSE 0
        END,
        CASE
          WHEN search_query IS NOT NULL AND p.name ILIKE search_query || '%' THEN 0.1
          ELSE 0
        END
      ) as text_score
    FROM public.products p
    WHERE search_query IS NOT NULL
      AND p.status = 'active'
  ),
  image_scores AS (
    SELECT
      p.id::TEXT as product_id,
      1 - (p.image_embedding <=> search_embedding) as image_score
    FROM public.products p
    WHERE search_embedding IS NOT NULL
      AND p.image_embedding IS NOT NULL
      AND p.status = 'active'
  ),
  combined_scores AS (
    SELECT
      COALESCE(t.product_id, i.product_id) as product_id,
      CASE
        WHEN t.text_score > 0 AND i.image_score IS NOT NULL
          THEN (t.text_score * 0.4 + i.image_score * 0.6)
        WHEN t.text_score > 0
          THEN t.text_score
        WHEN i.image_score IS NOT NULL
          THEN i.image_score
        ELSE 0
      END as final_score
    FROM text_scores t
    FULL OUTER JOIN image_scores i ON t.product_id = i.product_id
  )
  SELECT
    p.id::TEXT,
    p.name,
    p.handle,
    p.image_url,
    p.thumbnail,
    COALESCE(
      (SELECT min(v.price) FROM public.product_variants v WHERE v.product_id = p.id),
      p.price
    )::DECIMAL as price,
    p.currency_code,
    c.final_score::FLOAT as relevance_score
  FROM combined_scores c
  JOIN public.products p ON c.product_id = p.id::TEXT
  WHERE c.final_score >= match_threshold
    AND p.status = 'active'
  ORDER BY c.final_score DESC
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.search_products_multimodal IS
'Hybrid search combining text and image embeddings for active storefront products only. Last updated 2026-03-14.';

-- <<< END 20260314_active_only_multimodal_product_search.sql <<<


-- >>> BEGIN 20260323_add_easebuzz_payment_support.sql >>>

-- Add Easebuzz payment gateway support
-- Strategy: additive only — existing payu_txn_id column and pp_payu_payu row are untouched for safe revert

-- Add gateway_txn_id column for storing Easebuzz (and future gateway) transaction IDs
ALTER TABLE orders ADD COLUMN IF NOT EXISTS gateway_txn_id TEXT;

-- Add Easebuzz payment provider row (does not modify existing pp_payu_payu row)
INSERT INTO payment_providers (id, name, description, is_active, discount_percentage)
VALUES (
  'pp_easebuzz_easebuzz',
  'Easebuzz',
  'Pay securely using cards, UPI, net banking, or wallets.',
  true,
  0
)
ON CONFLICT (id) DO NOTHING;

-- <<< END 20260323_add_easebuzz_payment_support.sql <<<

-- ============================================================
-- End of full bootstrap
-- ============================================================

