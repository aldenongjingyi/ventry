-- Migration 003: Item Visuals (icon or photo per item name per org)
-- Run this in the Supabase SQL Editor

-- ============================================================
-- NEW TABLE: Item Visuals
-- ============================================================
CREATE TABLE IF NOT EXISTS public.item_visuals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  item_name text NOT NULL,
  visual_type text NOT NULL CHECK (visual_type IN ('icon', 'photo')),
  visual_value text NOT NULL,  -- icon name or storage path
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organisation_id, item_name)
);

CREATE INDEX IF NOT EXISTS idx_item_visuals_org ON public.item_visuals(organisation_id);

-- RLS
ALTER TABLE public.item_visuals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view item visuals" ON public.item_visuals
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Members can insert item visuals" ON public.item_visuals
  FOR INSERT WITH CHECK (public.is_org_member(organisation_id));

CREATE POLICY "Members can update item visuals" ON public.item_visuals
  FOR UPDATE USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can delete item visuals" ON public.item_visuals
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- ============================================================
-- STORAGE BUCKET: item-photos
-- ============================================================
-- Run this separately in the Supabase SQL Editor:
--
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('item-photos', 'item-photos', true);
--
-- CREATE POLICY "Org members can upload item photos"
-- ON storage.objects FOR INSERT
-- WITH CHECK (
--   bucket_id = 'item-photos'
--   AND auth.role() = 'authenticated'
-- );
--
-- CREATE POLICY "Anyone can view item photos"
-- ON storage.objects FOR SELECT
-- USING (bucket_id = 'item-photos');
--
-- CREATE POLICY "Org members can delete item photos"
-- ON storage.objects FOR DELETE
-- USING (
--   bucket_id = 'item-photos'
--   AND auth.role() = 'authenticated'
-- );

-- ============================================================
-- PERMISSIONS
-- ============================================================
GRANT ALL ON public.item_visuals TO authenticated;

NOTIFY pgrst, 'reload schema';
