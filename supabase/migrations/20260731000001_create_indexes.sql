-- Migration: 20260731000001_create_indexes.sql
-- Description: Creates database indexes for performance optimization and duplicate booking prevention.

----------------------------------------------------
-- FOOTBALL FIELDS INDEXES
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_football_fields_city_area 
    ON public.football_fields (city, area);

CREATE INDEX IF NOT EXISTS idx_football_fields_owner 
    ON public.football_fields (owner_id);

CREATE INDEX IF NOT EXISTS idx_football_fields_active_popular 
    ON public.football_fields (is_active, is_popular, is_recommended);

CREATE INDEX IF NOT EXISTS idx_football_fields_price_rating 
    ON public.football_fields (price_per_hour, rating DESC);

----------------------------------------------------
-- BOOKINGS INDEXES & UNIQUE DUPLICATE PREVENTION
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_bookings_user_id 
    ON public.bookings (user_id);

CREATE INDEX IF NOT EXISTS idx_bookings_field_date 
    ON public.bookings (field_id, booking_date);

-- CRITICAL: Unique partial index to strictly prevent duplicate bookings on the same field, date, and start_time
CREATE UNIQUE INDEX IF NOT EXISTS idx_bookings_unique_active_slot 
    ON public.bookings (field_id, booking_date, start_time) 
    WHERE status != 'cancelled';

----------------------------------------------------
-- FAVORITES & REVIEWS INDEXES
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_favorites_user_field 
    ON public.favorites (user_id, field_id);

CREATE INDEX IF NOT EXISTS idx_reviews_field_id 
    ON public.reviews (field_id, created_at DESC);

----------------------------------------------------
-- NOTIFICATIONS INDEXES
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_notifications_user_read 
    ON public.notifications (user_id, is_read, created_at DESC);
