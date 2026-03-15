create table if not exists public.pomodoro_dual_state (
  key text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.pomodoro_dual_state enable row level security;

-- Server-side service key bypasses RLS; this policy keeps table readable in SQL editor contexts.
create policy if not exists "allow read for authenticated"
on public.pomodoro_dual_state
for select
to authenticated
using (true);
