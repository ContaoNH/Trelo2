create table if not exists public.boards (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Meu quadro',
  owner_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.columns (
  id uuid primary key default gen_random_uuid(),
  board_id uuid not null references public.boards(id) on delete cascade,
  name text not null,
  position integer not null default 0
);

create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  column_id uuid not null references public.columns(id) on delete cascade,
  title text not null,
  description text not null default '',
  label text not null default 'Novo',
  label_tone text not null default 'blue',
  due_date date,
  position integer not null default 0,
  archived boolean not null default false,
  checklist jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.boards enable row level security;
alter table public.columns enable row level security;
alter table public.cards enable row level security;

create policy "owners can manage boards" on public.boards for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "board owners can manage columns" on public.columns for all using (exists (select 1 from public.boards b where b.id = board_id and b.owner_id = auth.uid())) with check (exists (select 1 from public.boards b where b.id = board_id and b.owner_id = auth.uid()));
create policy "board owners can manage cards" on public.cards for all using (exists (select 1 from public.columns c join public.boards b on b.id = c.board_id where c.id = column_id and b.owner_id = auth.uid())) with check (exists (select 1 from public.columns c join public.boards b on b.id = c.board_id where c.id = column_id and b.owner_id = auth.uid()));
