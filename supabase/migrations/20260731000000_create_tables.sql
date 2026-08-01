-- Migration: 20260731000000_create_tables.sql
-- Description: Creates core database tables for FieldTime application with trigger for Auth users.

-- 1. Enable pgcrypto extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

----------------------------------------------------
-- USERS TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    avatar_url TEXT,
    city TEXT DEFAULT 'القاهرة',
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'owner', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger to automatically create a public.users entry when a new Auth user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, email, avatar_url, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
        NEW.email,
        NEW.raw_user_meta_data->>'avatar_url',
        COALESCE(NEW.raw_user_meta_data->>'role', 'user')
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

----------------------------------------------------
-- FOOTBALL FIELDS TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.football_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    city TEXT NOT NULL DEFAULT 'القاهرة',
    area TEXT,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    phone TEXT,
    price_per_hour NUMERIC(10, 2) NOT NULL CHECK (price_per_hour >= 0),
    old_price NUMERIC(10, 2) CHECK (old_price > price_per_hour),
    rating NUMERIC(3, 2) DEFAULT 5.0 CHECK (rating BETWEEN 0 AND 5),
    reviews_count INTEGER DEFAULT 0 CHECK (reviews_count >= 0),
    distance TEXT DEFAULT '1.0 كم',
    field_type TEXT DEFAULT 'خماسي' CHECK (field_type IN ('خماسي', 'سباعي', '11v11', 'صالات')),
    grassType TEXT DEFAULT 'عشب صناعي',
    is_indoor BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_popular BOOLEAN DEFAULT FALSE,
    is_recommended BOOLEAN DEFAULT FALSE,
    is_available_today BOOLEAN DEFAULT TRUE,
    main_image TEXT,
    facilities TEXT[] DEFAULT ARRAY['إضاءة ليلية', 'مواقف سيارات', 'دورات مياه'],
    opening_time TIME DEFAULT '08:00:00',
    closing_time TIME DEFAULT '00:00:00',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

----------------------------------------------------
-- FIELD IMAGES TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.field_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_id UUID NOT NULL REFERENCES public.football_fields(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

----------------------------------------------------
-- OFFERS TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_id UUID REFERENCES public.football_fields(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    discount_text TEXT NOT NULL,
    image_url TEXT NOT NULL,
    tag TEXT DEFAULT 'عرض خاص',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

----------------------------------------------------
-- BOOKINGS TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_id UUID NOT NULL REFERENCES public.football_fields(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL CHECK (total_price >= 0),
    status TEXT DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'completed', 'cancelled')),
    booking_code TEXT UNIQUE NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

----------------------------------------------------
-- FAVORITES TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    field_id UUID NOT NULL REFERENCES public.football_fields(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, field_id)
);

----------------------------------------------------
-- REVIEWS TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    field_id UUID NOT NULL REFERENCES public.football_fields(id) ON DELETE CASCADE,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

----------------------------------------------------
-- NOTIFICATIONS TABLE
----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
