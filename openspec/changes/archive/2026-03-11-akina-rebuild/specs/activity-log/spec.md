# Activity Log

## Overview

The activity log records every significant change to items and projects within an organisation. It provides an audit trail for accountability and is displayed contextually on item detail screens and on the dashboard.

## Requirements

1. A log entry is created for every: item relocation (status change), item creation, item edit, item deletion, project creation, project status change (completion, archival), and item assignment/removal from a project.
2. Log entries are immutable. They are never updated or deleted.
3. Each log entry records: who performed the action, what action was performed, which entity was affected, the before and after state, and when it happened.
4. The item detail screen shows a chronological list of all log entries for that item, newest first.
5. The dashboard shows the most recent log entries across all items in the active org, newest first, limited to a configurable page size (default 20).
6. Log entries display the actor's name, a human-readable action description, and a relative timestamp (e.g., "2 hours ago").
7. Admins and members can both view the full activity log. No entries are hidden by role.
8. Log entries are scoped to the active organisation via `organisation_id`.

## Data Model

- **activity_log**: `id` (UUID PK), `user_id` (UUID FK -> auth.users, not null), `action` (text, not null), `entity_type` (enum: item, project), `entity_id` (UUID, not null), `from_status` (text, nullable), `to_status` (text, nullable), `project_id` (UUID FK -> projects, nullable), `organisation_id` (UUID FK -> organisations, not null), `metadata` (jsonb, nullable), `created_at` (timestamptz, default now()).

### Action Values

- `item.created`, `item.updated`, `item.deleted`
- `item.relocated` (with from_status and to_status)
- `project.created`, `project.completed`, `project.archived`, `project.deleted`

## Behavior

- The `from_status` and `to_status` fields are populated only for relocation actions and project status changes. For create/delete actions, `from_status` is null.
- The `project_id` field is populated when the action involves a project assignment (e.g., relocating an item to a project, or a project lifecycle event).
- The `metadata` jsonb field stores additional context when needed (e.g., on item edit, it stores the changed field names and old values).
- Log entries for deleted items remain in the log. The entity_id still references the deleted item's UUID for traceability.
- On the dashboard, tapping a log entry navigates to the item detail screen (or shows a "deleted item" notice if the item no longer exists).
- Activity log queries are indexed on `(organisation_id, created_at DESC)` and `(entity_id, created_at DESC)` for performant retrieval.
- No pagination is required in v1 for item detail (items typically have fewer than 100 entries). Dashboard log uses cursor-based pagination.
