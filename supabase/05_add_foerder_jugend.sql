BEGIN;
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_team_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_team_check CHECK (team IN ('G','F','E','D','FOERDER'));
ALTER TABLE public.slots DROP CONSTRAINT IF EXISTS slots_assigned_team_check;
ALTER TABLE public.slots ADD CONSTRAINT slots_assigned_team_check CHECK (assigned_team IN ('G','F','E','D','FOERDER'));
ALTER TABLE public.applications DROP CONSTRAINT IF EXISTS applications_team_check;
ALTER TABLE public.applications ADD CONSTRAINT applications_team_check CHECK (team IN ('G','F','E','D','FOERDER'));
COMMIT;