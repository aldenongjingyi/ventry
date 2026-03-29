-- Migration 004: Project icons, descriptions, dates
-- Run this in the Supabase SQL Editor

ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS icon text,
  ADD COLUMN IF NOT EXISTS description text,
  ADD COLUMN IF NOT EXISTS start_date date,
  ADD COLUMN IF NOT EXISTS due_date date;

NOTIFY pgrst, 'reload schema';
