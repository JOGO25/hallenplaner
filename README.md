# Hallenplaner 2026/2027

PWA für G-, F-, E- und D-Jugend. 30-Minuten-Bewerbungen, Admin-Zuteilung, wochenweises Löschen, zusätzliche Termine und automatische Statistik.

## Installation

1. GitHub Pages: Settings → Pages → Build and deployment → Deploy from a branch → main / (root) → Save.
2. In [Supabase](https://supabase.com) ein Projekt anlegen. Authentication → Providers → Email aktivieren; öffentliche Registrierung nach der Anlage der fünf Konten deaktivieren.
3. Supabase SQL Editor: erst `supabase/01_schema.sql`, danach `supabase/02_seed_slots.sql` ausführen. Achtung: Hallenzeiten und unklare Genehmigungszeiträume vor Echtbetrieb prüfen.
4. Supabase Project URL und **publishable/anon key** in `config.js` eintragen. **Niemals service_role/secret key veröffentlichen.**
5. Unter Authentication → Users fünf Benutzer erstellen. In SQL Editor anhand ihrer E-Mail-Adressen Rollen zuweisen:

```sql
update public.profiles set role='admin',team=null where id=(select id from auth.users where email='ADMIN_EMAIL');
update public.profiles set role='trainer',team='G' where id=(select id from auth.users where email='G_EMAIL');
update public.profiles set role='trainer',team='F' where id=(select id from auth.users where email='F_EMAIL');
update public.profiles set role='trainer',team='E' where id=(select id from auth.users where email='E_EMAIL');
update public.profiles set role='trainer',team='D' where id=(select id from auth.users where email='D_EMAIL');
```

6. Die Webseite auf `https://jogo25.github.io/hallenplaner/` öffnen und Logins testen.

## Hinweise

- Alle Bewerbungen werden zentral in Supabase gespeichert. Es ist kein GitHub-Konto für Trainer nötig.
- Jede Zuteilung zählt 0,5 Stunden in der Statistik. Gelöschte Zuteilungen zählen nicht mehr.
- Die App ist online nutzbar; eine Offline-Buchungssynchronisierung ist nicht implementiert.
- Die Website allein ersetzt nicht die Einrichtung von Supabase und den Benutzerkonten.
