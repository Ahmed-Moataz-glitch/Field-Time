-- Migration: 20260731000002_create_rls_policies.sql
-- Description: Enables Row Level Security (RLS) and defines fine-grained access policies for all tables.

----------------------------------------------------
-- 1. USERS RLS POLICIES
----------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public user profiles are viewable by everyone" 
    ON public.users FOR SELECT 
    USING (true);

CREATE POLICY "Users can insert their own profile" 
    ON public.users FOR INSERT 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
    ON public.users FOR UPDATE 
    USING (auth.uid() = id);

----------------------------------------------------
-- 2. FOOTBALL FIELDS RLS POLICIES
----------------------------------------------------
ALTER TABLE public.football_fields ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Active fields are viewable by everyone" 
    ON public.football_fields FOR SELECT 
    USING (is_active = true OR auth.uid() = owner_id);

CREATE POLICY "Owners can insert new fields" 
    ON public.football_fields FOR INSERT 
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their own fields" 
    ON public.football_fields FOR UPDATE 
    USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their own fields" 
    ON public.football_fields FOR DELETE 
    USING (auth.uid() = owner_id);

----------------------------------------------------
-- 3. FIELD IMAGES RLS POLICIES
----------------------------------------------------
ALTER TABLE public.field_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Field images are viewable by everyone" 
    ON public.field_images FOR SELECT 
    USING (true);

CREATE POLICY "Field owners can manage field images" 
    ON public.field_images FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM public.football_fields 
            WHERE id = field_id AND owner_id = auth.uid()
        )
    );

----------------------------------------------------
-- 4. OFFERS RLS POLICIES
----------------------------------------------------
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Active offers are viewable by everyone" 
    ON public.offers FOR SELECT 
    USING (is_active = true);

CREATE POLICY "Authenticated users can create offers" 
    ON public.offers FOR ALL 
    USING (auth.role() = 'authenticated');

----------------------------------------------------
-- 5. BOOKINGS RLS POLICIES
----------------------------------------------------
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players and field owners can view relevant bookings" 
    ON public.bookings FOR SELECT 
    USING (
        auth.uid() = user_id OR 
        EXISTS (
            SELECT 1 FROM public.football_fields 
            WHERE id = field_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Authenticated players can create bookings" 
    ON public.bookings FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Players and field owners can update booking status" 
    ON public.bookings FOR UPDATE 
    USING (
        auth.uid() = user_id OR 
        EXISTS (
            SELECT 1 FROM public.football_fields 
            WHERE id = field_id AND owner_id = auth.uid()
        )
    );

----------------------------------------------------
-- 6. FAVORITES RLS POLICIES
----------------------------------------------------
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own favorites" 
    ON public.favorites FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can add to their favorites" 
    ON public.favorites FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove from their favorites" 
    ON public.favorites FOR DELETE 
    USING (auth.uid() = user_id);

----------------------------------------------------
-- 7. REVIEWS RLS POLICIES
----------------------------------------------------
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reviews are viewable by everyone" 
    ON public.reviews FOR SELECT 
    USING (true);

CREATE POLICY "Authenticated players can create reviews" 
    ON public.reviews FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" 
    ON public.reviews FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" 
    ON public.reviews FOR DELETE 
    USING (auth.uid() = user_id);

----------------------------------------------------
-- 8. NOTIFICATIONS RLS POLICIES
----------------------------------------------------
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" 
    ON public.notifications FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notification read status" 
    ON public.notifications FOR UPDATE 
    USING (auth.uid() = user_id);
