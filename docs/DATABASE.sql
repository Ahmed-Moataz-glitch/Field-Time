-- Enable UUID
create extension if not exists "pgcrypto";

----------------------------------------------------
-- USERS
----------------------------------------------------

create table users (

    id uuid primary key references auth.users(id) on delete cascade,

    full_name text not null,

    email text unique,

    phone text,

    avatar_url text,

    city text,

    role text default 'user',

    created_at timestamptz default now(),

    updated_at timestamptz default now()

);

----------------------------------------------------
-- FOOTBALL FIELDS
----------------------------------------------------

create table football_fields(

    id uuid primary key default gen_random_uuid(),

    owner_id uuid references users(id),

    name text not null,

    description text,

    city text,

    area text,

    address text,

    latitude double precision,

    longitude double precision,

    phone text,

    price_per_hour numeric not null,

    rating numeric default 0,

    reviews_count integer default 0,

    field_type text,

    grass_type text,

    is_indoor boolean default false,

    is_active boolean default true,

    opening_time time,

    closing_time time,

    created_at timestamptz default now(),

    updated_at timestamptz default now()

);

----------------------------------------------------
-- FIELD IMAGES
----------------------------------------------------

create table field_images(

    id uuid primary key default gen_random_uuid(),

    field_id uuid references football_fields(id) on delete cascade,

    image_url text not null,

    sort_order integer default 0,

    created_at timestamptz default now()

);

----------------------------------------------------
-- BOOKINGS
----------------------------------------------------

create table bookings(

    id uuid primary key default gen_random_uuid(),

    field_id uuid references football_fields(id) on delete cascade,

    user_id uuid references users(id) on delete cascade,

    booking_date date not null,

    start_time time not null,

    end_time time not null,

    total_price numeric,

    status text default 'confirmed',

    booking_code text unique,

    notes text,

    created_at timestamptz default now(),

    updated_at timestamptz default now()

);

----------------------------------------------------
-- FAVORITES
----------------------------------------------------

create table favorites(

    id uuid primary key default gen_random_uuid(),

    user_id uuid references users(id),

    field_id uuid references football_fields(id),

    created_at timestamptz default now(),

    unique(user_id,field_id)

);

----------------------------------------------------
-- REVIEWS
----------------------------------------------------

create table reviews(

    id uuid primary key default gen_random_uuid(),

    user_id uuid references users(id),

    field_id uuid references football_fields(id),

    rating integer check(rating between 1 and 5),

    comment text,

    created_at timestamptz default now()

);

----------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------

create table notifications(

    id uuid primary key default gen_random_uuid(),

    user_id uuid references users(id),

    title text,

    body text,

    is_read boolean default false,

    created_at timestamptz default now()

);