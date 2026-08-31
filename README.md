# IC: Home — Phase 1 scaffold

"Every home is an incident waiting to happen. Now you have an Incident
Commander."

Expo (React Native + expo-router) + Supabase (Postgres + Auth + Storage),
RLS-isolated per user. IBM Plex Mono for readouts/status, IBM Plex Sans
for plain-language explanation — the design system mirrors an ops-room
console, not a lifestyle app.

## Vocabulary → structure

| Product language     | Screen / table                          |
|-----------------------|------------------------------------------|
| SITREP                | `app/(tabs)/index.tsx` (dashboard)       |
| Resources             | `app/(tabs)/resources.tsx` → `home_assets` |
| Incident Log          | `app/resources/[id].tsx` (per-resource)  |
| Operational Period    | upcoming tasks in `maintenance_tasks`    |
| IC Assistant          | `app/(tabs)/assistant.tsx`               |
| Home Status (G/Y/R)   | status light component, driven by task/asset status |

## Structure

```
app/
  (auth)/onboarding.tsx   "Welcome to IC: Home" — first screen, no session
  (auth)/sign-in.tsx      email/password
  (tabs)/                 SITREP, Resources, IC Assistant
  resources/[id].tsx      resource detail (incident log, docs, record)
src/lib/supabase.ts       Supabase client
src/lib/homeData.ts       typed data-access functions
supabase/migrations/      SQL schema + RLS policies (table names unchanged)
```

## Setup

1. `npm install`
2. Create a Supabase project, run `supabase/migrations/0001_init.sql`
3. Copy `.env.example` to `.env`, fill in project URL + anon key
4. `npm run start`

Fonts (`@expo-google-fonts/ibm-plex-mono`, `ibm-plex-sans`) load via
`expo-font` in `app/_layout.tsx` before any screen renders.

## Not yet built (by design — see Phase plan)

- `supabase/functions/ic-assistant` edge function (Phase 4: RAG over
  home_assets + documents, called from `app/(tabs)/assistant.tsx`)
- AI vision resource identification (Phase 3)
- Document upload + extraction into the Incident Log (Phase 6)
- Push notifications for Critical Issues (Phase 5)
- Session gating on `(auth)` vs `(tabs)` in `app/_layout.tsx` — currently
  a stub comment; wire to `supabase.auth.onAuthStateChange`

Each screen reads/writes real Supabase tables where wired, and is left
as a clearly-marked stub where a later phase owns the logic — nothing
here fakes data silently.
