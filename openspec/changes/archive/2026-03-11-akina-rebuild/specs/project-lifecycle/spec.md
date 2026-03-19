# Project Lifecycle

## Overview

Projects represent job sites or work contexts to which items are assigned. Projects have a simple lifecycle (active, completed, archived) and drive the "Assign to Project" relocation option. Only admins can create, edit, complete, or archive projects.

## Requirements

1. Each project belongs to exactly one organisation.
2. Projects have the following fields: name, location (optional text), status, organisation_id, created_at, updated_at.
3. `status` is an enum with values: `active`, `completed`, `archived`.
4. Only admins can create, edit, complete, and archive projects. Members have read-only access.
5. The project list screen shows all projects grouped or filterable by status, with item counts per project.
6. The project detail screen shows project info and a list of all items currently assigned to the project.
7. Items can be assigned to or removed from a project via the relocation flow (not directly on the project detail screen).
8. Only active projects appear as options when assigning an item to a project during relocation.

### Completion Flow

9. When an admin marks a project as `completed`, a prompt asks what to do with the assigned items: "Return all to storage", "Leave items as-is", or "Decide individually".
10. "Return all to storage" sets every assigned item's status to `storage` and clears `project_id`, with individual activity log entries per item.
11. "Decide individually" opens a list of assigned items where the admin can choose per item: return to storage, assign to another active project, or mark missing.
12. After the item decisions are made (or skipped), the project status is set to `completed`.

### Archival and Deletion

13. Completed projects can be archived. Archived projects are hidden from the default list view but accessible via a filter.
14. Deleting a project is allowed only if it has zero assigned items. If items are still assigned, the admin must relocate them first.
15. Deleting a project is a hard delete with a confirmation dialog.

## Data Model

- **projects**: `id` (UUID PK), `name` (text, not null), `location` (text, nullable), `status` (enum, default `active`), `organisation_id` (UUID FK -> organisations, not null), `created_at` (timestamptz), `updated_at` (timestamptz).

## Behavior

- Creating a project with a duplicate name in the same org is allowed (names are not unique).
- When a project is completed or archived, any scan that would assign an item to it treats it as unavailable (same as if it does not exist in the active project list).
- The project detail screen updates in real time via Supabase Realtime subscriptions on the items table filtered by `project_id`.
- `updated_at` is set on every write operation.
