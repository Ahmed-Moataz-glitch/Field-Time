-- Migration: 20260731000003_storage_and_realtime.sql
-- Description: Configures Supabase Realtime publications and Storage buckets with RLS policies.

----------------------------------------------------
-- 1. ENABLE SUPABASE REALTIME
----------------------------------------------------
-- Add tables to the supabase_realtime publication for instant live updates
BEGIN;
    DROP PUBLICATION IF EXISTS supabase_realtime;
    CREATE PUBLICATION supabase_realtime FOR TABLE 
        public.bookings, 
        public.notifications, 
        public.football_fields;
COMMIT;

----------------------------------------------------
-- 2. STORAGE BUCKETS SETUP
----------------------------------------------------
-- Create 'field-images' public storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('field-images', 'field-images', true)
ON CONFLICT (id) DO NOTHING;

-- Create 'user-avatars' public storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-avatars', 'user-avatars', true)
ON CONFLICT (id) DO NOTHING;

----------------------------------------------------
-- 3. STORAGE RLS POLICIES FOR FIELD IMAGES
----------------------------------------------------
CREATE POLICY "Public read access for field images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'field-images');

CREATE POLICY "Authenticated users can upload field images"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'field-images' AND auth.role() = 'authenticated');

CREATE POLICY "Owners can update or delete field images"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'field-images' AND auth.role() = 'authenticated');

----------------------------------------------------
-- 4. STORAGE RLS POLICIES FOR USER AVATARS
----------------------------------------------------
CREATE POLICY "Public read access for user avatars"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'user-avatars');

CREATE POLICY "Users can upload their own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'user-avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update or delete their avatar"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'user-avatars' AND auth.role() = 'authenticated');
