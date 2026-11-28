BEGIN;
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_team_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_team_check CHECK (team IN ('G','F','E','D','FOERDER'));
ALTER TABLE public.applications DROP CONSTRAINT IF EXISTS applications_team_check;
ALTER TABLE public.applications ADD CONSTRAINT applications_team_check CHECK (team IN ('G','F','E','D','FOERDER'));
ALTER TABLE public.slots DROP CONSTRAINT IF EXISTS slots_assigned_team_check;
ALTER TABLE public.slots ADD CONSTRAINT slots_assigned_team_check CHECK (assigned_team IN ('G','F','E','D','FOERDER','U40'));
DROP POLICY IF EXISTS apps_admin_insert ON public.applications;
CREATE POLICY apps_admin_insert ON public.applications FOR INSERT TO authenticated
WITH CHECK ((SELECT public.is_admin()) AND EXISTS (
 SELECT 1 FROM public.slots s WHERE s.id = slot_id
 AND (s.assigned_team IS NULL OR s.assigned_team = applications.team)
));
UPDATE public.slots s SET assigned_team = 'U40'
WHERE s.hall = 'gross' AND EXTRACT(ISODOW FROM s.day) = 4
AND s.day >= DATE '2026-11-28'
AND s.start_time >= TIME '19:00' AND s.start_time < TIME '22:00'
AND s.assigned_team IS NULL
AND NOT EXISTS (SELECT 1 FROM public.applications a WHERE a.slot_id = s.id);
COMMIT;
SELECT day, start_time, assigned_team FROM public.slots
WHERE hall = 'gross' AND EXTRACT(ISODOW FROM day) = 4
AND day >= DATE '2026-11-28' AND start_time >= TIME '19:00' AND start_time < TIME '22:00'
ORDER BY day, start_time;