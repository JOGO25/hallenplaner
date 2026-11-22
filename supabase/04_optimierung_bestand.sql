-- Einmalige Bestandsmigration: vorhandene Nutzer und Profile bleiben unverändert.
-- Die IDs der Willi-Bull-Termine bleiben erhalten; damit bleiben
-- Zuteilungen und Bewerbungen an diesen Terminen bestehen.
-- Soccer-Montagstermine werden entfernt. Bewerbungen darauf werden
-- durch ON DELETE CASCADE ebenfalls gelöscht.
BEGIN;

-- Vor der Änderung verhindern, dass eine vorhandene Leibniz-Zeit
-- mit einem umzuwandelnden Willi-Bull-Termin kollidiert.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.slots w
    JOIN public.slots g
      ON g.day = w.day
     AND g.start_time = w.start_time
     AND g.hall = 'gross'
    WHERE w.hall = 'willi'
  ) THEN
    RAISE EXCEPTION 'Abbruch: Willi-Bull- und große Leibniz-Termine überschneiden sich. Keine Daten verändert.';
  END IF;
END $$;

UPDATE public.slots
SET hall = 'gross'
WHERE hall = 'willi';

DELETE FROM public.slots
WHERE hall = 'soccer'
  AND EXTRACT(ISODOW FROM day) = 1;

COMMIT;

-- Kontrolle: Hallenzeiten je Halle
SELECT hall, count(*) AS termine
FROM public.slots
GROUP BY hall
ORDER BY hall;
