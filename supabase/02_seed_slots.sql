-- Saison 19.10.2026–31.03.2027. Vorläufige Hallenzeiten: bitte Genehmigungen prüfen.
-- Samstag große Leibniz nur bis 19.12.2026; Willi-Bull 09.01.–20.03.2027.
with dates as (select d::date day,extract(isodow from d)::int dow from generate_series('2026-10-19'::date,'2027-03-31'::date,interval '1 day') d),
rules as (
 select day,'gross'::text hall,960 start_m,1080 end_m from dates where dow=2
 union all select day,'gross',990,1320 from dates where dow=4
 union all select day,'klein',960,1020 from dates where dow=2
 union all select day,'klein',1260,1320 from dates where dow=3 and day<='2026-12-16'
 union all select day,'klein',1230,1320 from dates where dow=3 and day between '2027-01-13' and '2027-03-31'
 union all select day,'willi',1080,1140 from dates where dow=5 and day<='2026-12-25'
 union all select day,'willi',1080,1200 from dates where dow=5 and day>='2027-01-01'
 union all select day,'gross',840,1140 from dates where dow=6 and day<='2026-12-19'
 union all select day,'willi',840,1140 from dates where dow=6 and day between '2027-01-09' and '2027-03-20'
)
insert into public.slots(day,hall,start_time)
select r.day,r.hall,make_time(g.m/60,g.m%60,0) from rules r cross join lateral generate_series(r.start_m,r.end_m-30,30) as g(m)
on conflict(day,hall,start_time) do nothing;
