# GitHub Copilot Instructions

## Project

Project Name:
FieldTime

Description:

FieldTime is a premium Flutter application for booking football fields.

The application allows users to search football fields, view details, check available hours, and instantly reserve a field.

The app also contains an Owner Dashboard for football field owners.

---

## Tech Stack

Flutter (Latest Stable)

Dart

Material 3

Cubit (flutter_bloc)

Clean Architecture

Feature First Architecture

GoRouter

Supabase

Google Maps

CachedNetworkImage

Flutter SVG

ScreenUtil

Shimmer

---

## Code Style

Always write production-ready code.

Never write pseudo code.

Never leave TODOs.

Never use placeholders.

Generate complete files.

Use null safety.

Use const whenever possible.

Use immutable models.

Use Equatable.

Always separate:

Data

Domain

Presentation

Do not mix business logic with UI.

Business logic belongs inside Cubits and Repositories.

---

## Folder Structure

lib/

app/

core/

shared/

features/

Every feature must contain:

data/

domain/

presentation/

Example

features/

auth/

home/

booking/

field/

profile/

owner/

---

## Naming Convention

Classes

PascalCase

Variables

camelCase

Files

snake_case

Cubit

Example:

home_cubit.dart

home_state.dart

booking_repository.dart

---

## UI Rules

Premium modern UI.

Rounded corners.

Soft shadows.

Material 3.

Responsive.

No overflow.

No deprecated widgets.

Use reusable widgets.

Use custom buttons.

Use custom text fields.

Use loading skeletons.

Use Hero animations when needed.

---

## Theme

Primary Color

#22C55E

Dark Background

#0F172A

Light Background

#F8FAFC

Accent

#FACC15

Text

#111827

Font

Cairo

---

## Authentication

Supabase Auth

Google Login

Email Login

Register

Forgot Password

Persistent Login

---

## Database

Supabase PostgreSQL

Tables

users

fields

field_images

bookings

favorites

notifications

Every table must have:

id

created_at

updated_at

---

## Booking Rules

Booking must be instant.

Prevent duplicate bookings.

Use database constraints.

Use transactions.

Available hours should update immediately.

---

## Owner Dashboard

Owner can

Create field

Edit field

Delete field

Upload images

Set prices

Set available hours

View bookings

View revenue

---

## Maps

Use Google Maps.

Show football field location.

Open directions.

---

## Performance

Use pagination.

Lazy loading.

Cache images.

Dispose controllers.

Never rebuild unnecessary widgets.

---

## Error Handling

Every repository returns

Either

Success

Or

Failure

Never throw raw exceptions to UI.

---

## State Management

Only Cubit.

No Provider.

No GetX.

No Riverpod.

---

## Routing

Use GoRouter.

Typed routes.

Nested navigation.

---

## Models

Models must contain

fromJson()

toJson()

copyWith()

Equatable

---

## Widgets

Always create reusable widgets.

Example

PrimaryButton

PrimaryTextField

FieldCard

RatingWidget

LoadingWidget

---

## Architecture

UI

↓

Cubit

↓

Repository

↓

Supabase

---

## Security

Never expose service role keys.

Only use anon key.

Use Row Level Security.

---

## Localization

Arabic RTL

English LTR

Use easy_localization.

---

## Comments

Write comments only when necessary.

No unnecessary comments.

---

## AI Behaviour

Always generate complete files.

Never skip files.

Never shorten code.

If multiple files are required,
generate all of them.

If the task is large,
continue feature by feature.

Keep project consistency.

Never regenerate existing files unless requested.

Always check dependencies before generating code.

Always follow Clean Architecture.

Never change folder structure.

Always prefer readability over clever code.

Generate production-level Flutter code.
