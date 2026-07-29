# PROJECT SPECIFICATION

# FieldTime

Version: 1.0.0

Status:
Production Planning

Platform

- Android
- iOS

Framework

Flutter

Backend

Supabase

Architecture

Feature First + Clean Architecture

State Management

flutter_bloc (Cubit)

Navigation

GoRouter

Database

PostgreSQL

---

# 1. Project Overview

FieldTime is a premium football field booking application.

The application connects football players with football field owners.

Users can search football fields, compare prices, view images, check available hours, and instantly reserve a football field.

Owners can manage fields, reservations, schedules, pricing, and statistics.

The application focuses on speed, simplicity, premium UI, and real-time booking.

---

# 2. Vision

Become the easiest football field booking application in the Middle East.

Provide an experience similar to:

Booking.com

Airbnb

Uber

but for football fields.

---

# 3. Goals

Create the fastest booking process.

Reduce phone calls.

Provide live availability.

Prevent double booking.

Help owners manage reservations.

Provide a premium mobile experience.

---

# 4. User Types

## Guest

Can browse fields.

Cannot reserve.

Cannot favorite.

Cannot review.

---

## User

Create account.

Login.

Book field.

Cancel booking.

Favorite fields.

Rate field.

View bookings.

Receive notifications.

---

## Field Owner

Everything User has.

Additionally:

Create football field.

Upload images.

Manage bookings.

Edit prices.

Manage schedules.

View statistics.

---

# 5. Business Rules

Reservation is instant.

No approval required.

Double booking is impossible.

Payment can be added later.

User can only cancel before allowed period.

Owner cannot delete a field with active bookings.

Inactive fields never appear in search.

---

# 6. Main Features

Authentication

Home

Search

Football Field Details

Booking

Favorites

Reviews

Notifications

Profile

Owner Dashboard

Settings

Localization

Dark Mode

---

# 7. Authentication

Supported methods

Google

Email

Password

Forgot Password

Persistent Login

Logout

Delete Account

Profile Update

---

# 8. Home Screen

Contains

Search Bar

Location

Nearby Fields

Popular Fields

Offers

Categories

Recommended Fields

Recent Bookings

Top Rated Fields

Bottom Navigation

---

# 9. Search

Search by

Field Name

City

Area

Price

Rating

Distance

Open Now

Available Today

Artificial Grass

5v5

7v7

11v11

Indoor

Outdoor

---

# 10. Field Details

Image Slider

Field Name

Rating

Address

Google Map

Opening Hours

Available Hours

Price Per Hour

Facilities

Parking

Changing Rooms

Bathrooms

Cafe

Lighting

Artificial Grass Type

Description

Reviews

Book Now Button

Favorite Button

Call Owner

Open Maps

Share

---

# 11. Navigation Flow

Splash

↓

Onboarding

↓

Authentication

↓

Home

↓

Field Details

↓

Booking

↓

Booking Success

↓

My Bookings

↓

Profile

---

Owner Flow

Splash

↓

Login

↓

Owner Dashboard

↓

My Fields

↓

Field Details

↓

Bookings

↓

Statistics

↓

Profile

---

# 12. Bottom Navigation

There are four tabs.

Home

Bookings

Favorites

Profile

Navigation must preserve page state.

No page should reload when switching tabs.

---

# 13. UI Design System

Design Style

Premium

Modern

Minimal

Sports

Rounded

Soft Shadow

Material 3

Every screen should feel smooth.

No clutter.

No unnecessary elements.

---

# 14. Color Palette

Primary

#22C55E

Primary Dark

#16A34A

Accent

#FACC15

Background Light

#F8FAFC

Background Dark

#0F172A

Card

#FFFFFF

Card Dark

#1E293B

Divider

#E5E7EB

Error

#EF4444

Success

#22C55E

Warning

#F59E0B

---

# 15. Typography

Font Family

Cairo

Weights

Regular

Medium

SemiBold

Bold

Heading 1

32

Heading 2

28

Heading 3

24

Title

20

Body

16

Caption

14

Small

12

---

# 16. Icon Style

Material Symbols Rounded

Icons must be outlined.

Avoid filled icons except active navigation.

---

# 17. Components

Primary Button

Secondary Button

Outlined Button

Icon Button

Primary TextField

Password TextField

Search Field

Rating Widget

Price Widget

Football Field Card

Review Card

Loading Skeleton

Loading Button

Custom Dialog

Custom Snackbar

Confirmation Dialog

Error Widget

Empty State Widget

---

# 18. Animations

Fade

Scale

Slide

Hero

Page Transition

Animated Favorite

Animated Booking Success

Animated Search

Shimmer Loading

Duration

200ms

300ms

500ms

Never use long animations.

---

# 19. Home Screen Layout

Top AppBar

Current Location

Greeting

Search Field

Categories

Special Offers

Nearby Fields

Popular Fields

Recommended Fields

Recently Viewed

Bottom Navigation

---

# 20. Football Card

Contains

Image

Rating

Favorite Button

Field Name

Distance

Price Per Hour

Address

Available Today Badge

Book Now Button

---

# 21. Field Details Screen

Hero Image Slider

Field Name

Rating

Address

Open Google Maps

Gallery

Description

Facilities

Opening Hours

Available Time Slots

Reviews

Related Fields

Bottom Sticky Booking Button

---

# 22. Booking Screen

Choose Date

Choose Time

Booking Summary

Price

Discount

Coupon

Total

Confirm Booking Button

---

# 23. Booking Success

Large Success Animation

Booking Number

QR Code

Date

Time

Field Name

Directions Button

Download Receipt

Return Home

---

# 24. My Bookings

Upcoming

Completed

Cancelled

Each Booking Card

Field

Date

Time

Price

Status

Cancel Button

View Details

---

# 25. Favorites

Grid View

Remove Favorite

Open Details

---

# 26. Profile

Profile Picture

Edit Profile

Phone

Email

Language

Dark Mode

Notifications

Privacy Policy

Logout

Delete Account

---

# 27. Notifications

Booking Confirmed

Booking Cancelled

Reminder Before Match

Special Offers

Owner Messages

---

# 28. Search Experience

Instant Search

Suggestions

Recent Searches

Filter Sheet

Sort Sheet

No Results Screen

---

# 29. Empty States

No Favorites

No Bookings

No Internet

No Results

No Notifications

Every empty state should include:

Illustration

Title

Description

Primary Action

---

# 30. Loading States

Every screen must have loading placeholders.

Never show blank white screens.

Use shimmer placeholders.

---

# 31. Accessibility

Support RTL.

Support large fonts.

Support screen readers.

Minimum touch target

48dp

High contrast.

---

# 32. Database Design

Database

PostgreSQL

Backend

Supabase

Primary Key

UUID

Every table must contain

id

created_at

updated_at

---

# users

Purpose

Application users.

Columns

id

full_name

email

phone

avatar_url

role

city

created_at

updated_at

Role

user

owner

admin

---

# football_fields

Purpose

Football field information.

Columns

id

owner_id

name

description

city

area

address

latitude

longitude

price_per_hour

rating

reviews_count

field_type

grass_type

is_indoor

is_active

opening_time

closing_time

phone

created_at

updated_at

---

# field_images

Purpose

Store multiple images.

Columns

id

field_id

image_url

sort_order

created_at

---

# field_facilities

Purpose

Facilities.

Columns

id

field_id

parking

cafeteria

bathroom

changing_room

lighting

wifi

ball_rental

created_at

---

# bookings

Purpose

Reservations.

Columns

id

field_id

user_id

booking_date

start_time

end_time

price

status

booking_code

notes

created_at

updated_at

Booking Status

pending

confirmed

cancelled

completed

---

# favorites

Columns

id

field_id

user_id

created_at

---

# reviews

Columns

id

field_id

user_id

rating

comment

created_at

---

# notifications

Columns

id

user_id

title

body

type

is_read

created_at

---

# offers

Columns

id

field_id

title

description

discount

start_date

end_date

created_at

---

# coupons

Columns

id

code

discount

max_usage

expire_at

created_at

---

# owner_statistics

Columns

id

owner_id

month

bookings_count

total_income

cancelled_bookings

created_at

---

# Storage

Bucket

avatars

Bucket

field-images

Bucket

review-images

---

# Relationships

User

↓

Owns

↓

Football Fields

Football Field

↓

Has Many

↓

Images

Football Field

↓

Has Many

↓

Bookings

Football Field

↓

Has Many

↓

Reviews

Football Field

↓

Has Many

↓

Favorites

---

# Database Constraints

A booking must never overlap another booking.

One user cannot favorite the same field twice.

Rating

Minimum

1

Maximum

5

Price must be greater than zero.

---

# Booking Logic

User chooses

Date

↓

Available Time

↓

Check availability

↓

Create booking

↓

Reservation becomes confirmed immediately

↓

Time slot disappears from everyone else

---

# Double Booking Prevention

Must be handled inside database.

Never rely on Flutter only.

Use PostgreSQL Constraints.

Use Transaction.

Use RPC if needed.

---

# Booking Cancellation

Allowed only before configurable cancellation window.

Owner cannot cancel completed bookings.

Completed bookings become read only.

---

# Notifications

Booking Confirmed

Booking Cancelled

Booking Reminder

Owner New Booking

Offer Notification

---

# Row Level Security

Users

Can read only themselves.

Can update only themselves.

---

Football Fields

Everyone can read.

Only owner can edit.

Only owner can delete.

---

Bookings

User

Can read own bookings.

Owner

Can read bookings of own fields.

Admin

Can read everything.

---

Reviews

Everyone can read.

Only creator can edit.

Only creator can delete.

---

Favorites

Only owner of favorite can access.

---

Storage Rules

User avatar

Owner only.

Field images

Field owner only.

Review images

Review owner only.

---

# Real Time

Realtime enabled for

Bookings

Notifications

Football Fields

---

# Offline

Cache

Fields

Images

User Profile

Favorites

---

# Security

Enable RLS.

Never expose Service Role Key.

Use only anon key inside Flutter.

All sensitive operations must go through policies or Edge Functions.
