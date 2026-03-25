# New Supabase Project Setup (Empty DB)

Use this for a completely empty Supabase project.

## 1) Run full schema bootstrap

Open Supabase Dashboard -> SQL Editor and run:

- `supabase/new-project/migrations/20260325_000000_full_empty_project_bootstrap.sql`

This file creates base auth/profile objects and applies curated 2025/2026 migrations.

## 2) Promote admin user and assign phone

Then run:

- `supabase/new-project/migrations/20260325_120000_promote_admin_and_assign_phone.sql`

Pre-filled values:

- Email: `kartavyatech@gmail.com`
- Phone input: `9265348797` (normalized to `919265348797`)

## 3) Verify admin row

The second SQL file already includes a verification query at the bottom.
Expected:

- `role = 'admin'`
- `admin_role_name = 'Owner'`
- `profile_phone = auth_phone = '919265348797'`

## 4) Access admin

Run app and open:

- `http://localhost:3000/admin`

If you are redirected to login, use OTP for the configured phone.
