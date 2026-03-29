-- Migration 002: Item Groups, Sequential IDs, Label Colors
-- Run this in the Supabase SQL Editor AFTER schema.sql

-- ============================================================
-- NEW TABLE: Item Groups (user-defined sorting categories)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.item_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organisation_id, name)
);

CREATE INDEX idx_item_groups_org ON public.item_groups(organisation_id);

-- RLS
ALTER TABLE public.item_groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view item groups" ON public.item_groups
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Members can insert item groups" ON public.item_groups
  FOR INSERT WITH CHECK (public.is_org_member(organisation_id));

CREATE POLICY "Members can update item groups" ON public.item_groups
  FOR UPDATE USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can delete item groups" ON public.item_groups
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- ============================================================
-- ALTER ITEMS: Add sequential_id, label_color, item_group_id
-- ============================================================
ALTER TABLE public.items
  ADD COLUMN IF NOT EXISTS sequential_id int,
  ADD COLUMN IF NOT EXISTS label_color text,
  ADD COLUMN IF NOT EXISTS item_group_id uuid REFERENCES public.item_groups(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_items_group ON public.items(item_group_id);
CREATE INDEX IF NOT EXISTS idx_items_name_org ON public.items(organisation_id, name);

-- ============================================================
-- RPC: Get next sequential ID for a given item name in an org
-- ============================================================
DROP FUNCTION IF EXISTS public.next_sequential_id(uuid, text);

CREATE OR REPLACE FUNCTION public.next_sequential_id(
  p_org_id uuid,
  p_name text
)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_next int;
BEGIN
  SELECT COALESCE(MAX(sequential_id), 0) + 1
  INTO v_next
  FROM public.items
  WHERE organisation_id = p_org_id
    AND lower(trim(name)) = lower(trim(p_name));

  RETURN v_next;
END;
$$;

-- ============================================================
-- RPC: Batch create items with auto sequential IDs
-- ============================================================
DROP FUNCTION IF EXISTS public.create_items_batch(uuid, text, int, text, uuid, text);

CREATE OR REPLACE FUNCTION public.create_items_batch(
  p_org_id uuid,
  p_name text,
  p_quantity int,
  p_label_color text DEFAULT NULL,
  p_item_group_id uuid DEFAULT NULL,
  p_notes text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_next_seq int;
  v_next_item_num int;
  v_created_ids jsonb := '[]'::jsonb;
  v_id uuid;
  i int;
BEGIN
  IF NOT public.is_org_member(p_org_id) THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  IF p_quantity < 1 OR p_quantity > 100 THEN
    RAISE EXCEPTION 'Quantity must be between 1 and 100';
  END IF;

  -- Get starting sequential ID for this name
  v_next_seq := public.next_sequential_id(p_org_id, p_name);

  -- Get starting item number for the org
  SELECT COALESCE(MAX(item_number), 0) + 1
  INTO v_next_item_num
  FROM public.items
  WHERE organisation_id = p_org_id;

  FOR i IN 0..(p_quantity - 1) LOOP
    INSERT INTO public.items (
      organisation_id, name, item_number, sequential_id,
      label_color, item_group_id, notes
    ) VALUES (
      p_org_id, p_name, v_next_item_num + i, v_next_seq + i,
      p_label_color, p_item_group_id, p_notes
    )
    RETURNING id INTO v_id;

    v_created_ids := v_created_ids || to_jsonb(v_id::text);
  END LOOP;

  RETURN v_created_ids;
END;
$$;

-- ============================================================
-- PERMISSIONS
-- ============================================================
GRANT ALL ON public.item_groups TO authenticated;
GRANT EXECUTE ON FUNCTION public.next_sequential_id(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_items_batch(uuid, text, int, text, uuid, text) TO authenticated;

NOTIFY pgrst, 'reload schema';
