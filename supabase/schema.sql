-- Supabase > SQL Editor > New query > cole tudo > Run

create table public.games (
  id         bigint generated always as identity primary key,
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  titulo     text not null,
  plataforma text,
  jogado     boolean not null default false,
  created_at timestamptz not null default now()
);

-- Cada usuário só vê e altera os próprios jogos
alter table public.games enable row level security;

create policy "usuario acessa os proprios jogos" on public.games
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
