-- Ventry - Supabase Schema
-- Run this in the Supabase SQL Editor
-- WARNING: This drops all old tables. Back up data first.

-- ============================================================
-- DROP OLD SCHEMA (if migrating from previous versions)
-- ============================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.perform_checkout(uuid[], uuid, uuid, text) CASCADE;
DROP FUNCTION IF EXISTS public.perform_checkin(uuid[], jsonb) CASCADE;
DROP FUNCTION IF EXISTS public.perform_onboarding(text, text) CASCADE;
DROP FUNCTION IF EXISTS public.get_my_company_id() CASCADE;
DROP FUNCTION IF EXISTS public.get_active_org_id() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.is_org_member(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.is_org_admin(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.next_item_number(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.perform_relocation(uuid, text, uuid) CASCADE;
DROP FUNCTION IF EXISTS public.complete_project(uuid, text) CASCADE;
DROP FUNCTION IF EXISTS public.accept_invite(text) CASCADE;
DROP FUNCTION IF EXISTS public.accept_invite(text, text) CASCADE;
DROP FUNCTION IF EXISTS public.create_invite(uuid, int, int) CASCADE;
DROP FUNCTION IF EXISTS public.check_org_limit(uuid, text) CASCADE;
DROP FUNCTION IF EXISTS public.get_org_usage(uuid) CASCADE;

DROP TABLE IF EXISTS public.activity_log CASCADE;
DROP TABLE IF EXISTS public.org_invites CASCADE;
DROP TABLE IF EXISTS public.items CASCADE;
DROP TABLE IF EXISTS public.projects CASCADE;
DROP TABLE IF EXISTS public.org_memberships CASCADE;
DROP TABLE IF EXISTS public.organisations CASCADE;
DROP TABLE IF EXISTS public.equipment_assignments CASCADE;
DROP TABLE IF EXISTS public.equipment CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.companies CASCADE;

-- ============================================================
-- TABLES
-- ============================================================

-- Organisations (multi-tenant root, users can belong to multiple)
CREATE TABLE public.organisations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  plan text NOT NULL DEFAULT 'free'
    CHECK (plan IN ('free', 'pro')),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Organisation Memberships (many-to-many: users <-> organisations)
CREATE TABLE public.org_memberships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  full_name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, organisation_id)
);

CREATE INDEX idx_org_memberships_user ON public.org_memberships(user_id);
CREATE INDEX idx_org_memberships_org ON public.org_memberships(organisation_id);

-- Organisation Invites (invite codes / links for joining)
CREATE TABLE public.org_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  code text NOT NULL UNIQUE,
  created_by uuid NOT NULL REFERENCES auth.users(id),
  max_uses int,                          -- NULL = unlimited
  use_count int NOT NULL DEFAULT 0,
  expires_at timestamptz,                -- NULL = never expires
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_org_invites_code ON public.org_invites(code);
CREATE INDEX idx_org_invites_org ON public.org_invites(organisation_id);

-- Projects (must be defined before items due to FK)
CREATE TABLE public.projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  name text NOT NULL,
  location text,
  icon text,
  description text,
  start_date date,
  due_date date,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'completed', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_projects_org ON public.projects(organisation_id);
CREATE INDEX idx_projects_status ON public.projects(status);

-- Item Visuals (one icon or photo per item name per org)
CREATE TABLE public.item_visuals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  item_name text NOT NULL,
  visual_type text NOT NULL CHECK (visual_type IN ('icon', 'photo')),
  visual_value text NOT NULL,  -- icon name or storage path
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organisation_id, item_name)
);

CREATE INDEX idx_item_visuals_org ON public.item_visuals(organisation_id);

-- Item Groups (user-defined sorting categories)
CREATE TABLE public.item_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organisation_id, name)
);

CREATE INDEX idx_item_groups_org ON public.item_groups(organisation_id);

-- Items (equipment / gear tracked by the org)
CREATE TABLE public.items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  name text NOT NULL,
  item_number int NOT NULL,
  sequential_id int,
  status text NOT NULL DEFAULT 'storage'
    CHECK (status IN ('storage', 'in_project', 'missing', 'under_repair', 'retired')),
  project_id uuid REFERENCES public.projects(id) ON DELETE SET NULL,
  qr_code uuid NOT NULL DEFAULT gen_random_uuid(),
  label_color text,
  item_group_id uuid REFERENCES public.item_groups(id) ON DELETE SET NULL,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organisation_id, item_number),
  UNIQUE(qr_code)
);

CREATE INDEX idx_items_org ON public.items(organisation_id);
CREATE INDEX idx_items_status ON public.items(status);
CREATE INDEX idx_items_qr ON public.items(qr_code);
CREATE INDEX idx_items_project ON public.items(project_id);
CREATE INDEX idx_items_group ON public.items(item_group_id);
CREATE INDEX idx_items_name_org ON public.items(organisation_id, name);

-- Activity Log (tracks all item/project changes)
CREATE TABLE public.activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organisation_id uuid NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  from_status text,
  to_status text,
  project_id uuid,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_activity_org ON public.activity_log(organisation_id, created_at DESC);
CREATE INDEX idx_activity_entity ON public.activity_log(entity_id);

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Get the user's active organisation ID (first org they belong to)
CREATE OR REPLACE FUNCTION public.get_active_org_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT organisation_id
  FROM public.org_memberships
  WHERE user_id = auth.uid()
  LIMIT 1;
$$;

-- Get the user's role in a specific organisation
CREATE OR REPLACE FUNCTION public.get_user_role(p_org_id uuid)
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT role
  FROM public.org_memberships
  WHERE user_id = auth.uid()
    AND organisation_id = p_org_id;
$$;

-- Check if user is a member of a specific organisation
CREATE OR REPLACE FUNCTION public.is_org_member(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.org_memberships
    WHERE user_id = auth.uid()
      AND organisation_id = p_org_id
  );
$$;

-- Check if user is admin of a specific organisation
CREATE OR REPLACE FUNCTION public.is_org_admin(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.org_memberships
    WHERE user_id = auth.uid()
      AND organisation_id = p_org_id
      AND role = 'admin'
  );
$$;

-- ============================================================
-- PLAN LIMIT CHECKS
-- ============================================================

-- Check if an org has hit a limit for a given resource type
-- Returns TRUE if the action is ALLOWED, FALSE if limit reached
CREATE OR REPLACE FUNCTION public.check_org_limit(
  p_org_id uuid,
  p_resource text  -- 'members', 'items', 'projects'
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_plan text;
  v_count int;
  v_limit int;
BEGIN
  SELECT plan INTO v_plan FROM public.organisations WHERE id = p_org_id;

  -- Get current count
  IF p_resource = 'members' THEN
    SELECT count(*) INTO v_count FROM public.org_memberships WHERE organisation_id = p_org_id;
  ELSIF p_resource = 'items' THEN
    SELECT count(*) INTO v_count FROM public.items WHERE organisation_id = p_org_id;
  ELSIF p_resource = 'projects' THEN
    SELECT count(*) INTO v_count FROM public.projects WHERE organisation_id = p_org_id;
  ELSE
    RETURN true;
  END IF;

  -- Determine limit based on plan (free has limits, pro is unlimited)
  IF v_plan = 'free' THEN
    v_limit := CASE p_resource
      WHEN 'members' THEN 5
      WHEN 'items' THEN 50
      WHEN 'projects' THEN 3
      ELSE NULL
    END;
  ELSE
    v_limit := NULL;  -- pro = unlimited
  END IF;

  -- NULL limit means unlimited
  IF v_limit IS NULL THEN
    RETURN true;
  END IF;

  RETURN v_count < v_limit;
END;
$$;

-- Get org plan limits and current usage (for display in app)
CREATE OR REPLACE FUNCTION public.get_org_usage(p_org_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_plan text;
  v_members int;
  v_items int;
  v_projects int;
BEGIN
  IF NOT public.is_org_member(p_org_id) THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  SELECT plan INTO v_plan FROM public.organisations WHERE id = p_org_id;
  SELECT count(*) INTO v_members FROM public.org_memberships WHERE organisation_id = p_org_id;
  SELECT count(*) INTO v_items FROM public.items WHERE organisation_id = p_org_id;
  SELECT count(*) INTO v_projects FROM public.projects WHERE organisation_id = p_org_id;

  RETURN jsonb_build_object(
    'plan', v_plan,
    'members', jsonb_build_object(
      'current', v_members,
      'limit', CASE v_plan WHEN 'free' THEN 5 ELSE null END
    ),
    'items', jsonb_build_object(
      'current', v_items,
      'limit', CASE v_plan WHEN 'free' THEN 50 ELSE null END
    ),
    'projects', jsonb_build_object(
      'current', v_projects,
      'limit', CASE v_plan WHEN 'free' THEN 3 ELSE null END
    ),
    'features', jsonb_build_object(
      'activity_log_visible', v_plan = 'pro',
      'csv_export', v_plan = 'pro',
      'multi_org', v_plan = 'pro',
      'industrial_scanner', v_plan = 'pro'
    )
  );
END;
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.organisations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.item_visuals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.item_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;

-- Organisations: users can see orgs they belong to
CREATE POLICY "Members can view own orgs" ON public.organisations
  FOR SELECT USING (public.is_org_member(id));

CREATE POLICY "Anyone can create org" ON public.organisations
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can update org" ON public.organisations
  FOR UPDATE USING (public.is_org_admin(id));

-- Org Memberships: users can see memberships for their orgs
CREATE POLICY "Members can view org memberships" ON public.org_memberships
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can insert memberships" ON public.org_memberships
  FOR INSERT WITH CHECK (
    user_id = auth.uid() OR public.is_org_admin(organisation_id)
  );

CREATE POLICY "Admins can update memberships" ON public.org_memberships
  FOR UPDATE USING (public.is_org_admin(organisation_id));

CREATE POLICY "Admins can delete memberships" ON public.org_memberships
  FOR DELETE USING (
    public.is_org_admin(organisation_id) OR user_id = auth.uid()
  );

-- Org Invites: admins manage, anyone can read by code (via RPC)
CREATE POLICY "Admins can view org invites" ON public.org_invites
  FOR SELECT USING (public.is_org_admin(organisation_id));

CREATE POLICY "Admins can create invites" ON public.org_invites
  FOR INSERT WITH CHECK (public.is_org_admin(organisation_id));

CREATE POLICY "Admins can update invites" ON public.org_invites
  FOR UPDATE USING (public.is_org_admin(organisation_id));

CREATE POLICY "Admins can delete invites" ON public.org_invites
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- Item Visuals: org-scoped
CREATE POLICY "Members can view item visuals" ON public.item_visuals
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Members can insert item visuals" ON public.item_visuals
  FOR INSERT WITH CHECK (public.is_org_member(organisation_id));

CREATE POLICY "Members can update item visuals" ON public.item_visuals
  FOR UPDATE USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can delete item visuals" ON public.item_visuals
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- Item Groups: org-scoped
CREATE POLICY "Members can view item groups" ON public.item_groups
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Members can insert item groups" ON public.item_groups
  FOR INSERT WITH CHECK (public.is_org_member(organisation_id));

CREATE POLICY "Members can update item groups" ON public.item_groups
  FOR UPDATE USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can delete item groups" ON public.item_groups
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- Items: org-scoped, insert checks plan limit
CREATE POLICY "Members can view items" ON public.items
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can insert items" ON public.items
  FOR INSERT WITH CHECK (
    public.is_org_admin(organisation_id)
    AND public.check_org_limit(organisation_id, 'items')
  );

CREATE POLICY "Members can update items" ON public.items
  FOR UPDATE USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can delete items" ON public.items
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- Projects: org-scoped, insert checks plan limit
CREATE POLICY "Members can view projects" ON public.projects
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Admins can insert projects" ON public.projects
  FOR INSERT WITH CHECK (
    public.is_org_admin(organisation_id)
    AND public.check_org_limit(organisation_id, 'projects')
  );

CREATE POLICY "Admins can update projects" ON public.projects
  FOR UPDATE USING (public.is_org_admin(organisation_id));

CREATE POLICY "Admins can delete projects" ON public.projects
  FOR DELETE USING (public.is_org_admin(organisation_id));

-- Activity Log: org-scoped read, member insert
CREATE POLICY "Members can view activity" ON public.activity_log
  FOR SELECT USING (public.is_org_member(organisation_id));

CREATE POLICY "Members can insert activity" ON public.activity_log
  FOR INSERT WITH CHECK (public.is_org_member(organisation_id));

-- ============================================================
-- RPC FUNCTIONS
-- ============================================================

-- Get next item number for an organisation (auto-increment per org)
CREATE OR REPLACE FUNCTION public.next_item_number(p_org_id uuid)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_next int;
BEGIN
  SELECT COALESCE(MAX(item_number), 0) + 1
  INTO v_next
  FROM public.items
  WHERE organisation_id = p_org_id;

  RETURN v_next;
END;
$$;

-- Get next sequential ID for a given item name in an org
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

-- Batch create items with auto sequential IDs
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

  v_next_seq := public.next_sequential_id(p_org_id, p_name);

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

-- Atomic onboarding: creates organisation + membership (starts on free plan)
CREATE OR REPLACE FUNCTION public.perform_onboarding(
  p_org_name text,
  p_full_name text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_org_id uuid;
BEGIN
  -- Create organisation on free plan
  INSERT INTO public.organisations (name, plan)
  VALUES (p_org_name, 'free')
  RETURNING id INTO v_org_id;

  -- Create admin membership for the creator
  INSERT INTO public.org_memberships (user_id, organisation_id, role, full_name)
  VALUES (auth.uid(), v_org_id, 'admin', p_full_name);

  RETURN v_org_id;
END;
$$;

-- Generate an invite code for an org (admin only)
CREATE OR REPLACE FUNCTION public.create_invite(
  p_org_id uuid,
  p_max_uses int DEFAULT NULL,
  p_expires_in_hours int DEFAULT NULL
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_code text;
  v_expires_at timestamptz;
BEGIN
  IF NOT public.is_org_admin(p_org_id) THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;

  -- Generate a short, readable invite code (8 chars alphanumeric)
  v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));

  -- Calculate expiry if provided
  IF p_expires_in_hours IS NOT NULL THEN
    v_expires_at := now() + (p_expires_in_hours || ' hours')::interval;
  END IF;

  INSERT INTO public.org_invites (organisation_id, code, created_by, max_uses, expires_at)
  VALUES (p_org_id, v_code, auth.uid(), p_max_uses, v_expires_at);

  RETURN v_code;
END;
$$;

-- Accept an invite code and join the org
CREATE OR REPLACE FUNCTION public.accept_invite(
  p_code text,
  p_full_name text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invite record;
  v_org_id uuid;
BEGIN
  -- Look up the invite
  SELECT * INTO v_invite
  FROM public.org_invites
  WHERE code = upper(trim(p_code))
    AND is_active = true;

  IF v_invite IS NULL THEN
    RAISE EXCEPTION 'Invalid invite code';
  END IF;

  v_org_id := v_invite.organisation_id;

  -- Check expiry
  IF v_invite.expires_at IS NOT NULL AND v_invite.expires_at < now() THEN
    RAISE EXCEPTION 'Invite code has expired';
  END IF;

  -- Check max uses
  IF v_invite.max_uses IS NOT NULL AND v_invite.use_count >= v_invite.max_uses THEN
    RAISE EXCEPTION 'Invite code has reached maximum uses';
  END IF;

  -- Check org member limit
  IF NOT public.check_org_limit(v_org_id, 'members') THEN
    RAISE EXCEPTION 'Organisation has reached its member limit. Ask the admin to upgrade the plan.';
  END IF;

  -- Check if already a member
  IF public.is_org_member(v_org_id) THEN
    RAISE EXCEPTION 'You are already a member of this organisation';
  END IF;

  -- Create membership (always as member, not admin)
  INSERT INTO public.org_memberships (user_id, organisation_id, role, full_name)
  VALUES (auth.uid(), v_org_id, 'member', p_full_name);

  -- Increment use count
  UPDATE public.org_invites
  SET use_count = use_count + 1
  WHERE id = v_invite.id;

  RETURN v_org_id;
END;
$$;

-- Atomic item relocation: updates status + logs activity
CREATE OR REPLACE FUNCTION public.perform_relocation(
  p_item_id uuid,
  p_target_status text,
  p_project_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_org_id uuid;
  v_from_status text;
  v_item_name text;
BEGIN
  -- Get current item info
  SELECT organisation_id, status, name
  INTO v_org_id, v_from_status, v_item_name
  FROM public.items
  WHERE id = p_item_id;

  IF v_org_id IS NULL THEN
    RAISE EXCEPTION 'Item not found';
  END IF;

  IF NOT public.is_org_member(v_org_id) THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  -- Don't update if already in target state
  IF v_from_status = p_target_status AND (
    p_target_status != 'in_project' OR
    (SELECT project_id FROM public.items WHERE id = p_item_id) = p_project_id
  ) THEN
    RETURN;
  END IF;

  -- Update item status
  UPDATE public.items
  SET status = p_target_status,
      project_id = CASE
        WHEN p_target_status = 'in_project' THEN p_project_id
        ELSE NULL
      END,
      updated_at = now()
  WHERE id = p_item_id;

  -- Log activity
  INSERT INTO public.activity_log (
    organisation_id, user_id, action, entity_type, entity_id,
    from_status, to_status, project_id, metadata
  ) VALUES (
    v_org_id,
    auth.uid(),
    'relocate',
    'item',
    p_item_id,
    v_from_status,
    p_target_status,
    p_project_id,
    jsonb_build_object('item_name', v_item_name)
  );
END;
$$;

-- Complete project: handle items based on chosen action
CREATE OR REPLACE FUNCTION public.complete_project(
  p_project_id uuid,
  p_action text  -- 'return_to_storage', 'leave', 'retire'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_org_id uuid;
  v_item record;
BEGIN
  SELECT organisation_id INTO v_org_id
  FROM public.projects
  WHERE id = p_project_id;

  IF v_org_id IS NULL THEN
    RAISE EXCEPTION 'Project not found';
  END IF;

  IF NOT public.is_org_admin(v_org_id) THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;

  IF p_action = 'return_to_storage' THEN
    FOR v_item IN
      SELECT id, name FROM public.items
      WHERE project_id = p_project_id AND status = 'in_project'
    LOOP
      UPDATE public.items
      SET status = 'storage', project_id = NULL, updated_at = now()
      WHERE id = v_item.id;

      INSERT INTO public.activity_log (
        organisation_id, user_id, action, entity_type, entity_id,
        from_status, to_status, project_id, metadata
      ) VALUES (
        v_org_id, auth.uid(), 'relocate', 'item', v_item.id,
        'in_project', 'storage', p_project_id,
        jsonb_build_object('item_name', v_item.name, 'reason', 'project_completed')
      );
    END LOOP;
  ELSIF p_action = 'retire' THEN
    FOR v_item IN
      SELECT id, name FROM public.items
      WHERE project_id = p_project_id AND status = 'in_project'
    LOOP
      UPDATE public.items
      SET status = 'retired', project_id = NULL, updated_at = now()
      WHERE id = v_item.id;

      INSERT INTO public.activity_log (
        organisation_id, user_id, action, entity_type, entity_id,
        from_status, to_status, project_id, metadata
      ) VALUES (
        v_org_id, auth.uid(), 'relocate', 'item', v_item.id,
        'in_project', 'retired', p_project_id,
        jsonb_build_object('item_name', v_item.name, 'reason', 'project_completed')
      );
    END LOOP;
  END IF;

  UPDATE public.projects
  SET status = 'completed'
  WHERE id = p_project_id;

  INSERT INTO public.activity_log (
    organisation_id, user_id, action, entity_type, entity_id,
    metadata
  ) VALUES (
    v_org_id, auth.uid(), 'complete_project', 'project', p_project_id,
    jsonb_build_object('action', p_action)
  );
END;
$$;

-- ============================================================
-- TRIGGER: Handle new user signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- No auto-profile creation. Users go through onboarding to create/join org.
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- REALTIME: Enable for live updates
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.activity_log;
ALTER PUBLICATION supabase_realtime ADD TABLE public.projects;

-- ============================================================
-- PERMISSIONS + CACHE RELOAD
-- ============================================================
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Force PostgREST to pick up the new schema
NOTIFY pgrst, 'reload schema';
