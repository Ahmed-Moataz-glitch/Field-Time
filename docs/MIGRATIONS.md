# Supabase Database Migrations & Security Setup

This directory and `supabase/migrations/` contain production-ready PostgreSQL migration scripts, database indexes, Row Level Security (RLS) policies, Realtime publications, and Storage bucket configurations for the FieldTime application.

## Migration Structure

| File | Description |
|---|---|
| [`20260731000000_create_tables.sql`](file:///f:/Flutter%20Projects/field_time/supabase/migrations/20260731000000_create_tables.sql) | Enables `pgcrypto`, creates `users`, `football_fields`, `field_images`, `offers`, `bookings`, `favorites`, `reviews`, and `notifications` tables, and attaches `handle_new_user()` Auth trigger. |
| [`20260731000001_create_indexes.sql`](file:///f:/Flutter%20Projects/field_time/supabase/migrations/20260731000001_create_indexes.sql) | Creates performance indexes for search, location, and owner queries. Includes `idx_bookings_unique_active_slot` unique partial index preventing duplicate active bookings. |
| [`20260731000002_create_rls_policies.sql`](file:///f:/Flutter%20Projects/field_time/supabase/migrations/20260731000002_create_rls_policies.sql) | Enables Row Level Security (RLS) across all 8 tables and configures access control policies. |
| [`20260731000003_storage_and_realtime.sql`](file:///f:/Flutter%20Projects/field_time/supabase/migrations/20260731000003_storage_and_realtime.sql) | Configures Supabase Realtime publication on `bookings`, `notifications`, and `football_fields`, and creates `field-images` and `user-avatars` storage buckets. |

## Execution Instructions

### Option 1: Via Supabase CLI (Recommended)
```bash
npx supabase db push
```

### Option 2: Via Supabase Dashboard SQL Editor
1. Open your Supabase Project Dashboard.
2. Go to **SQL Editor** -> **New Query**.
3. Copy and run the files in numerical sequence (0 -> 1 -> 2 -> 3).
