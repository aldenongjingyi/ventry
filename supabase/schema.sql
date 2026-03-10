-- TrackGear Pro - Supabase Schema
-- Run this in the Supabase SQL Editor

-- ============================================================
-- HELPER FUNCTION: get current user's company_id
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_my_company_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT company_id FROM public.profiles WHERE id = auth.uid();
$$;

-- ============================================================
-- TABLES
-- ============================================================

-- Companies (multi-tenant root)
CREATE TABLE public.companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Profiles (linked to auth.users)
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Categories
CREATE TABLE public.categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  icon text NOT NULL DEFAULT 'category',
  color text NOT NULL DEFAULT '#6B7280',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Equipment
CREATE TABLE public.equipment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  category_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  barcode text,
  serial_number text,
  status text NOT NULL DEFAULT 'in-storage'
    CHECK (status IN ('in-storage', 'checked-out', 'maintenance', 'retired')),
  condition text NOT NULL DEFAULT 'good'
    CHECK (condition IN ('excellent', 'good', 'fair', 'poor', 'damaged')),
  image_url text,
  notes text,
  purchase_date date,
  purchase_price numeric(10,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_equipment_company ON public.equipment(company_id);
CREATE INDEX idx_equipment_barcode ON public.equipment(barcode);
CREATE INDEX idx_equipment_status ON public.equipment(status);

-- Projects
CREATE TABLE public.projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  client_name text,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('planning', 'active', 'completed', 'archived')),
  start_date date,
  end_date date,
  location text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Equipment Assignments (check-out/check-in tracking)
CREATE TABLE public.equipment_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  equipment_id uuid NOT NULL REFERENCES public.equipment(id) ON DELETE CASCADE,
  project_id uuid REFERENCES public.projects(id) ON DELETE SET NULL,
  checked_out_by uuid NOT NULL REFERENCES public.profiles(id),
  checked_out_at timestamptz NOT NULL DEFAULT now(),
  checked_in_at timestamptz,  -- NULL means still checked out
  checked_in_by uuid REFERENCES public.profiles(id),
  condition_on_return text CHECK (condition_on_return IN ('excellent', 'good', 'fair', 'poor', 'damaged')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_assignments_equipment ON public.equipment_assignments(equipment_id);
CREATE INDEX idx_assignments_active ON public.equipment_assignments(equipment_id) WHERE checked_in_at IS NULL;

-- Activity Log
CREATE TABLE public.activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  details jsonb DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_activity_company ON public.activity_log(company_id, created_at DESC);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;

-- Companies: users can read their own company
CREATE POLICY "Users can view own company" ON public.companies
  FOR SELECT USING (id = public.get_my_company_id());

CREATE POLICY "Users can insert company" ON public.companies
  FOR INSERT WITH CHECK (true);

-- Profiles: users can see teammates
CREATE POLICY "Users can view company profiles" ON public.profiles
  FOR SELECT USING (company_id = public.get_my_company_id());

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (id = auth.uid());

-- Categories: company-scoped
CREATE POLICY "Company members can view categories" ON public.categories
  FOR SELECT USING (company_id = public.get_my_company_id());

CREATE POLICY "Company members can insert categories" ON public.categories
  FOR INSERT WITH CHECK (company_id = public.get_my_company_id());

-- Equipment: company-scoped
CREATE POLICY "Company members can view equipment" ON public.equipment
  FOR SELECT USING (company_id = public.get_my_company_id());

CREATE POLICY "Company members can insert equipment" ON public.equipment
  FOR INSERT WITH CHECK (company_id = public.get_my_company_id());

CREATE POLICY "Company members can update equipment" ON public.equipment
  FOR UPDATE USING (company_id = public.get_my_company_id());

-- Projects: company-scoped
CREATE POLICY "Company members can view projects" ON public.projects
  FOR SELECT USING (company_id = public.get_my_company_id());

CREATE POLICY "Company members can insert projects" ON public.projects
  FOR INSERT WITH CHECK (company_id = public.get_my_company_id());

CREATE POLICY "Company members can update projects" ON public.projects
  FOR UPDATE USING (company_id = public.get_my_company_id());

-- Equipment Assignments: company-scoped
CREATE POLICY "Company members can view assignments" ON public.equipment_assignments
  FOR SELECT USING (company_id = public.get_my_company_id());

CREATE POLICY "Company members can insert assignments" ON public.equipment_assignments
  FOR INSERT WITH CHECK (company_id = public.get_my_company_id());

CREATE POLICY "Company members can update assignments" ON public.equipment_assignments
  FOR UPDATE USING (company_id = public.get_my_company_id());

-- Activity Log: company-scoped (read only for members)
CREATE POLICY "Company members can view activity" ON public.activity_log
  FOR SELECT USING (company_id = public.get_my_company_id());

CREATE POLICY "Company members can insert activity" ON public.activity_log
  FOR INSERT WITH CHECK (company_id = public.get_my_company_id());

-- ============================================================
-- RPC FUNCTIONS
-- ============================================================

-- Atomic checkout: creates assignments + updates equipment status + logs activity
CREATE OR REPLACE FUNCTION public.perform_checkout(
  p_equipment_ids uuid[],
  p_project_id uuid,
  p_checked_out_by uuid,
  p_notes text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  eq_id uuid;
  v_company_id uuid;
BEGIN
  v_company_id := public.get_my_company_id();

  FOREACH eq_id IN ARRAY p_equipment_ids
  LOOP
    -- Update equipment status
    UPDATE public.equipment
    SET status = 'checked-out', updated_at = now()
    WHERE id = eq_id AND company_id = v_company_id;

    -- Create assignment record
    INSERT INTO public.equipment_assignments (
      company_id, equipment_id, project_id, checked_out_by, notes
    ) VALUES (
      v_company_id, eq_id, p_project_id, p_checked_out_by, p_notes
    );

    -- Log activity
    INSERT INTO public.activity_log (
      company_id, user_id, action, entity_type, entity_id, details
    ) VALUES (
      v_company_id,
      auth.uid(),
      'checkout',
      'equipment',
      eq_id,
      jsonb_build_object(
        'project_id', p_project_id,
        'checked_out_by', p_checked_out_by
      )
    );
  END LOOP;
END;
$$;

-- Atomic checkin: updates assignments + equipment status + logs activity
CREATE OR REPLACE FUNCTION public.perform_checkin(
  p_assignment_ids uuid[],
  p_conditions jsonb DEFAULT '{}' -- { "assignment_id": "condition" }
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  a_id uuid;
  v_company_id uuid;
  v_equipment_id uuid;
  v_condition text;
BEGIN
  v_company_id := public.get_my_company_id();

  FOREACH a_id IN ARRAY p_assignment_ids
  LOOP
    -- Get the condition for this assignment
    v_condition := COALESCE(p_conditions->>a_id::text, 'good');

    -- Get equipment_id from assignment
    SELECT equipment_id INTO v_equipment_id
    FROM public.equipment_assignments
    WHERE id = a_id AND company_id = v_company_id;

    -- Update assignment
    UPDATE public.equipment_assignments
    SET checked_in_at = now(),
        checked_in_by = auth.uid(),
        condition_on_return = v_condition
    WHERE id = a_id AND company_id = v_company_id;

    -- Update equipment status back to in-storage
    UPDATE public.equipment
    SET status = 'in-storage',
        condition = v_condition,
        updated_at = now()
    WHERE id = v_equipment_id AND company_id = v_company_id;

    -- Log activity
    INSERT INTO public.activity_log (
      company_id, user_id, action, entity_type, entity_id, details
    ) VALUES (
      v_company_id,
      auth.uid(),
      'checkin',
      'equipment',
      v_equipment_id,
      jsonb_build_object(
        'condition', v_condition,
        'assignment_id', a_id
      )
    );
  END LOOP;
END;
$$;

-- ============================================================
-- TRIGGER: Auto-create profile on signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only auto-create profile if company_id is provided in metadata
  IF NEW.raw_user_meta_data->>'company_id' IS NOT NULL THEN
    INSERT INTO public.profiles (id, company_id, full_name, role)
    VALUES (
      NEW.id,
      (NEW.raw_user_meta_data->>'company_id')::uuid,
      COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
      COALESCE(NEW.raw_user_meta_data->>'role', 'member')
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- REALTIME: Enable for live updates
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.equipment;
ALTER PUBLICATION supabase_realtime ADD TABLE public.equipment_assignments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.activity_log;
