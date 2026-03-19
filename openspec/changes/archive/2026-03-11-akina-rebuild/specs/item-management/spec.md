# Item Management

## Overview

Items represent physical equipment tracked by the organisation. Each item has a unique QR code, an auto-incrementing item number within the org, and a lifecycle status. Admins perform full CRUD; members have read-only access.

## Requirements

1. Each item belongs to exactly one organisation.
2. Items have the following fields: name, item_number, status, qr_code, project_id (nullable), organisation_id, notes, created_at, updated_at.
3. `item_number` is an integer that auto-increments per organisation (org A and org B each start at 1).
4. `status` is an enum with values: `storage`, `in_project`, `missing`, `under_repair`, `retired`.
5. `qr_code` is a UUID generated client-side at creation time. It is immutable after creation.
6. `project_id` is a nullable FK to projects. It is non-null only when status is `in_project`.
7. Only admins can create, edit, and delete items. Members have read-only access.
8. The item list screen supports search by name or item number, and filtering by status.
9. The item detail screen displays the QR code, current status, assigned project (if any), notes, and the activity history for that item.
10. Deleting an item is a hard delete. A confirmation dialog warns the admin. An activity log entry is recorded before deletion.
11. Retired items remain visible in the list (filterable) but cannot be relocated or assigned to projects.

## Data Model

- **items**: `id` (UUID PK), `name` (text, not null), `item_number` (int, not null), `status` (enum, default `storage`), `qr_code` (UUID, unique, not null), `project_id` (UUID FK -> projects, nullable), `organisation_id` (UUID FK -> organisations, not null), `notes` (text, nullable), `created_at` (timestamptz), `updated_at` (timestamptz).
- Unique constraint on (`organisation_id`, `item_number`).
- Unique constraint on `qr_code`.

## Behavior

- When creating an item, the system determines the next `item_number` by finding `max(item_number)` for the org and adding 1. If no items exist, start at 1.
- Item number assignment must be atomic to prevent duplicates under concurrent creation (use a Supabase RPC or database sequence scoped per org).
- When an item's status changes to `in_project`, `project_id` must be set. When status changes away from `in_project`, `project_id` is cleared to null.
- `updated_at` is set on every write operation.
- Search is case-insensitive and matches partial strings on name. Item number search matches exact integer input.
- The item list defaults to showing all non-retired items, sorted by item_number ascending.
