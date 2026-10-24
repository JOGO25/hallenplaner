-- Soccerhalle für bestehende Datenbank ergänzen
-- Saison: 19.10.2026 bis 31.03.2027
-- Montags: 16:00, 16:30 und 17:00 Uhr

ALTER TABLE public.slots
  DROP CONSTRAINT IF EXISTS slots_hall_check;

ALTER TABLE public.slots
  ADD CONSTRAINT slots_hall_check
  CHECK (hall IN ('gross', 'klein', 'willi', 'soccer'));

INSERT INTO public.slots (day, hall, start_time)
SELECT
  d::date,
  'soccer',
  make_time(t.minute_of_day / 60, t.minute_of_day % 60, 0)
FROM generate_series(
  '2026-10-19'::date,
  '2027-03-31'::date,
  interval '1 day'
) AS d
CROSS JOIN (VALUES (960), (990), (1020)) AS t(minute_of_day)
WHERE EXTRACT(ISODOW FROM d) = 1
ON CONFLICT (day, hall, start_time) DO NOTHING;
